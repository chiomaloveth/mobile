import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_ce/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/general/model/community_model.dart';
import 'package:qik_talk/features/chat/general/screens/chat_media_tab_screen.dart';
import 'package:qik_talk/features/chat/general/services/chat_settings_persistence_service.dart';
import 'package:qik_talk/features/chat/general/services/chat_settings_service.dart';
import 'package:qik_talk/features/chat/general/services/community_api_service/community_api_service.dart';
import 'package:qik_talk/features/chat/general/services/protected_chats_service.dart';
import 'package:qik_talk/features/chat/group_chat/screens/members_list_screen.dart';
import 'package:qik_talk/features/chat/group_chat/screens/add_to_groups_screen.dart';
import 'package:qik_talk/features/community/services/community_cache_service.dart';
import 'package:qik_talk/features/chat/single_chat/screens/chat_tone_selection_screen.dart';
import 'package:qik_talk/features/chat/single_chat/screens/protected_chat_screen.dart';
import 'package:qik_talk/utilities/components/dialogs/edit_chat_dialogs.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/helpers/chat_lock_auth_helper.dart';
import 'package:qik_talk/utilities/helpers/wallpaper_picker_dialog.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityInfoScreen extends StatefulWidget {
  final String communityId;
  final CommunityModel? initialCommunity;
  final bool isAdmin;
  final VoidCallback? onUpdated;

  const CommunityInfoScreen({
    super.key,
    required this.communityId,
    this.initialCommunity,
    required this.isAdmin,
    this.onUpdated,
  });

  @override
  State<CommunityInfoScreen> createState() => _CommunityInfoScreenState();
}

