import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';

class RecorderUI extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onSend;
  final RecorderController recorderController;
  final int recordingDuration;

  const RecorderUI({
    Key? key,
    required this.onDelete,
    required this.onSend,
    required this.recorderController,
    required this.recordingDuration,
  }) : super(key: key);

  String formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('recorder'),
      child: SafeArea(
        top: false,
        child: Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Color(AppColors.primaryColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDelete,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent.shade200,
                        size: 28
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2F38),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 12, right: 8),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),

                      Text(
                        formatDuration(recordingDuration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFeatures: [FontFeature.tabularFigures()],
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: AudioWaveforms(
                          recorderController: recorderController,
                          size: const Size(double.infinity, 30),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          waveStyle: const WaveStyle(
                            waveColor: Color(0xFF4E74F9),
                            extendWaveform: true,
                            showMiddleLine: false,
                            spacing: 5.0,
                            waveCap: StrokeCap.round,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              GestureDetector(
                onTap: onSend,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A7F4B), Color(0xFF26B569)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A7F4B).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 24),
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