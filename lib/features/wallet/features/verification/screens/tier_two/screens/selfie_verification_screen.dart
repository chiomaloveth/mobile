import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/wallet/features/verification/screens/tier_two/screens/selfie_verification_capture_screen.dart';
import '../../../../../../../utilities/constants/app_colors.dart';
import '../../../../../../../features/settings/theme/provider/theme_provider.dart';

class SelfieVerificationScreen extends ConsumerStatefulWidget {
  const SelfieVerificationScreen({super.key});

  @override
  ConsumerState<SelfieVerificationScreen> createState() => _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState extends ConsumerState<SelfieVerificationScreen> {
  final List<String> _tips = [
    'Ensure good lighting',
    'Remove glasses and hat',
    'Look directly at camera',
    'Keep neutral expression',
  ];

  void _handleSkip() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Skipping selfie verification...'),
        backgroundColor: Colors.grey[800],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selfie Verification',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Step 2 of 3 (Optional)',
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.6) : AppTheme.textSecondary(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
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
                color: const Color(0xFFF96D15).withOpacity(isDark ? 0.35 : 0.15),
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
                color: const Color(0xFFF96D15).withOpacity(isDark ? 0.25 : 0.10),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    children: [
                      _buildProgressStep(isActive: true, isDark: isDark),
                      const SizedBox(width: 8),
                      _buildProgressStep(isActive: true, isDark: isDark),
                      const SizedBox(width: 8),
                      _buildProgressStep(isActive: false, isDark: isDark),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.05) : AppTheme.cardBg(isDark),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 60),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2),
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.person_outline_rounded,
                                            size: 48,
                                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'Position your face in the frame',
                                          style: TextStyle(
                                            color: isDark ? Colors.white.withOpacity(0.7) : AppTheme.textSecondary(isDark),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '📸 Tips for best results:',
                                          style: TextStyle(
                                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ..._tips.map((tip) => Padding(
                                          padding: const EdgeInsets.only(bottom: 12.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle_outline, size: 16, color: const Color(0xFFFF6B00).withOpacity(0.8)),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  tip,
                                                  style: TextStyle(
                                                    color: isDark ? Colors.white.withOpacity(0.7) : AppTheme.textSecondary(isDark),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => const SelfieVerificationCapturedScreen(),
                                        ));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF6B00),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: const Text(
                                        'Capture Photo',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: _handleSkip,
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? Colors.white.withOpacity(0.5) : AppTheme.textSecondary(isDark),
                          ),
                          child: const Text(
                            'Skip for now',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep({required bool isActive, required bool isDark}) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF6B00) : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(2),
          boxShadow: isActive
              ? [BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.3), blurRadius: 4)]
              : [],
        ),
      ),
    );
  }
}