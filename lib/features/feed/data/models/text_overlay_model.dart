import 'package:flutter/material.dart';

enum OverlayType { text, emoji, video }

class TextOverlay {
  final String id;
  String text;
  Offset position;
  Color color;
  double fontSize;
  double baseScale; // For pinch-to-zoom tracking
  TextAlign textAlign;
  final bool? _isEmoji;
  final OverlayType type;
  final bool isNormalized;
  String? localVideoPath;
  String? videoUrl;
  double aspectRatio;
  String fontFamily;

  bool get isEmoji => _isEmoji ?? (type == OverlayType.emoji);

  TextOverlay({
    required this.id,
    required this.text,
    required this.position,
    this.color = Colors.white,
    this.fontSize = 22,
    this.baseScale = 22,
    this.textAlign = TextAlign.center,
    this.type = OverlayType.text,
    this.isNormalized = false,
    this.localVideoPath,
    this.videoUrl,
    this.aspectRatio = 9 / 16,
    this.fontFamily = 'Poppins',
    bool isEmoji = false,
  }) : _isEmoji = isEmoji;

  TextOverlay copyWith({
    String? id,
    String? text,
    Offset? position,
    Color? color,
    double? fontSize,
    double? baseScale,
    TextAlign? textAlign,
    OverlayType? type,
    bool? isNormalized,
    String? localVideoPath,
    String? videoUrl,
    double? aspectRatio,
    String? fontFamily,
    bool? isEmoji,
  }) {
    return TextOverlay(
      id: id ?? this.id,
      text: text ?? this.text,
      position: position ?? this.position,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      baseScale: baseScale ?? this.baseScale,
      textAlign: textAlign ?? this.textAlign,
      type: type ?? this.type,
      isNormalized: isNormalized ?? this.isNormalized,
      localVideoPath: localVideoPath ?? this.localVideoPath,
      videoUrl: videoUrl ?? this.videoUrl,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      fontFamily: fontFamily ?? this.fontFamily,
      isEmoji: isEmoji ?? this.isEmoji,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'dx': position.dx,
      'dy': position.dy,
      'color': color.toARGB32(),
      'fontSize': fontSize,
      'baseScale': baseScale,
      'textAlign': textAlign.index,
      'isEmoji': isEmoji,
      'type': type.name,
      'videoUrl': videoUrl,
      'isNormalized': isNormalized,
      'aspectRatio': aspectRatio,
      'fontFamily': fontFamily,
    };
  }

  factory TextOverlay.fromJson(Map<String, dynamic> json) {
    // If isNormalized is missing, we check if coordinates are between 0 and 1
    // to determine if it's a normalized coordinate.
    bool? normFlag = json['isNormalized'] as bool?;
    double dx = ((json['dx'] ?? json['x'] ?? 100.0) as num).toDouble();
    double dy = ((json['dy'] ?? json['y'] ?? 100.0) as num).toDouble();
    
    // Auto-detect normalization for legacy data that might be normalized but missing the flag
    bool normalized = normFlag ?? (dx >= 0 && dx <= 1.1 && dy >= 0 && dy <= 1.1);

    return TextOverlay(
      id: (json['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: (json['text'] as String?) ?? "",
      position: Offset(dx, dy),
      color: Color(
        (json['color'] as int?) ?? Colors.white.value,
      ),
      fontSize: ((json['fontSize'] ?? 22) as num).toDouble(),
      baseScale: ((json['baseScale'] ?? json['fontSize'] ?? 22) as num).toDouble(),
      textAlign: (json['textAlign'] != null && 
                  (json['textAlign'] as int) < TextAlign.values.length)
          ? TextAlign.values[json['textAlign'] as int]
          : TextAlign.center,
      isEmoji: json['isEmoji'] as bool? ?? false,
      isNormalized: normalized,
      type: json['type'] != null
          ? (OverlayType.values.any((e) => e.name == json['type'])
              ? OverlayType.values.byName(json['type'] as String)
              : OverlayType.text)
          : (json['isEmoji'] == true ? OverlayType.emoji : OverlayType.text),
      videoUrl: json['videoUrl'] as String?,
      aspectRatio: _parseAspectRatio(json),
      fontFamily: (json['fontFamily'] as String?) ?? 'Poppins',
    );
  }

  static double _parseAspectRatio(Map<String, dynamic> json) {
    double asp = (json['aspectRatio'] as num?)?.toDouble() ?? 1.0;
    bool isVid = json['type'] == 'video' || json['type'] == OverlayType.video.name;
    // If it's a video and the aspect ratio got defaulted/corrupted to 1.0 (square),
    // force it to a portrait 9/16 rectangle which is the natural mobile video shape.
    if (isVid && asp == 1.0) {
      return 9 / 16;
    }
    return asp;
  }
}

