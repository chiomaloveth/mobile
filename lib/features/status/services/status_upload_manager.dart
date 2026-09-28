// lib/features/status/services/status_upload_manager.dart
//
// Singleton that holds live upload progress.
// Imported by:
//   • status_video_preview_screen.dart  (writes progress)
//   • status_upload_banner.dart         (reads progress)
//   • status_screen.dart                (reads progress for subtitle)

import 'package:flutter/foundation.dart';

class StatusUploadManager {
  static final StatusUploadManager _instance = StatusUploadManager._();
  factory StatusUploadManager() => _instance;
  StatusUploadManager._();

  /// null  = no upload in progress
  /// 0..1  = uploading (fraction complete)
  final ValueNotifier<double?> progress = ValueNotifier(null);

  /// Non-null when the upload failed
  final ValueNotifier<String?> error = ValueNotifier(null);

  /// True once upload completes successfully
  final ValueNotifier<bool> done = ValueNotifier(false);

  void reset() {
    progress.value = null;
    error.value = null;
    done.value = false;
  }
}
