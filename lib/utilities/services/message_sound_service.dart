import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MessageSoundService {
  static final MessageSoundService _instance = MessageSoundService._internal();
  factory MessageSoundService() => _instance;
  MessageSoundService._internal();

  Future<void> _playSound(String assetPath) async {
    final player = AudioPlayer();
    try {
      final bytes = await rootBundle.load(assetPath);
      await player.setVolume(1.0);
      await player.play(BytesSource(bytes.buffer.asUint8List()));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      debugPrint('❌ Sound error ($assetPath): $e');
      await player.dispose();
    }
  }

  Future<void> playSendSound() async {
    await _playSound('images/outgoing_message.mp3');
  }

  Future<void> playReceiveSound() async {
    await _playSound('images/incoming_message.mp3');
  }
}
