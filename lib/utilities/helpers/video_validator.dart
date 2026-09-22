import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoValidator {
  /// Validate video duration (max 3 minutes = 180 seconds)
  /// Returns true if valid, false if too long
  static Future<VideoValidationResult> validateVideoDuration(
    File videoFile,
  ) async {
    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();

      final duration = controller.value.duration;
      final durationInSeconds = duration.inSeconds;

      await controller.dispose();

      const maxDurationSeconds = 180; // 3 minutes

      if (durationInSeconds <= maxDurationSeconds) {
        return VideoValidationResult(
          isValid: true,
          duration: duration,
          message: 'Video duration: ${_formatDuration(duration)}',
        );
      } else {
        return VideoValidationResult(
          isValid: false,
          duration: duration,
          message:
              'Video is too long (${_formatDuration(duration)}). Maximum is 3 minutes.',
        );
      }
    } catch (e) {
      return VideoValidationResult(
        isValid: false,
        duration: Duration.zero,
        message: 'Failed to validate video: $e',
      );
    }
  }

  /// Format duration as MM:SS
  static String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// Show error dialog for invalid video
  static void showVideoTooLongDialog(BuildContext context, Duration duration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2E2E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Video Too Long', style: TextStyle(color: Colors.white)),
        content: Text(
          'The selected video is ${_formatDuration(duration)} long. Please select a video that is 3 minutes or shorter.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFFFF6B00))),
          ),
        ],
      ),
    );
  }

  /// Show loading dialog while validating
  static void showValidatingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Color(0xFF2E2E2E),
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFFFF6B00)),
              SizedBox(width: 20),
              Text(
                'Validating video...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoValidationResult {
  final bool isValid;
  final Duration duration;
  final String message;

  VideoValidationResult({
    required this.isValid,
    required this.duration,
    required this.message,
  });
}
