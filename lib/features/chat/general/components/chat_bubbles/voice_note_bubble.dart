import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'dart:convert';
import 'package:qik_talk/utilities/services/media_cache_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VoiceNoteBubble
//
// WhatsApp-style voice note with a clear 3-state machine:
//
//  State 1 — NOT DOWNLOADED
//    • Shows download ↓ icon
//    • Duration shows "0:10" (estimated or unknown)
//    • Flat waveform bars (grey, no interactivity)
//    • Tapping download button starts download
//
//  State 2 — DOWNLOADING
//    • Circular progress indicator replaces download icon
//    • "Downloading…" label
//    • Tap to cancel
//
//  State 3 — READY (downloaded)
//    • Play / Pause / Replay icon
//    • Live waveform via audio_waveforms
//    • Blue scrubber dot
//    • Plays from local file — never re-downloads
//    • Works fully offline
// ─────────────────────────────────────────────────────────────────────────────

enum _AudioState { notDownloaded, downloading, ready }

class VoiceNoteBubble extends StatefulWidget {
  final String audioUrl;
  final bool isMe;
  final bool isRead;
  final String timestamp;
  final bool isSaved;
  final String? replyToText;
  final bool? replyToIsMe;
  final String? replyToSenderName;
  final String? replyToMediaType;
  final String? replyToThumbnailUrl;
  final bool isForwarded;
  final MessageStatus? status;
  final VoidCallback? onReplyTap;
  final VoidCallback? onLongPress;
  final Function(String direction)? onSwipe;

  const VoiceNoteBubble({
    super.key,
    required this.audioUrl,
    required this.isMe,
    required this.isRead,
    required this.timestamp,
    this.isSaved = false,
    this.replyToText,
    this.replyToIsMe,
    this.replyToSenderName,
    this.replyToMediaType,
    this.replyToThumbnailUrl,
    this.isForwarded = false,
    this.status,
    this.onReplyTap,
    this.onLongPress,
    this.onSwipe,
  });

  @override
  State<VoiceNoteBubble> createState() => _VoiceNoteBubbleState();
}

class _VoiceNoteBubbleState extends State<VoiceNoteBubble> {
  // ── State machine ────────────────────────────────────────────────────────────
  _AudioState _audioState = _AudioState.notDownloaded;

  // ── Download ─────────────────────────────────────────────────────────────────
  double _downloadProgress = 0.0;
  bool _downloadCancelled = false;
  String? _localPath;

  // ── Playback ──────────────────────────────────────────────────────────────────
  AudioPlayer? _player;
  PlayerController? _waveController;

  bool _isPlaying = false;
  bool _isCompleted = false;
  bool _disposed = false;
  bool _waveReady = false;
  int _fileSizeBytes = 0;

  Duration _current = Duration.zero;
  Duration _total = Duration.zero;

  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;

  // ── Swipe ────────────────────────────────────────────────────────────────────
  bool _initializingPlayback = false;

  double _swipeOffset = 0;
  static const double _swipeThreshold = 50;

