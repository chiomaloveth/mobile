import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/status/services/status_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../model/my_status_model.dart';
import '../screens/status_viewers_sheet.dart';
import '../services/status_service.dart';
import '../components/status_cached_avatar.dart';
import '../../../utilities/constants/app_theme.dart';
import '../../../utilities/database/save_values.dart';
import '../../../utilities/services/app_pref_helper.dart';
import '../../../utilities/services/global_socket_service.dart';
import '../../feed/presentation/screens/widget/text_overlay_widget.dart';
import '../../feed/data/models/text_overlay_model.dart';

class StatusViewScreen extends StatefulWidget {
  final List<Update> updates;
  final bool isMyStatus;

  const StatusViewScreen({
    super.key,
    required this.updates,
    this.isMyStatus = false,
  });

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  late AnimationController _progressController;
  final SaveValues _saveValues = SaveValues();

  // ── State flags ──
  Set<String> _viewedThisSession = {};
  bool _isPaused = false;
  bool _videoError = false;
  bool _videoLoading = false;
  bool _isDisposed = false;

  // ── Reply state ──
  final TextEditingController _replyController = TextEditingController();
  bool _isReplying = false; // whether the reply input is visible
  bool _isSendingReply = false;

  // ── Reshare state ──
  bool _isResharing = false;

  // ── Delete state ──
  bool _isDeleting = false;

  // ✅ Media caching to prevent reloading
  final Map<String, dynamic> _mediaCache = {};

  static const Duration imageDuration = Duration(seconds: 5);

  Update get _currentStatus => widget.updates[_currentIndex];

  List<Viewer> get _allViewers {
    final Map<String, Viewer> seen = {};
    for (final update in widget.updates) {
      for (final v in update.viewers) {
        seen[v.id] = v;
      }
    }
    return seen.values.toList();
  }

  int get _totalViewCount {
    int count = 0;
    for (final update in widget.updates) {
      final live = _liveViewCounts[update.id];
      count += live != null
          ? (live > update.viewCount ? live : update.viewCount)
          : update.viewCount;
    }
    return count;
  }

