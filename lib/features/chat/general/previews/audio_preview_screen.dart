import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;

class AudioPreviewScreen extends StatefulWidget {
  final File audioFile;
  final Function(File file) onSend;

  const AudioPreviewScreen({
    super.key,
    required this.audioFile,
    required this.onSend,
  });

  @override
  State<AudioPreviewScreen> createState() => _AudioPreviewScreenState();
}

class _AudioPreviewScreenState extends State<AudioPreviewScreen> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _player.setFilePath(widget.audioFile.path);
      setState(() {
        _duration = _player.duration ?? Duration.zero;
        _isLoaded = true;
      });
      _player.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state.playing);
          if (state.processingState == ProcessingState.completed) {
            _player.seek(Duration.zero);
            setState(() => _isPlaying = false);
          }
        }
      });
    } catch (e) {
      debugPrint('Audio preview init error: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final fileName = p.basename(widget.audioFile.path);
    final ext = p
        .extension(widget.audioFile.path)
        .replaceAll('.', '')
        .toUpperCase();
    final fileSize = widget.audioFile.existsSync()
        ? widget.audioFile.lengthSync()
        : 0;
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Audio Preview',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
        actions: [
          // Send button — WhatsApp style green circle
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onSend(widget.audioFile);
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: HexColor('#1A7F4B'),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // File icon circle
              CircleAvatar(
                radius: 60,
                backgroundColor: HexColor('#1A7F4B').withOpacity(0.15),
                child: Icon(
                  Icons.audiotrack,
                  size: 60,
                  color: HexColor('#1A7F4B'),
                ),
              ),
              const SizedBox(height: 24),

              // File name
              Text(
                fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Size + type row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatFileSize(fileSize),
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: HexColor('#1A7F4B').withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ext,
                      style: GoogleFonts.poppins(
                        color: HexColor('#1A7F4B'),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Progress slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: HexColor('#1A7F4B'),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: HexColor('#1A7F4B'),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  trackHeight: 3,
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: _isLoaded
                      ? (val) {
                          final seek = Duration(
                            milliseconds: (val * _duration.inMilliseconds)
                                .round(),
                          );
                          _player.seek(seek);
                        }
                      : null,
                ),
              ),

              // Time row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Play / Pause button
              GestureDetector(
                onTap: () async {
                  if (_isPlaying) {
                    await _player.pause();
                  } else {
                    await _player.play();
                  }
                },
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: HexColor('#1A7F4B'),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
