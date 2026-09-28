import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'package:qik_talk/utilities/services/presigned_upload_service.dart';
import '../../../utilities/services/app_pref_helper.dart';
import '../../../utilities/database/save_values.dart';
import '../../../utilities/constants/app_strings/api_strings.dart';
import '../services/status_upload_manager.dart';
import '../services/status_upload_service.dart';

// ── Theme ──────────────────────────────────────────────────────────────────
const _kOrange = Color(0xFFFF6B00);
const _kGreen = Color(0xFF1A7F4B);
const _kOverlay = Color(0x88000000);

const _kBrushColors = [
  Color(0xFFFFFFFF),
  Color(0xFF000000),
  Color(0xFFFF9800),
  Color(0xFF00BCD4),
  Color(0xFFFFEB3B),
  Color(0xFF4CAF50),
  Color(0xFFF44336),
  Color(0xFF9C27B0),
];

const _kStickers = [
  '😀',
  '😂',
  '😍',
  '😎',
  '🔥',
  '❤️',
  '✨',
  '🎉',
  '👍',
  '🙌',
  '💯',
  '⭐',
  '💪',
  '🎵',
  '📸',
  '🌈',
  '💖',
  '🎨',
  '🏆',
  '🌸',
  '🦋',
  '☀️',
  '💫',
  '🥳',
];

// ── Models ─────────────────────────────────────────────────────────────────
class _DrawStroke {
  final List<Offset> points;
  final Color color;
  final double size;
  final bool isEraser;
  _DrawStroke({
    required this.points,
    required this.color,
    required this.size,
    required this.isEraser,
  });
}

class _StickerOverlay {
  String emoji;
  Offset position;
  double scale;
  _StickerOverlay({
    required this.emoji,
    required this.position,
    this.scale = 1.0,
  });
}

class _TextOverlay {
  String text;
  String style;
  Color color;
  Offset position;
  double scale;
  _TextOverlay({
    required this.text,
    required this.style,
    required this.color,
    required this.position,
    this.scale = 1.0,
  });
}

enum _ActiveTool { none, draw, text, stickers, crop }

// ── Screen ─────────────────────────────────────────────────────────────────
class StatusImagePreviewScreen extends StatefulWidget {
  final File file;
  final bool isVideo;

  final VoidCallback? onUploadComplete;

  const StatusImagePreviewScreen({
    super.key,
    required this.file,
    required this.isVideo,
    this.onUploadComplete,
  });

  @override
  State<StatusImagePreviewScreen> createState() =>
      _StatusImagePreviewScreenState();
}

