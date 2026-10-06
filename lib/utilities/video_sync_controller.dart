import 'dart:async';
import 'package:flutter/foundation.dart';

/// A controller that coordinates the initialization of multiple video players
/// (e.g., a background video and its overlays) to ensure they start playing
/// at the same time.
class VideoSyncController extends ChangeNotifier {
  final int expectedCount;
  final Duration timeout;
  
  // Using a bitmask or set to track which specific indices are ready
  final Set<int> _readyIndices = {};
  bool _shouldPlay = false;
  Timer? _timeoutTimer;
  bool _disposed = false;

  VideoSyncController({
    required this.expectedCount,
    this.timeout = const Duration(seconds: 5),
  }) {
    if (expectedCount <= 1) {
      _shouldPlay = true;
    } else {
      _startTimeout();
    }
  }

  bool get shouldPlay => _shouldPlay;

  /// Mark a specific video index as initialized and ready.
  /// Index 0 is typically the background video.
  void markReady(int index) {
    if (_shouldPlay || _disposed) return;

    _readyIndices.add(index);
    
    if (_readyIndices.length >= expectedCount) {
      _triggerPlay();
    }
  }

  void _startTimeout() {
    _timeoutTimer = Timer(timeout, () {
      if (!_shouldPlay && !_disposed) {
        debugPrint("⏳ VideoSyncController: Timeout reached, triggering playback anyway.");
        _triggerPlay();
      }
    });
  }

  void _triggerPlay() {
    _timeoutTimer?.cancel();
    _shouldPlay = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timeoutTimer?.cancel();
    super.dispose();
  }
}
