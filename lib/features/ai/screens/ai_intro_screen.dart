import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'ai_send_message_screen.dart';

class AIIntroScreen extends ConsumerWidget {
  const AIIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: AppTheme.iconColor(isDark), size: 24),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // Open menu
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.more_vert, color: AppTheme.iconColor(isDark), size: 24),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Qik AI Title
                  Text(
                    "Qik AI",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 28.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Information Cards
                  _buildInfoCard(
                    "Remembers what user said\nearlier in the conversation",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    "Allows user to provide.\nfollow-up corrections With Ai",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    "Limited knowledge of world\nand events after 2021",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    "May occasionally generate\nincorrect information",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    "May occasionally produce harmful\ninstructions or biased content",
                    isDark,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Send message input - ✅ FIXED WITH SAFEAREA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AISendMessageScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(isDark),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppTheme.border(isDark), width: 1),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          "Send a message.",
                          style: GoogleFonts.poppins(
                            color: AppTheme.textHint(isDark),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.arrow_forward,
                          color: AppTheme.iconColorSubtle(isDark),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border(isDark), width: 1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: AppTheme.textSecondary(isDark),
          fontSize: 13.0,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }
}
