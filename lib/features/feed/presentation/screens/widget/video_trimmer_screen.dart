import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:iconly/iconly.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimmerScreen extends StatefulWidget {
  final File file;

  const VideoTrimmerScreen({super.key, required this.file});

  @override
  State<VideoTrimmerScreen> createState() => _VideoTrimmerScreenState();
}

class _VideoTrimmerScreenState extends State<VideoTrimmerScreen> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 1.0; // Default to full length

  bool _isPlaying = false;
  bool _progressVisibility = false;

  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    // Dismiss keyboard if it was open in the previous screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    await _trimmer.loadVideo(videoFile: widget.file);
    _trimmer.videoPlayerController?.setVolume(_volume);
  }

  Future<void> _togglePlayback() async {
    bool playbackState = await _trimmer.videoPlaybackControl(
      startValue: _startValue,
      endValue: _endValue,
    );
    setState(() {
      _isPlaying = playbackState;
    });
  }

  Future<void> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    await _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (outputPath) {
        setState(() {
          _progressVisibility = false;
        });
        if (outputPath != null) {
          Navigator.of(context).pop(File(outputPath));
        } else {
          // ScaffoldMessenger.of(
          //   context,
          // ).showSnackBar(const SnackBar(content: Text('Failed to save video')));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video Preview Area
            Positioned.fill(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: VideoViewer(trimmer: _trimmer),
                      ),
                    ),
                  ),
                  const SizedBox(height: 300), // Space for bottom panel
                ],
              ),
            ),

            // Top Overlay: Trim Video Title
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: Text(
                  "Trim Video",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Back Button
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Bottom Panel
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: HexColor("#0D0D0D"),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Controls Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              IconlyLight.volume_up,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 80,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 10,
                                  ),
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white24,
                                  thumbColor: Colors.white,
                                ),
                                child: Slider(
                                  value: _volume,
                                  onChanged: (value) {
                                    setState(() {
                                      _volume = value;
                                    });
                                    _trimmer.videoPlayerController?.setVolume(
                                      value,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Relocated Play/Pause Button (The "Red Dot")
                        GestureDetector(
                          onTap: _togglePlayback,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: HexColor("#ED1E4D"),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/svgs/video_filter.svg",
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 20),
                            SvgPicture.asset(
                              "assets/svgs/undo.svg",
                              width: 20,
                              height: 20,
                            ),

                            const SizedBox(width: 12),
                            SvgPicture.asset(
                              "assets/svgs/redo.svg",
                              width: 20,
                              height: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    Text(
                      "Drag to adjust clip length",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ruler and Trim Viewer
                    // Ruler and Trim Viewer
                    SizedBox(
                      height: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:
                                [
                                      "0s",
                                      "5s",
                                      "10s",
                                      "15s",
                                      "20s",
                                      "25s",
                                      "30s",
                                      "35s",
                                    ]
                                    .map(
                                      (s) => Text(
                                        s,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              // Ruler Bars (Custom Painter)
                              CustomPaint(
                                size: Size(
                                  MediaQuery.of(context).size.width - 40,
                                  50,
                                ),
                                painter: RulerPainter(),
                              ),
                              TrimViewer(
                                trimmer: _trimmer,
                                viewerHeight: 50.0,
                                viewerWidth:
                                    MediaQuery.of(context).size.width - 40,
                                maxVideoLength: const Duration(seconds: 180),
                                onChangeStart: (value) => _startValue = value,
                                onChangeEnd: (value) => _endValue = value,
                                onChangePlaybackState: (value) {
                                  setState(() {
                                    _isPlaying = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Start Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _progressVisibility ? null : _saveVideo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor("#ED1E4D"),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _progressVisibility
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Start",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Saving Progress Overlay
            if (_progressVisibility)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                    ],

                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    final double step = size.width / 35; // Total 35s
    for (int i = 0; i <= 35; i++) {
      final double x = i * step;
      final bool isMajor = i % 5 == 0;
      final double height = isMajor ? 50 : 30;

      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint..color = isMajor ? Colors.white54 : Colors.white24,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
