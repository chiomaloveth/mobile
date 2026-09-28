import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
//import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/status_privacy_screen.dart';
import 'package:qik_talk/features/status/services/status_cache_service.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/utilities/widgets/segmented_status_ring.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qik_talk/features/status/services/status_service.dart';
import 'package:qik_talk/features/status/screens/status_image_preview_screen.dart';
import 'package:qik_talk/features/status/screens/status_video_preview_screen.dart';
import 'package:qik_talk/features/status/screens/status_view_screen.dart';
import 'package:qik_talk/features/status/screens/text_status_screen.dart';
import 'package:qik_talk/features/status/screens/status_upload_banner.dart';
import 'package:qik_talk/features/status/services/status_upload_manager.dart';
import '../../../utilities/services/app_pref_helper.dart';
import '../../ai/screens/ai_chat_screen.dart';
import '../../ai/screens/ai_onboarding_screen.dart';
import '../../../utilities/database/save_values.dart';
import '../components/status_choice_dialog.dart';
import '../../settings/screen/settings_screen.dart';
import '../model/my_status_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';
import 'package:qik_talk/features/authentication/provider/user_provider.dart';

class StatusFragment extends ConsumerStatefulWidget {
  const StatusFragment({super.key});

  @override
  ConsumerState<StatusFragment> createState() => _StatusFragmentState();
}

// ROBOT DISABLED: SingleTickerProviderStateMixin removed (was only needed for robot animation)
class _StatusFragmentState extends ConsumerState<StatusFragment> {
  final SaveValues mySaveValues = SaveValues();
  // ROBOT DISABLED:
  // late AnimationController _robotAnimationController;
  // late Animation<double> _robotAnimation;
  // ROBOT DISABLED: bool _hasCompletedOnboarding = false;
  String myUserId = "";
  List<MyStatusModel> statuses = [];
  bool isLoading = false;
  Timer? _autoRefreshTimer;
  Set<String> _locallyViewedIds = {};

  // ── Search ────────────────────────────────────────────────────────────────
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initStatus();
    _loadLocallyViewedIds();

