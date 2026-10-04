import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:qik_talk/features/wallet/features/verification/screens/tier_two/screens/tier_two_verification_success_screen.dart';
import '../../../../../../../utilities/constants/app_colors.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  int _currentStep = 0;
  final List<String> _steps = [
    "Checking identity details...",
    "Verifying with database...",
    "Processing verification...",
  ];

  @override
  void initState() {
    super.initState();
    _startVerificationProcess();
  }

  void _startVerificationProcess() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _currentStep = i + 1;
        });
      }
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TierTwoVerificationSuccessScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(Theme.of(context).brightness == Brightness.dark),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF96D15).withOpacity(0.35),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF96D15).withOpacity(0.25),
              ),
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 60,
                          width: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                            color: Colors.white,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Verifying\nYour Identity",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Please wait while we verify\nyour information...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),

                        Column(
                          children: List.generate(_steps.length, (index) {
                            bool isCompleted = _currentStep > index;
                            bool isProcessing = _currentStep == index;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCompleted
                                          ? Colors.greenAccent
                                          : (isProcessing ? Colors.white : Colors.white24),
                                      boxShadow: isProcessing
                                          ? [BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 8)]
                                          : [],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      _steps[index],
                                      style: TextStyle(
                                        color: isProcessing || isCompleted
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.3),
                                        fontSize: 15,
                                        fontWeight: isProcessing ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isCompleted)
                                    const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}