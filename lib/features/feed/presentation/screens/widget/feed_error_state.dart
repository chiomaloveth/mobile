import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class FeedErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const FeedErrorState({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.textSecondary(isDark).withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull down to retry',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textHint(isDark),
                    fontSize: 14,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: onRetry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: HexColor("#FF6B00")),
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.poppins(
                          color: HexColor("#FF6B00"),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