class _StatusImagePreviewScreenState extends State<StatusImagePreviewScreen>
    with SingleTickerProviderStateMixin {
  final _captionCtrl = TextEditingController();
  final _repaintKey = GlobalKey();
  bool _isUploading = false;

  File? _processedFile;
  _ActiveTool _tool = _ActiveTool.none;

  // Draw
  Color _brushColor = Colors.white;
  double _brushSize = 6;
  bool _eraserMode = false;
  final List<_DrawStroke> _strokes = [];
  List<Offset> _currentStroke = [];

  // Text
  String _selTextStyle = 'Classic';
  Color _textColor = Colors.white;
  final List<_TextOverlay> _textOverlays = [];

  // Stickers
  final List<_StickerOverlay> _stickers = [];

  // Scale tracking — stores scale at gesture start to avoid drift
  double _textScaleStart = 1.0;
  double _stickerScaleStart = 1.0;

  // Caption focus
  final _captionFocus = FocusNode();

  // Tool panel animation
  late AnimationController _panelAnim;
  late Animation<double> _panelSlide;

  @override
  void initState() {
    super.initState();
    _captionCtrl.clear();
    _processImage();
    _panelAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _panelSlide = CurvedAnimation(parent: _panelAnim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _captionFocus.dispose();
    _panelAnim.dispose();
    super.dispose();
  }

  // ── Image processing ────────────────────────────────────────────────────
  Future<void> _processImage() async {
    // Show the original immediately so the user sees something right away
    if (mounted) setState(() => _processedFile = widget.file);

    // Then re-encode in an isolate-friendly way (compute runs off main thread)
    try {
      final result = await compute(_encodeImageIsolate, widget.file.path);
      if (result != null && mounted) {
        setState(() => _processedFile = File(result));
      }
    } catch (_) {
      // already showing the original, nothing more to do
    }
  }

  // ── Tool toggle ─────────────────────────────────────────────────────────
  void _selectTool(_ActiveTool tool) {
    setState(() {
      if (_tool == tool) {
        _tool = _ActiveTool.none;
        _panelAnim.reverse();
      } else {
        _tool = tool;
        _panelAnim.forward();
        _captionFocus.unfocus();
      }
    });
  }

  // ── Crop ────────────────────────────────────────────────────────────────
  Future<void> _crop(CropAspectRatioPreset? preset) async {
    final src = _processedFile ?? widget.file;
    final cropped = await ImageCropper().cropImage(
      sourcePath: src.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          toolbarColor: _kOrange,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: _kOrange,
          initAspectRatio: preset ?? CropAspectRatioPreset.original,
          lockAspectRatio: preset != null,
        ),
        IOSUiSettings(title: 'Crop'),
      ],
    );
    if (cropped != null && mounted)
      setState(() => _processedFile = File(cropped.path));
  }

  Future<void> _rotate(bool left) async {
    final src = _processedFile ?? widget.file;
    final bytes = await src.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return;
    final rotated = img.copyRotate(decoded, angle: left ? -90 : 90);
    final dir = await getTemporaryDirectory();
    final path = p.join(
      dir.path,
      'rot_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final out = File(path)..writeAsBytesSync(img.encodeJpg(rotated));
    if (mounted) setState(() => _processedFile = out);
  }

  // ── Text dialog ─────────────────────────────────────────────────────────
  TextStyle _ts(String style, Color color, double size) {
    switch (style) {
      case 'Modern':
        return GoogleFonts.montserrat(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
        );
      case 'Neon':
        return GoogleFonts.orbitron(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: color, blurRadius: 14)],
        );
      case 'Bold':
        return GoogleFonts.poppins(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w900,
        );
      case 'Typewriter':
        return GoogleFonts.courierPrime(color: color, fontSize: size);
      case 'Handwritten':
        return GoogleFonts.dancingScript(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w700,
        );
      default:
        return GoogleFonts.poppins(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w500,
        );
    }
  }

  void _showTextDialog() {
    final ctrl = TextEditingController();
    String dlgStyle = _selTextStyle;
    Color dlgColor = _textColor;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Add Text',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  style: _ts(dlgStyle, dlgColor, 16),
                  decoration: const InputDecoration(
                    hintText: 'Enter text...',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _kOrange),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Style',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      [
                        'Classic',
                        'Modern',
                        'Neon',
                        'Bold',
                        'Typewriter',
                        'Handwritten',
                      ].map((s) {
                        final sel = dlgStyle == s;
                        return GestureDetector(
                          onTap: () => set(() => dlgStyle = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: sel
                                  ? _kOrange.withOpacity(0.18)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                              border: sel ? Border.all(color: _kOrange) : null,
                            ),
                            child: Text(
                              s,
                              style: _ts(
                                s,
                                sel ? _kOrange : Colors.white70,
                                11,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  'Color',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _kBrushColors.map((c) {
                    final sel = dlgColor == c;
                    return GestureDetector(
                      onTap: () => set(() => dlgColor = c),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: sel
                              ? Border.all(color: Colors.white, width: 2.5)
                              : Border.all(color: Colors.white24, width: 1),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final txt = ctrl.text.trim();
                if (txt.isNotEmpty)
                  setState(() {
                    _selTextStyle = dlgStyle;
                    _textColor = dlgColor;
                    _textOverlays.add(
                      _TextOverlay(
                        text: txt,
                        style: dlgStyle,
                        color: dlgColor,
                        position: const Offset(60, 120),
                      ),
                    );
                  });
                Navigator.pop(ctx);
              },
              child: const Text(
                'Add',
                style: TextStyle(color: _kOrange, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Send — fire and forget, navigate immediately ─────────────────────────
  Future<void> _send() async {
    if (_processedFile == null || _isUploading) return;
    setState(() => _isUploading = true);

    // 1. Flatten edits into a single image file
    File fileToUpload = _processedFile!;
    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        final pixRatio =
            View.of(_repaintKey.currentContext!).devicePixelRatio * 2.0;
        final uiImage = await boundary.toImage(pixelRatio: pixRatio);
        final byteData = await uiImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (byteData != null) {
          final dir = await getTemporaryDirectory();
          final path = p.join(
            dir.path,
            'status_edit_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          fileToUpload = File(path)
            ..writeAsBytesSync(byteData.buffer.asUint8List());
        }
      }
    } catch (_) {}

    final caption = _captionCtrl.text.trim();
    final token =
        await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN) ?? '';

    // 2. Navigate back IMMEDIATELY — don't await upload
    if (mounted) {
      Navigator.pop(context, true);
      widget.onUploadComplete?.call();
    }

    // 3. Upload in background via StatusUploadManager
    final mgr = StatusUploadManager();
    mgr.reset();
    mgr.progress.value = 0.001; // show banner immediately

    (() async {
      try {
        final mimeType = lookupMimeType(fileToUpload.path) ?? 'image/jpeg';

        debugPrint('📤 Starting MinIO upload for image status...');
        debugPrint('   File: ${fileToUpload.path}');
        debugPrint('   MimeType: $mimeType');

        final publicUrl = await PresignedUploadService.uploadFile(
          file: fileToUpload,
          mimeType: mimeType,
          onProgress: (p) => mgr.progress.value = p * 0.8,
        );

        if (publicUrl == null || publicUrl.isEmpty) {
          throw Exception('MinIO upload returned null/empty URL');
        }

        debugPrint('✅ MinIO upload done. publicUrl = $publicUrl');
        mgr.progress.value = 0.9;

        // Build the body map explicitly so we can log it
        final body = <String, dynamic>{
          'mediaType': 'image',
          'mediaUrl': publicUrl, // ✅ field name confirmed by backend
          'caption': caption,
        };
        debugPrint('📦 Sending to backend: $body');

        final dio = Dio();
        final response = await dio.post(
          ApiStrings.uploadStatus,
          data: body,
          options: Options(
            contentType: 'application/json',
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ),
        );

        debugPrint(
          '✅ Backend response: ${response.statusCode} ${response.data}',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          mgr.progress.value = 1.0;
          mgr.done.value = true;
          await Future.delayed(const Duration(seconds: 3));
        } else {
          throw Exception(
            'Backend returned ${response.statusCode}: ${response.data}',
          );
        }
      } on DioException catch (e) {
        debugPrint('❌ Status image upload DioException: ${e.type}');
        debugPrint('   Response status: ${e.response?.statusCode}');
        debugPrint('   Response body:   ${e.response?.data}');
        mgr.progress.value = null;
        mgr.error.value =
            e.response?.data?['message'] ?? e.message ?? 'Upload failed';
        await Future.delayed(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('❌ Status image upload error: $e');
        mgr.progress.value = null;
        mgr.error.value = e.toString();
        await Future.delayed(const Duration(seconds: 4));
      } finally {
        mgr.done.value = false;
        mgr.progress.value = null;
        mgr.error.value = null;
      }
    })();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full-screen image canvas ──────────────────────────────────
          RepaintBoundary(
            key: _repaintKey,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Base image
                if (_processedFile != null)
                  Image.file(_processedFile!, fit: BoxFit.contain)
                else
                  const Center(
                    child: CircularProgressIndicator(color: _kOrange),
                  ),

                // Draw strokes
                if (_strokes.isNotEmpty || _currentStroke.isNotEmpty)
                  CustomPaint(
                    painter: _DrawPainter(
                      _strokes,
                      _currentStroke,
                      _brushColor,
                      _brushSize,
                      _eraserMode,
                    ),
                    child: const SizedBox.expand(),
                  ),

                // Text overlays
                for (int i = 0; i < _textOverlays.length; i++)
                  _buildImageTextOverlay(i),

                // Sticker overlays
                for (int i = 0; i < _stickers.length; i++)
                  _buildImageSticker(i),
              ],
            ),
          ),

          // ── Draw gesture capture (covers full screen when in draw mode) ──
          if (_tool == _ActiveTool.draw)
            GestureDetector(
              onPanStart: (d) =>
                  setState(() => _currentStroke = [d.localPosition]),
              onPanUpdate: (d) =>
                  setState(() => _currentStroke.add(d.localPosition)),
              onPanEnd: (_) {
                if (_currentStroke.isNotEmpty)
                  setState(() {
                    _strokes.add(
                      _DrawStroke(
                        points: List.from(_currentStroke),
                        color: _brushColor,
                        size: _brushSize,
                        isEraser: _eraserMode,
                      ),
                    );
                    _currentStroke = [];
                  });
              },
              child: Container(color: Colors.transparent),
            ),

          // ── Top bar — close + tool icons (WhatsApp arrangement) ───────
          Positioned(
            top: MediaQuery.of(context).padding.top + 6,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // Close
                  _iconBtn(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  // Crop
                  _toolBtn(_ActiveTool.crop, Icons.crop),
                  const SizedBox(width: 4),
                  // Draw
                  _toolBtn(_ActiveTool.draw, Icons.edit_outlined),
                  const SizedBox(width: 4),
                  // Text
                  _toolBtn(_ActiveTool.text, Icons.text_fields),
                  const SizedBox(width: 4),
                  // Sticker / Emoji
                  _toolBtn(_ActiveTool.stickers, Icons.emoji_emotions_outlined),
                  const SizedBox(width: 4),
                  // Undo (draw mode only)
                  if (_tool == _ActiveTool.draw && _strokes.isNotEmpty)
                    _iconBtn(
                      icon: Icons.undo,
                      onTap: () => setState(() => _strokes.removeLast()),
                    ),
                ],
              ),
            ),
          ),

          // ── Sliding tool panel ─────────────────────────────────────────
          if (_tool != _ActiveTool.none && _tool != _ActiveTool.draw)
            Positioned(
              bottom: bottomInset + 90,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_panelSlide),
                child: _buildToolPanel(),
              ),
            ),

          // ── Bottom caption + send bar ─────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: _buildBottomBar(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top icon button ─────────────────────────────────────────────────────
  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Tool toggle button ───────────────────────────────────────────────────
  Widget _toolBtn(_ActiveTool tool, IconData icon) {
    final active = _tool == tool;
    return GestureDetector(
      onTap: () {
        if (tool == _ActiveTool.text) {
          _selectTool(tool);
          _showTextDialog();
        } else {
          _selectTool(tool);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active ? _kOrange : Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Tool panel content ───────────────────────────────────────────────────
  Widget _buildToolPanel() {
    switch (_tool) {
      case _ActiveTool.draw:
        return _buildDrawPanel();
      case _ActiveTool.stickers:
        return _buildStickerPanel();
      case _ActiveTool.crop:
        return _buildCropPanel();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDrawPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eraser toggle + label row
          Row(
            children: [
              Text(
                'Draw',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _eraserMode = !_eraserMode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _eraserMode
                        ? _kOrange.withOpacity(0.2)
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                    border: _eraserMode ? Border.all(color: _kOrange) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_fix_high,
                        size: 14,
                        color: _eraserMode ? _kOrange : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Eraser',
                        style: TextStyle(
                          fontSize: 12,
                          color: _eraserMode ? _kOrange : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Colors
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _kBrushColors.map((c) {
                final sel = !_eraserMode && _brushColor == c;
                return GestureDetector(
                  onTap: () => setState(() {
                    _brushColor = c;
                    _eraserMode = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    margin: const EdgeInsets.only(right: 8),
                    width: sel ? 36 : 30,
                    height: sel ? 36 : 30,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: sel
                          ? Border.all(color: Colors.white, width: 2.5)
                          : Border.all(color: Colors.white24, width: 1),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // Size slider
          Row(
            children: [
              Text(
                '${_brushSize.toInt()}px',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _kOrange,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    overlayColor: Colors.transparent,
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    value: _brushSize,
                    min: 2,
                    max: 28,
                    onChanged: (v) => setState(() => _brushSize = v),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickerPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stickers  •  tap to add  •  long-press on image to remove',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 8,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _kStickers
                .map(
                  (e) => GestureDetector(
                    onTap: () {
                      setState(
                        () => _stickers.add(
                          _StickerOverlay(
                            emoji: e,
                            position: const Offset(100, 140),
                          ),
                        ),
                      );
                      _selectTool(_ActiveTool.none);
                    },
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCropPanel() {
    const aspects = <(String, CropAspectRatioPreset?)>[
      ('Free', null),
      ('1:1', CropAspectRatioPreset.square),
      ('4:5', CropAspectRatioPreset.ratio4x3),
      ('16:9', CropAspectRatioPreset.ratio16x9),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crop & Rotate',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Aspect ratio chips
              ...aspects.map(
                (a) => GestureDetector(
                  onTap: () {
                    _selectTool(_ActiveTool.none);
                    _crop(a.$2);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      a.$1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Rotate buttons
              GestureDetector(
                onTap: () => _rotate(true),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white12,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rotate_left,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _rotate(false),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white12,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rotate_right,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Image sticker overlay ────────────────────────────────────────────────
  Widget _buildImageSticker(int i) {
    final sticker = _stickers[i];
    return Positioned(
      left: sticker.position.dx,
      top: sticker.position.dy,
      child: Listener(
        // Listener fires before gesture arena — gives us pointer count instantly
        onPointerDown: (_) {},
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: (d) {
            _stickerScaleStart = sticker.scale;
          },
          onScaleUpdate: (d) {
            setState(() {
              // Always move with focal point
              sticker.position = Offset(
                (sticker.position.dx + d.focalPointDelta.dx).clamp(
                  0,
                  MediaQuery.of(context).size.width - 60,
                ),
                (sticker.position.dy + d.focalPointDelta.dy).clamp(
                  0,
                  MediaQuery.of(context).size.height - 60,
                ),
              );
              // Scale whenever there's a meaningful pinch delta
              if (d.scale != 1.0) {
                sticker.scale = (_stickerScaleStart * d.scale).clamp(0.3, 6.0);
              }
            });
          },
          onScaleEnd: (_) {
            // Lock in the scale so next gesture starts fresh
            _stickerScaleStart = sticker.scale;
          },
          onLongPress: () => setState(() => _stickers.removeAt(i)),
          child: Transform.scale(
            scale: sticker.scale,
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(sticker.emoji, style: const TextStyle(fontSize: 44)),
            ),
          ),
        ),
      ),
    );
  }

  // ── Text overlay ─────────────────────────────────────────────────────────
  Widget _buildImageTextOverlay(int i) {
    final overlay = _textOverlays[i];
    return Positioned(
      left: overlay.position.dx,
      top: overlay.position.dy,
      child: Listener(
        onPointerDown: (_) {},
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: (d) {
            _textScaleStart = overlay.scale;
          },
          onScaleUpdate: (d) {
            setState(() {
              overlay.position = Offset(
                (overlay.position.dx + d.focalPointDelta.dx).clamp(
                  0,
                  MediaQuery.of(context).size.width - 50,
                ),
                (overlay.position.dy + d.focalPointDelta.dy).clamp(
                  0,
                  MediaQuery.of(context).size.height - 50,
                ),
              );
              if (d.scale != 1.0) {
                overlay.scale = (_textScaleStart * d.scale).clamp(0.3, 6.0);
              }
            });
          },
          onScaleEnd: (_) {
            _textScaleStart = overlay.scale;
          },
          onLongPress: () => setState(() => _textOverlays.removeAt(i)),
          child: Transform.scale(
            scale: overlay.scale,
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white30, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _buildTextWithShadow(overlay),
            ),
          ),
        ),
      ),
    );
  }

  // ── Text with shadow so it reads on any background ──────────────────────
  Widget _buildTextWithShadow(_TextOverlay overlay) {
    return Text(
      overlay.text,
      style: _ts(overlay.style, overlay.color, 22).copyWith(
        shadows: [
          Shadow(
            color: Colors.black87,
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final navBarHeight = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 16 + navBarHeight),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.72)],
        ),
      ),
      child: Row(
        children: [
          // Caption field
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _tool = _ActiveTool.none);
                _panelAnim.reverse();
              },
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
                    focusNode: _captionFocus,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    cursorColor: Colors.white,
                    onTap: () {
                      setState(() => _tool = _ActiveTool.none);
                      _panelAnim.reverse();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Add a caption...',
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
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: _processedFile == null ? null : _send,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _kGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kGreen.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Isolate helper — runs off the main thread so UI never freezes ─────────────
Future<String?> _encodeImageIsolate(String srcPath) async {
  try {
    final bytes = await File(srcPath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    // Downscale if larger than 1920px on either axis — keeps quality high
    // but cuts encode time dramatically on megapixel photos
    img.Image toEncode = decoded;
    if (decoded.width > 1920 || decoded.height > 1920) {
      toEncode = img.copyResize(
        decoded,
        width: decoded.width > decoded.height ? 1920 : -1,
        height: decoded.height >= decoded.width ? 1920 : -1,
      );
    }

    final jpeg = img.encodeJpg(toEncode, quality: 90);
    final dir = await getTemporaryDirectory();
    final outPath = p.join(
      dir.path,
      'status_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    File(outPath).writeAsBytesSync(jpeg);
    return outPath;
  } catch (_) {
    return null;
  }
}

// ── Draw painter ─────────────────────────────────────────────────────────────
class _DrawPainter extends CustomPainter {
  final List<_DrawStroke> strokes;
  final List<Offset> currentStroke;
  final Color currentColor;
  final double currentSize;
  final bool isEraser;

  const _DrawPainter(
    this.strokes,
    this.currentStroke,
    this.currentColor,
    this.currentSize,
    this.isEraser,
  );

  void _paintStroke(
    Canvas canvas,
    List<Offset> pts,
    Color color,
    double sz,
    bool eraser,
  ) {
    if (pts.length < 2) return;
    final paint = Paint()
      ..strokeWidth = sz
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..color = eraser ? const Color(0x00000000) : color
      ..blendMode = eraser ? BlendMode.clear : BlendMode.srcOver;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final mid = Offset(
        (pts[i - 1].dx + pts[i].dx) / 2,
        (pts[i - 1].dy + pts[i].dy) / 2,
      );
      path.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, mid.dx, mid.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final s in strokes)
      _paintStroke(canvas, s.points, s.color, s.size, s.isEraser);
    _paintStroke(canvas, currentStroke, currentColor, currentSize, isEraser);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DrawPainter old) => true;
}
