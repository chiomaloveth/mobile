import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/settings/account/screens/two_step_verification/confirm_pin_screen.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class CreatePinScreen extends ConsumerStatefulWidget {
  /// Optional callback invoked when the full setup chain completes.
  /// When provided, the success screen calls this instead of popping to root.
  final VoidCallback? onSetupComplete;

  const CreatePinScreen({super.key, this.onSetupComplete});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onNext() {
    final pin = _pinController.text.trim();
    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be 6 digits')),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ConfirmPinScreen(
        originalPin: pin,
        onSetupComplete: widget.onSetupComplete,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);
    final double topPadding = MediaQuery.of(context).padding.top + 10;

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
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? HexColor("#3A1D07") : AppTheme.scaffoldBg(isDark),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: isDark ? const DecorationImage(
                  image: AssetImage("images/app_bar_gredient.png"),
                  fit: BoxFit.cover,
                ) : null,
                color: isDark ? null : AppTheme.scaffoldBg(isDark),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topPadding,
                            left: 16.0,
                            right: 40.0,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 22.0,
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: topPadding, left: 10.0),
                        child: Text(
                          "Create PIN",
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24, 60, 24,
                MediaQuery.of(context).viewInsets.bottom + 40,
              ),
              child: Column(
                children: [
                  // Lock icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3A2A1A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFFFFB800),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Create your PIN',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose a 6-digit PIN that only you will know',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // PIN input field
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        obscureText: false,
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 12,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          hintText: 'Enter 6-digit PIN',
                          hintStyle: GoogleFonts.poppins(
                            color: isDark ? Colors.white24 : Colors.black26,
                            fontSize: 16,
                            letterSpacing: 0,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Blue info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2A3A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Don\'t use easily guessable PINs like your birthday or "123456"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6AADDB),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Next button
                  GestureDetector(
                    onTap: _pinController.text.length == 6 ? _onNext : null,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _pinController.text.length == 6
                            ? const Color(0xFF5C3A1A)
                            : const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Next',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
