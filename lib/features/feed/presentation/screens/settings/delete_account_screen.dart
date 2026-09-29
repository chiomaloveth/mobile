import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/feed/data/models/delete_account_dto.dart';
import 'package:qik_talk/utilities/services/app_clear_service.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';

class DeleteAccountScreen extends ConsumerWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryRed = HexColor("#EA4359");
    final state = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: AppTheme.textPrimary(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Delete Account",
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Warning card ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryRed.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: primaryRed, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    "Are you sure?",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "This action cannot be undone. All your data will be permanently deleted.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── What gets deleted ──────────────────────────────────────
            Text(
              "What will be deleted:",
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _item("Your profile and all personal information", primaryRed),
            _item("All your posts, videos, and content", primaryRed),
            _item("Your followers and following lists", primaryRed),
            _item("All messages and chat history", primaryRed),
            _item("Likes, comments, and saved content", primaryRed),

            const Spacer(),

            // ── Delete button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isDeleteAccountLoading
                    ? null
                    : () => _confirmAndDelete(
                        context, ref, isDark, primaryRed),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isDeleteAccountLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        "Continue with Deletion",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Cancel button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.cardBg(isDark),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Color primaryRed,
  ) async {
    // ── Step 1: Final confirmation dialog ──────────────────────────
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg(isDark),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Final Confirmation",
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          "Are you absolutely sure? This will permanently remove all your data and cannot be undone.",
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary(isDark),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary(isDark)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              "Delete Forever",
              style: GoogleFonts.poppins(
                  color: primaryRed, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    // ── Step 2: Call feedProvider.deleteAccount() ──────────────────
    final success = await ref
        .read(feedProvider.notifier)
        .deleteAccount(const DeleteAccountDto(confirmation: "DELETE"));

    if (!context.mounted) return;

    if (success) {
      // ── Step 3: Wipe ALL locally stored / cached data ────────────────
      ref.read(biometricAuthProvider.notifier).logout();
      await AppClearService.clearAll();

      if (!context.mounted) return;

      // ── Step 4: Navigate to root clearing all routes ─────────────────
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete account. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _item(String text, Color bulletColor) {
    return Builder(
      builder: (context) {
        final bool isDark =
            Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: bulletColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}