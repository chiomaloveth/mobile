import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoCompressionService {
  /// Compresses a video to fit within [maxSizeMb] (best-effort).
  ///
  /// - If the input is already <= maxSizeMb, returns the original file.
  /// - Otherwise attempts a few passes reducing bitrate/scale until it fits.
  static Future<File> compressToMaxSize({
    required File input,
    required double maxSizeMb,
  }) async {
    final targetBytes = (maxSizeMb * 1024 * 1024).round();

    try {
      if (!await input.exists()) return input;
      final inBytes = await input.length();
      if (inBytes <= targetBytes) return input;

      final durationSec = await _getDurationSeconds(input);
      if (durationSec <= 0.1) return input;

      final tmpDir = await getTemporaryDirectory();
      final baseName = p.basenameWithoutExtension(input.path);

      // Start with a bitrate target derived from size + duration, then iterate down.
      // Add a safety factor so container/audio overhead doesn't push us over the limit.
      int targetVideoBitrate = ((targetBytes * 8) / durationSec * 0.82)
          .round(); // bits/sec
      targetVideoBitrate = targetVideoBitrate.clamp(300000, 6000000);

      // Pass configs: progressively reduce bitrate and scale down.
      final passes = <({int maxW, int audioKbps, double brMultiplier})>[
        (maxW: 1280, audioKbps: 96, brMultiplier: 1.00),
        (maxW: 960, audioKbps: 80, brMultiplier: 0.78),
        (maxW: 854, audioKbps: 64, brMultiplier: 0.62),
      ];

      File lastOut = input;
      for (var i = 0; i < passes.length; i++) {
        final outPath = p.join(
          tmpDir.path,
          '${baseName}_qik_${maxSizeMb.toStringAsFixed(0)}mb_p$i.mp4',
        );

        final pass = passes[i];
        final br = (targetVideoBitrate * pass.brMultiplier).round();
        final buf = br * 2;

        // scale filter keeps aspect ratio and prevents upscaling.
        final vf = "scale='min(${pass.maxW},iw)':-2";

        // Fix bitrate formatting: ffmpeg expects like 1200k
        final cmdStr = [
          "-y",
          "-i",
          _q(input.path),
          "-vf",
          vf,
          "-c:v",
          "libx264",
          "-preset",
          "veryfast",
          "-b:v",
          "${(br / 1000).round()}k",
          "-maxrate",
          "${(br / 1000).round()}k",
          "-bufsize",
          "${(buf / 1000).round()}k",
          "-c:a",
          "aac",
          "-b:a",
          "${pass.audioKbps}k",
          "-movflags",
          "+faststart",
          _q(outPath),
        ].join(' ');

        debugPrint('🎞️ Compress pass $i: $cmdStr');
        await FFmpegKit.execute(cmdStr);

        final outFile = File(outPath);
        if (!await outFile.exists()) continue;
        final outBytes = await outFile.length();
        lastOut = outFile;
        if (outBytes <= targetBytes) return outFile;
      }

      return lastOut;
    } catch (_) {
      return input;
    }
  }

  static String _q(String path) => '"$path"';

  static Future<File> trimIfNecessary({
    required File input,
    double maxDurationSeconds = 180.0, // 3 minutes
  }) async {
    try {
      if (!await input.exists()) return input;
      
      final duration = await _getDurationSeconds(input);
      if (duration <= maxDurationSeconds) return input;

      debugPrint('✂️ Trimming video to ${maxDurationSeconds}s (original: ${duration}s)');
      
      final tmpDir = await getTemporaryDirectory();
      final baseName = p.basenameWithoutExtension(input.path);
      final outPath = p.join(
        tmpDir.path,
        '${baseName}_trimmed_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      final cmdStr = [
        "-y",
        "-i",
        _q(input.path),
        "-t",
        maxDurationSeconds.toString(),
        "-c:v",
        "libx264",
        "-preset",
        "ultrafast",
        "-c:a",
        "aac",
        _q(outPath),
      ].join(' ');

      await FFmpegKit.execute(cmdStr);

      final outFile = File(outPath);
      if (await outFile.exists()) {
        return outFile;
      }
      return input;
    } catch (e) {
      debugPrint('⚠️ Trim error: $e');
      return input;
    }
  }

  static Future<double> _getDurationSeconds(File file) async {

    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.file(file);
      await controller.initialize();
      return controller.value.duration.inMilliseconds / 1000.0;
    } catch (_) {
      return 0;
    } finally {
      await controller?.dispose();
    }
  }
}
