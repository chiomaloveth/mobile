import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:qik_talk/features/chat/general/model/community_model.dart';
import 'package:qik_talk/features/chat/general/services/chat_settings_service.dart';
import 'package:qik_talk/features/chat/general/services/community_api_service/community_api_service.dart';
import 'package:qik_talk/features/chat/group_chat/widgets/group_composite_avatar.dart';
import 'package:qik_talk/utilities/constants/app_config.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

import 'package:qik_talk/features/community/screens/create_community_announcement.dart';
import 'package:qik_talk/features/community/services/community_cache_service.dart';

import 'package:qik_talk/features/chat/group_chat/screens/group_chat_screen.dart';
import 'package:qik_talk/features/chat/group_chat/screens/create_new_group_screen.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:qik_talk/utilities/services/presigned_upload_service.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';
import 'package:video_player/video_player.dart';
import 'community_info_screen.dart';

import 'add_group_to_community_sheet.dart';

class CommunityDetailsScreen extends StatefulWidget {
  final String communityId;
  final CommunityModel? initialCommunity;

  const CommunityDetailsScreen({
    super.key,
    required this.communityId,
    this.initialCommunity,
  });

  @override
  State<CommunityDetailsScreen> createState() => _CommunityDetailsScreenState();
}

class _CommunityDetailsScreenState extends State<CommunityDetailsScreen>
    with WidgetsBindingObserver {
  final _api = CommunityApiService();
  final _save = SaveValues();
  final _mediaCache = MediaCacheService();

  CommunityModel? _community;

  bool _isLoading = false;
  String _myUserId = '';

  final _menuKey = GlobalKey();
  final _imagePicker = ImagePicker();
  Timer? _refreshTimer;

  // ── FIX 2: controller for the edit-name dialog ────────────────────────────
  final _nameController = TextEditingController();
  VideoPlayerController? _videoController;
  bool _isVideoBackground = false;

  Future<void> _forceMuteVideoController(
    VideoPlayerController controller,
  ) async {
    try {
      await controller.setVolume(0.0);
      // Re-assert mute in case platform/player state resets on play/rebuild.
      controller.removeListener(_enforceMuteListener);
      controller.addListener(_enforceMuteListener);
    } catch (_) {}
  }

  void _enforceMuteListener() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.volume != 0.0) {
      controller.setVolume(0.0);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _community = widget.initialCommunity;
    _isLoading = widget.initialCommunity == null;
    _refreshTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (mounted) _reload();
    });
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _nameController.dispose();
    _videoController?.removeListener(_enforceMuteListener);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reload();
    }
  }

  // ── Camera/video edit (images + video up to 15s) ──────────────────────────
  Future<void> _pickMediaForCover() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: HexColor('#1E1E1E'),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.image, color: Colors.blue),
                ),
                title: Text(
                  'Choose a photo',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, 'photo'),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.videocam, color: Colors.red),
                ),
                title: Text(
                  'Choose a video (max 15s)',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, 'video'),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == null || !mounted) return;

    if (choice == 'photo') {
      ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).isPickerActive = true;
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      await ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).onPickerReturned();
      if (picked == null || !mounted) return;
      await _uploadCommunityBackground(File(picked.path));
    } else if (choice == 'video') {
      ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).isPickerActive = true;
      final picked = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 15),
      );
      await ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).onPickerReturned();
      if (picked == null || !mounted) return;
      await _uploadCommunityBackground(File(picked.path));
    }
  }

  // ── FIX 1: Edit icon (photo only) — avatar tap ────────────────────────────
  Future<void> _pickPhotoForAvatar() async {
    debugPrint('🖊️ pickPhotoForAvatar called — isAdmin: $_isAdmin');
    ProviderScope.containerOf(
      context,
    ).read(biometricAuthProvider.notifier).isPickerActive = true;
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    await ProviderScope.containerOf(
      context,
    ).read(biometricAuthProvider.notifier).onPickerReturned();
    if (picked == null || !mounted) return;
    await _uploadCommunityImage(File(picked.path));
  }

  // ── Shared upload helpers ─────────────────────────────────────────────────
  Future<void> _uploadCommunityImage(File file) async {
    _showLoadingDialog();
    try {
      final svc = ChatSettingsService();
      final result = await svc.updateChatImage(
        chatId: widget.communityId,
        imageFile: file,
        isCommunity: true,
      );
      if (mounted) Navigator.pop(context);
      if (result.success) {
        _snack('Community image updated');
        await _reload();
      } else {
        _snack(result.message, color: Colors.red);
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      if (mounted) Navigator.pop(context);
      _snack('Error: $e', color: Colors.red);
    }
  }

  Future<void> _uploadCommunityVideo(File file) async {
    _showLoadingDialog();
    try {
      final mimeType = lookupMimeType(file.path) ?? 'video/mp4';
      // Step 1 — Upload to MinIO
      final publicUrl = await PresignedUploadService.uploadFile(
        file: file,
        mimeType: mimeType,
      );
      if (publicUrl == null) {
        if (mounted) Navigator.pop(context);
        _snack('Failed to upload video', color: Colors.red);
        return;
      }

      // Step 2 — Tell backend about the new background URL
      final token = await _save.getString(AppPreferenceHelper.AUTH_TOKEN);
      final uri = Uri.parse(
        '${AppConfig.apiUrl}chat/community/${widget.communityId}/background',
      );
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'backgroundUrl': publicUrl,
        }), // ✅ confirmed field name
      );

      if (mounted) Navigator.pop(context);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _snack('Community cover video updated');
        await _reload();
      } else {
        debugPrint('🔴 Video BG STATUS: ${response.statusCode}');
        debugPrint('🔴 Video BG BODY: ${response.body}');
        _snack(
          'Failed to update cover: ${response.statusCode}',
          color: Colors.red,
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _snack('Error: $e', color: Colors.red);
    }
  }

  Future<void> _uploadCommunityBackground(File file) async {
    _showLoadingDialog();
    try {
      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      // Step 1 — Upload to MinIO via presigned URL
      final publicUrl = await PresignedUploadService.uploadFile(
        file: file,
        mimeType: mimeType,
      );
      if (publicUrl == null) {
        if (mounted) Navigator.pop(context);
        _snack('Failed to upload background', color: Colors.red);
        return;
      }

      // Step 2 — Persist the MinIO URL to backend
      final token = await _save.getString(AppPreferenceHelper.AUTH_TOKEN);
      final uri = Uri.parse(
        '${AppConfig.apiUrl}chat/community/${widget.communityId}/background',
      );
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'backgroundUrl': publicUrl,
        }), // ✅ confirmed field name
      );

      if (mounted) Navigator.pop(context);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _snack('Community background updated');
        await _reload();
      } else {
        debugPrint('🔴 BG STATUS: ${response.statusCode}');
        debugPrint('🔴 BG BODY: ${response.body}');
        _snack(
          'Failed to update background: ${response.statusCode}',
          color: Colors.red,
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _snack('Error: $e', color: Colors.red);
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Center(child: CircularProgressIndicator(color: HexColor('#1A7F4B'))),
    );
  }

  Future<void> _init() async {
    _myUserId = await _save.getString(AppPreferenceHelper.ID) ?? '';
    debugPrint('👤 CommunityDetails — myUserId: "$_myUserId"');

    if (_community == null) {
      final cached = await CommunityCacheService.loadCommunity(
        widget.communityId,
      );
      if (cached != null && mounted) {
        setState(() {
          _community = cached;
          _isLoading = false;
        });
      }
    }

    if (_community != null) {
      CommunityCacheService.prewarmSingleCommunityMedia(_community!);
      _initVideoBackground(_community!);
    }

    // Reload silently — UI renders with cached/initial community immediately
    _reload();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    final res = await _api.getCommunityInfo(widget.communityId);
    if (!mounted) return;
    setState(() {
      if (res.success && res.community != null) {
        _community = res.community;
      }
      _isLoading = false; // always clear loading
      print('👑 isAdmin($_myUserId) = ${_community?.isAdmin(_myUserId)}');
      print('   adminIds: ${_community?.adminIds}');
      print(
        '   groupAdmins: ${_community?.groupAdmins.map((a) => a.id).toList()}',
      );
    });

    if (_community != null) {
      CommunityCacheService.prewarmSingleCommunityMedia(_community!);
      await _initVideoBackground(_community!);
    }
  }

  Future<void> _initVideoBackground(CommunityModel community) async {
    final bg = _imgUrl(community.communityBackground ?? community.chatImage);
    final isVideo = _isVideoUrl(bg);
    if (!isVideo || bg.isEmpty) {
      _videoController?.removeListener(_enforceMuteListener);
      await _videoController?.pause();
      await _videoController?.dispose();
      _videoController = null;
      if (mounted) setState(() => _isVideoBackground = false);
      return;
    }

    VideoPlayerController? controller;
    try {
      final cachedPath = _mediaCache.getCachedPath(bg);
      controller = cachedPath != null && File(cachedPath).existsSync()
          ? VideoPlayerController.file(File(cachedPath))
          : VideoPlayerController.networkUrl(Uri.parse(bg));

      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      controller.addListener(_enforceMuteListener);
      await controller.play();

      _videoController?.removeListener(_enforceMuteListener);
      await _videoController?.pause();
      await _videoController?.dispose();
      _videoController = controller;
      if (mounted) setState(() => _isVideoBackground = true);

      Future.delayed(const Duration(milliseconds: 300), () {
        _videoController?.setVolume(0.0);
      });

      _mediaCache.cacheMedia(url: bg, mediaType: 'video');
    } catch (e) {
      debugPrint('❌ Video init error: $e');
      await controller?.dispose();
      if (mounted) setState(() => _isVideoBackground = false);
    }
  }

  bool get _isAdmin {
    if (_myUserId.isEmpty || _community == null) return false;
    return _community!.isAdmin(_myUserId);
  }

  String _imgUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

  bool _isVideoUrl(String url) {
    if (url.isEmpty) return false;
    final lower = url.toLowerCase();
    // Extension-based detection
    if (lower.contains('.mp4') ||
        lower.contains('.mov') ||
        lower.contains('.webm') ||
        lower.contains('.m4v'))
      return true;
    // Cloud storage path-based detection (MinIO, S3)
    if (lower.contains('/video/upload/') ||
        lower.contains('/videos/') ||
        lower.contains('video%2F'))
      return true;
    return false;
  }

  void _snack(String msg, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: color ?? HexColor('#1A7F4B'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _persistCommunityLocally(CommunityModel community) async {
    await CommunityCacheService.saveCommunity(community);
    await CommunityCacheService.upsertCommunity(community);
    CommunityCacheService.prewarmSingleCommunityMedia(community);
  }

  void _popWithCurrentCommunityName() {
    Navigator.pop(context, _community?.chatName);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FIX 2: EDIT NAME DIALOG — with Save/Done button
  // ─────────────────────────────────────────────────────────────────────────

  void _showEditNameDialog() {
    _nameController.text = _community?.chatName ?? '';

    showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: HexColor('#2A2A2A'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Name',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: HexColor('#1A7F4B'),
          decoration: InputDecoration(
            hintText: 'Enter community name',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: HexColor('#1A1A1A'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: HexColor('#1A7F4B'), width: 1.5),
            ),
          ),
        ),
        actions: [
          // Cancel
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
          // ── NEW: Save / Done button ──────────────────────────────────
          TextButton(
            onPressed: () async {
              final newName = _nameController.text.trim();
              if (newName.isEmpty) {
                _snack('Name cannot be empty', color: Colors.red);
                return;
              }
              Navigator.pop(dialogContext);
              await _saveCommunityName(newName);
            },
            style: TextButton.styleFrom(
              backgroundColor: HexColor('#1A7F4B').withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                color: HexColor('#1A7F4B'),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCommunityName(String newName) async {
    if (_community == null) return;
    _showLoadingDialog();
    try {
      final result = await _api.renameCommunity(
        communityId: widget.communityId,
        newName: newName,
      );
      if (mounted) Navigator.pop(context);
      if (result.success) {
        final updated = _community!.copyWith(chatName: newName);
        await _persistCommunityLocally(updated);
        if (mounted) {
          setState(() => _community = updated);
        }
        _snack('Community name updated');
      } else {
        _snack(result.message, color: Colors.red);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _snack('Error: $e', color: Colors.red);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WHATSAPP-STYLE 3-DOT MENU
  // ─────────────────────────────────────────────────────────────────────────

  void _showMoreMenu() {
    final RenderBox button =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    print('🔑 Opening menu — isAdmin: $_isAdmin, userId: $_myUserId');

    showMenu<String>(
      context: context,
      position: position,
      color: HexColor('#2A2A2A'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: [
        if (_isAdmin) ...[
          PopupMenuItem<String>(
            value: 'create_group',
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.group_add, color: HexColor('#1A7F4B'), size: 20),
                const SizedBox(width: 14),
                Text(
                  'Create new group',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'add_existing',
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.playlist_add, color: HexColor('#1A7F4B'), size: 20),
                const SizedBox(width: 14),
                Text(
                  'Add existing group',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
        PopupMenuItem<String>(
          value: 'community_info',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 14),
              Text(
                'Community info',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        if (!_isAdmin)
          PopupMenuItem<String>(
            value: 'exit',
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.exit_to_app, color: Colors.red, size: 20),
                const SizedBox(width: 14),
                Text(
                  'Exit community',
                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                ),
              ],
            ),
          ),
      ],
    ).then((value) {
      switch (value) {
        case 'create_group':
          _goToCreateGroup();
          break;
        case 'add_existing':
          _showAddExistingGroup();
          break;
        case 'community_info':
          _openCommunityInfo();
          break;
        case 'exit':
          _confirmLeave();
          break;
      }
    });
  }

  void _goToCreateGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNewGroupScreen(communityId: widget.communityId),
      ),
    ).then((_) => _reload());
  }

  void _showAddExistingGroup() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HexColor('#1A1A1A'),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddGroupToCommunitySheet(
        communityId: widget.communityId,
        alreadyAddedIds: _community?.subGroups.map((g) => g.id).toList() ?? [],
        onGroupAdded: (groupId) async {
          final res = await _api.addGroupToCommunity(
            communityId: widget.communityId,
            groupId: groupId,
          );
          if (res.success) {
            _snack('✅ Group added to community!');
            await _reload();
          } else {
            _snack(res.message, color: Colors.red);
          }
        },
      ),
    );
  }

  void _openGroupChat(CommunitySubGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatScreen(
          groupId: group.id,
          groupName: group.chatName,
          communityName: _community?.chatName ?? '',
          memberCount: group.memberCount,
          groupImage: group.chatImage ?? '',
        ),
      ),
    );
  }

  void _openAnnouncement() {
    if (_community == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityAnnouncementScreen(
          communityId: widget.communityId,
          communityName: _community!.chatName,
          isAdmin: _isAdmin,
        ),
      ),
    );
  }

  void _openCommunityInfo() {
    if (_community == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityInfoScreen(
          communityId: widget.communityId,
          initialCommunity: _community,
          isAdmin: _isAdmin,
          onUpdated: _reload,
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
          'Exit community',
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
            child: Text('Exit', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) Navigator.pop(context);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (_community == null && _isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        body: Center(
          child: CircularProgressIndicator(
            color: HexColor('#1A7F4B'),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_community == null) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        body: Center(
          child: Text(
            'Community not found',
            style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark)),
          ),
        ),
      );
    }

    final c = _community!;
    final topPad = MediaQuery.of(context).padding.top;
    final imageUrl = _imgUrl(c.chatImage);
    final backgroundUrl = _imgUrl(
      c.communityBackground?.isNotEmpty == true
          ? c.communityBackground
          : c.chatImage,
    );
    final desc = c.displayDescription;

    final myGroups = c.subGroups.where((g) => g.isMember(_myUserId)).toList();
    final otherGroups = c.subGroups
        .where((g) => !g.isMember(_myUserId))
        .toList();

    return WillPopScope(
      onWillPop: () async {
        _popWithCurrentCommunityName();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        body: Column(
          children: [
            // ── Hero header ─────────────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Background image
                SizedBox(
                  height: 200 + topPad,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base background color
                      Container(
                        color: isDark
                            ? HexColor('#2A2A2A')
                            : HexColor('#D9CFC4'),
                      ),
                      // Image background
                      if (!_isVideoBackground && backgroundUrl.isNotEmpty)
                        OfflineCachedImage(
                          imageUrl: backgroundUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200 + topPad,
                          borderRadius: BorderRadius.zero,
                          errorWidget: const SizedBox.shrink(),
                          placeholder: const SizedBox.shrink(),
                        ),
                      // Video background
                      if (_isVideoBackground &&
                          _videoController != null &&
                          _videoController!.value.isInitialized)
                        ClipRect(
                          child: OverflowBox(
                            maxWidth: double.infinity,
                            maxHeight: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
                                child: VideoPlayer(_videoController!),
                              ),
                            ),
                          ),
                        ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Back button + camera/edit icons row
                Positioned(
                  top: topPad + 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _headerBtn(
                        Icons.arrow_back,
                        _popWithCurrentCommunityName,
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _isAdmin ? _pickMediaForCover : null,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.35),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'images/community_cameraedit.png',
                                width: 22,
                                height: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          KeyedSubtree(
                            key: _menuKey,
                            child: _headerBtn(Icons.more_vert, _showMoreMenu),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Avatar + edit badge ───────────────────────────────────
                Positioned(
                  bottom: -50,
                  left: 16,
                  child: GestureDetector(
                    onTap: _isAdmin ? _pickPhotoForAvatar : null,
                    child: Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.scaffoldBg(isDark),
                              width: 3,
                            ),
                            color: HexColor('#3A3A3A'),
                          ),
                          child: ClipOval(
                            child: imageUrl.isEmpty
                                ? const Icon(
                                    Icons.people,
                                    color: Colors.white,
                                    size: 40,
                                  )
                                : OfflineCachedImage(
                                    imageUrl: imageUrl,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.zero,
                                    errorWidget: const Icon(
                                      Icons.people,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    placeholder: Container(
                                      color: HexColor('#3A3A3A'),
                                    ),
                                  ),
                          ),
                        ),
                        // ── Edit badge bottom-right like Figma ───────────
                        if (_isAdmin)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: HexColor('#1A7F4B'),
                                border: Border.all(
                                  color: HexColor('#141414'),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Community name + description ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
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
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // ── FIX 2: edit icon now calls _showEditNameDialog ──────
                      if (_isAdmin)
                        GestureDetector(
                          onTap: _showEditNameDialog,
                          child: Icon(
                            Icons.edit,
                            color: AppTheme.iconColor(isDark),
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary(isDark),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${c.memberCount} member${c.memberCount == 1 ? '' : 's'}${_isAdmin ? ' · Admin' : ''}',
                    style: GoogleFonts.poppins(
                      color: _isAdmin
                          ? HexColor('#1A7F4B')
                          : AppTheme.textSecondary(isDark),
                      fontSize: 12,
                      fontWeight: _isAdmin
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Message + Community Info buttons ──────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _openAnnouncement,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg(isDark),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: HexColor('#FB8830').withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  color: AppTheme.iconColor(isDark),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Message',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary(isDark),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _openCommunityInfo,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg(isDark),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: AppTheme.border(isDark),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppTheme.iconColor(isDark),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Community Info',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary(isDark),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Groups list ─────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reload,
                color: HexColor('#1A7F4B'),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 16, bottom: 100),
                  children: [
                    if (myGroups.isNotEmpty) ...[
                      _sectionLabel("Groups you're in"),
                      ...myGroups.map((g) => _groupTile(g, joined: true)),
                    ],
                    if (otherGroups.isNotEmpty) ...[
                      _sectionLabel('Groups you can join'),
                      ...otherGroups.map((g) => _groupTile(g, joined: false)),
                    ],
                    if (c.subGroups.isEmpty) _emptyGroups(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────

  Widget _headerBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: AppTheme.textPrimary(isDark),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _announcementTile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: GestureDetector(
        onTap: _openAnnouncement,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: HexColor('#FB8830').withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HexColor('#FB8830').withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: HexColor('#FB8830').withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.campaign_outlined,
                  color: HexColor('#FB8830'),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Announcements',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _isAdmin
                          ? 'Broadcast to all members'
                          : 'Important messages from admins',
                      style: GoogleFonts.poppins(
                        color: HexColor('#A0A0A0'),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isAdmin)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: HexColor('#FB8830'),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Admin',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Icon(Icons.chevron_right, color: HexColor('#A0A0A0')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupTile(CommunitySubGroup group, {required bool joined}) {
    final imgUrl = _imgUrl(group.chatImage);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () => joined ? _openGroupChat(group) : _showJoinSheet(group),
        child: Row(
          children: [
            group.membersAvatarUrls.isNotEmpty
                ? GroupCompositeAvatar(
                    imageUrls: group.membersAvatarUrls,
                    totalMemberCount: group.memberCount,
                    size: 55,
                  )
                : Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? HexColor('#3A3A3A') : HexColor('#D9CFC4'),
                    ),
                    child: Icon(
                      Icons.group,
                      color: isDark
                          ? Colors.white60
                          : AppTheme.iconColorSubtle(isDark),
                      size: 26,
                    ),
                  ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.chatName,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    group.memberCount > 0
                        ? '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}'
                        : group.description ?? 'Group',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!joined)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: HexColor('#1A7F4B').withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: HexColor('#1A7F4B').withOpacity(0.4),
                  ),
                ),
                child: Text(
                  'Join',
                  style: GoogleFonts.poppins(
                    color: HexColor('#1A7F4B'),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: AppTheme.iconColorSubtle(isDark),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyGroups() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.group_outlined,
              color: AppTheme.iconColorSubtle(isDark),
              size: 60,
            ),
            const SizedBox(height: 12),
            Text(
              'No groups yet',
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary(isDark),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            if (_isAdmin) ...[
              Text(
                'Use the ⋮ menu to create or add groups',
                style: GoogleFonts.poppins(
                  color: AppTheme.textHint(isDark),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _emptyActionBtn(
                    icon: Icons.group_add,
                    label: 'Create Group',
                    onTap: _goToCreateGroup,
                  ),
                  const SizedBox(width: 12),
                  _emptyActionBtn(
                    icon: Icons.playlist_add,
                    label: 'Add Existing',
                    onTap: _showAddExistingGroup,
                  ),
                ],
              ),
            ] else
              Text(
                'No groups have been added yet',
                style: GoogleFonts.poppins(
                  color: AppTheme.textHint(isDark),
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: HexColor('#1A7F4B').withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HexColor('#1A7F4B').withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: HexColor('#1A7F4B'), size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: HexColor('#1A7F4B'),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinSheet(CommunitySubGroup group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HexColor('#1E1E1E'),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.group_add_outlined,
                color: HexColor('#1A7F4B'),
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                group.chatName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              if (group.memberCount > 0)
                Text(
                  '${group.memberCount} members',
                  style: GoogleFonts.poppins(
                    color: HexColor('#A0A0A0'),
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor('#1A7F4B'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Request to Join',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
