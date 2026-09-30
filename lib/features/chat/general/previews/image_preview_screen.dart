import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';

// ─────────────────────────────────────────────
//  THEME CONSTANTS
// ─────────────────────────────────────────────
const _kOrange = Color(0xFFFF6B00);
const _kBg = Color(0xFF1A1A1A);
const _kSurface = Color(0xFF2C2C2C);
const _kSelBg = Color(0xFF2E1A00);

const _kBrushColors = [
  Color(0xFFFF9800),
  Color(0xFF00BCD4),
  Color(0xFFFFFFFF),
  Color(0xFF000000),
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
  '⭐',
  '💖',
  '🎨',
  '🏆',
  '🎭',
  '🌸',
  '🦋',
  '☀️',
];

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────
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
  _TextOverlay({
    required this.text,
    required this.style,
    required this.color,
    required this.position,
  });
}

class _MusicTrack {
  final String path;
  final String name;
  final String ext;
  _MusicTrack({required this.path, required this.name, required this.ext});
}

enum _EditorTab { crop, draw, text, stickers, music }

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────
class EnhancedImagePreviewScreen extends StatefulWidget {
  final List<File> images;
  final Function(List<File> images, String caption) onSend;

  const EnhancedImagePreviewScreen({
    super.key,
    required this.images,
    required this.onSend,
  });

  @override
  State<EnhancedImagePreviewScreen> createState() =>
      _EnhancedImagePreviewScreenState();
}