class _CommunityInfoScreenState extends State<CommunityInfoScreen>
    with WidgetsBindingObserver {
  final _api = CommunityApiService();
  final _settingsSvc = ChatSettingsPersistenceService();
  final _settingsApiSvc = ChatSettingsService(); // ✅ for image upload
  final _saveValues = SaveValues();

  CommunityModel? _community;
  bool _isLoading = false;
  String _currentUserId = '';
  String _currentUsername = '';

  bool _muteNotification = false;
  bool _protectedChat = false;
  bool _hideChat = false;
  bool _hideChatHistory = false;
  Color _customChatColor = const Color(0xFF4A90E2);
  Color _customBgColor = Colors.white;
  String? _wallpaperPath;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _community = widget.initialCommunity;
    _isLoading = widget.initialCommunity == null;
    _refreshTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (mounted) _refreshCommunityOnly();
    });
    _initAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshCommunityOnly();
    }
  }

  Future<void> _initAll() async {
    if (_community == null) {
      final cached = await CommunityCacheService.loadCommunity(widget.communityId);
      if (cached != null && mounted) {
        setState(() {
          _community = cached;
          _isLoading = false;
        });
      }
    }

    final futures = await Future.wait([
      _saveValues.getString(AppPreferenceHelper.ID),
      _saveValues.getString(AppPreferenceHelper.USER_NAME),
      _settingsSvc.loadAll(widget.communityId),
      _saveValues.getString(
        AppPreferenceHelper.chatWallpaper(widget.communityId),
      ),
      _api.getCommunityInfo(widget.communityId),
    ]);

    if (!mounted) return;

    final userId = futures[0] as String? ?? '';
    final userName = futures[1] as String? ?? '';
    final s = futures[2] as ChatLocalSettings;
    final wp = futures[3] as String?;

    setState(() {
      _currentUserId = userId;
      _currentUsername = userName;
      _muteNotification = s.muted;
      _protectedChat = s.protected;
      _hideChat = s.hideChat;
      _hideChatHistory = s.hideChatHistory;
      if (s.customColor != null) _customChatColor = Color(s.customColor!);
      if (s.customBgColor != null) _customBgColor = Color(s.customBgColor!);
      _wallpaperPath = wp;
      _isLoading = false;
      final res = futures[4] as CommunityResponse;
      if (res.success && res.community != null) {
        _community = res.community;
        CommunityCacheService.prewarmSingleCommunityMedia(res.community!);
      }
    });
  }

  Future<void> _refreshCommunityOnly() async {
    final res = await _api.getCommunityInfo(widget.communityId);
    if (!mounted) return;
    if (res.success && res.community != null) {
      setState(() => _community = res.community);
      CommunityCacheService.prewarmSingleCommunityMedia(res.community!);
    }
  }

  Future<void> _setWallpaper(String path) async {
    await _saveValues.saveString(
      AppPreferenceHelper.chatWallpaper(widget.communityId),
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

  String _imgUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

  void _snack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: color ?? HexColor('#1A7F4B'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Image upload ──────────────────────────────────────────────────────────
  // ✅ FIX: open gallery, upload via ChatSettingsService, refresh community
  Future<void> _pickAndUploadCommunityImage() async {
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
    final result = await _settingsApiSvc.updateChatImage(
      chatId: widget.communityId,
      imageFile: File(picked.path),
      isCommunity: true, // ✅ routes to PUT /chat/community/:id
    );
    if (mounted) Navigator.pop(context); // dismiss loading

    if (result.success) {
      _snack('Community image updated');
      // Refresh community data so new image URL is shown
      final res = await _api.getCommunityInfo(widget.communityId);
      if (mounted && res.success && res.community != null) {
        setState(() => _community = res.community);
      }
    } else {
      _snack(result.message, color: Colors.red);
    }
  }

  // ── Announcement ─────────────────────────────────────────────────────────
  void _showAnnouncementDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: HexColor('#2A2A2A'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Send Announcement',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Title (optional)',
                  hintStyle: GoogleFonts.poppins(color: Colors.white38),
                  filled: true,
                  fillColor: HexColor('#1A1A1A'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                style: GoogleFonts.poppins(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your announcement...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white38),
                  filled: true,
                  fillColor: HexColor('#1A1A1A'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: isSending
                  ? null
                  : () async {
                      final content = contentController.text.trim();
                      if (content.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please write an announcement',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      setDialogState(() => isSending = true);
                      final title = titleController.text.trim();
                      final result = await _api.postAnnouncement(
                        communityId: widget.communityId,
                        content: content,
                        title: title.isNotEmpty ? title : null,
                      );
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      if (result['success'] == true) {
                        _snack('Announcement sent ✅');
                      } else {
                        _snack(
                          result['message'] as String? ?? 'Failed to send',
                          color: Colors.red,
                        );
                      }
                    },
              child: isSending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: HexColor('#1A7F4B'),
                      ),
                    )
                  : Text(
                      'Send',
                      style: GoogleFonts.poppins(
                        color: HexColor('#1A7F4B'),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
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

  // ── Persisted toggles ─────────────────────────────────────────────────────
  void _toggleMute(bool v) {
    setState(() => _muteNotification = v);
    _settingsSvc.setMuted(widget.communityId, v);
    // ✅ Sync to Hive chat box so chat list mute icon updates instantly
    _updateMuteInHive(v);
  }

  Future<void> _updateMuteInHive(bool muted) async {
    try {
      final chatListBox = Hive.box<ChatListItemHive>('chats');
      final chatItem = chatListBox.get(widget.communityId);
      if (chatItem == null) return;
      await chatListBox.put(
        widget.communityId,
        chatItem.copyWith(isMuted: muted),
      );
    } catch (e) {
      debugPrint('❌ _updateMuteInHive community: $e');
    }
  }

  Future<void> _toggleProtected(bool v) async {
    final reason = v
        ? 'Authenticate to protect this community'
        : 'Authenticate to unprotect this community';
    final ok = await ChatLockAuthHelper.authenticate(context, reason: reason);
    if (!ok || !mounted) return;
    setState(() => _protectedChat = v);
    _settingsSvc.setProtected(widget.communityId, v);
    final svc = ProtectedChatsService();
    if (v) {
      await svc.addProtectedChat(widget.communityId);
    } else {
      await svc.removeProtectedChat(widget.communityId);
    }
    svc.invalidateCache();
  }

  Future<void> _openProtectedChatScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProtectedChatScreen(
          username: _community?.chatName ?? 'Community',
          initialProtectedChatValue: _protectedChat,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _protectedChat = result);
      await _settingsSvc.setProtected(widget.communityId, result);
    }
  }

  void _toggleHideChat(bool v) {
    setState(() => _hideChat = v);
    _settingsSvc.setHideChat(widget.communityId, v);
  }

  void _toggleHideChatHistory(bool v) {
    setState(() => _hideChatHistory = v);
    _settingsSvc.setHideChatHistory(widget.communityId, v);
  }

  void _showColorPicker(
    Color current,
    String title,
    void Function(Color) onSelected,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HexColor('#2A2A2A'),
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
                await _settingsSvc.removeCustomColor(widget.communityId);
                if (mounted)
                  setState(() => _customChatColor = const Color(0xFF4A90E2));
                Navigator.pop(ctx);
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
                      Navigator.pop(ctx);
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

  void _showCustomNotificationSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatToneSelectionScreen(
          chatId: widget.communityId,
          chatName: _community?.chatName ?? 'Community',
        ),
      ),
    );
  }

  Future<void> _confirmLeave() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: HexColor('#2A2A2A'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Leave Community',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to leave this community?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Leave', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      Navigator.pop(context);
      widget.onUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _community == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: HexColor('#1A7F4B')),
        ),
      );
    }

    if (_community == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Text(
            'Community not found',
            style: GoogleFonts.poppins(color: AppTheme.textSecondary(false)),
          ),
        ),
      );
    }

    final c = _community!;
    final imageUrl = _imgUrl(c.chatImage);
    final memberCount = c.memberCount;
    final preview = c.users.take(3).toList();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldColor = AppTheme.scaffoldBg(isDark);
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg(isDark),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: textPrimary, size: 28),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ── Avatar with upload button ───────────────────────────
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cardBg(isDark),
                          ),
                          child: ClipOval(
                            child: imageUrl.isEmpty
                                ? Icon(Icons.people, color: textPrimary, size: 56)
                                : OfflineCachedImage(
                                    imageUrl: imageUrl,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.zero,
                                    placeholder: Container(
                                      color: AppTheme.cardBg(isDark),
                                    ),
                                    errorWidget: Icon(
                                      Icons.people,
                                      color: textPrimary,
                                      size: 56,
                                    ),
                                  ),
                          ),
                        ),
                        // ✅ FIX: calls _pickAndUploadCommunityImage instead of snackbar
                        if (widget.isAdmin)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickAndUploadCommunityImage,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: HexColor('#1A7F4B'),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: HexColor('#1A1A1A'),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Name row with edit button ───────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              c.chatName
                                  .split(' ')
                                  .map(
                                    (w) => w.isNotEmpty
                                        ? '${w[0].toUpperCase()}${w.substring(1)}'
                                        : '',
                                  )
                                  .join(' '),
                              style: GoogleFonts.poppins(
                                color: textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // ✅ FIX: pass isCommunity: true
                          if (widget.isAdmin) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  showDialog<String>(
                                    context: context,
                                    builder: (_) => EditChatNameDialog(
                                      chatId: widget.communityId,
                                      currentName: c.chatName,
                                      label: 'Community Name',
                                      isCommunity: true, // ✅
                                    ),
                                  ).then((newName) async {
                                    if (newName == null || newName.isEmpty)
                                      return;
                                    final updated = _community?.copyWith(
                                      chatName: newName,
                                    );
                                    if (updated == null) return;
                                    await CommunityCacheService.upsertCommunity(
                                      updated,
                                    );
                                    await CommunityCacheService.saveCommunity(
                                      updated,
                                    );
                                    if (!mounted) return;
                                    setState(() => _community = updated);
                                    widget.onUpdated?.call();
                                  }),
                              child: Icon(
                                Icons.edit,
                                color: textPrimary,
                                size: 18,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$memberCount Members',
                          style: GoogleFonts.poppins(
                            color: textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.content_copy,
                          color: textSecondary,
                          size: 16,
                        ),
                      ],
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
                              groupId: widget.communityId,
                              groupName: c.chatName,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: HexColor('#1A7F4B'),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (preview.isNotEmpty)
                                    SizedBox(
                                      width: preview.length * 18.0 + 14,
                                      height: 32,
                                      child: Stack(
                                        children: preview.asMap().entries.map((
                                          e,
                                        ) {
                                          final avatarUrl = _imgUrl(
                                            e.value.profilePicture,
                                          );
                                          return Positioned(
                                            left: e.key * 18.0,
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: HexColor('#1A7F4B'),
                                                  width: 2,
                                                ),
                                                color: HexColor('#2A7F5B'),
                                                image: avatarUrl.isNotEmpty
                                                    ? DecorationImage(
                                                        image: NetworkImage(
                                                          avatarUrl,
                                                        ),
                                                        fit: BoxFit.cover,
                                                        onError: (_, __) {},
                                                      )
                                                    : null,
                                              ),
                                              child: avatarUrl.isEmpty
                                                  ? Center(
                                                      child: Text(
                                                        e
                                                                .value
                                                                .username
                                                                .isNotEmpty
                                                            ? e
                                                                  .value
                                                                  .username[0]
                                                                  .toUpperCase()
                                                            : '?',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'See all members',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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

                    // ── Settings items ────────────────────────────────────
                    // ✅ FIX: pass isCommunity: true to EditDescriptionDialog
                    if (widget.isAdmin)
                      _settingsItem(
                        icon: Icons.description_outlined,
                        title: 'Edit Description',
                        hasChevron: true,
                        onTap: () =>
                            showDialog<String>(
                              context: context,
                              builder: (_) => EditDescriptionDialog(
                                chatId: widget.communityId,
                                currentDescription: c.displayDescription,
                                label: 'Community Description',
                                isCommunity: true, // ✅
                              ),
                            ).then((newDesc) async {
                              if (newDesc == null) return;
                              final updated = _community?.copyWith(
                                description: newDesc,
                              );
                              if (updated == null) return;
                              await CommunityCacheService.upsertCommunity(
                                updated,
                              );
                              await CommunityCacheService.saveCommunity(
                                updated,
                              );
                              if (!mounted) return;
                              setState(() => _community = updated);
                              widget.onUpdated?.call();
                            }),
                      ),

                    if (widget.isAdmin)
                      _settingsItem(
                        icon: Icons.campaign_outlined,
                        title: 'Send Announcement',
                        hasChevron: true,
                        onTap: _showAnnouncementDialog,
                      ),

                    _settingsItem(
                      icon: Icons.perm_media_outlined,
                      title: 'Media, Links & Documents',
                      trailing: '${c.subGroups.length * 5}',
                      hasChevron: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatMediaTabScreen(
                            userId: '',
                            username: c.chatName,
                            isOnline: true,
                            chatId: widget.communityId,
                            initialTabIndex: 0,
                          ),
                        ),
                      ),
                    ),

                    _toggleItem(
                      icon: Icons.notifications_off_outlined,
                      title: 'Mute Notification',
                      value: _muteNotification,
                      onChanged: _toggleMute,
                    ),

                    _settingsItem(
                      icon: Icons.notifications_outlined,
                      title: 'Custom Notification',
                      hasChevron: true,
                      onTap: _showCustomNotificationSheet,
                    ),

                    _toggleItem(
                      icon: Icons.shield_outlined,
                      title: 'Protected Chat',
                      value: _protectedChat,
                      onChanged: _toggleProtected,
                      hasChevron: true,
                      onChevronTap: _openProtectedChatScreen,
                    ),

                    _toggleItem(
                      icon: Icons.visibility_off_outlined,
                      title: 'Hide Chat',
                      value: _hideChat,
                      onChanged: _toggleHideChat,
                      hasChevron: true,
                    ),

                    _toggleItem(
                      icon: Icons.history_toggle_off_outlined,
                      title: 'Hide Chat History',
                      value: _hideChatHistory,
                      onChanged: _toggleHideChatHistory,
                      hasChevron: true,
                    ),

                    _settingsItem(
                      icon: Icons.group_add_outlined,
                      title: 'Add To Group',
                      hasChevron: true,
                      onTap: () {
                        if (_currentUserId.isEmpty) {
                          _snack('Loading user info, please try again');
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddToGroupsScreen(
                              username: _currentUsername.isNotEmpty
                                  ? _currentUsername
                                  : c.chatName,
                              userId: _currentUserId,
                            ),
                          ),
                        );
                      },
                    ),

                    _settingsItem(
                      icon: Icons.color_lens_outlined,
                      title: 'Custom Color Chat',
                      trailing: 'color_swatch',
                      trailingColor: _customChatColor,
                      onTap: () => _showColorPicker(
                        _customChatColor,
                        'Pick Chat Color',
                        (picked) async {
                          setState(() => _customChatColor = picked);
                          await _settingsSvc.setCustomColor(
                            widget.communityId,
                            picked.value,
                          );
                        },
                      ),
                    ),

                    _settingsItem(
                      icon: Icons.wallpaper_outlined,
                      title: 'Custom Background Chat',
                      trailing: 'color_swatch',
                      trailingColor: _customBgColor,
                      onTap: () => _showColorPicker(
                        _customBgColor,
                        'Pick Background Color',
                        (picked) async {
                          setState(() => _customBgColor = picked);
                          await _settingsSvc.setCustomBgColor(
                            widget.communityId,
                            picked.value,
                          );
                        },
                      ),
                    ),

                    _settingsItem(
                      icon: Icons.image_outlined,
                      title: 'Chat Wallpaper',
                      hasChevron: true,
                      trailing:
                          _wallpaperPath != null && _wallpaperPath!.isNotEmpty
                          ? 'set'
                          : null,
                      onTap: _showWallpaperPicker,
                    ),

                    const SizedBox(height: 16),

                    _actionItem(
                      icon: Icons.report_outlined,
                      title: 'Report',
                      color: Colors.red,
                      onTap: () => _snack('Report sent'),
                    ),

                    if (!widget.isAdmin)
                      _actionItem(
                        icon: Icons.block,
                        title: 'Leave Community',
                        color: Colors.red,
                        onTap: _confirmLeave,
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    String? trailing,
    Color? trailingColor,
    bool hasChevron = false,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);
    final Color iconColor = AppTheme.iconColor(isDark);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (trailing == 'color_swatch' && trailingColor != null)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: trailingColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: textSecondary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              )
            else if (trailing == 'set')
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A7F4B),
                  shape: BoxShape.circle,
                ),
              )
            else if (trailing != null &&
                trailing != 'color_swatch' &&
                trailing != 'set')
              Text(
                trailing,
                style: GoogleFonts.poppins(color: textSecondary, fontSize: 15),
              ),
            if (hasChevron) ...[
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: textSecondary, size: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _toggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool hasChevron = false,
    VoidCallback? onChevronTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);
    final Color iconColor = AppTheme.iconColor(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: HexColor('#1A7F4B'),
            inactiveThumbColor: isDark
                ? HexColor('#5A5A5A')
                : Colors.grey.shade400,
            inactiveTrackColor: isDark
                ? HexColor('#2A2A2A')
                : Colors.grey.shade200,
          ),
          if (hasChevron) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onChevronTap,
              child: Icon(Icons.chevron_right, color: textSecondary, size: 24),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom Notification Sheet ─────────────────────────────────────────────────

