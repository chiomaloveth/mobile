import 'package:audio_waveforms/audio_waveforms.dart';

class AudioRecorderService {
  final RecorderController recorderController = RecorderController();

  Future<void> startRecording() async {
    await recorderController.record(
      androidEncoder: AndroidEncoder.aac,
      androidOutputFormat: AndroidOutputFormat.mpeg4,
      bitRate: 128000,
      iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
    );
  }

  Future<String?> stopRecording() async {
    final path = await recorderController.stop();
    return path;
  }

  void dispose() {
    recorderController.dispose();
  }
}
