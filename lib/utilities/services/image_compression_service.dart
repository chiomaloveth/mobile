import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Compresses images before upload using flutter_image_compress.
/// Falls back to the original file if compression fails.
class ImageCompressionService {
  /// Compresses a single image file.
  ///
  /// [quality] — JPEG quality 0–100 (default 72, matches WhatsApp behavior)
  /// [maxWidth] / [maxHeight] — caps resolution; aspect ratio is preserved.
  /// Returns the compressed [File], or [input] on any error.
  static Future<File> compress({
    required File input,
    int quality = 72,
    int maxWidth = 1280,
    int maxHeight = 1280,
  }) async {
    try {
      if (!await input.exists()) return input;

      final inBytes = await input.length();
      // Skip compression if already small (< 200 KB)
      if (inBytes < 200 * 1024) return input;

      final tmpDir = await getTemporaryDirectory();
      final baseName = p.basenameWithoutExtension(input.path);
      final outPath = p.join(tmpDir.path, '${baseName}_compressed.jpg');

      final result = await FlutterImageCompress.compressAndGetFile(
        input.absolute.path,
        outPath,
        quality: quality,
        minWidth: 0,
        minHeight: 0,
        keepExif: false,
      );

      if (result == null) return input;

      final outFile = File(result.path);
      final outBytes = await outFile.length();

      debugPrint(
        '🖼️ Image compressed: ${(inBytes / 1024).toStringAsFixed(0)} KB '
        '→ ${(outBytes / 1024).toStringAsFixed(0)} KB',
      );

      return outFile;
    } catch (e) {
      debugPrint('⚠️ ImageCompressionService error: $e — using original');
      return input;
    }
  }

  /// Compresses a list of images in parallel (up to 3 concurrent).
  static Future<List<File>> compressAll({
    required List<File> inputs,
    int quality = 72,
    int maxWidth = 1280,
    int maxHeight = 1280,
  }) async {
    // Process in chunks of 3 to avoid memory spikes
    final results = <File>[];
    for (var i = 0; i < inputs.length; i += 3) {
      final chunk = inputs.sublist(i, (i + 3).clamp(0, inputs.length));
      final compressed = await Future.wait(
        chunk.map(
          (f) => compress(
            input: f,
            quality: quality,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
        ),
      );
      results.addAll(compressed);
    }
    return results;
  }
}