class _CommunityNotificationSheet extends StatefulWidget {
  final String chatId;
  const _CommunityNotificationSheet({required this.chatId});
  @override
  State<_CommunityNotificationSheet> createState() =>
      _CommunityNotificationSheetState();
}

class _CommunityNotificationSheetState
    extends State<_CommunityNotificationSheet> {
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color sheetBg = isDark ? HexColor('#1B1B1B') : Colors.white;
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color dividerColor = AppTheme.dividerSubtle(isDark);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
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
                color: isDark ? HexColor('#3A3A3A') : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Custom Notification',
            style: GoogleFonts.poppins(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _row(
            Icons.music_note_outlined,
            'Notification Tone',
            DropdownButton<String>(
              value: _selectedTone,
              dropdownColor: sheetBg,
              underline: const SizedBox(),
              style: GoogleFonts.poppins(color: textPrimary, fontSize: 13),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.textSecondary(isDark),
              ),
              items: _tones
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedTone = v ?? 'Default'),
            ),
            textPrimary,
          ),
          Divider(color: dividerColor),
          _row(
            Icons.vibration,
            'Vibrate',
            Switch(
              value: _vibrate,
              onChanged: (v) => setState(() => _vibrate = v),
              activeColor: HexColor('#1A7F4B'),
              inactiveTrackColor: isDark
                  ? HexColor('#3A3A3A')
                  : Colors.grey.shade300,
            ),
            textPrimary,
          ),
          Divider(color: dividerColor),
          _row(
            Icons.preview_outlined,
            'Show Preview',
            Switch(
              value: _showPreview,
              onChanged: (v) => setState(() => _showPreview = v),
              activeColor: HexColor('#1A7F4B'),
              inactiveTrackColor: isDark
                  ? HexColor('#3A3A3A')
                  : Colors.grey.shade300,
            ),
            textPrimary,
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

  Widget _row(IconData icon, String title, Widget trailing, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: HexColor('#FB8830'), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(color: textColor, fontSize: 14),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
