import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/authentication/login/screens/login_screen.dart';
import 'package:qik_talk/features/authentication/provider/user_provider.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/notifications/services/notification_service.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/provider/privacy_settings_provider.dart';
import 'package:qik_talk/utilities/services/app_clear_service.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LogoutConfirmDialog
//
// Matches the Figma design:
//   • Dark modal with red glow border
//   • Logout icon in dark-red circle
//   • "Logout of QikTalk?" title
//   • Subtitle copy
//   • Cancel (grey) + Logout (red) buttons
//
// Usage:
//   final confirmed = await showDialog<bool>(
//     context: context,
//     barrierColor: Colors.black.withOpacity(0.75),
//     builder: (_) => const LogoutConfirmDialog(),
//   );
//   if (confirmed == true) {
//     Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
//   }
// ─────────────────────────────────────────────────────────────────────────────

class LogoutConfirmDialog extends ConsumerStatefulWidget {
  const LogoutConfirmDialog({super.key});

  @override
  ConsumerState<LogoutConfirmDialog> createState() =>
      _LogoutConfirmDialogState();
}

class _LogoutConfirmDialogState extends ConsumerState<LogoutConfirmDialog> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);

    try {
      // 1. Delete FCM token so push notifications stop for this device
      await NotificationService().deleteToken();

      // 2. Disconnect socket cleanly
      GlobalSocketService().disconnect();

      // 3. Reset biometric lock state
      ref.read(biometricAuthProvider.notifier).logout();

      // 4. Wipe ALL locally stored / cached data
      await AppClearService.clearAll();

      // 5. Invalidate in-memory Riverpod state so the next user
      //    starts with a completely clean slate
      ref.invalidate(feedProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(privacySettingsProvider);
    } catch (_) {
      // Even if something fails, still clear and log out
      try { GlobalSocketService().disconnect(); } catch (_) {}
      ref.read(biometricAuthProvider.notifier).logout();
      await AppClearService.clearAll();
    } finally {
      // 6. Navigate to LoginScreen and remove the entire back stack
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LogInScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color dialogBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Color textSecondary =
        isDark ? const Color(0xFFA3A3A3) : const Color(0xFF6B6B6B);
    final Color cancelBg =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F0);
    const Color redAccent = Color(0xFFE53935);
    final Color redIconBg =
        isDark ? const Color(0xFF4A1010) : const Color(0xFFFFE5E5);
    const Color borderGlow = Color(0xFF8B0000);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderGlow.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: borderGlow.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Close (X) button ──────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: _isLoading ? null : () => Navigator.pop(context, false),
                child: Icon(Icons.close, color: textSecondary, size: 24),
              ),
            ),

            const SizedBox(height: 8),

            // ── Logout icon in dark-red circle ────────────────────────────
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: redIconBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: redAccent,
                size: 42,
              ),
            ),

            const SizedBox(height: 24),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              'Logout of QikTalk?',
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 12),

            // ── Subtitle ──────────────────────────────────────────────────
            Text(
              'Are you sure you want to log out of your account?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 32),

            // ── Action buttons ────────────────────────────────────────────
            Row(
              children: [
                // Cancel
                Expanded(
                  child: GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => Navigator.pop(context, false),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: cancelBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Logout
                Expanded(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _handleLogout,
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: redAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Logout',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
