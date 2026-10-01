import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

void showFinanceGroupModal(BuildContext context, VoidCallback onContinue) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _FinanceGroupModal(onContinue: onContinue),
  );
}

class _FinanceGroupModal extends ConsumerStatefulWidget {
  final VoidCallback onContinue;
  const _FinanceGroupModal({required this.onContinue});

  @override
  ConsumerState<_FinanceGroupModal> createState() => _FinanceGroupModalState();
}

class _FinanceGroupModalState extends ConsumerState<_FinanceGroupModal> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    final Color sheetBg = AppTheme.cardBg(isDark);
    final Color borderColor = isDark ? HexColor('#2A2A2A') : const Color(0xFFCFC4B5);
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);
    final Color warningBg = isDark ? AppColors.warningBg : const Color(0xFFFFF4E5);
    final Color warningBorder = isDark ? AppColors.warningBorder : const Color(0xFFFFD699);
    final Color warningText = isDark ? AppColors.warningText : const Color(0xFFD97706);
    final Color checkboxBorder = isDark ? Colors.white38 : const Color(0xFF9CA3AF);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 45 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Note card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: warningBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: warningBorder, width: 1),
            ),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Note: ',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: warningText,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'Finance groups require wallet connection and cannot be converted to other types. Family & Friends groups can be upgraded to Games groups later.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Checkbox row
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _agreed
                        ? AppColors.progressActive
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color:
                          _agreed ? AppColors.progressActive : checkboxBorder,
                      width: 1.5,
                    ),
                  ),
                  child: _agreed
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  'I understand and agree to the terms.',
                  style: GoogleFonts.poppins(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Button
          Tooltip(
            message: _agreed ? '' : 'Please agree to the terms to continue',
            triggerMode: TooltipTriggerMode.tap,
            child: Opacity(
              opacity: _agreed ? 1.0 : 0.5,
              child: CustomButtonTwo(
                title: 'Continue to Group',
                isLoading: false,
                hasMargin: false,
                onClick: _agreed
                    ? () {
                        Navigator.pop(context);
                        widget.onContinue();
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please agree to the terms to continue.',
                              style:
                                  GoogleFonts.poppins(color: Colors.white),
                            ),
                            backgroundColor: isDark ? HexColor('#1A1A1A') : const Color(0xFF4A4A4A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}