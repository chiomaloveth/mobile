import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qik_talk/utilities/services/presigned_upload_service.dart';
import 'package:video_player/video_player.dart';
import '../../../utilities/services/app_pref_helper.dart';
import '../../../utilities/database/save_values.dart';
import '../../../utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/features/status/services/status_upload_manager.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────
class _TextSticker {
  String text;
  Color color;
  double fontSize;
  Offset position;
  double scale;
  _TextSticker({
    required this.text,
    required this.color,
    required this.fontSize,
    required this.position,
    this.scale = 1.0,
  });
}

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  _Stroke({required this.points, required this.color, required this.width});
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class StatusVideoPreviewScreen extends StatefulWidget {
  final File file;
  final bool isVideo;
  final VoidCallback? onUploadComplete;

  const StatusVideoPreviewScreen({
    super.key,
    required this.file,
    required this.isVideo,
    this.onUploadComplete,
  });

  @override
  State<StatusVideoPreviewScreen> createState() =>
      _StatusVideoPreviewScreenState();
}

class _StatusVideoPreviewScreenState extends State<StatusVideoPreviewScreen> {
  bool _isUploading = false;
  File? _activeFile;

  VideoPlayerController? _videoCtrl;
  bool _videoInitialized = false;
  bool _videoError = false;
  bool _disposed = false;

  final TextEditingController _captionCtrl = TextEditingController();

  // ── Edit mode: 0=none 1=draw 2=text 3=filter 4=trim ──────────────────────
  int _editMode = 0;
  bool _showPauseIcon = false;

  // ── Trim ──────────────────────────────────────────────────────────────────
  double _trimStart = 0.0;
  double _trimEnd = 1.0;
  bool _draggingStart = false;
  bool _draggingEnd = false;
  bool _trimApplied = false;

  // ── Draw ──────────────────────────────────────────────────────────────────
  final List<_Stroke> _strokes = [];
  final List<Offset> _curPoints = [];
  Color _brushColor = Colors.white;
  double _brushSize = 4.0;

  // ── Text stickers ─────────────────────────────────────────────────────────
  final List<_TextSticker> _stickers = [];
  final List<Color> _textColors = [
    Colors.white,
    Colors.black,
    Colors.yellow,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
  ];

  // ── Sticker scale tracking ────────────────────────────────────────────────
  double _stickerScaleStart = 1.0;

  // ── Filters ───────────────────────────────────────────────────────────────
  final List<_Filter> _filters = [
    _Filter('Normal', null),
    _Filter('Warm', ColorFilter.matrix(_warmMatrix())),
    _Filter('Cool', ColorFilter.matrix(_coolMatrix())),
    _Filter('B&W', ColorFilter.matrix(_bwMatrix())),
    _Filter('Vivid', ColorFilter.matrix(_vividMatrix())),
    _Filter('Fade', ColorFilter.matrix(_fadeMatrix())),
  ];
  int _filterIndex = 0;

