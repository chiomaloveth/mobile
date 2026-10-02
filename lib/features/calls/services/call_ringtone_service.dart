import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

/// Handles ringtone playback and vibration for incoming calls.
class CallRingtoneService {
  static final CallRingtoneService _instance = CallRingtoneService._internal();
  factory CallRingtoneService() => _instance;
  CallRingtoneService._internal();

  AudioPlayer? _player;
  bool _isPlaying = false;

  /// Start ringtone + vibration. Safe to call multiple times.
  Future<void> startRinging() async {
    if (_isPlaying) return;
    _isPlaying = true;

    // ── Vibration ──────────────────────────────────────────
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        Vibration.vibrate(pattern: [0, 600, 1000, 600, 1000, 600], repeat: 0);
        debugPrint('✅ Vibration started');
      }
    } catch (e) {
      debugPrint('⚠️ Vibration error: $e');
    }

    // ── Ringtone via AssetSource (more robust on iOS) ──────
    try {
      _player = AudioPlayer();
      // Ensure the prefix is empty so it doesn't prepend 'assets/' twice or incorrectly
      _player!.audioCache.prefix = '';
      await _player!.setVolume(1.0);
      await _player!.setReleaseMode(ReleaseMode.loop);

      // Use the exact path as defined in pubspec.yaml
      const ringtonePath = 'images/sounds_ringtone.mp3';
      debugPrint('🎵 [CallRingtoneService] Attempting AssetSource: $ringtonePath');
      await _player!.play(AssetSource(ringtonePath));

      debugPrint('✅ [CallRingtoneService] Ringtone started');
    } catch (e) {
      debugPrint('❌ [CallRingtoneService] Ringtone error: $e');
    }
  }

  /// Stop ringtone and vibration.
  Future<void> stopRinging() async {
    if (!_isPlaying) return;
    _isPlaying = false;
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      await _player?.stop();
      await _player?.dispose();
      _player = null;
      debugPrint('✅ Ringtone stopped');
    } catch (e) {
      debugPrint('❌ Error stopping ringtone: $e');
    }

    try {
      await Vibration.cancel();
      debugPrint('✅ Vibration stopped');
    } catch (e) {
      debugPrint('⚠️ Vibration cancel error: $e');
    }
  }

  Future<void> dispose() async => stopRinging();
}
