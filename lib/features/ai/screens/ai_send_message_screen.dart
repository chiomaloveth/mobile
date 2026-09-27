import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'ai_chat_screen.dart';

class AISendMessageScreen extends ConsumerStatefulWidget {
  const AISendMessageScreen({super.key});

  @override
  ConsumerState<AISendMessageScreen> createState() => _AISendMessageScreenState();
}

class _AISendMessageScreenState extends ConsumerState<AISendMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            onTap: () {},
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
                  const SizedBox(height: 30),

                  // Qik AI Title
                  Text(
                    "Qik AI",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 28.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),

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
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Bottom section with input and icons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 20.0),
              child: Column(
                children: [
                  // Message Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg(isDark),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppTheme.border(isDark), width: 1),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 14.0,
                            ),
                            decoration: InputDecoration(
                              hintText: "Explain quantum computing in simple terms",
                              hintStyle: GoogleFonts.poppins(
                                color: AppTheme.textHint(isDark),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
                            ),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                        GestureDetector(
                          onTap: _hasText
                              ? () {
                                  final message = _messageController.text.trim();
                                  if (message.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AIChatScreen(initialMessage: message),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Icon(
                              Icons.arrow_forward,
                              color: _hasText
                                  ? AppTheme.iconColor(isDark)
                                  : AppTheme.iconColorSubtle(isDark),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Emoji and Voice Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          color: AppTheme.iconColorSubtle(isDark),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.mic_none,
                          color: AppTheme.iconColorSubtle(isDark),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
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