  bool get _isImage => !widget.isVideo;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _captionCtrl.clear();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _activeFile = widget.file;
    if (widget.isVideo) _initVideo();
  }

  Future<void> _initVideo({File? overrideFile}) async {
    final ctrl = VideoPlayerController.file(
      overrideFile ?? _activeFile ?? widget.file,
    );
    try {
      await ctrl.initialize();
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      await ctrl.setLooping(true);
      await ctrl.play();

      // Listener to loop within trim range when trim is applied
      ctrl.addListener(() {
        if (!mounted || _disposed) return;
        final c = _videoCtrl;
        if (c == null || !c.value.isInitialized || !_trimApplied) return;
        final totalMs = c.value.duration.inMilliseconds;
        final endMs = (_trimEnd * totalMs).round();
        final currentMs = c.value.position.inMilliseconds;
        if (currentMs >= endMs) {
          final startMs = (_trimStart * totalMs).round();
          c.seekTo(Duration(milliseconds: startMs));
        }
      });

      if (_disposed) {
        ctrl.dispose();
        return;
      }
      setState(() {
        _videoCtrl = ctrl;
        _videoInitialized = true;
        _videoError = false;
      });
    } catch (e) {
      ctrl.dispose();
      if (mounted && !_disposed) setState(() => _videoError = true);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    final ctrl = _videoCtrl;
    _videoCtrl = null;
    _videoInitialized = false;
    _trimApplied = false;

    try {
      ctrl?.removeListener(() {});
      ctrl?.pause();
    } catch (_) {}

    Future.microtask(() {
      try {
        ctrl?.dispose();
      } catch (_) {}
    });

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _captionCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Upload — pops immediately, trims + uploads in background
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _startUpload() async {
    if (_isUploading) return;
    _isUploading = true;

    final mgr = StatusUploadManager();
    mgr.reset();
    mgr.progress.value = 0.001;

    // Capture trim values NOW before the controller is disposed on pop
    final trimApplied = _trimApplied;
    final trimStart = _trimStart;
    final trimEnd = _trimEnd;
    int totalMs = 0;
    try {
      final ctrl = _videoCtrl;
      if (ctrl != null && ctrl.value.isInitialized) {
        totalMs = ctrl.value.duration.inMilliseconds;
      }
    } catch (_) {}

    // Pop immediately — user is free to do other things
    Navigator.pop(context, true);
    widget.onUploadComplete?.call();

    // Run everything in the background
    _runUploadInBackground(
      mgr: mgr,
      trimApplied: trimApplied,
      trimStart: trimStart,
      trimEnd: trimEnd,
      totalMs: totalMs,
    );
  }

  Future<void> _runUploadInBackground({
    required StatusUploadManager mgr,
    required bool trimApplied,
    required double trimStart,
    required double trimEnd,
    required int totalMs,
  }) async {
    try {
      File uploadFile = _activeFile ?? widget.file;

      // ── Step 1: If trim applied, cut with FFmpeg in background ──────────
      if (trimApplied && widget.isVideo && totalMs > 0) {
        final startMs = (trimStart * totalMs).round();
        final endMs = (trimEnd * totalMs).round();

        if (startMs > 0 || endMs < totalMs) {
          mgr.progress.value = 0.05;
          debugPrint('✂️ Trimming in background: ${startMs}ms → ${endMs}ms');

          try {
            final startSec = startMs / 1000.0;
            final durSec = (endMs - startMs) / 1000.0;

            final dir = await getTemporaryDirectory();
            final outPath =
                '${dir.path}/status_trimmed_'
                '${DateTime.now().millisecondsSinceEpoch}.mp4';

            final session = await FFmpegKit.execute(
              '-y -ss $startSec -i "${widget.file.path}" -t $durSec '
              '-c:v libx264 -c:a aac -preset ultrafast "$outPath"',
            );

            final returnCode = await session.getReturnCode();

            if (ReturnCode.isSuccess(returnCode)) {
              uploadFile = File(outPath);
              debugPrint('✅ Background trim ready: $outPath');
            } else {
              final logs = await session.getAllLogsAsString();
              debugPrint('❌ Background trim failed: $logs');
              // Fall through — upload original
            }
          } catch (e) {
            debugPrint('❌ Background trim error: $e');
            // Fall through — upload original
          }
        }
      }

      mgr.progress.value = 0.1;

      // ── Step 2: Upload the file (trimmed or original) ────────────────────
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final mimeType =
          lookupMimeType(uploadFile.path) ??
          (widget.isVideo ? 'video/mp4' : 'image/jpeg');

      final publicUrl = await PresignedUploadService.uploadFile(
        file: uploadFile,
        mimeType: mimeType,
        onProgress: (p) => mgr.progress.value = 0.1 + p * 0.8,
      );

      if (publicUrl == null) throw Exception('Upload to storage failed');

      mgr.progress.value = 0.92;

      // ── Step 3: Tell backend about the status ────────────────────────────
      final response = await Dio().post(
        ApiStrings.uploadStatus,
        data: {
          'mediaType': widget.isVideo ? 'video' : 'image',
          'caption': _captionCtrl.text.trim(),
          'mediaUrl': publicUrl,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        mgr.progress.value = 1.0;
        mgr.done.value = true;
        await Future.delayed(const Duration(seconds: 3));
      } else {
        throw Exception('Server ${response.statusCode}');
      }
    } on DioException catch (e) {
      mgr.progress.value = null;
      mgr.error.value =
          e.response?.data?['message'] ?? e.message ?? 'Upload failed';
      await Future.delayed(const Duration(seconds: 4));
    } catch (e) {
      mgr.progress.value = null;
      mgr.error.value = e.toString();
      await Future.delayed(const Duration(seconds: 4));
    } finally {
      mgr.done.value = false;
      mgr.progress.value = null;
      mgr.error.value = null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Media
          Positioned.fill(child: _buildMedia(size)),

          // Draw layer
          if (_editMode == 1) _buildDrawLayer(),

          // Text stickers
          ..._stickers.map(_buildDraggableSticker),

          // Top toolbar
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

          // Brush panel
          if (_editMode == 1)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: _buildBrushPanel(),
            ),

          // Filter panel
          if (_editMode == 3)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: _buildFilterPanel(),
            ),

          // Trim panel
          if (_editMode == 4 && widget.isVideo)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: _buildTrimPanel(),
            ),

          // Trim active badge
          if (_trimApplied && _editMode != 4)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A7F4B).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✂️ Trim active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom bar
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Media widget
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMedia(Size size) {
    Widget media;

    if (_isImage) {
      media = Image.file(widget.file, fit: BoxFit.cover);
    } else if (_videoError) {
      media = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, color: Colors.white54, size: 56),
            const SizedBox(height: 12),
            const Text(
              'Could not load video',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _videoError = false;
                  _videoInitialized = false;
                });
                _initVideo();
              },
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else if (!_disposed &&
        _videoInitialized &&
        _videoCtrl != null &&
        _videoCtrl!.value.isInitialized) {
      media = GestureDetector(
        onTap: () {
          setState(() {
            if (_videoCtrl!.value.isPlaying) {
              _videoCtrl!.pause();
              _showPauseIcon = true;
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) setState(() => _showPauseIcon = false);
              });
            } else {
              _videoCtrl!.play();
              _showPauseIcon = false;
            }
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _videoCtrl!.value.aspectRatio,
                child: VideoPlayer(_videoCtrl!),
              ),
            ),
            if (_showPauseIcon)
              AnimatedOpacity(
                opacity: _showPauseIcon ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pause, color: Colors.white, size: 34),
                ),
              ),
          ],
        ),
      );
    } else {
      media = const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_filterIndex > 0 && _filters[_filterIndex].colorFilter != null) {
      media = ColorFiltered(
        colorFilter: _filters[_filterIndex].colorFilter!,
        child: media,
      );
    }

    return Center(
      child: SizedBox(
        width: size.width,
        height: size.width * (16 / 9),
        child: ClipRect(child: media),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Top bar
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _iconBtn(Icons.close, () => Navigator.pop(context)),
          const Spacer(),
          if (_editMode == 1)
            _iconBtn(Icons.undo, () {
              setState(() {
                if (_strokes.isNotEmpty) _strokes.removeLast();
              });
            }),
          const SizedBox(width: 4),
          _toolBtn(
            icon: Icons.brush,
            label: 'Draw',
            active: _editMode == 1,
            onTap: () => setState(() => _editMode = _editMode == 1 ? 0 : 1),
          ),
          const SizedBox(width: 8),
          _toolBtn(
            icon: Icons.text_fields,
            label: 'Text',
            active: _editMode == 2,
            onTap: _openTextInput,
          ),
          const SizedBox(width: 8),
          _toolBtn(
            icon: Icons.tune,
            label: 'Filter',
            active: _editMode == 3,
            onTap: () => setState(() => _editMode = _editMode == 3 ? 0 : 3),
          ),
          if (widget.isVideo) ...[
            const SizedBox(width: 8),
            _toolBtn(
              icon: Icons.content_cut,
              label: 'Trim',
              active: _editMode == 4,
              onTap: () => setState(() => _editMode = _editMode == 4 ? 0 : 4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.black38,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );

  Widget _toolBtn({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.black45,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: active ? Colors.black : Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Draw layer
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildDrawLayer() => Positioned.fill(
    child: GestureDetector(
      onPanStart: (d) => setState(
        () => _curPoints
          ..clear()
          ..add(d.localPosition),
      ),
      onPanUpdate: (d) => setState(() => _curPoints.add(d.localPosition)),
      onPanEnd: (_) {
        setState(() {
          _strokes.add(
            _Stroke(
              points: List.from(_curPoints),
              color: _brushColor,
              width: _brushSize,
            ),
          );
          _curPoints.clear();
        });
      },
      child: CustomPaint(
        painter: _DrawPainter(
          strokes: _strokes,
          currentPoints: _curPoints,
          currentColor: _brushColor,
          currentWidth: _brushSize,
        ),
      ),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Brush panel
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBrushPanel() {
    final colors = [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Icon(Icons.brush, color: Colors.white, size: 14),
              Expanded(
                child: Slider(
                  value: _brushSize,
                  min: 2,
                  max: 20,
                  activeColor: _brushColor,
                  inactiveColor: Colors.white24,
                  onChanged: (v) => setState(() => _brushSize = v),
                ),
              ),
              const Icon(Icons.brush, color: Colors.white, size: 22),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: colors
                .map(
                  (c) => GestureDetector(
                    onTap: () => setState(() => _brushColor = c),
                    child: Container(
                      width: 34,
                      height: 34,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _brushColor == c
                              ? Colors.white
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Text sticker input
  // ─────────────────────────────────────────────────────────────────────────

  void _openTextInput() {
    setState(() => _editMode = 0);
    final ctrl = TextEditingController();
    Color chosen = Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSt) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _textColors
                      .map(
                        (c) => GestureDetector(
                          onTap: () => setSt(() => chosen = c),
                          child: Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: chosen == c
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: TextStyle(
                  color: chosen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Add text…',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A7F4B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final text = ctrl.text.trim();
                    if (text.isNotEmpty) {
                      final size = MediaQuery.of(context).size;
                      setState(() {
                        _stickers.add(
                          _TextSticker(
                            text: text,
                            color: chosen,
                            fontSize: 22,
                            position: Offset(size.width / 4, size.height / 3),
                          ),
                        );
                      });
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Draggable sticker
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildDraggableSticker(_TextSticker sticker) => Positioned(
    left: sticker.position.dx,
    top: sticker.position.dy,
    child: GestureDetector(
      onScaleStart: (_) => _stickerScaleStart = sticker.scale,
      onScaleUpdate: (d) => setState(() {
        sticker.position = Offset(
          sticker.position.dx + d.focalPointDelta.dx,
          sticker.position.dy + d.focalPointDelta.dy,
        );
        if (d.scale != 1.0) {
          sticker.scale = (_stickerScaleStart * d.scale).clamp(0.3, 6.0);
        }
      }),
      onLongPress: () => setState(() => _stickers.remove(sticker)),
      child: Transform.scale(
        scale: sticker.scale,
        alignment: Alignment.topLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            sticker.text,
            style: TextStyle(
              color: sticker.color,
              fontSize: sticker.fontSize,
              fontWeight: FontWeight.bold,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ),
      ),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Trim panel
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTrimPanel() {
    final ctrl = _videoCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const SizedBox.shrink();
    }
    final totalMs = ctrl.value.duration.inMilliseconds.toDouble();

    String fmt(double fraction) {
      final ms = (fraction * totalMs).round();
      final s = (ms ~/ 1000) % 60;
      final m = ms ~/ 60000;
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }

    const double barHeight = 56.0;
    const double handleW = 20.0;
    const Color handleColor = Color(0xFFFFD600);
    const Color selectedTint = Color(0x44FFD600);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fmt(_trimStart),
                style: const TextStyle(
                  color: Color(0xFFFFD600),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [ui.FontFeature.tabularFigures()],
                ),
              ),
              Text(
                'Drag handles to trim',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
              Text(
                fmt(_trimEnd),
                style: const TextStyle(
                  color: Color(0xFFFFD600),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [ui.FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),

        // Track + handles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: LayoutBuilder(
            builder: (_, constraints) {
              final trackW = constraints.maxWidth;
              final leftPx = _trimStart * trackW;
              final rightPx = _trimEnd * trackW;

              return SizedBox(
                height: barHeight,
                child: Stack(
                  children: [
                    // Dark background
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),

                    // Yellow tint over selected range
                    Positioned(
                      left: leftPx + handleW,
                      width: (rightPx - leftPx - handleW * 2).clamp(0, trackW),
                      top: 0,
                      bottom: 0,
                      child: Container(color: selectedTint),
                    ),

                    // Top border of selected range
                    Positioned(
                      left: leftPx + handleW,
                      width: (rightPx - leftPx - handleW * 2).clamp(0, trackW),
                      top: 0,
                      height: 3,
                      child: Container(color: handleColor),
                    ),

                    // Bottom border of selected range
                    Positioned(
                      left: leftPx + handleW,
                      width: (rightPx - leftPx - handleW * 2).clamp(0, trackW),
                      bottom: 0,
                      height: 3,
                      child: Container(color: handleColor),
                    ),

                    // Left handle
                    Positioned(
                      left: leftPx,
                      width: handleW,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragStart: (_) =>
                            setState(() => _draggingStart = true),
                        onHorizontalDragUpdate: (d) {
                          final newFrac = (_trimStart + d.delta.dx / trackW)
                              .clamp(0.0, _trimEnd - 0.05);
                          setState(() => _trimStart = newFrac);
                          ctrl.seekTo(
                            Duration(milliseconds: (newFrac * totalMs).round()),
                          );
                        },
                        onHorizontalDragEnd: (_) =>
                            setState(() => _draggingStart = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          decoration: BoxDecoration(
                            color: handleColor,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(6),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (_) => Container(
                                  width: 3,
                                  height: 10,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Right handle
                    Positioned(
                      left: rightPx - handleW,
                      width: handleW,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragStart: (_) =>
                            setState(() => _draggingEnd = true),
                        onHorizontalDragUpdate: (d) {
                          final newFrac = (_trimEnd + d.delta.dx / trackW)
                              .clamp(_trimStart + 0.05, 1.0);
                          setState(() => _trimEnd = newFrac);
                          ctrl.seekTo(
                            Duration(milliseconds: (newFrac * totalMs).round()),
                          );
                        },
                        onHorizontalDragEnd: (_) =>
                            setState(() => _draggingEnd = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          decoration: BoxDecoration(
                            color: handleColor,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(6),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (_) => Container(
                                  width: 3,
                                  height: 10,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Playhead
                    ValueListenableBuilder(
                      valueListenable: ctrl,
                      builder: (_, value, __) {
                        final pos = value.position.inMilliseconds / totalMs;
                        return Positioned(
                          left: (pos * trackW).clamp(0, trackW - 2),
                          top: 4,
                          bottom: 4,
                          width: 2.5,
                          child: Container(
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
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Apply button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _applyTrim,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A7F4B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.content_cut, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Apply Trim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Apply trim — seeks to start and enables loop listener
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _applyTrim() async {
    final ctrl = _videoCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    final totalMs = ctrl.value.duration.inMilliseconds;
    final startMs = (_trimStart * totalMs).round();
    final endMs = (_trimEnd * totalMs).round();

    if (startMs == 0 && endMs == totalMs) {
      setState(() => _editMode = 0);
      return;
    }

    await ctrl.seekTo(Duration(milliseconds: startMs));
    await ctrl.play();

    setState(() {
      _trimApplied = true;
      _editMode = 0;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Trim applied! Video will loop within selected range.'),
        backgroundColor: Color(0xFF1A7F4B),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Filter panel
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFilterPanel() => SizedBox(
    height: 110,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _filters.length,
      itemBuilder: (_, i) {
        final f = _filters[i];
        final selected = i == _filterIndex;
        return GestureDetector(
          onTap: () => setState(() => _filterIndex = i),
          child: Container(
            width: 70,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: _isImage
                        ? (f.colorFilter != null
                              ? ColorFiltered(
                                  colorFilter: f.colorFilter!,
                                  child: Image.file(
                                    widget.file,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : Image.file(
                                  widget.file,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ))
                        : Container(
                            color: Colors.white12,
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white54,
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    f.name,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white54,
                      fontSize: 10,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Bottom bar
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final navBarHeight = MediaQuery.of(context).padding.bottom;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 10 + navBarHeight),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.75), Colors.transparent],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    inputDecorationTheme: const InputDecorationTheme(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                  child: TextField(
                    controller: _captionCtrl,
                    maxLines: 3,
                    minLines: 1,
                    cursorColor: Colors.white,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Add a caption…',
                      hintStyle: TextStyle(color: Colors.white60, fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _startUpload,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A7F4B),
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Draw painter
// ─────────────────────────────────────────────────────────────────────────────
class _DrawPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final List<Offset> currentPoints;
  final Color currentColor;
  final double currentWidth;

  _DrawPainter({
    required this.strokes,
    required this.currentPoints,
    required this.currentColor,
    required this.currentWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) _paint(canvas, s.points, s.color, s.width);
    if (currentPoints.isNotEmpty) {
      _paint(canvas, currentPoints, currentColor, currentWidth);
    }
  }

  void _paint(Canvas c, List<Offset> pts, Color col, double w) {
    if (pts.isEmpty) return;
    final p = Paint()
      ..color = col
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_DrawPainter _) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter helpers
// ─────────────────────────────────────────────────────────────────────────────
class _Filter {
  final String name;
  final ColorFilter? colorFilter;
  const _Filter(this.name, this.colorFilter);
}

List<double> _warmMatrix() => [
  1.2,
  0,
  0,
  0,
  0.05,
  0,
  1.0,
  0,
  0,
  0.02,
  0,
  0,
  0.8,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

List<double> _coolMatrix() => [
  0.8,
  0,
  0,
  0,
  0,
  0,
  1.0,
  0,
  0,
  0,
  0,
  0,
  1.3,
  0,
  0.05,
  0,
  0,
  0,
  1,
  0,
];

List<double> _bwMatrix() => [
  0.33,
  0.33,
  0.33,
  0,
  0,
  0.33,
  0.33,
  0.33,
  0,
  0,
  0.33,
  0.33,
  0.33,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

List<double> _vividMatrix() => [
  1.5,
  0,
  0,
  0,
  -0.2,
  0,
  1.5,
  0,
  0,
  -0.2,
  0,
  0,
  1.5,
  0,
  -0.2,
  0,
  0,
  0,
  1,
  0,
];

List<double> _fadeMatrix() => [
  0.9,
  0,
  0,
  0,
  0.08,
  0,
  0.9,
  0,
  0,
  0.08,
  0,
  0,
  0.9,
  0,
  0.08,
  0,
  0,
  0,
  1,
  0,
];
