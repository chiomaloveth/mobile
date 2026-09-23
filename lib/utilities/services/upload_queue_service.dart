import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:qik_talk/utilities/services/presigned_upload_service.dart';

/// Represents a single queued upload job.
class UploadJob {
  final String jobId;
  final File file;
  final String mimeType;
  final void Function(double progress) onProgress;
  final void Function(String publicUrl) onSuccess;
  final void Function(String error) onError;

  UploadJob({
    required this.jobId,
    required this.file,
    required this.mimeType,
    required this.onProgress,
    required this.onSuccess,
    required this.onError,
  });
}

/// Singleton background upload queue.
/// Add jobs with [enqueue] — they are processed one at a time.
/// Progress, success, and error callbacks fire on the main isolate.
///
/// Usage:
/// ```dart
/// final jobId = UploadQueueService().enqueue(
///   file: file,
///   mimeType: 'image/jpeg',
///   onProgress: (p) => setState(() => _progress = p),
///   onSuccess: (url) => _handleSuccess(url),
///   onError: (err) => _handleError(err),
/// );
/// // To cancel before completion:
/// UploadQueueService().cancel(jobId);
/// ```
class UploadQueueService {
  static final UploadQueueService _instance = UploadQueueService._internal();
  factory UploadQueueService() => _instance;
  UploadQueueService._internal();

  final _queue = <UploadJob>[];
  final _cancelled = <String>{};
  bool _processing = false;

  /// Adds a file to the upload queue.
  /// Returns a [jobId] you can pass to [cancel].
  String enqueue({
    required File file,
    required String mimeType,
    required void Function(double progress) onProgress,
    required void Function(String publicUrl) onSuccess,
    required void Function(String error) onError,
  }) {
    final jobId =
        '${file.path.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
    _queue.add(
      UploadJob(
        jobId: jobId,
        file: file,
        mimeType: mimeType,
        onProgress: onProgress,
        onSuccess: onSuccess,
        onError: onError,
      ),
    );
    _processNext();
    return jobId;
  }

  /// Cancels a pending job. If it is already uploading, the cancel takes
  /// effect after the current chunk completes (network-level cancel not
  /// supported by PresignedUploadService, but the callback won't fire).
  void cancel(String jobId) {
    _cancelled.add(jobId);
    _queue.removeWhere((j) => j.jobId == jobId);
  }

  Future<void> _processNext() async {
    if (_processing || _queue.isEmpty) return;
    _processing = true;

    while (_queue.isNotEmpty) {
      final job = _queue.removeAt(0);
      if (_cancelled.contains(job.jobId)) {
        _cancelled.remove(job.jobId);
        continue;
      }

      try {
        final publicUrl = await PresignedUploadService.uploadFile(
          file: job.file,
          mimeType: job.mimeType,
          onProgress: (p) {
            if (!_cancelled.contains(job.jobId)) {
              job.onProgress(p);
            }
          },
        );

        if (_cancelled.contains(job.jobId)) {
          _cancelled.remove(job.jobId);
          continue;
        }

        if (publicUrl != null) {
          job.onSuccess(publicUrl);
        } else {
          job.onError('Upload failed — server returned no URL');
        }
      } catch (e) {
        if (!_cancelled.contains(job.jobId)) {
          job.onError(e.toString());
        }
        _cancelled.remove(job.jobId);
      }
    }

    _processing = false;
  }
}
