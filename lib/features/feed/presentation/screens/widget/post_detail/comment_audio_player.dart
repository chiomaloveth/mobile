import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CommentAudioPlayer extends StatefulWidget {
  final String audioUrl;

  const CommentAudioPlayer({super.key, required this.audioUrl});

  @override
  State<CommentAudioPlayer> createState() => _CommentAudioPlayerState();
}

class _CommentAudioPlayerState extends State<CommentAudioPlayer> {
  late AudioPlayer _player;
  late PlayerController _waveController;

  bool isPlaying = false;
  bool isPrepared = false;
  Duration current = Duration.zero;
  Duration total = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _waveController = PlayerController();
    _initAudio();
  }

  Future<String> _getLocalFilePath(String url) async {
    if (!url.startsWith("http")) return url;
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a',
    );

    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  Future<void> _initAudio() async {
    try {
      final localPath = await _getLocalFilePath(widget.audioUrl);

      await _player.setFilePath(localPath);

      await _waveController.preparePlayer(
        path: localPath,
        shouldExtractWaveform: true,
      );

      if (mounted) {
        setState(() => isPrepared = true);
      }

      _player.durationStream.listen((d) {
        if (d != null && mounted) {
          setState(() => total = d);
        }
      });

      _player.positionStream.listen((p) {
        if (mounted) {
          setState(() => current = p);
          _waveController.seekTo(p.inMilliseconds);
        }
      });

      _player.playerStateStream.listen((state) {
        if (!mounted) return;

        if (state.processingState == ProcessingState.completed) {
          _player.pause();
          _player.seek(Duration.zero);
          _waveController.stopPlayer();
          _waveController.seekTo(0);
          if (mounted) {
            setState(() {
              isPlaying = false;
              current = Duration.zero;
            });
          }
        } else {
          if (mounted) {
            setState(() => isPlaying = state.playing);
          }
        }
      });
    } catch (e) {
      debugPrint("Error loading comment audio: $e");
      if (mounted) {
        setState(() => isPrepared = false);
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _waveController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            if (!isPrepared) return;

            if (isPlaying) {
              await _player.pause();
              _waveController.pausePlayer();
            } else {
              if (_player.processingState == ProcessingState.completed ||
                  current >= total) {
                await _player.seek(Duration.zero);
                _waveController.seekTo(0);
              }

              setState(() => isPlaying = true);
              _waveController.startPlayer();
              await _player.play();
            }
          },
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatDuration(current == Duration.zero ? total : current),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: isPrepared
              ? Stack(
                  children: [
                    AudioFileWaveforms(
                      playerController: _waveController,
                      size: const Size(double.infinity, 30),
                      waveformType: WaveformType.fitWidth,
                      playerWaveStyle: const PlayerWaveStyle(
                        fixedWaveColor: Colors.white,
                        liveWaveColor: Colors.white,
                        spacing: 4,
                        waveThickness: 2,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Container(
                    height: 2,
                    color: Colors.white24,
                  ),
                ),
        ),
      ],
    );
  }
}
