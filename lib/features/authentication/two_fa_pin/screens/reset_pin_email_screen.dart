import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/provider/two_fa_pin_provider.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/screens/reset_pin_otp_screen.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/screens/two_fa_pin_shared.dart';

class ResetPinEmailScreen extends ConsumerStatefulWidget {
  const ResetPinEmailScreen({super.key});

  @override
  ConsumerState<ResetPinEmailScreen> createState() =>
      _ResetPinEmailScreenState();
}

class _ResetPinEmailScreenState extends ConsumerState<ResetPinEmailScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPinProvider);
    final notifier = ref.read(resetPinProvider.notifier);

    return Scaffold(
      backgroundColor: HexColor("#141414"),
      appBar: buildTwoFaGradientAppBar(context, title: 'Reset PIN'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48.0),

              // Email icon circle (blue)
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: HexColor("#1A3A6B"),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mail_outline_rounded,
                  color: HexColor("#4A90D9"),
                  size: 34.0,
                ),
              ),

              const SizedBox(height: 28.0),

              Text(
                'Enter your email',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8.0),

              Text(
                'Enter the email connected to this account',
                style: GoogleFonts.poppins(
                  color: HexColor("#9D9D9D"),
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32.0),

              // Recommendation banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: HexColor("#2A1A00"),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: HexColor("#3A2500"), width: 1.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: HexColor("#C8960C"),
                      size: 20.0,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended',
                            style: GoogleFonts.poppins(
                              color: HexColor("#C8960C"),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'QikTalk will never send you marketing emails. This email is only used for PIN recovery.',
                            style: GoogleFonts.poppins(
                              color: HexColor("#C8960C"),
                              fontSize: 12.5,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28.0),

              // Email label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email Address',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 10.0),

              // Email input
              TextField(
                controller: notifier.emailController,
                onChanged: notifier.updateEmail,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
                cursorColor: HexColor("#C8960C"),
                decoration: InputDecoration(
                  hintText: 'your@gmail.com',
                  hintStyle: GoogleFonts.poppins(
                    color: HexColor("#555555"),
                    fontSize: 14.0,
                  ),
                  filled: true,
                  fillColor: HexColor("#1E1E1E"),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: HexColor("#2E2E2E"),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: HexColor("#3A2A00"),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32.0),

              TwoFaActionButton(
                label: 'Proceed',
                isEnabled: state.isButtonEnabled,
                isLoading: state.isLoading,
                onTap: () async {
                  final success = await notifier.sendResetEmail(context);
                  if (success && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ResetPinOtpScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
