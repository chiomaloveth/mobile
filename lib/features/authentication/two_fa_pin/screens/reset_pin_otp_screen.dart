import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/provider/two_fa_pin_provider.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/screens/create_pin_screen.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/screens/two_fa_pin_shared.dart';

class ResetPinOtpScreen extends ConsumerStatefulWidget {
  const ResetPinOtpScreen({super.key});

  @override
  ConsumerState<ResetPinOtpScreen> createState() => _ResetPinOtpScreenState();
}

class _ResetPinOtpScreenState extends ConsumerState<ResetPinOtpScreen> {
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

              // Lock icon circle
              buildTwoFaIconCircle(
                color: HexColor("#4A3A00"),
                icon: Icons.lock_outline_rounded,
                iconColor: HexColor("#C8960C"),
              ),

              const SizedBox(height: 28.0),

              Text(
                'Reset OTP Sent',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8.0),

              Text(
                'Enter the 6-digit Reset OTP Code sent to\nyour email',
                style: GoogleFonts.poppins(
                  color: HexColor("#9D9D9D"),
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40.0),

              // OTP input field
              TwoFaPinTextField(
                controller: notifier.otpController,
                onChanged: notifier.updateOtp,
                hintText: '------',
                letterSpacing: 8.0,
              ),

              const SizedBox(height: 16.0),

              // Error or resend row
              if (state.errorMessage != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        'Code is Incorrect or expired. ',
                        style: GoogleFonts.poppins(
                          color: HexColor("#9D9D9D"),
                          fontSize: 13.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => notifier.resendOtp(context),
                        child: Text(
                          'Try again',
                          style: GoogleFonts.poppins(
                            color: HexColor("#C8960C"),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't get it? ",
                      style: GoogleFonts.poppins(
                        color: HexColor("#9D9D9D"),
                        fontSize: 14.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => notifier.resendOtp(context),
                      child: Text(
                        'Resend',
                        style: GoogleFonts.poppins(
                          color: HexColor("#C8960C"),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 40.0),

              // Next — navigate to Create PIN screen
              // (OTP is validated server-side together with the new PIN in reset-pin)
              TwoFaActionButton(
                label: 'Next',
                isEnabled: state.isButtonEnabled,
                isLoading: state.isLoading,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreatePinScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
