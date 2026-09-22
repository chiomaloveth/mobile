import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/settings/theme/provider/theme_provider.dart';

class CustomCountdownTimer extends ConsumerStatefulWidget {
  final Color? color;
  const CustomCountdownTimer({super.key, this.color});

  @override
  ConsumerState<CustomCountdownTimer> createState() =>
      _CustomCountdownTimerState();
}

class _CustomCountdownTimerState extends ConsumerState<CustomCountdownTimer> {
  Duration _remainingTime = const Duration(minutes: 5);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = _remainingTime.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    String secondsStr = _remainingTime.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _timerSection(a: minutesStr[0], b: minutesStr[1], isDark: isDark),
            Text(
              "Minutes",
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            children: [
              Container(
                height: 3,
                width: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 3,
                width: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _timerSection(a: secondsStr[0], b: secondsStr[1], isDark: isDark),
            Text(
              "Seconds",
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _timerSection({
    required String a,
    required String b,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: widget.color ?? Colors.white),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Text(
              a,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 3),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: widget.color ?? Colors.white),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Text(
              b,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
