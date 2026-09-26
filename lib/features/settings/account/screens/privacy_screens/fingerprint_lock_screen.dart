import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';

class FingerprintLockScreen extends ConsumerStatefulWidget {
  const FingerprintLockScreen({super.key});

  @override
  ConsumerState<FingerprintLockScreen> createState() => _FingerprintLockScreenState();
}

class _FingerprintLockScreenState extends ConsumerState<FingerprintLockScreen> {
  bool _isToggling = false;

  Future<void> _toggleBiometric(bool enable) async {
    if (_isToggling) return;
    
    setState(() => _isToggling = true);
    
    try {
      if (enable) {
        await ref.read(biometricAuthProvider.notifier).enableBiometric();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fingerprint lock enabled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await ref.read(biometricAuthProvider.notifier).disableBiometric();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fingerprint lock disabled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isToggling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final biometricState = ref.watch(biometricAuthProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightNavBar,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor:
            isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightNavBar,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(AppColors.gradientColorsTwo),
                  Color(AppColors.gradientColorsOne),
                ],
              ) : null,
              color: isDark ? null : AppColors.lightNavBar,
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: CustomBackButton(buildContext: context),
              title: Text(
                'Fingerprint Lock',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Toggle card
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Fingerprint icon in orange circle
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFB85C00),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fingerprint,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unlock with Fingerprint',
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Enable biometric security',
                              style: GoogleFonts.poppins(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: biometricState.isEnabled,
                        onChanged: (value) => _toggleBiometric(value),
                        activeColor: Colors.white,
                        activeTrackColor: Colors.grey,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Info box
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A2A3A)
                      : const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "When enabled, you'll need to unlock QikTalk when returning from background or after closing the app.",
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? const Color(0xFF6AADDB)
                            : const Color(0xFF1A6FA0),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "• Unlock required when returning from background\n• Works with fingerprint or face unlock only\n• Keeps your conversations secure",
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? const Color(0xFF6AADDB)
                            : const Color(0xFF1A6FA0),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