class _EnhancedImagePreviewScreenState
    extends State<EnhancedImagePreviewScreen> {
  late List<File> _editedImages;
  int _currentIndex = 0;
  late PageController _pageController;
  final TextEditingController _captionController = TextEditingController();

  // One RepaintBoundary key per image page — used to flatten edits into pixels
  late List<GlobalKey> _repaintKeys;
  bool _isSending = false;

  _EditorTab _activeTab = _EditorTab.crop;

  // Crop
  String _selectedAspect = 'Original';

  // Draw
  Color _brushColor = const Color(0xFFFF9800);
  double _brushSize = 5;
  bool _eraserMode = false;
  final List<_DrawStroke> _strokes = [];
  List<Offset> _currentStroke = [];

  // Text
  String _selectedTextStyle = 'Classic';
  Color _textColor = const Color(0xFFFF9800);
  final List<_TextOverlay> _textOverlays = [];

  // Stickers
  final List<_StickerOverlay> _stickers = [];

  // Music
  final List<_MusicTrack> _musicTracks = [];
  _MusicTrack? _selectedTrack;
  String _musicSearch = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _editedImages = List.from(widget.images);
    _pageController = PageController();
    _repaintKeys = List.generate(widget.images.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _captionController.dispose();
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════
  //  CROP / ROTATE
  // ════════════════════════════════════════════
  Future<void> _cropImage(CropAspectRatioPreset? preset) async {
    final file = _editedImages[_currentIndex];
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: file.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: _kOrange,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: _kOrange,
            initAspectRatio: preset ?? CropAspectRatioPreset.original,
            lockAspectRatio: preset != null,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: preset != null
                ? [preset]
                : [
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9,
                  ],
          ),
        ],
      );
      if (cropped != null && mounted) {
        setState(() => _editedImages[_currentIndex] = File(cropped.path));
      }
    } catch (e) {
      debugPrint('Crop error: $e');
    }
  }

  /// Real pixel-level rotation using the `image` package
  Future<void> _rotateImage(bool left) async {
    final file = _editedImages[_currentIndex];
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return;
      final rotated = img.copyRotate(decoded, angle: left ? -90 : 90);
      final dir = await getTemporaryDirectory();
      final outPath = p.join(
        dir.path,
        'rotated_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final outFile = File(outPath)..writeAsBytesSync(img.encodeJpg(rotated));
      if (mounted) setState(() => _editedImages[_currentIndex] = outFile);
    } catch (e) {
      debugPrint('Rotate error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rotation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ════════════════════════════════════════════
  //  TEXT
  // ════════════════════════════════════════════
  /// Returns a live TextStyle for the named preset
  TextStyle _buildTextStyle(String style, Color color, double size) {
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
          shadows: [
            Shadow(color: color, blurRadius: 12),
            Shadow(color: color, blurRadius: 24),
          ],
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
      default: // Classic
        return GoogleFonts.poppins(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w500,
        );
    }
  }

  void _showAddTextDialog() {
    final ctrl = TextEditingController();
    // local copies so the dialog can update independently
    String dlgStyle = _selectedTextStyle;
    Color dlgColor = _textColor;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, dlgSet) {
          return AlertDialog(
            backgroundColor: _kSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
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
                  // Live-preview input — font changes with style selection
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    style: _buildTextStyle(dlgStyle, dlgColor, 16),
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
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
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
                            onTap: () => dlgSet(() => dlgStyle = s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: sel
                                    ? _kOrange.withOpacity(0.2)
                                    : Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                                border: sel
                                    ? Border.all(color: _kOrange)
                                    : null,
                              ),
                              child: Text(
                                s,
                                style: _buildTextStyle(
                                  s,
                                  sel ? _kOrange : Colors.white,
                                  12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Color',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: _kBrushColors.map((c) {
                      final sel = dlgColor == c;
                      return GestureDetector(
                        onTap: () => dlgSet(() => dlgColor = c),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: sel
                                ? Border.all(color: Colors.white, width: 2.5)
                                : null,
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
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  final txt = ctrl.text.trim();
                  if (txt.isNotEmpty) {
                    setState(() {
                      _selectedTextStyle = dlgStyle;
                      _textColor = dlgColor;
                      _textOverlays.add(
                        _TextOverlay(
                          text: txt,
                          style: dlgStyle,
                          color: dlgColor,
                          position: const Offset(60, 80),
                        ),
                      );
                    });
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Add', style: TextStyle(color: _kOrange)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════
  //  MUSIC — real local file picker + playback
  // ════════════════════════════════════════════
  Future<void> _pickMusicFromDevice() async {
    ProviderScope.containerOf(
      context,
    ).read(biometricAuthProvider.notifier).isPickerActive = true;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    await ProviderScope.containerOf(
      context,
    ).read(biometricAuthProvider.notifier).onPickerReturned();
    if (result != null && result.files.isNotEmpty && mounted) {
      setState(() {
        for (final f in result.files) {
          if (f.path != null) {
            // Avoid duplicates
            final exists = _musicTracks.any((t) => t.path == f.path);
            if (!exists) {
              _musicTracks.add(
                _MusicTrack(
                  path: f.path!,
                  name: p.basenameWithoutExtension(f.path!),
                  ext: p.extension(f.path!).replaceFirst('.', '').toUpperCase(),
                ),
              );
            }
          }
        }
      });
    }
  }

  Future<void> _playTrack(_MusicTrack track) async {
    try {
      if (_selectedTrack?.path == track.path && _isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.setFilePath(track.path);
        await _audioPlayer.play();
        setState(() {
          _selectedTrack = track;
          _isPlaying = true;
        });
      }
    } catch (e) {
      debugPrint('Audio error: $e');
    }
  }

  // ════════════════════════════════════════════
  //  FLATTEN ALL EDITS INTO PIXEL DATA, THEN SEND
  // ════════════════════════════════════════════

  /// Captures the RepaintBoundary for [pageIndex] as a PNG file.
  /// To capture a page that isn't currently visible we must first jump
  /// to it, wait one frame for it to render, then capture.
  Future<File?> _capturePage(int pageIndex) async {
    // Jump to the target page and wait for it to render
    _pageController.jumpToPage(pageIndex);
    await Future.delayed(const Duration(milliseconds: 80));

    final key = _repaintKeys[pageIndex];
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    // Capture at 3× device pixel ratio for high quality
    final pixelRatio = View.of(key.currentContext!).devicePixelRatio * 3.0;
    final uiImage = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    final dir = await getTemporaryDirectory();
    final outPath = p.join(
      dir.path,
      'qiktalk_edit_${pageIndex}_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    return File(outPath)..writeAsBytesSync(byteData.buffer.asUint8List());
  }

  Future<void> _flattenAndSend() async {
    if (_isSending) return;
    setState(() => _isSending = true);

    try {
      final flattenedFiles = <File>[];

      for (int i = 0; i < _editedImages.length; i++) {
        // ✅ BUG3 FIX: Only capture the CURRENT page via RepaintBoundary.
        // Non-current pages haven't been rendered by Flutter's lazy PageView,
        // so toImage() returns a 0x0 black PNG. Use the edited file directly
        // for all other pages — it already reflects crop/rotate edits.
        if (i == _currentIndex) {
          // Give the current page 200ms to finish rendering before capture
          await Future.delayed(const Duration(milliseconds: 200));
          final key = _repaintKeys[i];
          final boundary =
              key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
          if (boundary != null && boundary.hasSize) {
            final pixelRatio =
                View.of(key.currentContext!).devicePixelRatio * 3.0;
            final uiImage = await boundary.toImage(pixelRatio: pixelRatio);
            final byteData = await uiImage.toByteData(
              format: ui.ImageByteFormat.png,
            );
            if (byteData != null) {
              final dir = await getTemporaryDirectory();
              final outPath = p.join(
                dir.path,
                'qiktalk_edit_${i}_${DateTime.now().millisecondsSinceEpoch}.png',
              );
              final captured = File(outPath)
                ..writeAsBytesSync(byteData.buffer.asUint8List());
              flattenedFiles.add(captured);
              continue;
            }
          }
        }
        // For non-current pages (or if capture failed), use the edited file directly
        flattenedFiles.add(_editedImages[i]);
      }

      _audioPlayer.stop();
      if (mounted) {
        widget.onSend(flattenedFiles, _captionController.text.trim());
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Flatten error: $e');
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: _kBg,
      // IMPORTANT: false so we control insets manually → no overflow
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),

            // Image area shrinks when keyboard is open
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: bottomInset > 0
                  ? MediaQuery.of(context).size.height * 0.25
                  : MediaQuery.of(context).size.height * 0.40,
              child: _buildImageArea(),
            ),

            // Tab bar + content + caption bar — this section is scrollable
            Expanded(
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      // Pad for keyboard when open
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 10,
                        bottom: bottomInset + 10,
                      ),
                      child: _buildTabContent(),
                    ),
                  ),
                  _buildCaptionBar(),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'Edit',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Send button only in caption bar — no duplicate checkmark here
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ── Image / Canvas Area ────────────────────
  Widget _buildImageArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Composite canvas: image + draw + text + stickers ──
          // Each page gets its own RepaintBoundary so we can capture
          // exactly what the user sees, including all edits.
          PageView.builder(
            controller: _pageController,
            itemCount: _editedImages.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => RepaintBoundary(
              key: _repaintKeys[i],
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Base image
                  Image.file(_editedImages[i], fit: BoxFit.contain),

                  // Draw strokes (only rendered on active page for performance)
                  if (i == _currentIndex && _strokes.isNotEmpty ||
                      _currentStroke.isNotEmpty)
                    CustomPaint(
                      painter: _DrawPainter(
                        i == _currentIndex ? _strokes : [],
                        i == _currentIndex ? _currentStroke : [],
                        _brushColor,
                        _brushSize,
                        _eraserMode,
                      ),
                      child: const SizedBox.expand(),
                    ),

                  // Text overlays (only for current page)
                  if (i == _currentIndex)
                    for (int t = 0; t < _textOverlays.length; t++)
                      Positioned(
                        left: _textOverlays[t].position.dx,
                        top: _textOverlays[t].position.dy,
                        child: GestureDetector(
                          onPanUpdate: (d) => setState(
                            () => _textOverlays[t].position += d.delta,
                          ),
                          onLongPress: () =>
                              setState(() => _textOverlays.removeAt(t)),
                          child: Text(
                            _textOverlays[t].text,
                            style: _buildTextStyle(
                              _textOverlays[t].style,
                              _textOverlays[t].color,
                              22,
                            ),
                          ),
                        ),
                      ),

                  // Sticker overlays (only for current page)
                  if (i == _currentIndex)
                    for (int s = 0; s < _stickers.length; s++)
                      Positioned(
                        left: _stickers[s].position.dx,
                        top: _stickers[s].position.dy,
                        child: GestureDetector(
                          onPanUpdate: (d) =>
                              setState(() => _stickers[s].position += d.delta),
                          onLongPress: () =>
                              setState(() => _stickers.removeAt(s)),
                          child: Text(
                            _stickers[s].emoji,
                            style: TextStyle(fontSize: 40 * _stickers[s].scale),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),

          // ── Draw gesture detector (outside RepaintBoundary so it
          //    doesn't appear in the captured image) ──────────────
          if (_activeTab == _EditorTab.draw)
            GestureDetector(
              onPanStart: (d) =>
                  setState(() => _currentStroke = [d.localPosition]),
              onPanUpdate: (d) =>
                  setState(() => _currentStroke.add(d.localPosition)),
              onPanEnd: (_) {
                if (_currentStroke.isNotEmpty) {
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
                }
              },
              child: Container(color: Colors.transparent),
            ),

          // Page badge
          if (_editedImages.length > 1)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1}/${_editedImages.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),

          // Undo draw button
          if (_activeTab == _EditorTab.draw && _strokes.isNotEmpty)
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                onTap: () => setState(() => _strokes.removeLast()),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.undo, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Tab Bar ────────────────────────────────
  Widget _buildTabBar() {
    final tabs = [
      (_EditorTab.crop, Icons.crop, 'Crop'),
      (_EditorTab.draw, Icons.palette_outlined, 'Draw'),
      (_EditorTab.text, Icons.text_fields, 'Text'),
      (_EditorTab.stickers, Icons.sentiment_satisfied_alt_outlined, 'Stickers'),
      (_EditorTab.music, Icons.music_note_outlined, 'Music'),
    ];
    return Container(
      color: _kBg,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.map((t) {
          final active = _activeTab == t.$1;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = t.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: active
                  ? BoxDecoration(
                      color: _kSelBg,
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.$2, color: active ? _kOrange : Colors.grey, size: 22),
                  const SizedBox(height: 3),
                  Text(
                    t.$3,
                    style: TextStyle(
                      color: active ? _kOrange : Colors.grey,
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Tab Content ────────────────────────────
  Widget _buildTabContent() {
    return switch (_activeTab) {
      _EditorTab.crop => _buildCropPanel(),
      _EditorTab.draw => _buildDrawPanel(),
      _EditorTab.text => _buildTextPanel(),
      _EditorTab.stickers => _buildStickersPanel(),
      _EditorTab.music => _buildMusicPanel(),
    };
  }

  // ── CROP ───────────────────────────────────
  Widget _buildCropPanel() {
    const aspects = <(String, CropAspectRatioPreset?)>[
      ('Original', null),
      ('Square', CropAspectRatioPreset.square),
      ('4:5', CropAspectRatioPreset.ratio4x3),
      ('16:9', CropAspectRatioPreset.ratio16x9),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crop & Rotate',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: aspects.map((a) {
            final sel = _selectedAspect == a.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedAspect = a.$1);
                  _cropImage(a.$2);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? _kOrange.withOpacity(0.15) : _kSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: sel
                        ? Border.all(color: _kOrange, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      a.$1,
                      style: TextStyle(
                        color: sel ? _kOrange : Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _iconBtn(
                'Rotate Left',
                Icons.rotate_left,
                () => _rotateImage(true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _iconBtn(
                'Rotate Right',
                Icons.rotate_right,
                () => _rotateImage(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconBtn(String label, IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      );

  // ── DRAW ───────────────────────────────────
  Widget _buildDrawPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Draw',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _eraserMode = !_eraserMode),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _eraserMode ? _kOrange.withOpacity(0.2) : _kSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: _eraserMode ? Border.all(color: _kOrange) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_fix_high,
                      color: _eraserMode ? _kOrange : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Eraser',
                      style: TextStyle(
                        color: _eraserMode ? _kOrange : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Brush Color',
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: _kBrushColors.map((c) {
            final sel = !_eraserMode && _brushColor == c;
            return GestureDetector(
              onTap: () => setState(() {
                _brushColor = c;
                _eraserMode = false;
              }),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: sel
                      ? Border.all(color: Colors.white, width: 2.5)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Brush Size',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
            ),
            const Spacer(),
            Text(
              '${_brushSize.toInt()}px',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.cyan,
            inactiveTrackColor: Colors.pink.shade200,
            thumbColor: Colors.white,
            overlayColor: Colors.transparent,
            trackHeight: 3,
          ),
          child: Slider(
            value: _brushSize,
            min: 1,
            max: 30,
            onChanged: (v) => setState(() => _brushSize = v),
          ),
        ),
      ],
    );
  }

  // ── TEXT ───────────────────────────────────
  Widget _buildTextPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Text',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        // Style chips — each rendered in its own font
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                'Classic',
                'Modern',
                'Neon',
                'Bold',
                'Typewriter',
                'Handwritten',
              ].map((s) {
                final sel = _selectedTextStyle == s;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTextStyle = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? _kOrange.withOpacity(0.15) : _kSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: sel
                          ? Border.all(color: _kOrange, width: 1.5)
                          : null,
                    ),
                    child: Text(
                      s,
                      style: _buildTextStyle(
                        s,
                        sel ? _kOrange : Colors.white,
                        13,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          'Text Color',
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: _kBrushColors.map((c) {
            final sel = _textColor == c;
            return GestureDetector(
              onTap: () => setState(() => _textColor = c),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: sel
                      ? Border.all(color: Colors.white, width: 2.5)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
        if (_textOverlays.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Long-press text on image to delete it',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: _showAddTextDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: _kOrange, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Add Text',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── STICKERS ───────────────────────────────
  Widget _buildStickersPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stickers',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to add  •  Long-press on image to remove',
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 8,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _kStickers
              .map(
                (e) => GestureDetector(
                  onTap: () => setState(
                    () => _stickers.add(
                      _StickerOverlay(emoji: e, position: const Offset(80, 80)),
                    ),
                  ),
                  child: Center(
                    child: Text(e, style: const TextStyle(fontSize: 26)),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ── MUSIC — real local files ────────────────
  Widget _buildMusicPanel() {
    final filtered = _musicSearch.isEmpty
        ? _musicTracks
        : _musicTracks
              .where(
                (t) =>
                    t.name.toLowerCase().contains(_musicSearch.toLowerCase()),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Add Music',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _pickMusicFromDevice,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _kOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Browse',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Search
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _musicSearch = v),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Search music...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Empty state
        if (_musicTracks.isEmpty)
          Column(
            children: [
              const SizedBox(height: 16),
              Icon(
                Icons.library_music_outlined,
                color: Colors.grey[700],
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'No music added yet',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap Browse to add audio from your device',
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 16),
            ],
          )
        else
          ...filtered.map((track) {
            final sel = _selectedTrack?.path == track.path;
            final playing = sel && _isPlaying;
            return GestureDetector(
              onTap: () => _playTrack(track),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: sel ? _kOrange.withOpacity(0.12) : _kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: sel ? Border.all(color: _kOrange, width: 1.5) : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: sel
                              ? [_kOrange.withOpacity(0.6), _kOrange]
                              : [
                                  const Color(0xFF1E3A5F),
                                  const Color(0xFF0D7377),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: sel ? _kOrange : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            track.ext,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (sel) await _audioPlayer.stop();
                        setState(() {
                          _musicTracks.remove(track);
                          if (sel) {
                            _selectedTrack = null;
                            _isPlaying = false;
                          }
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

        if (_selectedTrack != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(Icons.music_note, color: _kOrange, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Playing: ${_selectedTrack!.name}',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(color: _kOrange, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Caption Bar ────────────────────────────
  Widget _buildCaptionBar() {
    return Container(
      color: _kBg,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                filled: true,
                fillColor: _kSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isSending ? null : _flattenAndSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _isSending ? Colors.grey : _kOrange,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DRAW PAINTER — eraser via saveLayer + BlendMode.clear
// ─────────────────────────────────────────────
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
      // Smooth with quadratic bezier
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
    // saveLayer is required for BlendMode.clear to erase to transparent
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final s in strokes) {
      _paintStroke(canvas, s.points, s.color, s.size, s.isEraser);
    }
    _paintStroke(canvas, currentStroke, currentColor, currentSize, isEraser);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DrawPainter old) => true;
}
