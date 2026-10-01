import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qik_talk/features/chat/single_chat/screens/chat_tone_selection_screen.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/features/chat/general/model/group_model.dart';
import 'package:qik_talk/features/chat/general/screens/chat_media_tab_screen.dart';
import 'package:qik_talk/features/chat/general/services/chat_settings_persistence_service.dart';
import 'package:qik_talk/features/chat/general/services/chat_settings_service.dart';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_api_service.dart';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_invite_service.dart';
import 'package:qik_talk/features/chat/general/services/protected_chats_service.dart';
import 'package:qik_talk/features/chat/group_chat/screens/add_members_screen.dart';
import 'package:qik_talk/features/chat/group_chat/screens/members_list_screen.dart';
import 'package:qik_talk/features/chat/group_chat/widgets/composite_group_avatar.dart';
import 'package:qik_talk/features/chat/single_chat/screens/protected_chat_screen.dart';
import 'package:qik_talk/utilities/components/dialogs/edit_chat_dialogs.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/helpers/chat_lock_auth_helper.dart';
import 'package:qik_talk/utilities/helpers/wallpaper_picker_dialog.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';

class GroupInfoScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupImage;
  final int memberCount;
  final int mediaCount;

  const GroupInfoScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.groupImage,
    this.memberCount = 10,
    this.mediaCount = 152,
  }) : super(key: key);

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final GroupApiService _groupApiService = GroupApiService();
  final ChatSettingsService _settingsApiService = ChatSettingsService();
  final SaveValues _saveValues = SaveValues();
  final GlobalSocketService _globalSocket = GlobalSocketService();
  final ChatSettingsPersistenceService _settingsSvc =
      ChatSettingsPersistenceService();

  bool muteNotification = false;
  bool protectedChat = false;
  bool hideChat = false;
  bool hideChatHistory = false;
  Color customChatColor = const Color(0xFF4A90E2);
  Color customBackgroundColor = Colors.white;
  bool _settingsLoaded = false;
  String? _wallpaperPath;

  GroupModel? _groupDetails;
  bool _isLoading = false;
  String? _currentUserId;
  bool _isAdmin = false;
  bool _justRenamed = false;
  // Incremented after upload to bust Image.network cache
  int _imageVersion = 0;

  String get _cacheKey => 'group_info_cache_${widget.groupId}';

  @override
  void initState() {
    super.initState();
    _initAll();
    _setupSocketListeners();
  }

  Future<void> _initAll() async {
    // ── Step 1: Load local settings and cached group instantly (no network) ─
    final results = await Future.wait([
      _saveValues.getString(AppPreferenceHelper.ID),
      _settingsSvc.loadAll(widget.groupId),
      _saveValues.getString(AppPreferenceHelper.chatWallpaper(widget.groupId)),
      _saveValues.getString(_cacheKey),
    ]);

    final userId = results[0] as String?;
    final s = results[1] as ChatLocalSettings;
    final wp = results[2] as String?;
    final cachedRaw = results[3] as String?;
    final cachedGroup = _decodeCachedGroup(cachedRaw);

    if (mounted) {
      setState(() {
        _currentUserId = userId;
        _groupDetails = cachedGroup ?? _fallbackGroupFromWidget();
        _isAdmin = userId != null && _groupDetails!.isAdmin(userId);
        muteNotification = s.muted;
        protectedChat = s.protected;
        hideChat = s.hideChat;
        hideChatHistory = s.hideChatHistory;
        if (s.customColor != null) customChatColor = Color(s.customColor!);
        if (s.customBgColor != null)
          customBackgroundColor = Color(s.customBgColor!);
        _settingsLoaded = true;
        _wallpaperPath = wp;
        _isLoading = false;
      });
    }

    // ── Step 2: Fetch group profile silently in background ───────────────
    final group = await _groupApiService.getGroupProfile(
      groupId: widget.groupId,
    );

    if (!mounted) return;
    if (group != null) await _cacheGroup(group);
    setState(() {
      if (group != null) _groupDetails = group;
      _isLoading = false;
      if (group != null && userId != null) _isAdmin = group.isAdmin(userId);
    });

    // Try to get full member profiles (phone, etc.) from members endpoint
    if (group != null) {
      try {
        final membersResult = await _groupApiService.getGroupMembers(
          groupId: widget.groupId,
        );
        if (membersResult != null &&
            membersResult.members.isNotEmpty &&
            mounted) {
          final fullGroup = GroupModel(
            id: group.id,
            chatName: group.chatName,
            description: group.description,
            isGroupChat: group.isGroupChat,
            users: membersResult.members,
            groupAdmins: group.groupAdmins,
            groupImage: group.groupImage,
            settings: group.settings,
            createdAt: group.createdAt,
            updatedAt: group.updatedAt,
          );
          await _cacheGroup(fullGroup);
          setState(() => _groupDetails = fullGroup);
        }
      } catch (e) {
        debugPrint('⚠️ Could not load full member profiles: $e');
      }
    }
  }

  Future<void> _loadGroupDetails() async {
    if (!mounted) return;
    final group = await _groupApiService.getGroupProfile(
      groupId: widget.groupId,
    );
    if (!mounted) return;
    setState(() {
      if (group != null) {
        // Preserve current image if server returns null/empty
        final preservedImage =
            (group.groupImage != null && group.groupImage!.isNotEmpty)
            ? group.groupImage
            : _groupDetails?.groupImage;

        final updatedGroup = GroupModel(
          id: group.id,
          chatName: group.chatName,
          description: group.description,
          isGroupChat: group.isGroupChat,
          users: group.users,
          groupAdmins: group.groupAdmins,
          groupImage: preservedImage,
          settings: group.settings,
          createdAt: group.createdAt,
          updatedAt: group.updatedAt,
        );
        _groupDetails = updatedGroup;
        _cacheGroup(updatedGroup);
        _isAdmin = group.isAdmin(_currentUserId ?? '');
      }
    });
  }

  Future<void> _setWallpaper(String path) async {
    await _saveValues.saveString(
      AppPreferenceHelper.chatWallpaper(widget.groupId),
      path,
    );
    if (mounted) setState(() => _wallpaperPath = path);
  }

  void _showWallpaperPicker() {
    showDialog(
      context: context,
      builder: (_) => WallpaperPickerDialog(
        currentWallpaper: _wallpaperPath,
        onWallpaperSelected: _setWallpaper,
      ),
    );
  }

  void _setupSocketListeners() {
    _globalSocket.chatListUpdates.listen((_) {
      if (mounted && !_justRenamed) _loadGroupDetails();
    });

    _globalSocket.socket?.on('group updated', (data) {
      if (data['action'] == 'rename' &&
          data['groupId'] == widget.groupId &&
          data['newName'] != null) {
        _justRenamed = true;
        if (mounted) {
          setState(() {
            if (_groupDetails != null) {
              _groupDetails = GroupModel(
                id: _groupDetails!.id,
                chatName: data['newName'] as String,
                description: _groupDetails!.description,
                isGroupChat: _groupDetails!.isGroupChat,
                users: _groupDetails!.users,
                groupAdmins: _groupDetails!.groupAdmins,
                groupImage: _groupDetails!.groupImage,
                settings: _groupDetails!.settings,
                createdAt: _groupDetails!.createdAt,
                updatedAt: DateTime.now(),
              );
            }
          });
        }
        Future.delayed(const Duration(seconds: 3), () {
          _justRenamed = false;
          if (mounted) _loadGroupDetails();
        });
      }
    });
  }

  GroupModel? _decodeCachedGroup(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return GroupModel.fromJson(decoded);
    } catch (e) {
      debugPrint('⚠️ Group info cache decode failed: $e');
      return null;
    }
  }

  GroupModel _fallbackGroupFromWidget() {
    return GroupModel(
      id: widget.groupId,
      chatName: widget.groupName,
      description: null,
      isGroupChat: true,
      users: widget.memberCount > 0
          ? List.generate(
              widget.memberCount,
              (i) => GroupMember(id: 'stub_$i', username: 'Member'),
            )
          : const [],
      groupAdmins: const [],
      groupImage: widget.groupImage.isNotEmpty ? widget.groupImage : null,
      settings: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _cacheGroup(GroupModel group) async {
    await _saveValues.saveString(_cacheKey, jsonEncode(group.toJson()));
  }

  // ── Image upload ──────────────────────────────────────────────────────────
  Future<void> _pickAndUploadGroupImage() async {
    final picker = ImagePicker();
    ProviderScope.containerOf(
      context,
    ).read(biometricAuthProvider.notifier).isPickerActive = true;
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    await ProviderScope.containerOf(
      context,
    ).read(biometricAuthProvider.notifier).onPickerReturned();
    if (picked == null) return;

    _showLoadingDialog();
    final result = await _settingsApiService.updateChatImage(
      chatId: widget.groupId,
      imageFile: File(picked.path),
      isCommunity: false,
    );
    if (mounted) Navigator.pop(context);

    if (result.success) {
      if (mounted) {
        final responseData = result.data as Map<String, dynamic>?;

        // Backend fix: groupIcon (uploaded file) takes priority, both fields synced.
        final newImageUrl =
            responseData?['groupIcon'] as String? ??
            responseData?['chatImage'] as String? ??
            (responseData?['data'] as Map<String, dynamic>?)?['groupIcon']
                as String? ??
            (responseData?['data'] as Map<String, dynamic>?)?['chatImage']
                as String?;

        print('🖼 After upload — newImageUrl: $newImageUrl');

        setState(() {
          _imageVersion++;
          if (newImageUrl != null &&
              newImageUrl.isNotEmpty &&
              _groupDetails != null) {
            _groupDetails = GroupModel(
              id: _groupDetails!.id,
              chatName: _groupDetails!.chatName,
              description: _groupDetails!.description,
              isGroupChat: _groupDetails!.isGroupChat,
              users: _groupDetails!.users,
              groupAdmins: _groupDetails!.groupAdmins,
              groupImage: newImageUrl,
              settings: _groupDetails!.settings,
              createdAt: _groupDetails!.createdAt,
              updatedAt: DateTime.now(),
            );
            _cacheGroup(_groupDetails!);
          }
        });

        // Confirm from server after short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _loadGroupDetails();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Group image updated',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1A7F4B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // ── Rename ────────────────────────────────────────────────────────────────
  void _showEditGroupNameDialog() {
    if (!_isAdmin) {
      _showPermissionError();
      return;
    }
    showDialog<String>(
      context: context,
      builder: (_) => EditChatNameDialog(
        chatId: widget.groupId,
        currentName: _groupDetails?.chatName ?? widget.groupName,
        label: 'Group Name',
        isCommunity: false,
      ),
    ).then((newName) async {
      if (newName == null || newName.isEmpty) return;
      _justRenamed = true;
      if (mounted) {
        setState(() {
          if (_groupDetails != null) {
            _groupDetails = GroupModel(
              id: _groupDetails!.id,
              chatName: newName,
              description: _groupDetails!.description,
              isGroupChat: _groupDetails!.isGroupChat,
              users: _groupDetails!.users,
              groupAdmins: _groupDetails!.groupAdmins,
              groupImage: _groupDetails!.groupImage,
              settings: _groupDetails!.settings,
              createdAt: _groupDetails!.createdAt,
              updatedAt: DateTime.now(),
            );
            _cacheGroup(_groupDetails!);
          }
        });
      }
      _globalSocket.emit('group updated', {
        'groupId': widget.groupId,
        'action': 'rename',
        'newName': newName,
      });
      Future.delayed(const Duration(seconds: 2), () {
        _justRenamed = false;
        if (mounted) _loadGroupDetails();
      });
    });
  }

  // ── Description ───────────────────────────────────────────────────────────
  void _showEditDescriptionDialog() {
    if (!_isAdmin) {
      _showPermissionError();
      return;
    }
    showDialog<String>(
      context: context,
      builder: (_) => EditDescriptionDialog(
        chatId: widget.groupId,
        currentDescription: _groupDetails?.description ?? '',
        label: 'Group Description',
        isCommunity: false,
      ),
    ).then((newDesc) {
      if (newDesc == null) return;
      if (mounted) {
        setState(() {
          if (_groupDetails != null) {
            _groupDetails = GroupModel(
              id: _groupDetails!.id,
              chatName: _groupDetails!.chatName,
              description: newDesc,
              isGroupChat: _groupDetails!.isGroupChat,
              users: _groupDetails!.users,
              groupAdmins: _groupDetails!.groupAdmins,
              groupImage: _groupDetails!.groupImage,
              settings: _groupDetails!.settings,
              createdAt: _groupDetails!.createdAt,
              updatedAt: DateTime.now(),
            );
            _cacheGroup(_groupDetails!);
          }
        });
      }
    });
  }

  // ── Group Settings ────────────────────────────────────────────────────────
  void _showGroupSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GroupSettingsSheet(
        chatId: widget.groupId,
        isAdmin: _isAdmin,
        initialOnlyAdminsMessage:
            _groupDetails?.settings?.onlyAdminsCanMessage ?? false,
        initialOnlyAdminsEditInfo:
            _groupDetails?.settings?.onlyAdminsCanEditInfo ?? false,
        initialDisappearing:
            _groupDetails?.settings?.disappearingMessages?.enabled ?? false,
        initialDisappearDuration:
            _groupDetails?.settings?.disappearingMessages?.duration ?? 0,
        onChanged: _loadGroupDetails,
      ),
    );
  }

  void _toggleMute(bool val) {
    setState(() => muteNotification = val);
    _settingsSvc.setMuted(widget.groupId, val);
  }

  /// Locks or unlocks the group chat with biometric authentication.
  Future<void> _toggleProtected(bool val) async {
    final reason = val
        ? 'Authenticate to protect this group'
        : 'Authenticate to unprotect this group';
    final ok = await ChatLockAuthHelper.authenticate(context, reason: reason);
    if (!ok || !mounted) return;

    setState(() => protectedChat = val);
    _settingsSvc.setProtected(widget.groupId, val);

    final svc = ProtectedChatsService();
    if (val) {
      await svc.addProtectedChat(widget.groupId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Group moved to Locked Chats'),
            backgroundColor: const Color(0xFF1A7F4B),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      await svc.removeProtectedChat(widget.groupId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Group returned to main list'),
            backgroundColor: const Color(0xFF1A7F4B),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    svc.invalidateCache();
  }

  Future<void> _openProtectedChatScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProtectedChatScreen(
          username: _groupDetails?.chatName ?? widget.groupName,
          initialProtectedChatValue: protectedChat,
        ),
      ),
    );
    if (result != null && mounted) {
      if (result != protectedChat) {
        await _toggleProtected(result);
      }
    }
  }

  void _toggleHideChat(bool val) {
    setState(() => hideChat = val);
    _settingsSvc.setHideChat(widget.groupId, val);
  }

  void _toggleHideChatHistory(bool val) {
    setState(() => hideChatHistory = val);
    _settingsSvc.setHideChatHistory(widget.groupId, val);
  }

  void _showCustomNotificationSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatToneSelectionScreen(
          chatId: widget.groupId,
          chatName: _groupDetails?.chatName ?? widget.groupName,
        ),
      ),
    );
  }

  void _showColorPicker(
    Color current,
    String title,
    void Function(Color) onSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            GestureDetector(
              onTap: () async {
                onSelected(const Color(0xFF4A90E2));
                await _settingsSvc.removeCustomColor(widget.groupId);
                if (mounted)
                  setState(() => customChatColor = const Color(0xFF4A90E2));
                Navigator.pop(context);
              },
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1B),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: current == const Color(0xFF1B1B1B)
                        ? Colors.white
                        : Colors.white38,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Default',
                    style: TextStyle(color: Colors.white, fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            ...[
                  const Color(0xFF4A90E2),
                  const Color(0xFFFF3B30),
                  const Color(0xFF1A7F4B),
                  const Color(0xFFAF52DE),
                  const Color(0xFFFF9500),
                  const Color(0xFFFF2D55),
                  const Color(0xFF5AC8FA),
                  const Color(0xFFFFCC00),
                  const Color(0xFF00C7BE),
                  Colors.white,
                ]
                .map(
                  (color) => GestureDetector(
                    onTap: () {
                      onSelected(color);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: current == color
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  void _showLeaveGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Leave Group',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to leave ${_groupDetails?.chatName ?? widget.groupName}?',
          style: GoogleFonts.poppins(
            color: const Color(0xFFB0B0B0),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _leaveGroup();
            },
            child: Text(
              'Leave',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF3B30),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveGroup() async {
    _showLoadingDialog();
    final success = await _groupApiService.leaveGroup(groupId: widget.groupId);
    if (mounted) Navigator.pop(context);
    if (success) {
      _globalSocket.emit('group updated', {
        'groupId': widget.groupId,
        'action': 'member_left',
        'userId': _currentUserId,
      });
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Left ${_groupDetails?.chatName ?? "group"}'),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to leave group'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Report Group',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to report ${_groupDetails?.chatName ?? widget.groupName}?',
          style: GoogleFonts.poppins(
            color: const Color(0xFFB0B0B0),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Group reported'),
                  backgroundColor: Color(0xFFFF3B30),
                ),
              );
            },
            child: Text(
              'Report',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF3B30),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Center(child: CircularProgressIndicator(color: HexColor('#1A7F4B'))),
    );
  }

  void _showPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Only admins can perform this action'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Best available image URL — groupImage from API response takes priority.
  String? get _displayImageUrl {
    final img = _groupDetails?.groupImage;
    if (img != null && img.isNotEmpty) return img;
    if (widget.groupImage.isNotEmpty) return widget.groupImage;
    return null;
  }

  Widget _buildStackedMemberAvatars() {
    if (_groupDetails == null || _groupDetails!.users.isEmpty)
      return const SizedBox(width: 60, height: 40);
    final members = _groupDetails!.users.take(3).toList();
    return SizedBox(
      width: 60,
      height: 40,
      child: Stack(
        children: List.generate(members.length, (i) {
          final m = members[i];
          return Positioned(
            left: i * 13.0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1A7F4B), width: 2),
                color: AppTheme.cardBgAlt(
                  Theme.of(context).brightness == Brightness.dark,
                ),
              ),
              child: m.profilePicture != null && m.profilePicture!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        m.profilePicture!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? AppTheme.iconColor(isDark),
              size: 24,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: textColor ?? AppTheme.textPrimary(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildToggleMenuItem({
    required IconData icon,
    required String title,
    required bool value,
    required void Function(bool) onChanged,
    bool hasSubMenu = false,
    VoidCallback? onSubMenuTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: hasSubMenu ? onSubMenuTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.iconColor(isDark), size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF1A7F4B),
                activeTrackColor: const Color(0xFF1A7F4B).withOpacity(0.5),
                inactiveThumbColor: const Color(0xFF787880),
                inactiveTrackColor: const Color(0xFF39393D),
              ),
            ),
            if (hasSubMenu) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: AppTheme.iconColorSubtle(isDark),
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorPickerMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.iconColor(isDark), size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                'Custom Color Chat',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border(isDark), width: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: topPadding + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    final currentName =
                        _groupDetails?.chatName ?? widget.groupName;
                    Navigator.pop(context, currentName);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBgAlt(isDark),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppTheme.iconColor(isDark),
                      size: 22,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // ── Group composite avatar ────────────────────────
                  Stack(
                    children: [
                      _groupDetails != null && _groupDetails!.users.isNotEmpty
                          ? CompositeGroupAvatar(
                              members: _groupDetails!.users,
                              avatarRadius: 40,
                              overlap: 28,
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFE0E0E0),
                              ),
                              child: Icon(
                                Icons.group,
                                size: 40,
                                color: isDark
                                    ? Colors.white
                                    : AppTheme.textPrimary(isDark),
                              ),
                            ),
                      if (_isAdmin)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _pickAndUploadGroupImage,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A7F4B),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.scaffoldBg(isDark),
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Group name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            _groupDetails?.chatName ?? widget.groupName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_isAdmin) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showEditGroupNameDialog,
                            child: Icon(
                              Icons.edit,
                              color: AppTheme.iconColor(isDark),
                              size: 20,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_groupDetails?.description != null &&
                      _groupDetails!.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _groupDetails!.description!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary(isDark),
                          fontSize: 14,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Member count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBgAlt(
                        Theme.of(context).brightness == Brightness.dark,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_groupDetails?.memberCount ?? widget.memberCount} Members',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(
                                text:
                                    '${_groupDetails?.memberCount ?? widget.memberCount} Members',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Member count copied'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: HexColor('#FF6B00'),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy,
                            color: AppTheme.iconColorSubtle(isDark),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // See all members
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MembersListScreen(
                            groupId: widget.groupId,
                            groupName:
                                _groupDetails?.chatName ?? widget.groupName,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A7F4B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildStackedMemberAvatars(),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'See all members',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildMenuItem(
                    icon: Icons.link,
                    title: 'Invite via Link',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppTheme.iconColorSubtle(isDark),
                      size: 22,
                    ),
                    onTap: () => GroupInviteService.generateAndShare(
                      context,
                      groupId: widget.groupId,
                      groupName: _groupDetails?.chatName ?? widget.groupName,
                    ),
                  ),

                  _buildMenuItem(
                    icon: Icons.person_add_outlined,
                    title: 'Add Members',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppTheme.iconColorSubtle(isDark),
                      size: 22,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddMembersScreen(
                          groupId: widget.groupId,
                          groupName:
                              _groupDetails?.chatName ?? widget.groupName,
                        ),
                      ),
                    ),
                  ),

                  if (_isAdmin)
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Edit Description',
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppTheme.iconColorSubtle(isDark),
                        size: 22,
                      ),
                      onTap: _showEditDescriptionDialog,
                    ),

                  _buildMenuItem(
                    icon: Icons.insert_photo_outlined,
                    title: 'Media, Links & Documents',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppTheme.iconColorSubtle(isDark),
                      size: 22,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatMediaTabScreen(
                          userId: '',
                          username: _groupDetails?.chatName ?? widget.groupName,
                          isOnline: true,
                          chatId: widget.groupId,
                          initialTabIndex: 0,
                        ),
                      ),
                    ),
                  ),

                  if (_isAdmin)
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Group Settings',
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppTheme.iconColorSubtle(isDark),
                        size: 22,
                      ),
                      onTap: _showGroupSettings,
                    ),

                  _buildToggleMenuItem(
                    icon: Icons.notifications_off_outlined,
                    title: 'Mute Notification',
                    value: muteNotification,
                    onChanged: _toggleMute,
                  ),

                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Custom Notification',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFB0B0B0),
                      size: 22,
                    ),
                    onTap: _showCustomNotificationSheet,
                  ),

                  _buildToggleMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Protected Chat',
                    value: protectedChat,
                    hasSubMenu: true,
                    onChanged: _toggleProtected,
                    onSubMenuTap: _openProtectedChatScreen,
                  ),

                  _buildToggleMenuItem(
                    icon: Icons.visibility_off_outlined,
                    title: 'Hide Chat',
                    value: hideChat,
                    onChanged: _toggleHideChat,
                  ),

                  _buildToggleMenuItem(
                    icon: Icons.history_toggle_off_outlined,
                    title: 'Hide Chat History',
                    value: hideChatHistory,
                    onChanged: _toggleHideChatHistory,
                  ),

                  _buildColorPickerMenuItem(
                    icon: Icons.palette_outlined,
                    title: 'Custom Color Chat',
                    color: customChatColor,
                    onTap: () => _showColorPicker(
                      customChatColor,
                      'Pick Chat Color',
                      (c) async {
                        setState(() => customChatColor = c);
                        await _settingsSvc.setCustomColor(
                          widget.groupId,
                          c.value,
                        );
                      },
                    ),
                  ),

                  InkWell(
                    onTap: () => _showColorPicker(
                      customBackgroundColor,
                      'Pick Background Color',
                      (c) async {
                        setState(() => customBackgroundColor = c);
                        await _settingsSvc.setCustomBgColor(
                          widget.groupId,
                          c.value,
                        );
                      },
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.format_paint_outlined,
                            color: AppTheme.iconColor(isDark),
                            size: 24,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              'Custom Background Color',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary(isDark),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: customBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.border(isDark),
                                width: 1,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppTheme.iconColorSubtle(isDark),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: _showWallpaperPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.wallpaper,
                            color: AppTheme.iconColor(isDark),
                            size: 24,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              'Chat Wallpaper',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary(isDark),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          if (_wallpaperPath != null &&
                              _wallpaperPath!.isNotEmpty)
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A7F4B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          Icon(
                            Icons.chevron_right,
                            color: AppTheme.iconColorSubtle(isDark),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  _buildMenuItem(
                    icon: Icons.error_outline,
                    title: 'Report',
                    textColor: const Color(0xFFFF3B30),
                    iconColor: const Color(0xFFFF3B30),
                    onTap: _showReportDialog,
                  ),

                  _buildMenuItem(
                    icon: Icons.exit_to_app,
                    title: 'Leave Group',
                    textColor: const Color(0xFFFF3B30),
                    iconColor: const Color(0xFFFF3B30),
                    onTap: _showLeaveGroupDialog,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() => super.dispose();
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Notification Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CustomNotificationSheet extends StatefulWidget {
  final String chatId;
  const _CustomNotificationSheet({required this.chatId});

  @override
  State<_CustomNotificationSheet> createState() =>
      _CustomNotificationSheetState();
}

class _CustomNotificationSheetState extends State<_CustomNotificationSheet> {
  String _selectedTone = 'Default';
  bool _vibrate = true;
  bool _showPreview = true;

  final List<String> _tones = [
    'Default',
    'None',
    'Chime',
    'Bell',
    'Ping',
    'Tri-tone',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor('#1B1B1B'),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: HexColor('#3A3A3A'),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Custom Notification',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _sheetRow(
            icon: Icons.music_note_outlined,
            title: 'Notification Tone',
            trailing: DropdownButton<String>(
              value: _selectedTone,
              dropdownColor: HexColor('#1B1B1B'),
              underline: const SizedBox(),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              icon: Icon(Icons.keyboard_arrow_down, color: HexColor('#787880')),
              items: _tones
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedTone = v ?? 'Default'),
            ),
          ),
          Divider(color: HexColor('#2A2A2A')),
          _sheetRow(
            icon: Icons.vibration,
            title: 'Vibrate',
            trailing: Switch(
              value: _vibrate,
              onChanged: (v) => setState(() => _vibrate = v),
              activeColor: HexColor('#1A7F4B'),
              inactiveTrackColor: HexColor('#3A3A3A'),
            ),
          ),
          Divider(color: HexColor('#2A2A2A')),
          _sheetRow(
            icon: Icons.preview_outlined,
            title: 'Show Preview',
            trailing: Switch(
              value: _showPreview,
              onChanged: (v) => setState(() => _showPreview = v),
              activeColor: HexColor('#1A7F4B'),
              inactiveTrackColor: HexColor('#3A3A3A'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Notification settings saved',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: HexColor('#1A7F4B'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor('#1A7F4B'),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetRow({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: HexColor('#FB8830'), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