  // ── Init ─────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _checkCache();
    _resolveFileSize();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelStreams();
    _player?.stop().catchError((_) {}).whenComplete(() => _player?.dispose());
    _waveController?.stopPlayer().catchError((_) {});
    _waveController?.dispose();
    super.dispose();
  }

  void _cancelStreams() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
  }

  // ── Cache check — runs on mount, no download ─────────────────────────────────
  // If the file is already on disk we skip straight to the ready state.

  Future<void> _checkCache() async {
    // 1. Check MediaCacheService (persistent cache used by the rest of the app)
    final cached = MediaCacheService().getCachedPath(widget.audioUrl);
    if (cached != null && File(cached).existsSync()) {
      _localPath = cached;
      await _initPlayback(_localPath!);
      return;
    }

    // 2. Check our own temp-directory hash-named file
    if (widget.audioUrl.startsWith('http')) {
      final tempPath = await _buildTempPath(widget.audioUrl);
      if (File(tempPath).existsSync()) {
        _localPath = tempPath;
        await _initPlayback(_localPath!);
        return;
      }
    } else {
      // Already a local path (voice note just recorded by this user)
      _localPath = widget.audioUrl;
      await _initPlayback(_localPath!);
      return;
    }

    // 3. File not cached — show not-downloaded state
    if (mounted) setState(() => _audioState = _AudioState.notDownloaded);
  }

  // ── Download ──────────────────────────────────────────────────────────────────

  Future<void> _startDownload() async {
    if (_audioState == _AudioState.downloading) return;
    _downloadCancelled = false;

    if (mounted) {
      setState(() {
        _audioState = _AudioState.downloading;
        _downloadProgress = 0.0;
      });
    }

    try {
      final savePath = await _buildTempPath(widget.audioUrl);
      final uri = Uri.parse(widget.audioUrl);

      // Stream download so we can track progress
      final request = http.Request('GET', uri);
      final response = await request.send();

      final contentLength = response.contentLength ?? 0;
      final bytes = <int>[];
      int received = 0;

      await for (final chunk in response.stream) {
        if (_downloadCancelled) {
          // User cancelled — clean up partial file
          final partial = File(savePath);
          if (await partial.exists()) await partial.delete();
          if (mounted) setState(() => _audioState = _AudioState.notDownloaded);
          return;
        }
        bytes.addAll(chunk);
        received += chunk.length;
        if (contentLength > 0 && mounted) {
          setState(() => _downloadProgress = received / contentLength);
        }
      }

      await File(savePath).writeAsBytes(bytes);
      await MediaCacheService().registerCachedMedia(
        url: widget.audioUrl,
        localPath: savePath,
        mediaType: 'audio',
      );
      if (mounted) setState(() => _fileSizeBytes = bytes.length);
      debugPrint('✅ Voice note downloaded → $savePath');

      if (_downloadCancelled || !mounted) return;

      _localPath = savePath;
      await _initPlayback(savePath);
    } catch (e) {
      debugPrint('❌ Voice note download failed: $e');
      if (mounted) {
        setState(() => _audioState = _AudioState.notDownloaded);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Download failed. Tap to retry.'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _cancelDownload() {
    _downloadCancelled = true;
  }

  // ── Playback init (called after file is confirmed on disk) ───────────────────

  Future<void> _initPlayback(String path) async {
    if (_initializingPlayback || _disposed) return;
    _initializingPlayback = true;

    // ✅ Dispose any previous player instance before creating a new one
    // This prevents the "Loading interrupted" crash when widgets rebuild
    try {
      await _player?.stop();
      _player?.dispose();
      _player = null;
      _waveController?.dispose();
      _waveController = null;
    } catch (_) {}

    try {
      // ✅ Small delay prevents race condition when multiple bubbles init at once
      await Future.delayed(const Duration(milliseconds: 50));
      if (_disposed) return;

      final player = AudioPlayer();
      _player = player;

      // ✅ Set audio attributes BEFORE setting source — prevents abort exception
      await player.setAudioSource(
        AudioSource.file(path),
        preload: false, // ✅ Don't preload — only load when user taps play
      );

      if (_disposed) {
        player.dispose();
        return;
      }

      // ── audio_waveforms ────────────────────────────────────────────────
      final waveCtrl = PlayerController();
      _waveController = waveCtrl;

      await waveCtrl.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
        noOfSamples: 100,
      );
      await waveCtrl.stopPlayer();

      if (!mounted || _disposed) return;

      setState(() {
        _audioState = _AudioState.ready;
        _waveReady = true;
        _total = player.duration ?? Duration.zero;
      });

      // ── Listeners ───────────────────────────────────────────────────────────
      _durationSub = _player!.durationStream.listen((d) {
        if (d != null && mounted && !_disposed) {
          setState(() => _total = d);
        }
      });

      _positionSub = _player!.positionStream.listen((p) {
        if (!mounted || _disposed) return;
        setState(() => _current = p);
      });

      _stateSub = _player!.playerStateStream.listen((state) {
        if (!mounted || _disposed) return;
        if (state.processingState == ProcessingState.completed) {
          _handleCompletion();
        } else if (state.processingState == ProcessingState.ready) {
          setState(() {
            _isPlaying = state.playing;
            if (state.playing) _isCompleted = false;
          });
        }
      });
    } catch (e) {
      debugPrint('❌ Playback init failed: $e');
      if (mounted && !_disposed) {
        setState(() => _audioState = _AudioState.notDownloaded);
      }
    } finally {
      _initializingPlayback = false;
    }
  }

  // ── Completion handler ────────────────────────────────────────────────────────

  Future<void> _handleCompletion() async {
    if (_disposed) return;

    await _player?.stop().catchError((_) {});
    try {
      await _waveController?.stopPlayer();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isPlaying = false;
        _isCompleted = true;
        _current = Duration.zero;
      });
    }

    await Future.delayed(const Duration(milliseconds: 300), () {
      if (_disposed || !mounted) return;
      try {
        _waveController?.seekTo(0);
      } catch (_) {}
    });
  }

  // ── Play / Pause ──────────────────────────────────────────────────────────────

  Future<void> _handlePlayPause() async {
    if (_audioState != _AudioState.ready || _localPath == null) return;
    if (_player == null) return;

    try {
      if (_isPlaying) {
        await _player!.pause();
        _waveController?.pausePlayer();
      } else {
        // ✅ Handle preload:false — source is set but not loaded until play
        final needsReset =
            _isCompleted ||
            _player!.processingState == ProcessingState.completed ||
            _player!.processingState == ProcessingState.idle ||
            _player!.processingState == ProcessingState.loading; // ✅ add this

        if (needsReset) {
          await _player!.stop().catchError((_) {});
          await _player!.setAudioSource(
            AudioSource.file(_localPath!),
            preload: true, // ✅ Now load fully when user actually taps play
          );
          await _waveController?.preparePlayer(
            path: _localPath!,
            shouldExtractWaveform: false,
          );
          await _waveController?.stopPlayer();
          if (mounted)
            setState(() {
              _current = Duration.zero;
              _isCompleted = false;
            });
        }

        await _player!.play();
        _waveController?.startPlayer();
      }
    } catch (e) {
      debugPrint('❌ play/pause error: $e');
    }
  }

  Widget _buildStatusTicks(Color subtleColor) {
    if (widget.status == MessageStatus.sending) {
      return Icon(Icons.access_time_rounded, size: 12, color: subtleColor);
    }
    if (widget.status == MessageStatus.failed) {
      return const Icon(Icons.error_outline, size: 13, color: Colors.redAccent);
    }
    if (widget.status == MessageStatus.read || widget.isRead) {
      return _doubleTick(color: const Color(0xFF53BDEB));
    }
    if (widget.status == MessageStatus.delivered) {
      return _doubleTick(color: subtleColor);
    }
    // ✅ Explicit case for sent status (WhatsApp style)
    if (widget.status == MessageStatus.sent) {
      return Icon(Icons.check, size: 13, color: subtleColor);
    }
    // Fallback: Single grey tick
    return Icon(Icons.check, size: 13, color: subtleColor);
  }

  Widget _doubleTick({required Color color}) {
    return SizedBox(
      width: 18,
      height: 13,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(left: 0, child: Icon(Icons.check, size: 13, color: color)),
          Positioned(left: 5, child: Icon(Icons.check, size: 13, color: color)),
        ],
      ),
    );
  }
  Future<void> _resolveFileSize() async {
    try {
      if (!widget.audioUrl.startsWith('http')) {
        final file = File(widget.audioUrl);
        if (await file.exists()) {
          final size = await file.length();
          if (mounted) setState(() => _fileSizeBytes = size);
        }
        return;
      }

      final cached = MediaCacheService().getCachedPath(widget.audioUrl);
      if (cached != null && File(cached).existsSync()) {
        final size = await File(cached).length();
        if (mounted) setState(() => _fileSizeBytes = size);
        return;
      }

      final tempPath = await _buildTempPath(widget.audioUrl);
      if (await File(tempPath).exists()) {
        final size = await File(tempPath).length();
        if (mounted) setState(() => _fileSizeBytes = size);
        return;
      }

      final response = await http.head(Uri.parse(widget.audioUrl));
      final length = int.tryParse(response.headers['content-length'] ?? '');
      if (length != null && length > 0 && mounted) {
        setState(() => _fileSizeBytes = length);
      }
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Future<String> _buildTempPath(String url) async {
    final tempDir = await getTemporaryDirectory();
    final hash = md5.convert(utf8.encode(url)).toString();
    return '${tempDir.path}/voice_$hash.aac';
  }

  String _formatTime(String iso) {
    final d = DateTime.parse(iso).toLocal();
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _durationAndSizeLabel() {
    switch (_audioState) {
      case _AudioState.ready:
        if (_isCompleted && _total > Duration.zero) {
          return _formatDuration(_total);
        }
        if (_current > Duration.zero) {
          return _formatDuration(_current);
        }
        if (_total > Duration.zero) {
          return _formatDuration(_total);
        }
        return '0:00';
      case _AudioState.downloading:
        return 'Downloading…';
      case _AudioState.notDownloaded:
        final size = _formatFileSize(_fileSizeBytes);
        return size.isEmpty ? '0:00' : '0:00 · $size';
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _swipeOffset += details.delta.dx;
          _swipeOffset = _swipeOffset.clamp(-80.0, 80.0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_swipeOffset.abs() > _swipeThreshold && widget.onSwipe != null) {
          widget.onSwipe!(_swipeOffset > 0 ? 'right' : 'left');
        }
        setState(() => _swipeOffset = 0);
      },
      onLongPress: widget.onLongPress,
      child: Stack(
        children: [
          // ── Swipe reply icon ─────────────────────────────────────────────
          if (_swipeOffset.abs() > 10)
            Positioned(
              left: widget.isMe ? null : 10,
              right: widget.isMe ? 10 : null,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: (_swipeOffset.abs() / _swipeThreshold).clamp(0.0, 1.0),
                child: Icon(Icons.reply, color: HexColor('#1A7F4B'), size: 24),
              ),
            ),

          Transform.translate(
            offset: Offset(_swipeOffset, 0),
            child: Align(
              alignment: widget.isMe
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Builder(
                builder: (context) {
                  final bool isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final Color bubbleBg = isDark
                      ? (widget.isMe
                            ? HexColor('#1B1B1B')
                            : HexColor('#232323'))
                      : Colors.white;
                  final Color subtleColor = isDark
                      ? Colors.white70
                      : const Color(0xFF8A7060);
                  const List<BoxShadow> shadows = [];

                  return Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: bubbleBg,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(widget.isMe ? 18 : 4),
                        bottomRight: Radius.circular(widget.isMe ? 4 : 18),
                      ),
                      boxShadow: shadows,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Reply preview ──────────────────────────────────────
                        if (widget.isForwarded)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shortcut,
                                  size: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF8A7060),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Forwarded',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF8A7060),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.replyToText != null &&
                            widget.replyToText!.isNotEmpty)
                          _ReplyPreview(
                            text: widget.replyToText!,
                            isMe: widget.replyToIsMe ?? false,
                            senderName: widget.replyToSenderName,
                            mediaType: widget.replyToMediaType,
                            thumbnailUrl: widget.replyToThumbnailUrl,
                            onTap: widget.onReplyTap,
                          ),

                        // ── Voice note player row ──────────────────────────────
                        _buildPlayerRow(isDark),

                        const SizedBox(height: 4),

                        // ── Timestamp + ticks ──────────────────────────────────
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.isSaved) ...[
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              _formatTime(widget.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: subtleColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            if (widget.isMe) _buildStatusTicks(subtleColor),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Player row — switches between the 3 states ────────────────────────────────

  Widget _buildPlayerRow(bool isDark) {
    final Color playerBg = isDark
        ? const Color(0xFF39393D)
        : const Color(0xFFE8E0D8);
    final Color durationColor = isDark
        ? Colors.white70
        : const Color(0xFF6B5A4A);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: playerBg,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // ── Left button — changes per state ────────────────────────────
          _buildLeftButton(isDark),

          const SizedBox(width: 6),

          // ── Duration label ──────────────────────────────────────────────
          Text(
            _durationAndSizeLabel(),
            style: TextStyle(color: durationColor, fontSize: 12),
          ),

          const SizedBox(width: 8),

          // ── Waveform area ───────────────────────────────────────────────
          Expanded(child: _buildWaveformArea(isDark)),
        ],
      ),
    );
  }

  // ── Left button ────────────────────────────────────────────────────────────────

  Widget _buildLeftButton(bool isDark) {
    final Color iconColor = isDark ? Colors.white : const Color(0xFF3A2A1A);
    switch (_audioState) {
      // ── NOT DOWNLOADED: download arrow ────────────────────────────────────
      case _AudioState.notDownloaded:
        return GestureDetector(
          onTap: _startDownload,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: HexColor('#1A7F4B'),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.download_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        );

      // ── DOWNLOADING: circular progress + cancel ───────────────────────────
      case _AudioState.downloading:
        return GestureDetector(
          onTap: _cancelDownload,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _downloadProgress > 0 ? _downloadProgress : null,
                  strokeWidth: 2.5,
                  color: iconColor,
                  backgroundColor: isDark ? Colors.white24 : Colors.black12,
                ),
                Icon(Icons.close, color: iconColor, size: 14),
              ],
            ),
          ),
        );

      // ── READY: play / pause / replay ─────────────────────────────────────
      case _AudioState.ready:
        return GestureDetector(
          onTap: _handlePlayPause,
          child: Icon(
            _isCompleted
                ? Icons.replay
                : _isPlaying
                ? Icons.pause
                : Icons.play_arrow,
            color: iconColor,
            size: 32,
          ),
        );
    }
  }

  // ── Waveform area ──────────────────────────────────────────────────────────────

  Widget _buildWaveformArea(bool isDark) {
    // NOT DOWNLOADED or DOWNLOADING: flat static bars
    if (_audioState != _AudioState.ready ||
        !_waveReady ||
        _waveController == null) {
      return _FlatWaveform(
        isDownloading: _audioState == _AudioState.downloading,
        progress: _downloadProgress,
        isDark: isDark,
      );
    }

    final Color fixedWave = isDark ? Colors.white30 : const Color(0xFFB0A090);
    final Color liveWave = isDark ? Colors.white : const Color(0xFF3A2A1A);

    // READY: live interactive waveform + scrubber dot
    return Stack(
      children: [
        AudioFileWaveforms(
          playerController: _waveController!,
          size: const Size(double.infinity, 48),
          waveformType: WaveformType.fitWidth,
          playerWaveStyle: PlayerWaveStyle(
            fixedWaveColor: fixedWave,
            liveWaveColor: liveWave,
            spacing: 5,
            waveThickness: 3,
          ),
        ),
        // Blue scrubber dot
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final progress = _total.inMilliseconds == 0
                  ? 0.0
                  : _current.inMilliseconds / _total.inMilliseconds;
              final left = (width * progress).clamp(0.0, width - 10);
              return Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: left),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF53BDEB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FlatWaveform
//
// Static bar visualisation shown before download. Mimics the waveform shape
// WhatsApp shows while audio hasn't been downloaded yet. When downloading,
// bars fill left-to-right proportional to download progress.
// ─────────────────────────────────────────────────────────────────────────────
class _FlatWaveform extends StatelessWidget {
  final bool isDownloading;
  final double progress; // 0.0 – 1.0
  final bool isDark;

  const _FlatWaveform({
    required this.isDownloading,
    required this.progress,
    required this.isDark,
  });

  // Fixed heights give a realistic-looking waveform silhouette
  static const List<double> _barHeights = [
    6,
    10,
    16,
    22,
    18,
    12,
    20,
    26,
    20,
    14,
    8,
    16,
    24,
    20,
    12,
    18,
    22,
    16,
    10,
    14,
    20,
    26,
    18,
    12,
    8,
    16,
    22,
    18,
    12,
    10,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalBars = _barHeights.length;
        final filledBars = isDownloading ? (totalBars * progress).round() : 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(totalBars, (i) {
            final isFilled = isDownloading && i < filledBars;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: 3,
              height: _barHeights[i % _barHeights.length],
              decoration: BoxDecoration(
                color: isFilled
                    ? (isDark ? Colors.white70 : const Color(0xFF6B5A4A))
                    : (isDark ? Colors.white24 : const Color(0xFFB0A090)),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReplyPreview — extracted to keep the main build clean
// ─────────────────────────────────────────────────────────────────────────────
class _ReplyPreview extends StatelessWidget {
  final String text;
  final bool isMe;
  final String? senderName;
  final String? mediaType;
  final String? thumbnailUrl;
  final VoidCallback? onTap;

  const _ReplyPreview({
    required this.text,
    required this.isMe,
    this.senderName,
    this.mediaType,
    this.thumbnailUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.black26 : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isMe ? HexColor('#FB8830') : HexColor('#1A7F4B'),
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              senderName ?? (isMe ? 'You' : 'Them'),
              style: TextStyle(
                color: isMe ? HexColor('#FB8830') : HexColor('#1A7F4B'),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                if (mediaType != null) ...[
                  // ✅ BUG1 FIX: support local file path thumbnails too
                  if (mediaType == 'image' &&
                      thumbnailUrl != null &&
                      thumbnailUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: thumbnailUrl!.startsWith('http')
                            ? Image.network(
                                thumbnailUrl!,
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.image_outlined,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF8A7060),
                                  size: 14,
                                ),
                              )
                            : Image.file(
                                File(thumbnailUrl!),
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.image_outlined,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF8A7060),
                                  size: 14,
                                ),
                              ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        mediaType == 'video'
                            ? Icons.videocam_outlined
                            : mediaType == 'voice_note'
                            ? Icons.graphic_eq
                            : mediaType == 'audio'
                            ? Icons.audiotrack
                            : mediaType == 'document'
                            ? Icons.description_outlined
                            : Icons.image_outlined,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF8A7060),
                        size: 14,
                      ),
                    ),
                ],
                Expanded(
                  child: Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF8A7060),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