    // ROBOT DISABLED:
    // _robotAnimationController = AnimationController(
    //   duration: const Duration(milliseconds: 1500),
    //   vsync: this,
    // );
    // _robotAnimation = Tween<double>(begin: 0, end: 15).animate(
    //   CurvedAnimation(
    //     parent: _robotAnimationController,
    //     curve: Curves.easeInOut,
    //   ),
    // );
    // _robotAnimationController.repeat(reverse: true);
    _startAutoRefresh();
    StatusUploadManager().progress.addListener(_onUploadProgressChanged);
  }

  void _onUploadProgressChanged() {
    final p = StatusUploadManager().progress.value;
    if (p == null || p >= 1.0) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _loadFreshOnly();
      });
    }
  }

  Future<void> _initStatus() async {
    await _loadUserId();
    await _loadStatuses();
  }

  Future<void> _loadUserId() async {
    final storedUserId = await mySaveValues.getString(AppPreferenceHelper.ID);
    if (mounted) {
      setState(() {
        myUserId = storedUserId ?? "";
      });
    }
  }

  Future<void> _loadLocallyViewedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final viewed = prefs.getStringList('viewed_status_ids') ?? [];
    if (mounted) setState(() => _locallyViewedIds = viewed.toSet());
  }

  Future<void> _loadStatuses() async {
    // ── Step 1: Show cached data instantly (works fully offline) ───────────
    final cached = await StatusCacheService.loadCached();
    if (mounted) {
      setState(() {
        if (cached.isNotEmpty) statuses = cached;
        isLoading = false; // never block on loading
      });
    }

    // ── Step 2: Fetch fresh data from API ───────────────────────────────────
    try {
      final token = await mySaveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      if (token == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }
      final fresh = await StatusService.fetchStatuses(token);
      if (!mounted) return;
      setState(() {
        statuses = fresh;
        isLoading = false;
      });
      // ── Step 3: Save to cache + pre-download all media in background ────
      await StatusCacheService.save(fresh);
      StatusCacheService.prewarmMedia(fresh); // fire-and-forget, no await

      // ── Step 4: Pre-generate video thumbnail for own status ─────────────
      if (hasMyStatus) {
        final latest = myStatusModel!.updates.first;
        if (latest.mediaType == 'video') {
          _generateVideoThumbnailIfNeeded(latest);
        }
      }
    } catch (e) {
      debugPrint('Status fetch error (using cache): $e');
      if (!mounted) return;
      // Keep cached data on screen — don't show empty state when offline
      setState(() => isLoading = false);
    }
  }

  bool get hasMyStatus {
    if (statuses.isEmpty) return false;
    final mine = statuses.where((s) => s.user.id == myUserId).toList();
    return mine.isNotEmpty && mine.first.updates.isNotEmpty;
  }

  MyStatusModel? get myStatusModel {
    try {
      return statuses.firstWhere((s) => s.user.id == myUserId);
    } catch (_) {
      return null;
    }
  }

  Update? get firstMyStatus =>
      hasMyStatus ? myStatusModel!.updates.first : null;

  List<MyStatusModel> get otherStatuses => statuses
      .where((s) => s.user.id != myUserId && s.updates.isNotEmpty)
      .toList();

  bool _hasSeenAllUpdates(MyStatusModel status) =>
      status.updates.every((u) => _locallyViewedIds.contains(u.id));

  // ── Filtered list for search ──────────────────────────────────────────────
  List<MyStatusModel> get _filteredOtherStatuses {
    if (_searchQuery.isEmpty) return otherStatuses;
    final q = _searchQuery.toLowerCase();
    return otherStatuses.where((s) {
      // Match username
      if (s.user.username.toLowerCase().contains(q)) return true;
      // Match any update caption or text media
      return s.updates.any((u) {
        if ((u.caption ?? '').toLowerCase().contains(q)) return true;
        if (u.mediaType == 'text' && u.media.toLowerCase().contains(q))
          return true;
        return false;
      });
    }).toList();
  }

  Future<void> _forceRefreshAfterUpload() async {
    // Wait for upload to finish (max 10s)
    int attempts = 0;
    while (StatusUploadManager().progress.value != null &&
        StatusUploadManager().progress.value! < 1.0 &&
        attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    await _loadFreshOnly();
  }

  Future<void> _loadFreshOnly() async {
    try {
      final token = await mySaveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      if (token == null || !mounted) return;
      final fresh = await StatusService.fetchStatuses(token);
      if (!mounted) return;
      setState(() {
        statuses = fresh;
        isLoading = false;
      });
      await StatusCacheService.save(fresh);
      StatusCacheService.prewarmMedia(fresh);

      // Pre-generate video thumbnail for own status after refresh
      if (hasMyStatus) {
        final latest = myStatusModel!.updates.first;
        if (latest.mediaType == 'video') {
          _generateVideoThumbnailIfNeeded(latest);
        }
      }
    } catch (e) {
      debugPrint('Force refresh failed: $e');
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted) return;
      _loadStatuses();
      _loadLocallyViewedIds();
    });
  }

  Future<void> getImage(BuildContext parentContext, ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final status = await Permission.photos.request();
        final storageStatus = await Permission.storage.request();
        if (!status.isGranted && !storageStatus.isGranted) return;
      } else {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) return;
      }

      ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).isPickerActive = true;
      final pickedImage = await ImagePicker().pickImage(
        source: source,
        imageQuality: 100,
      );
      await ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).onPickerReturned();
      if (pickedImage == null) return;

      final imageFile = File(pickedImage.path);
      if (!mounted) return;
      await Navigator.of(parentContext).push(
        MaterialPageRoute(
          builder: (_) => StatusImagePreviewScreen(
            file: imageFile,
            isVideo: false,
            onUploadComplete: () {
              if (mounted) _forceRefreshAfterUpload();
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        parentContext,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> pickVideoFromGallery(BuildContext context) async {
    try {
      ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).isPickerActive = true;
      final pickedVideo = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );
      await ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).onPickerReturned();
      if (pickedVideo == null) return;

      final file = File(pickedVideo.path);
      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StatusVideoPreviewScreen(
            file: file,
            isVideo: true,
            onUploadComplete: () {
              if (mounted) _forceRefreshAfterUpload();
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick video: $e')));
    }
  }

  Future<void> recordVideoFromCamera(BuildContext context) async {
    try {
      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      if (!cameraStatus.isGranted || !micStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Camera and microphone permission required"),
          ),
        );
        return;
      }

      ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).isPickerActive = true;
      final pickedVideo = await ImagePicker().pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );
      await ProviderScope.containerOf(
        context,
      ).read(biometricAuthProvider.notifier).onPickerReturned();
      if (pickedVideo == null) return;

      final file = File(pickedVideo.path);
      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StatusVideoPreviewScreen(file: file, isVideo: true),
        ),
      );
      _loadStatuses();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to record video: $e')));
    }
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg(
        Theme.of(context).brightness == Brightness.dark,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bsCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.dividerSubtle(
                      Theme.of(bsCtx).brightness == Brightness.dark,
                    ),
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
                    child: const Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                  title: Text(
                    "Take a photo",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(
                        Theme.of(bsCtx).brightness == Brightness.dark,
                      ),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(bsCtx);
                    await getImage(context, ImageSource.camera);
                  },
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
                    "Record a video",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(
                        Theme.of(bsCtx).brightness == Brightness.dark,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    "Max 30 seconds",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(
                        Theme.of(bsCtx).brightness == Brightness.dark,
                      ),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(bsCtx);
                    await recordVideoFromCamera(context);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo, color: Colors.green),
                  ),
                  title: Text(
                    "Choose a photo",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(
                        Theme.of(bsCtx).brightness == Brightness.dark,
                      ),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(bsCtx);
                    await getImage(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.video_library,
                      color: Colors.orange,
                    ),
                  ),
                  title: Text(
                    "Choose a video",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(
                        Theme.of(bsCtx).brightness == Brightness.dark,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    "Max 30 seconds",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(
                        Theme.of(bsCtx).brightness == Brightness.dark,
                      ),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(bsCtx);
                    await pickVideoFromGallery(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Cache of videoUrl → local thumbnail path
  final Map<String, String> _videoThumbCache = {};

  Future<void> _generateVideoThumbnailIfNeeded(Update update) async {
    if (update.mediaType != 'video') return;
    final url = update.media;
    if (url.isEmpty || _videoThumbCache.containsKey(url)) return;

    try {
      final dir = await getTemporaryDirectory();
      final outPath = '${dir.path}/status_thumb_${url.hashCode.abs()}.jpg';
      final file = File(outPath);

      if (await file.exists() && await file.length() > 0) {
        if (mounted) setState(() => _videoThumbCache[url] = outPath);
        return;
      }

      // Extract frame at 0.5s from the remote video URL
      await FFmpegKit.execute(
        '-y -ss 0.5 -i "$url" -vframes 1 -q:v 2 "$outPath"',
      );

      if (await file.exists() && await file.length() > 0) {
        if (mounted) setState(() => _videoThumbCache[url] = outPath);
      }
    } catch (e) {
      debugPrint('Video thumb error: $e');
    }
  }

  ImageProvider _myAvatarImage(String profilePictureUrl) {
    if (hasMyStatus) {
      final sorted = [...myStatusModel!.updates]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latest = sorted.first;

      if (latest.mediaType == 'image' && latest.media.isNotEmpty) {
        final busted = latest.media.contains('?')
            ? '${latest.media}&_t=${latest.createdAt.millisecondsSinceEpoch}'
            : '${latest.media}?_t=${latest.createdAt.millisecondsSinceEpoch}';
        return NetworkImage(busted);
      }

      if (latest.mediaType == 'video' && latest.media.isNotEmpty) {
        final thumbPath = _videoThumbCache[latest.media];
        if (thumbPath != null) {
          // Thumbnail ready — show it
          return FileImage(File(thumbPath));
        }
        // Trigger generation in background, show profile pic meanwhile
        _generateVideoThumbnailIfNeeded(latest);
        if (profilePictureUrl.isNotEmpty)
          return NetworkImage(profilePictureUrl);
        return const AssetImage("images/profile_logo.png");
      }

      // Text status — background colour handles this, image not needed
      if (profilePictureUrl.isNotEmpty) return NetworkImage(profilePictureUrl);
      return const AssetImage("images/profile_logo.png");
    }
    if (profilePictureUrl.isNotEmpty) return NetworkImage(profilePictureUrl);
    return const AssetImage("images/profile_logo.png");
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? "minute" : "minutes"} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? "hour" : "hours"} ago';
    }
    final d = diff.inDays;
    return '$d ${d == 1 ? "day" : "days"} ago';
  }

  Widget? _buildMyStatusOverlay(Update update) {
    // Only show text preview if ALL updates are text type
    // If there's any image/video, the backgroundImage handles it
    final allText =
        myStatusModel?.updates.every((u) => u.mediaType == 'text') ?? false;
    if (!allText) return null;

    switch (update.mediaType) {
      case 'text':
        final t = update.media.isNotEmpty
            ? update.media
            : (update.caption ?? '');
        final preview = t.length > 2
            ? t.substring(0, 2).toUpperCase()
            : t.toUpperCase();
        return Text(
          preview,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        );
      default:
        return null;
    }
  }

  @override
  void dispose() {
    StatusUploadManager().progress.removeListener(_onUploadProgressChanged);
    _autoRefreshTimer?.cancel();
    // ROBOT DISABLED: _robotAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildStatusRing({
    required Widget child,
    required bool hasSeen,
    required bool hasStatus,
    double radius = 33.0,
    MyStatusModel? statusModel,
  }) {
    if (!hasStatus) return child;

    final updates = statusModel?.updates ?? [];
    final totalSegments = updates.isEmpty ? 1 : updates.length;
    final seenCount = updates.isEmpty
        ? (hasSeen ? 1 : 0)
        : updates.where((u) => _locallyViewedIds.contains(u.id)).length;

    // Ring sits OUTSIDE the avatar but the child stays the same size.
    // We use an OverflowBox so the ring can paint beyond the child's bounds
    // without affecting layout.
    const double strokeWidth = 2.5;
    const double gap = 4.0; // space between avatar edge and ring
    final double ringRadius = radius + gap + strokeWidth;

    return SizedBox(
      // Keep the layout box exactly the same as the avatar
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Ring overflows but doesn't affect layout
          Positioned.fill(
            child: OverflowBox(
              maxWidth: ringRadius * 2,
              maxHeight: ringRadius * 2,
              child: SegmentedStatusRing(
                totalSegments: totalSegments,
                seenCount: seenCount,
                radius: ringRadius,
                strokeWidth: strokeWidth,
                gap: totalSegments == 1 ? 0 : 5.0,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double topPadding = MediaQuery.of(context).padding.top + 10;
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_isSearching ? 60 : 60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: HexColor("#3A1D07"),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF3A1D07),
              image: DecorationImage(
                image: AssetImage("images/app_bar_gredient.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    if (_isSearching) ...[
                      // ── Search mode ──────────────────────────────────────────
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: topPadding),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isSearching = false;
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search statuses…',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.white54,
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (val) =>
                                      setState(() => _searchQuery = val.trim()),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _searchController.clear();
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ), // closes Expanded
                    ] else ...[
                      // ── Normal mode ──────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.only(top: topPadding, left: 16.0),
                        child: Text(
                          "QikTalk",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      GestureDetector(
                        onTap: () => setState(() => _isSearching = true),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topPadding,
                            right: 10.0,
                          ),
                          child: Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.85),
                            size: 25.0,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final selected = await showMenu<String>(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              MediaQuery.of(context).size.width - 160,
                              75,
                              10,
                              20,
                            ),
                            color: AppTheme.scaffoldBg(isDark),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            items: [
                              PopupMenuItem<String>(
                                value: 'status',
                                child: Text(
                                  "Status privacy",
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary(isDark),
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'settings',
                                child: Text(
                                  "Settings",
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary(isDark),
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                            ],
                          );
                          if (selected == 'settings') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SettingsScreen(),
                              ),
                            );
                          } else if (selected == 'status') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StatusPrivacyScreen(),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topPadding,
                            right: 20.0,
                          ),
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.white.withOpacity(0.85),
                            size: 25.0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Scrollable content ─────────────────────────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── MY STATUS ROW ──
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 10.0),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: hasMyStatus
                                  ? () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => StatusViewScreen(
                                            updates: myStatusModel!.updates,
                                            isMyStatus: true,
                                          ),
                                        ),
                                      );
                                      // Always refresh — handles normal close
                                      // AND deletion (viewer pops with 'deleted')
                                      await _loadFreshOnly();
                                      if (mounted) setState(() {});
                                    }
                                  : null,
                              child: _buildStatusRing(
                                hasStatus: hasMyStatus,
                                hasSeen: false,
                                statusModel: myStatusModel,
                                child: CircleAvatar(
                                  radius: 33.0,
                                  backgroundColor:
                                      hasMyStatus &&
                                          myStatusModel!
                                                  .updates
                                                  .first
                                                  .mediaType ==
                                              'text'
                                      ? Color(
                                          myStatusModel!
                                              .updates
                                              .first
                                              .backgroundColor,
                                        )
                                      : HexColor("#9D9D9D"),
                                  backgroundImage: _myAvatarImage(
                                    userProfile.profilePictureUrl,
                                  ),
                                  key: ValueKey(
                                    hasMyStatus
                                        ? '${myStatusModel!.updates.first.media}'
                                              '_${_videoThumbCache[myStatusModel!.updates.first.media] ?? ''}'
                                        : userProfile.profilePictureUrl,
                                  ),
                                  child: hasMyStatus
                                      ? _buildMyStatusOverlay(
                                          myStatusModel!.updates.reduce(
                                            (a, b) =>
                                                a.createdAt.isAfter(b.createdAt)
                                                ? a
                                                : b,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: showImageOptions,
                                child: Image.asset(
                                  "images/add_status.png",
                                  width: 22.0,
                                  height: 22.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 15.0),
                        Expanded(
                          child: GestureDetector(
                            onTap: hasMyStatus ? null : showImageOptions,
                            onLongPress: hasMyStatus
                                ? () async {
                                    final token = await mySaveValues.getString(
                                      AppPreferenceHelper.AUTH_TOKEN,
                                    );
                                    if (token == null || !mounted) return;

                                    final confirmed = await showModalBottomSheet<bool>(
                                      context: context,
                                      backgroundColor: AppTheme.cardBg(isDark),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder: (ctx) => SafeArea(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            20,
                                            20,
                                            20,
                                            16,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Delete this status?',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme.textPrimary(
                                                    isDark,
                                                  ),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'This status will be removed for everyone.',
                                                style: GoogleFonts.poppins(
                                                  color: AppTheme.textSecondary(
                                                    isDark,
                                                  ),
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: OutlinedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      style: OutlinedButton.styleFrom(
                                                        side: BorderSide(
                                                          color:
                                                              AppTheme.divider(
                                                                isDark,
                                                              ),
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Cancel',
                                                        style: GoogleFonts.poppins(
                                                          color:
                                                              AppTheme.textPrimary(
                                                                isDark,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red.shade700,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Delete',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );

                                    if (confirmed != true || !mounted) return;

                                    final statusId =
                                        myStatusModel!.updates.first.id;
                                    final success =
                                        await StatusService.deleteStatus(
                                          token: token,
                                          statusId: statusId,
                                        );

                                    if (!mounted) return;

                                    if (success) {
                                      // ✅ Remove from Hive cache immediately
                                      await StatusCacheService.removeStatus(
                                        statusId,
                                      );

                                      // ✅ Socket event for real-time sync
                                      final socket =
                                          GlobalSocketService().socket;
                                      if (socket != null && socket.connected) {
                                        socket.emit('status_deleted', {
                                          'statusId': statusId,
                                        });
                                      }

                                      await _loadFreshOnly();
                                      if (mounted) {
                                        setState(() {});
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Status deleted successfully',
                                            ),
                                            backgroundColor: Color(0xFF1A7F4B),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Failed to delete status — check your connection',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "My status",
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary(isDark),
                                    fontSize: 17.0,
                                  ),
                                ),
                                // ✅ Shows "Posting… 47%" while upload runs
                                ValueListenableBuilder<double?>(
                                  valueListenable:
                                      StatusUploadManager().progress,
                                  builder: (_, progress, __) {
                                    if (progress != null && progress < 1.0) {
                                      return Text(
                                        'Posting… ${(progress * 100).toStringAsFixed(0)}%',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF1A7F4B),
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    }
                                    return Text(
                                      hasMyStatus
                                          ? _timeAgo(firstMyStatus!.createdAt)
                                          : "Tap to add status update",
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.textSecondary(isDark),
                                        fontSize: 14.0,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (hasMyStatus)
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.remove_red_eye_outlined,
                                  color: AppTheme.textHint(isDark),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${myStatusModel!.updates.fold(0, (sum, u) => sum + u.viewCount)}",
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textHint(isDark),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── RECENT UPDATES ──
                  if (otherStatuses.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 30.0,
                        left: 20.0,
                        bottom: 4,
                      ),
                      child: Text(
                        "Recent updates",
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary(isDark),
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _filteredOtherStatuses.length,
                      itemBuilder: (context, index) {
                        final status = _filteredOtherStatuses[index];
                        final latestUpdate = status.updates.first;
                        final hasSeen = _hasSeenAllUpdates(status);

                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StatusViewScreen(
                                  updates: status.updates,
                                  isMyStatus: false,
                                ),
                              ),
                            );
                            _loadLocallyViewedIds();
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 6.0,
                            ),
                            child: Row(
                              children: [
                                _buildStatusRing(
                                  hasStatus: true,
                                  hasSeen: hasSeen,
                                  statusModel: status,
                                  child: CircleAvatar(
                                    radius: 30.0,
                                    backgroundColor:
                                        latestUpdate.mediaType == 'text'
                                        ? Color(latestUpdate.backgroundColor)
                                        : HexColor("#2E2E2E"),
                                    backgroundImage:
                                        latestUpdate.mediaType != 'text' &&
                                            status
                                                .user
                                                .profilePicture
                                                .isNotEmpty
                                        ? NetworkImage(
                                            status.user.profilePicture,
                                          )
                                        : null,
                                    child: latestUpdate.mediaType == 'text'
                                        ? Text(
                                            (() {
                                              final t =
                                                  latestUpdate.media.isNotEmpty
                                                  ? latestUpdate.media
                                                  : (latestUpdate.caption ??
                                                        '');
                                              return t.length > 2
                                                  ? t
                                                        .substring(0, 2)
                                                        .toUpperCase()
                                                  : t.toUpperCase();
                                            })(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 15.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        status.user.username,
                                        style: GoogleFonts.poppins(
                                          color: AppTheme.textPrimary(isDark),
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      Text(
                                        _timeAgo(latestUpdate.createdAt),
                                        style: GoogleFonts.poppins(
                                          color: AppTheme.textSecondary(isDark),
                                          fontSize: 13.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!hasSeen)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF00C853),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  if (_filteredOtherStatuses.isEmpty && !isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No statuses match "$_searchQuery"'
                              : "No recent updates from contacts",
                          style: GoogleFonts.poppins(
                            color: AppTheme.textHint(isDark),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          // ✅ FIX: StatusUploadBanner wrapped in Positioned — NOT a bare Stack child.
          // A widget that internally returns Positioned must itself be inside Positioned.
          Positioned(
            top: MediaQuery.of(context).padding.top + 66,
            left: 16,
            right: 16,
            child: const StatusUploadBanner(),
          ),

          // ROBOT DISABLED: Robot animation widget temporarily hidden
          // AnimatedBuilder(
          //   animation: _robotAnimation,
          //   builder: (context, child) => Positioned(
          //     right: 20,
          //     top:
          //         MediaQuery.of(context).size.height * 0.48 -
          //         52 +
          //         _robotAnimation.value,
          //     child: GestureDetector(
          //       onTap: () async {
          //         if (_hasCompletedOnboarding) {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (_) => AIChatScreen(initialMessage: ""),
          //             ),
          //           );
          //         } else {
          //           final result = await Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (_) => const AIOnboardingScreen(),
          //             ),
          //           );
          //           if (result == true || result == null) {
          //             await mySaveValues.saveBool(
          //               AppPreferenceHelper.AI_ONBOARDING_COMPLETED,
          //               true,
          //             );
          //             setState(() => _hasCompletedOnboarding = true);
          //           }
          //         }
          //       },
          //       child: ClipOval(
          //         child: Image.asset(
          //           "images/robot.png",
          //           width: 45,
          //           height: 45,
          //           fit: BoxFit.cover,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          // ── Text status FAB ──
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.5 - 10,
            child: _buildFAB(
              size: 45,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTextStatusScreen(),
                  ),
                );
                if (result == true && mounted) {
                  await _loadFreshOnly();
                  setState(() {});
                }
              },
              child: Icon(Icons.edit, color: Colors.white, size: 15),
            ),
          ),

          // ── Camera FAB ──
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.6 - 18,
            child: _buildFAB(
              size: 60,
              onPressed: showImageOptions,
              child: Image.asset(
                "images/camera_add.png",
                width: 30,
                height: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB({
    required double size,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [HexColor("#FF00A8"), HexColor("#00D1FF")],
        ),
        boxShadow: [
          BoxShadow(
            color: HexColor("#FB8830").withOpacity(0.6),
            offset: const Offset(4, 4),
            blurRadius: 13,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            offset: const Offset(-4, -4),
            blurRadius: 5,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1B1B1B)
                : const Color(0xFF4D3C2F),
          ),
          child: FloatingActionButton(
            heroTag: null,
            onPressed: onPressed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            splashColor: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }
}
