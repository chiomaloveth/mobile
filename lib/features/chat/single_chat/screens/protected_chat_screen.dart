import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

/// Returns [bool] when popped — true if protectedChat is ON, false if OFF.
///
/// Usage in parent:
///   final result = await Navigator.push<bool>(
///     context,
///     MaterialPageRoute(builder: (_) => ProtectedChatScreen(
///       username: groupName,
///       initialProtectedChatValue: protectedChat,
///     )),
///   );
///   if (result != null) setState(() => protectedChat = result);
class ProtectedChatScreen extends StatefulWidget {
  final String username;
  final bool initialProtectedChatValue;

  const ProtectedChatScreen({
    Key? key,
    required this.username,
    this.initialProtectedChatValue = false,
  }) : super(key: key);

  @override
  State<ProtectedChatScreen> createState() => _ProtectedChatScreenState();
}

class _ProtectedChatScreenState extends State<ProtectedChatScreen> {
  bool protectedChat = false;
  bool pinSecurity = false;
  bool faceRecognition = false;
  bool fingerprintSecurity = false;

  @override
  void initState() {
    super.initState();
    protectedChat = widget.initialProtectedChatValue;
  }

  // ── Return protected value on back ────────────────────────────────────────
  void _goBack() => Navigator.pop(context, protectedChat);

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return WillPopScope(
      // Intercept Android hardware back button
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // AppBar
            Container(
              padding: EdgeInsets.only(
                top: topPadding + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _goBack,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg(Theme.of(context).brightness == Brightness.dark),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppTheme.textPrimary(Theme.of(context).brightness == Brightness.dark),
                        size: 22,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.username,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary(Theme.of(context).brightness == Brightness.dark),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _appBarBtn(
                        Icons.videocam_outlined,
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Video call feature'),
                            backgroundColor: HexColor('#FF6B00'),
                            duration: const Duration(seconds: 1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _appBarBtn(
                        Icons.call_outlined,
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Voice call feature'),
                            backgroundColor: HexColor('#FF6B00'),
                            duration: const Duration(seconds: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Protected Chat master toggle
                    _toggleItem(
                      icon: Icons.lock_outline,
                      title: 'Protected Chat',
                      value: protectedChat,
                      onChanged: (v) {
                        setState(() {
                          protectedChat = v;
                          if (!v) {
                            pinSecurity = false;
                            faceRecognition = false;
                            fingerprintSecurity = false;
                          }
                        });
                      },
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      height: 1,
                      color: AppTheme.dividerSubtle(Theme.of(context).brightness == Brightness.dark),
                    ),

                    // PIN Security
                    Opacity(
                      opacity: protectedChat ? 1.0 : 0.4,
                      child: _toggleItem(
                        icon: Icons.pin_outlined,
                        title: 'PIN Security',
                        value: pinSecurity,
                        onChanged: protectedChat
                            ? (v) {
                                if (v) {
                                  _showSetupPinDialog();
                                } else {
                                  setState(() => pinSecurity = false);
                                }
                              }
                            : null,
                      ),
                    ),

                    // Face Recognition
                    Opacity(
                      opacity: protectedChat ? 1.0 : 0.4,
                      child: _toggleItem(
                        icon: Icons.face_outlined,
                        title: 'Face Recognition',
                        value: faceRecognition,
                        onChanged: protectedChat
                            ? (v) {
                                if (v) {
                                  _showSetupFaceRecognitionDialog();
                                } else {
                                  setState(() => faceRecognition = false);
                                }
                              }
                            : null,
                      ),
                    ),

                    // Fingerprint Security
                    Opacity(
                      opacity: protectedChat ? 1.0 : 0.4,
                      child: _toggleItem(
                        icon: Icons.fingerprint_outlined,
                        title: 'Fingerprint Security',
                        value: fingerprintSecurity,
                        onChanged: protectedChat
                            ? (v) {
                                if (v) {
                                  _showSetupFingerprintDialog();
                                } else {
                                  setState(() => fingerprintSecurity = false);
                                }
                              }
                            : null,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBarBtn(IconData icon, VoidCallback onTap) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.cardBg(isDark),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.textPrimary(isDark), size: 22),
      ),
    );
  }

  Widget _toggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool)? onChanged,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color iconColor = AppTheme.iconColor(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF1A7F4B),
              activeTrackColor: const Color(0xFF1A7F4B).withOpacity(0.5),
              inactiveThumbColor: isDark ? const Color(0xFF787880) : Colors.grey.shade400,
              inactiveTrackColor: isDark ? const Color(0xFF39393D) : Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  void _showSetupPinDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color dialogBg = AppTheme.cardBg(isDark);
        final Color textPrimary = AppTheme.textPrimary(isDark);
        final Color textSecondary = AppTheme.textSecondary(isDark);
        final Color inputBg = AppTheme.inputFill(isDark);

        return AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Setup PIN',
          style: GoogleFonts.poppins(color: textPrimary, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create a 4-digit PIN to protect this chat',
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 24,
                letterSpacing: 8,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '----',
                hintStyle: GoogleFonts.poppins(
                  color: AppTheme.textHint(isDark),
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                filled: true,
                fillColor: inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => pinSecurity = true);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PIN Security enabled'),
                  backgroundColor: Color(0xFF1A7F4B),
                ),
              );
            },
            child: Text(
              'Set PIN',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1A7F4B),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
      },
    );
  }

  void _showSetupFaceRecognitionDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color dialogBg = AppTheme.cardBg(isDark);
        final Color textPrimary = AppTheme.textPrimary(isDark);
        final Color textSecondary = AppTheme.textSecondary(isDark);

        return AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Setup Face Recognition',
          style: GoogleFonts.poppins(color: textPrimary, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.face, color: Color(0xFF1A7F4B), size: 64),
            const SizedBox(height: 16),
            Text(
              'Position your face within the frame to enable Face Recognition for this chat',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => faceRecognition = true);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Face Recognition enabled'),
                  backgroundColor: Color(0xFF1A7F4B),
                ),
              );
            },
            child: Text(
              'Enable',
              style: GoogleFonts.poppins(
                color: const Color(0xFF34C759),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
      },
    );
  }

  void _showSetupFingerprintDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color dialogBg = AppTheme.cardBg(isDark);
        final Color textPrimary = AppTheme.textPrimary(isDark);
        final Color textSecondary = AppTheme.textSecondary(isDark);

        return AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Setup Fingerprint',
          style: GoogleFonts.poppins(color: textPrimary, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fingerprint, color: Color(0xFF34C759), size: 64),
            const SizedBox(height: 16),
            Text(
              'Touch the fingerprint sensor to enable Fingerprint Security for this chat',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => fingerprintSecurity = true);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fingerprint Security enabled'),
                  backgroundColor: Color(0xFF34C759),
                ),
              );
            },
            child: Text(
              'Enable',
              style: GoogleFonts.poppins(
                color: const Color(0xFF34C759),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
      },
    );
  }
}
