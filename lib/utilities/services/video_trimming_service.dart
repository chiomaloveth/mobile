import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Video trimming service for QikTalk
/// Enforces 3-minute maximum video length
class VideoTrimmingService {
  static const int MAX_VIDEO_DURATION_SECONDS = 180; // 3 minutes

  /// Get video duration in seconds
  static Future<int> getVideoDuration(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);

    try {
      await controller.initialize();
      final duration = controller.value.duration.inSeconds;
      await controller.dispose();
      return duration;
    } catch (e) {
      debugPrint('❌ Error getting video duration: $e');
      return 0;
    }
  }

  /// Check if video duration is within limits
  static Future<VideoValidationResult> validateVideo(File videoFile) async {
    final duration = await getVideoDuration(videoFile);

    if (duration == 0) {
      return VideoValidationResult(
        isValid: false,
        duration: 0,
        error: 'Unable to read video file',
      );
    }

    if (duration > MAX_VIDEO_DURATION_SECONDS) {
      return VideoValidationResult(
        isValid: false,
        duration: duration,
        error:
            'Video is too long (max ${MAX_VIDEO_DURATION_SECONDS ~/ 60} minutes)',
      );
    }

    return VideoValidationResult(isValid: true, duration: duration);
  }

  /// Format duration for display
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  /// Show video too long dialog
  static Future<void> showVideoTooLongDialog(
    BuildContext context,
    int actualDuration,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Video Too Long',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'The selected video is ${formatDuration(actualDuration)} long. '
          'Please select a video shorter than ${MAX_VIDEO_DURATION_SECONDS ~/ 60} minutes or trim it first.',
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF1A7F4B))),
          ),
        ],
      ),
    );
  }

  /// Show validating dialog
  static void showValidatingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF2E2E2E),
        content: Row(
          children: [
            CircularProgressIndicator(color: Color(0xFF1A7F4B)),
            SizedBox(width: 20),
            Text('Validating video...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// Video validation result
class VideoValidationResult {
  final bool isValid;
  final int duration;
  final String? error;

  VideoValidationResult({
    required this.isValid,
    required this.duration,
    this.error,
  });
}
