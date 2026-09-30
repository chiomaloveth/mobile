import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/model/community_model.dart';
import 'package:qik_talk/features/chat/general/services/community_api_service/community_api_service.dart';
import 'package:qik_talk/features/community/screens/create_new_community_screen.dart';
import 'package:qik_talk/features/community/services/community_cache_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';
import 'package:video_player/video_player.dart';
import '../screens/community_details_screen.dart';

class CommunitiesComponent extends StatefulWidget {
  const CommunitiesComponent({super.key});

  @override
  State<CommunitiesComponent> createState() => _CommunitiesComponentState();
}

class _CommunitiesComponentState extends State<CommunitiesComponent>
    with WidgetsBindingObserver {
  final CommunityApiService _api = CommunityApiService();

  // Static cache so data survives tab switches — no re-fetch needed
  static List<CommunityModel> _cachedCommunities = [];
  static bool _hasLoaded = false;

  List<CommunityModel> _communities = [];
  bool _isLoading = false;
  final Map<String, String> _renamedCommunities = {};
  final Map<String, VideoPlayerController> _videoControllers = {};
  final MediaCacheService _mediaCache = MediaCacheService();
  Timer? _refreshTimer;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    for (final c in _videoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadInBackground();
    }
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (mounted) _loadInBackground();
    });
    if (_hasLoaded && _cachedCommunities.isNotEmpty) {
      // Memory cache hit — show immediately, refresh silently
      _communities = List.from(_cachedCommunities);
      _isLoading = false;
      _loadInBackground();
    } else {
      // Try persistent cache first so we never show empty screen offline
      _loadFromCache().then((_) {
        // Then try the network (updates in background if prefs data was shown)
        if (_communities.isNotEmpty) {
          _loadInBackground();
        } else {
          _load();
        }
      });
    }
  }

  /// Loads communities persisted to local storage — works fully offline.
  Future<void> _loadFromCache() async {
    try {
      final items = await CommunityCacheService.loadCommunities();
      if (items.isNotEmpty && mounted) {
        CommunityCacheService.prewarmCommunityMedia(items);
        setState(() {
          _communities = items;
          _cachedCommunities = items;
          _hasLoaded = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ _loadFromCache communities: $e');
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await _api.getMyCommunities();
      if (!mounted) return;
      if (result.isNotEmpty) {
        _cachedCommunities = result;
        _hasLoaded = true;
        await CommunityCacheService.saveCommunities(result);
        CommunityCacheService.prewarmCommunityMedia(result);
      }
      setState(() {
        if (result.isNotEmpty) _communities = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ _load communities: $e');
      if (!mounted) return;
      // Don't wipe existing data — Hive/prefs data stays on screen
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadInBackground() async {
    try {
      final result = await _api.getMyCommunities();
      if (!mounted) return;
      if (result.isNotEmpty) {
        _cachedCommunities = result;
        _hasLoaded = true;
        await CommunityCacheService.saveCommunities(result);
        CommunityCacheService.prewarmCommunityMedia(result);
        setState(() => _communities = result);
      }
    } catch (e) {
      // Offline — keep showing whatever is on screen
      debugPrint('⚠️ background refresh communities (offline): $e');
    }
  }

  bool _isVideoUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.contains('/video/upload/') ||
        url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.webm');
  }

  void _initVideoForCommunity(String communityId, String videoUrl) {
    if (_videoControllers.containsKey(communityId)) return;

    () async {
      VideoPlayerController? controller;
      try {
        final cachedPath = _mediaCache.getCachedPath(videoUrl);
        controller = cachedPath != null && File(cachedPath).existsSync()
            ? VideoPlayerController.file(File(cachedPath))
            : VideoPlayerController.networkUrl(Uri.parse(videoUrl));

        await controller.initialize();
        if (!mounted) {
          controller.dispose();
          return;
        }

        await controller.setLooping(true);
        await controller.setVolume(0.0);
        await controller.play();
        _videoControllers[communityId] = controller;
        setState(() {});

        Future.delayed(const Duration(milliseconds: 300), () {
          controller?.setVolume(0.0);
        });

        _mediaCache.cacheMedia(url: videoUrl, mediaType: 'video');
      } catch (e) {
        debugPrint('⚠️ community video init failed: $e');
        controller?.dispose();
      }
    }();
  }

  String _absoluteUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

  String _imageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return _absoluteUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: NO Scaffold here — ChatFragment already provides one.
    // Having a nested Scaffold causes back-button crashes and navigator issues.
    return Stack(
      children: [
        if (_isLoading && _communities.isEmpty)
          Center(child: CircularProgressIndicator(color: HexColor('#FB8830')))
        else
          _communities.isEmpty ? _buildEmpty() : _buildList(),
      ],
    );
  }

  Widget _buildEmpty() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Column(
          children: [
            Icon(
              Icons.people_outline,
              color: AppTheme.textHint(isDark),
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              'No communities yet',
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create one to organise your groups',
              style: GoogleFonts.poppins(
                color: AppTheme.textHint(isDark),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 130),
      itemCount: _communities.length,
      itemBuilder: (_, i) => _buildCard(_communities[i]),
    );
  }

  Widget _buildCard(CommunityModel c) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bgUrl = c.communityBackground?.isNotEmpty == true
        ? c.communityBackground!
        : c.chatImage ?? '';
    final mediaUrl = _absoluteUrl(bgUrl);
    final isVideo = _isVideoUrl(mediaUrl);
    final imageUrl = _imageUrl(isVideo ? null : mediaUrl);

    if (isVideo && mediaUrl.isNotEmpty) {
      _initVideoForCommunity(c.id, mediaUrl);
    }

    final videoController = _videoControllers[c.id];
    final desc = c.displayDescription;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CommunityDetailsScreen(communityId: c.id, initialCommunity: c),
          ),
        );
        if (result is String && result.isNotEmpty) {
          final updated = c.copyWith(chatName: result);
          setState(() {
            _renamedCommunities[c.id] = result;
            _communities = _communities
                .map((item) => item.id == c.id ? updated : item)
                .toList();
            _cachedCommunities = _cachedCommunities
                .map((item) => item.id == c.id ? updated : item)
                .toList();
          });
        }
        await _load();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: isVideo
                        ? (videoController != null &&
                                  videoController.value.isInitialized
                              ? ClipRect(
                                  child: OverflowBox(
                                    maxWidth: double.infinity,
                                    maxHeight: double.infinity,
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: videoController.value.size.width,
                                        height:
                                            videoController.value.size.height,
                                        child: VideoPlayer(videoController),
                                      ),
                                    ),
                                  ),
                                )
                              : _placeholder())
                        : (imageUrl.isNotEmpty
                              ? OfflineCachedImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 150,
                                  borderRadius: BorderRadius.zero,
                                  placeholder: _placeholder(),
                                  errorWidget: _placeholder(),
                                )
                              : _placeholder()),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.3, 1.0],
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 14,
                    right: 14,
                    child: Text(
                      _capitalizeWords(_renamedCommunities[c.id] ?? c.chatName),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (desc.isNotEmpty) ...[
                    Text(
                      desc,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary(isDark),
                        fontSize: 13,
                        height: 1.55,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'images/community_image.png',
                            width: 17,
                            height: 17,
                            color: AppTheme.textSecondary(isDark),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${c.memberCount} member${c.memberCount == 1 ? '' : 's'}',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary(isDark),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.border(isDark)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'View All',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 190,
      width: double.infinity,
      color: HexColor('#2A2A2A'),
      child: Icon(Icons.people, color: HexColor('#3A3A3A'), size: 60),
    );
  }
}
