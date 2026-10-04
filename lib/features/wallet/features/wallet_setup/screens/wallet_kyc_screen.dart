import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/wallet/features/wallet_setup/screens/wallet_kyc_selfie_screen.dart';
import 'package:qik_talk/features/wallet/features/wallet_setup/services/wallet_setup_services.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class WalletKYCScreen extends ConsumerStatefulWidget {
  const WalletKYCScreen({super.key});

  @override
  ConsumerState<WalletKYCScreen> createState() => _WalletKYCScreenState();
}

class _WalletKYCScreenState extends ConsumerState<WalletKYCScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bvnController = TextEditingController();
  final TextEditingController _createSecurePINController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _hasAgreed = false;

  void _handleCheckBox() {
    setState(() {
      _hasAgreed = !_hasAgreed;
    });
  }

  @override
  void initState() {
    super.initState();
    // ref.read(userProfileProvider.notifier).loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark ? const Color(0xFF1C0D05) : AppTheme.scaffoldBg(isDark),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : AppTheme.scaffoldBg(isDark),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: 70,
          leading: _buildCustomBackButton(context: context, isDark: isDark),
          title: Text(
            "Setup Wallet",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              letterSpacing: 0.2,
            ),
          ),
          centerTitle: false,
          titleSpacing: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isDark
                ? const RadialGradient(
                    center: Alignment(0.3, 1.1),
                    radius: 1.3,
                    colors: [Color(0xFF2E1202), Color(0xFF070505)],
                    stops: [0.0, 1.0],
                  )
                : null,
            color: isDark ? null : AppTheme.scaffoldBg(isDark),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Enter your details to create your secure wallet",
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: isDark ? const Color(0xFFAFAFAF) : AppTheme.textSecondary(isDark),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 28),

                    _buildCustomTextField(
                      title: "Full Name",
                      hintText: "Odogwu Hilary",
                      controller: _fullNameController,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    _buildCustomTextField(
                      title: "Email Address",
                      hintText: "odogwu@gmail.com",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    _buildCustomTextField(
                      title: "Phone Number",
                      hintText: "+234 801 234 5678",
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    _buildCustomTextField(
                      title: "BVN Number",
                      hintText: "11111111111",
                      controller: _bvnController,
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    _buildCustomTextField(
                      title: "Date Of Birth",
                      hintText: "yyyy-mm-dd",
                      controller: _dobController,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    _buildCustomTextField(
                      title: "Create Security PIN",
                      hintText: "Enter 4-digit PIN",
                      controller: _createSecurePINController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 28),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _handleCheckBox,
                          child: Container(
                            margin: const EdgeInsets.only(top: 2, right: 14),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _hasAgreed
                                  ? const Color(0xFF7A340C)
                                  : (isDark ? const Color(0xFFB0B0B0) : AppTheme.border(isDark)),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: _hasAgreed
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "I agree to the Terms & Conditions\nand Privacy Policy",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark ? const Color(0xFFD1D1D1) : AppTheme.textSecondary(isDark),
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 45),

                    Container(
                      height: 58,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF381B09), Color(0xFF7F3B11)],
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            Map<String, dynamic> data = {
                              "fullName": _fullNameController.text.trim(),
                              "email": _emailController.text.trim(),
                              "phoneNumber": _phoneNumberController.text.trim(),
                              "BVN": _bvnController.text.trim(),
                              "securePin": _createSecurePINController.text.trim(),
                              "dob": _dobController.text.trim(),
                            };

                            if (_fullNameController.text.trim().isEmpty ||
                                _emailController.text.trim().isEmpty ||
                                _phoneNumberController.text.trim().isEmpty ||
                                _bvnController.text.trim().isEmpty ||
                                _createSecurePINController.text.trim().isEmpty ||
                                _dobController.text.trim().isEmpty ||
                                !_hasAgreed) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All fields are required, and also agree to the terms and conditions")));
                            } else {
                              final registered = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (context) => SelfieVerificationFlow(data: data),
                                ),
                              );
                              if (registered == true && context.mounted) {
                                Navigator.of(context).pop(true);
                              }
                            }
                          },
                          child: Center(
                            child: Text(
                              "Create Wallet",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBackButton({required BuildContext context, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 8, bottom: 8, right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C1B) : AppTheme.cardBg(isDark),
          shape: BoxShape.circle,
          border: Border.all(
            width: 1,
            color: isDark ? const Color(0xFF383533) : AppTheme.border(isDark),
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFDEDEDE) : AppTheme.textPrimary(isDark),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1817) : AppTheme.inputFill(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              width: 1,
              color: isDark ? const Color(0xFF33302D) : AppTheme.inputBorder(isDark),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              fontSize: 15,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18),
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                color: isDark ? const Color(0xFF6B6562) : AppTheme.textHint(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