  // ✅ Track live viewer counts per statusId
  final Map<String, int> _liveViewCounts = {};

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(
          vsync: this,
          duration: imageDuration,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted && !_isDisposed) {
            _goToNext();
          }
        });

    _loadCurrentStatus();
    if (!widget.isMyStatus) _markCurrentAsViewed();
    if (widget.isMyStatus) _setupViewerSocketListener();
  }

  void _setupViewerSocketListener() {
    final socket = GlobalSocketService().socket;
    if (socket == null || !socket.connected) return;
    socket.off('status viewed');
    socket.on('status viewed', (data) {
      final statusId =
          data['statusId']?.toString() ?? data['status']?.toString() ?? '';
      if (!mounted) return;
      setState(() {
        _liveViewCounts[statusId] = (_liveViewCounts[statusId] ?? 0) + 1;
      });
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _progressController.dispose();
    _replyController.dispose();
    final ctrl = _videoController;
    _videoController = null;
    _mediaCache.clear();
    Future.microtask(() {
      try {
        ctrl?.pause();
        ctrl?.dispose();
      } catch (_) {}
    });
    GlobalSocketService().socket?.off('status viewed');
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // VIEW TRACKING
  // ─────────────────────────────────────────────

  Future<void> _markCurrentAsViewed() async {
    final statusId = _currentStatus.id;
    if (_viewedThisSession.contains(statusId)) return;
    _viewedThisSession.add(statusId);

    // ✅ Persist locally so the ring turns grey immediately on back-press
    final prefs = await SharedPreferences.getInstance();
    final viewed = prefs.getStringList('viewed_status_ids') ?? [];
    if (!viewed.contains(statusId)) {
      viewed.add(statusId);
      await prefs.setStringList('viewed_status_ids', viewed);
    }

    // ✅ Tell the backend — adds current userId to viewers array
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      if (token != null) await StatusService.markAsViewed(token, statusId);
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  // MEDIA LOADING
  // ─────────────────────────────────────────────

  Future<void> _loadCurrentStatus() async {
    if (_isDisposed) return;

    // ✅ Cache key — skip full reload if same status
    final cacheKey = _currentStatus.id;

    _progressController.reset();
    _isPaused = false;
    _videoError = false;

    //// No controller caching — always create fresh to avoid disposed controller crashes

    final oldCtrl = _videoController;
    _videoController = null;
    Future.microtask(() {
      try {
        oldCtrl?.pause();
        oldCtrl?.dispose();
      } catch (_) {}
    });
    _videoLoading = false;

    final status = _currentStatus;
    debugPrint("Loading status: ${status.mediaType} — ${status.media}");

    if (status.mediaType == 'text') {
      _progressController.duration = imageDuration;
      if (mounted && !_isDisposed) {
        setState(() {});
        _progressController.forward();
      }
      return;
    }

    if (status.mediaType == 'reshare') {
      _progressController.duration = imageDuration;
      final ref = status.resharedFrom;
      if (ref != null && ref.mediaType == 'text') {
      } else {
        // Image reshares — start progress immediately
        if (mounted && !_isDisposed) {
          setState(() => _videoLoading = false);
          _progressController.forward();
        }
      }
      return;
    }

    if (status.mediaType == 'image') {
      _progressController.duration = imageDuration;
      // Progress bar starts in _buildMedia frameBuilder after image renders
      if (mounted && !_isDisposed) {
        setState(() => _videoLoading = false);
      }
      return;
    }

    if (status.mediaType == 'video') {
      if (status.media.isEmpty) {
        debugPrint("❌ Video URL is empty!");
        _goToNext();
        return;
      }

      if (mounted && !_isDisposed) setState(() => _videoLoading = true);

      try {
        final cachedPath = await StatusCacheService.localMediaPath(
          status.media,
        );
        _videoController = cachedPath != null && File(cachedPath).existsSync()
            ? VideoPlayerController.file(File(cachedPath))
            : VideoPlayerController.networkUrl(Uri.parse(status.media));

        await _videoController!.initialize().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('Video load timed out — possibly offline');
          },
        );

        final duration = _videoController!.value.duration;

        if (!mounted) return;

        _progressController.duration = duration == Duration.zero
            ? const Duration(seconds: 10)
            : duration;

        _videoController!.addListener(() {
          if (!mounted || _isDisposed) return;
          final ctrl = _videoController;
          if (ctrl == null) return;
          final pos = ctrl.value.position;
          final dur = ctrl.value.duration;

          if (dur > Duration.zero && pos >= dur) _goToNext();

          if (ctrl.value.hasError) {
            setState(() {
              _videoError = true;
              _videoLoading = false;
            });
          }
        });

        if (_isDisposed) {
          _videoController?.dispose();
          _videoController = null;
          return;
        }
        if (!mounted) return;
        setState(() => _videoLoading = false);
        _videoController!.play();
        _progressController.forward();
        StatusCacheService.cacheMediaNow(status.media, mediaType: 'video');
      } catch (e) {
        debugPrint("❌ Video init error: $e");
        if (mounted && !_isDisposed) {
          setState(() {
            _videoError = true;
            _videoLoading = false;
          });
        }
      }
    }
  }

  // ─────────────────────────────────────────────
  // NAVIGATION
  // ─────────────────────────────────────────────

  void _goToNext() {
    if (!mounted || _isDisposed) return;
    if (_currentIndex < widget.updates.length - 1) {
      setState(() => _currentIndex++);
      _loadCurrentStatus();
      if (!widget.isMyStatus) _markCurrentAsViewed();
    } else {
      // ✅ Use SchedulerBinding to defer pop until after current frame
      // prevents '!_debugLocked' assertion when animation fires during transition
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _goToPrevious() {
    if (!mounted) return;
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _loadCurrentStatus();
    }
  }

  // ─────────────────────────────────────────────
  // GESTURES
  // ─────────────────────────────────────────────

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() => _isPaused = true);
    _progressController.stop();
    try {
      _videoController?.pause();
    } catch (_) {}
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() => _isPaused = false);
    _progressController.forward();
    try {
      _videoController?.play();
    } catch (_) {}
  }

  void _handleTap(TapUpDetails details) {
    if (_isDisposed || !mounted) return;
    if (_isReplying) {
      setState(() => _isReplying = false);
      FocusScope.of(context).unfocus();
      _progressController.forward();
      _videoController?.play();
      return;
    }
    if (_isPaused) return;
    final screenWidth = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < screenWidth / 2) {
      _goToPrevious();
    } else {
      _goToNext();
    }
  }

  // ─────────────────────────────────────────────
  // REPLY
  // ─────────────────────────────────────────────

  void _openReply() {
    _progressController.stop();
    _videoController?.pause();
    _showReplySheet();
  }

  /// Shows a WhatsApp-style reply bottom sheet:
  ///   - status preview card at top (blurred, non-interactive)
  ///   - text input + send below
  void _showReplySheet() {
    _replyController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Handle bar ──
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // ── Status preview ──
                _buildReplyPreviewCard(),

                const Divider(color: Colors.white12, height: 1),

                // ── Input row ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 120),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: TextField(
                            controller: _replyController,
                            autofocus: true,
                            maxLines: null,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Reply to ${_currentStatus.user.username}…',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      StatefulBuilder(
                        builder: (ctx2, setBtn) {
                          return GestureDetector(
                            onTap: _isSendingReply
                                ? null
                                : () async {
                                    Navigator.pop(ctx);
                                    await _sendReply();
                                  },
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A7F4B),
                                shape: BoxShape.circle,
                              ),
                              child: _isSendingReply
                                  ? const Padding(
                                      padding: EdgeInsets.all(11),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      // Resume playback when sheet is dismissed without sending
      if (mounted && !_isSendingReply) {
        _progressController.forward();
        _videoController?.play();
      }
    });
  }

  /// The status preview card shown inside the reply sheet
  Widget _buildReplyPreviewCard() {
    final s = _currentStatus;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── "Replying to status" label ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                const Icon(Icons.reply, color: Color(0xFF1A7F4B), size: 14),
                const SizedBox(width: 6),
                Text(
                  "Replying to ${s.user.username}'s status",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1A7F4B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ── Media thumbnail / text preview ──
          if (s.mediaType == 'image' && s.media.isNotEmpty)
            Image.network(
              s.media,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 60,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white38,
                    size: 28,
                  ),
                ),
              ),
            )
          else if (s.mediaType == 'video')
            Container(
              height: 80,
              color: Colors.black,
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white54,
                  size: 36,
                ),
              ),
            )
          else if (s.mediaType == 'text')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Color(s.backgroundColor),
              child: Text(
                s.media.isNotEmpty ? s.media : (s.caption ?? ''),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // ── Caption ──
          if (s.caption != null &&
              s.caption!.isNotEmpty &&
              s.mediaType != 'text')
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Text(
                s.caption!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSendingReply = true);

    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      if (token == null) throw Exception('Not authenticated');

      final statusOwner = _currentStatus.user;

      // ✅ Step 1: Ensure the DM chat exists (creates it if not)
      final chatId = await StatusService.ensureChat(
        token: token,
        otherUserId: statusOwner.id,
      );

      if (chatId == null) throw Exception('Could not open chat');

      // ✅ Step 2: Send the reply with status preview metadata
      final messageId = await StatusService.replyToStatus(
        token: token,
        chatId: chatId,
        replyText: text,
        statusId: _currentStatus.id,
        statusOwnerName: statusOwner.username,
        statusMediaType: _currentStatus.mediaType,
        statusMedia: _currentStatus.media,
        statusCaption: _currentStatus.caption ?? '',
      );

      if (!mounted) return;

      if (messageId != null) {
        _replyController.clear();
        setState(() {
          _isReplying = false;
          _isSendingReply = false;
        });
        FocusScope.of(context).unfocus();

        // Resume playback
        _progressController.forward();
        _videoController?.play();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reply sent to ${statusOwner.username}'),
            backgroundColor: const Color(0xFF1A7F4B),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to send reply');
      }
    } catch (e) {
      debugPrint('❌ Reply error: $e');
      if (mounted) {
        setState(() => _isSendingReply = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reply: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // RESHARE
  // ─────────────────────────────────────────────

  Future<void> _reshareStatus() async {
    // Prevent double-tap
    if (_isResharing) return;

    // Confirm with the user
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppTheme.cardBg(
        Theme.of(context).brightness == Brightness.dark,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reshare to your status?',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "This will add ${_currentStatus.user.username}'s status to your own. "
                "The original poster will be credited.",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A7F4B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reshare',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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

    setState(() => _isResharing = true);
    _progressController.stop();
    _videoController?.pause();

    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      if (token == null) throw Exception('Not authenticated');

      // ✅ Use the root original statusId if this is already a reshare
      final originalId = _currentStatus.isReshare
          ? (_currentStatus.resharedFrom?.statusId ?? _currentStatus.id)
          : _currentStatus.id;

      final success = await StatusService.reshareStatus(
        token: token,
        originalStatusId: originalId,
      );

      if (!mounted) return;

      setState(() => _isResharing = false);

      if (success) {
        _progressController.forward();
        _videoController?.play();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reshared to your status!'),
            backgroundColor: Color(0xFF1A7F4B),
          ),
        );
      } else {
        throw Exception('Reshare failed');
      }
    } catch (e) {
      debugPrint('❌ Reshare error: $e');
      if (mounted) {
        setState(() => _isResharing = false);
        _progressController.forward();
        _videoController?.play();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reshare: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────

  Future<void> _deleteCurrentStatus() async {
    // Hard guard — if already deleting from any code path, bail immediately
    if (_isDeleting) return;
    setState(() => _isDeleting = true); // lock BEFORE showing the sheet

    _progressController.stop();
    _videoController?.pause();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete this status?',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This status will be removed for everyone.',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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

    if (confirmed != true || !mounted) {
      // User cancelled — release the lock and resume playback
      setState(() => _isDeleting = false);
      _progressController.forward();
      _videoController?.play();
      return;
    }

    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      if (token == null) throw Exception('Not authenticated');

      final statusId = _currentStatus.id;

      final success = await StatusService.deleteStatus(
        token: token,
        statusId: statusId,
      );

      if (!mounted) return;

      if (success) {
        // ✅ Remove from local Hive cache immediately
        await StatusCacheService.removeStatus(statusId);

        // ✅ Emit socket event for real-time sync across sessions
        final socket = GlobalSocketService().socket;
        if (socket != null && socket.connected) {
          socket.emit('status_deleted', {'statusId': statusId});
        }

        setState(() => _isDeleting = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status deleted successfully'),
            backgroundColor: Color(0xFF1A7F4B),
            duration: Duration(seconds: 2),
          ),
        );

        // ✅ Pop and signal caller to refresh
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, 'deleted');
        }
      } else {
        throw Exception('Delete failed — server returned error');
      }
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      if (mounted) {
        setState(() => _isDeleting = false);
        _progressController.forward();
        _videoController?.play();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: _handleTap,
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        child: Stack(
          children: [
            // ── Full-screen media ──
            Positioned.fill(child: _buildMedia()),

            // ── Text Overlays (Stories) ──
            if (_currentStatus.overlays.isNotEmpty)
              ..._currentStatus.overlays.map((json) {
                try {
                  final overlay = TextOverlay.fromJson(
                    Map<String, dynamic>.from(json),
                  );

                  // ── Ensure overlays stay below the progress bars and user info ──
                  final topPadding = MediaQuery.of(context).padding.top;
                  const safetyMargin = 90.0;
                  final safeThreshold = topPadding + safetyMargin;

                  final clampedOverlay = overlay.copyWith(
                    position: Offset(
                      overlay.position.dx,
                      overlay.position.dy < safeThreshold
                          ? safeThreshold
                          : overlay.position.dy,
                    ),
                  );

                  return TextOverlayWidget(overlay: clampedOverlay);
                } catch (e) {
                  return const SizedBox.shrink();
                }
              }).toList(),

            // ── Pause overlay (WhatsApp-style: no icon shown) ──
            if (_isPaused)
              Positioned.fill(child: Container(color: Colors.black26)),

            // ── Top bar ──
            Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

            // ── Bottom bar (reply / views / reshare) ──
            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MEDIA WIDGET
  // ─────────────────────────────────────────────

  Widget _buildMedia() {
    // ── IMAGE ──
    if (_currentStatus.mediaType == 'image') {
      final cacheKey = _currentStatus.media;

      // ✅ Helper: build an Image widget from any ImageProvider with frameBuilder
      Widget _imageWithProgress(ImageProvider provider) {
        return Image(
          image: provider,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted &&
                    !_isDisposed &&
                    !_isPaused &&
                    !_progressController.isAnimating) {
                  _progressController.forward();
                }
              });
            }
            return child;
          },
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 60),
          ),
        );
      }

      // 1️⃣ In-memory cache (fastest)
      if (_mediaCache.containsKey(cacheKey)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              !_isDisposed &&
              !_isPaused &&
              !_progressController.isAnimating) {
            _progressController.forward();
          }
        });
        return _imageWithProgress(_mediaCache[cacheKey] as ImageProvider);
      }

      // 2️⃣ Disk cache from StatusCacheService (works offline)
      return FutureBuilder<String?>(
        future: StatusCacheService.localMediaPath(cacheKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            // Offline — use local file
            final provider = FileImage(File(snapshot.data!));
            _mediaCache[cacheKey] = provider; // promote to memory cache
            return _imageWithProgress(provider);
          }

          // 3️⃣ Network load (online)
          return Image.network(
            cacheKey,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            cacheWidth: 1440,
            cacheHeight: 2560,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame != null) {
                // Cache in memory for this session
                _mediaCache[cacheKey] = NetworkImage(cacheKey);
                StatusCacheService.cacheMediaNow(cacheKey, mediaType: 'image');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted &&
                      !_isDisposed &&
                      !_isPaused &&
                      !_progressController.isAnimating) {
                    _progressController.forward();
                  }
                });
              }
              return child;
            },
            errorBuilder: (_, __, ___) {
              // Network failed — show broken image icon
              return const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 60,
                ),
              );
            },
          );
        },
      );
    }

    // ── VIDEO ──
    if (_currentStatus.mediaType == 'video') {
      if (_videoLoading) {
        // Silent loading for own status, subtle indicator for others
        return Center(
          child: widget.isMyStatus
              ? const SizedBox.shrink() // invisible — loads silently
              : const CircularProgressIndicator(color: Colors.white),
        );
      }
      if (_videoError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white54, size: 60),
              const SizedBox(height: 12),
              const Text(
                "Could not play video",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadCurrentStatus,
                child: const Text(
                  "Retry",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }
      if (!_isDisposed &&
          _videoController != null &&
          _videoController!.value.isInitialized) {
        return Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        );
      }
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // ── TEXT ──
    if (_currentStatus.mediaType == 'text') {
      // Prefer media field; fall back to caption if media is empty
      // (some backend responses store text in caption instead of media)
      final textContent = _currentStatus.media.trim().isNotEmpty
          ? _currentStatus.media
          : (_currentStatus.caption ?? '');

      debugPrint(
        'TEXT STATUS content: "$textContent"  '
        'media="${_currentStatus.media}"  '
        'caption="${_currentStatus.caption}"  '
        'bgColor=${_currentStatus.backgroundColor}',
      );

      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(_currentStatus.backgroundColor),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: textContent.isEmpty
            ? const Text(
                '(empty status)',
                style: TextStyle(color: Colors.white38, fontSize: 16),
              )
            : Text(
                textContent,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
      );
    }

    // ── RESHARE ──
    if (_currentStatus.mediaType == 'reshare' || _currentStatus.isReshare) {
      final ref = _currentStatus.resharedFrom;
      if (ref == null) {
        return const Center(
          child: Icon(Icons.repeat, color: Colors.white54, size: 60),
        );
      }

      // Show the original media with an attribution banner overlay
      Widget mediaWidget;
      if (ref.mediaType == 'image') {
        final cacheKey = ref.media;

        // ✅ Check cache for reshared image
        if (_mediaCache.containsKey(cacheKey)) {
          mediaWidget = Image(
            image: _mediaCache[cacheKey] as ImageProvider,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 60),
            ),
          );
          if (mounted && _videoLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _videoLoading) {
                setState(() => _videoLoading = false);
                _progressController.forward();
              }
            });
          }
        } else {
          mediaWidget = FutureBuilder<String?>(
            future: StatusCacheService.localMediaPath(cacheKey),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                final provider = FileImage(File(snapshot.data!));
                _mediaCache[cacheKey] = provider;
                return Image(
                  image: provider,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 60,
                    ),
                  ),
                );
              }

              return Image.network(
                ref.media,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                cacheWidth: 1440,
                cacheHeight: 2560,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame != null && !wasSynchronouslyLoaded) {
                    _mediaCache[cacheKey] = NetworkImage(ref.media);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _videoLoading) {
                        setState(() => _videoLoading = false);
                        _progressController.forward();
                      }
                    });
                    StatusCacheService.cacheMediaNow(
                      ref.media,
                      mediaType: 'image',
                    );
                  }
                  return child;
                },
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 60,
                  ),
                ),
              );
            },
          );
        }
      } else if (ref.mediaType == 'text') {
        mediaWidget = Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF1A1A1A),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            ref.media,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      } else {
        // Video reshare — show a placeholder (full video reshare playback
        // requires loading the video URL from resharedFrom.media)
        mediaWidget = Container(
          color: Colors.black,
          child: const Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white54,
              size: 72,
            ),
          ),
        );
      }

      return Stack(
        children: [
          Positioned.fill(child: mediaWidget),
          // ✅ Attribution chip
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.repeat, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Originally from ${ref.ownerUsername}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  // ─────────────────────────────────────────────
  // TOP BAR
  // ─────────────────────────────────────────────

  Widget _buildTopBar() {
    return GestureDetector(
      onTap: () {},
      onTapDown: (_) {},
      onTapUp: (_) {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          right: 12,
          bottom: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProgressBars(),
            const SizedBox(height: 14),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 10),
                StatusCachedAvatar(
                  imageUrl: _currentStatus.user.profilePicture,
                  fallbackText: _currentStatus.user.username,
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentStatus.user.username,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _timeAgo(_currentStatus.createdAt),
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BOTTOM BAR  ← main change: reply + reshare
  // ─────────────────────────────────────────────

  Widget _buildBottomBar() {
    return GestureDetector(
      // Absorb ALL taps in the bottom bar so they never reach the
      // full-screen background detector that calls _handleTap / _goToNext
      onTap: () {},
      onTapDown: (_) {},
      onTapUp: (_) {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 12,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Caption (non-text statuses only) ──
            if (_currentStatus.mediaType != 'text' &&
                _currentStatus.caption != null &&
                _currentStatus.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _currentStatus.caption!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Owner view: viewers count + delete ──
            if (widget.isMyStatus)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Eye / viewers pill ──
                  GestureDetector(
                    onTap: () async {
                      _progressController.stop();
                      _videoController?.pause();
                      await showModalBottomSheet(
                        context: context,
                        backgroundColor: AppTheme.cardBg(
                          Theme.of(context).brightness == Brightness.dark,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        isScrollControlled: true,
                        builder: (_) => StatusViewersSheet(
                          viewers: _allViewers,
                          totalUpdates: _totalViewCount,
                          statusId: _currentStatus.id,
                          socket: GlobalSocketService().socket,
                        ),
                      );
                      if (mounted) {
                        _progressController.forward();
                        _videoController?.play();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_totalViewCount',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Delete pill ──
                  GestureDetector(
                    // absorb the tap so it never reaches the full-screen
                    // background GestureDetector (_handleTap / _goToNext)
                    onTapDown: (_) {},
                    onTap: _isDeleting
                        ? null
                        : () async {
                            // Extra guard: ignore if already in-flight
                            if (_isDeleting) return;
                            await _deleteCurrentStatus();
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _isDeleting
                            ? Colors.grey.shade800
                            : Colors.red.shade900.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.red.shade700),
                      ),
                      child: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Delete',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),

            // ── Viewer: reply / reshare action row ──
            if (!widget.isMyStatus) _buildViewerActions(),
          ],
        ),
      ), // closes Container
    ); // closes GestureDetector
  }

  Widget _buildReplyInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24),
            ),
            child: TextField(
              controller: _replyController,
              autofocus: true,
              maxLines: 3,
              minLines: 1,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Reply to ${_currentStatus.user.username}…',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // ── Send button ──
        GestureDetector(
          onTap: _isSendingReply ? null : _sendReply,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _isSendingReply ? Colors.grey : const Color(0xFF1A7F4B),
              shape: BoxShape.circle,
            ),
            child: _isSendingReply
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 6),
        // ── Cancel button ──
        GestureDetector(
          onTap: () {
            setState(() => _isReplying = false);
            FocusScope.of(context).unfocus();
            _progressController.forward();
            _videoController?.play();
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildViewerActions() {
    return Row(
      children: [
        // ── Reply pill ──
        Expanded(
          child: GestureDetector(
            onTap: _openReply,
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.reply, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Reply',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // ── Reshare button ──
        GestureDetector(
          onTap: _isResharing ? null : _reshareStatus,
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: _isResharing
                  ? Colors.grey.shade700
                  : const Color(0xFF1A7F4B).withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
            ),
            child: _isResharing
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.repeat, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Reshare',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // PROGRESS BARS
  // ─────────────────────────────────────────────

  Widget _buildProgressBars() {
    return Row(
      children: List.generate(widget.updates.length, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Stack(
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (index < _currentIndex)
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                else if (index == _currentIndex)
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        widthFactor: _progressController.value,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
