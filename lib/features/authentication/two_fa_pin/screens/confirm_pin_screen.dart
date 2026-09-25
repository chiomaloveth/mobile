import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/provider/two_fa_pin_provider.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/screens/pin_reset_success_screen.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/screens/two_fa_pin_shared.dart';

class ConfirmPinScreen extends ConsumerStatefulWidget {
  const ConfirmPinScreen({super.key});

  @override
  ConsumerState<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends ConsumerState<ConfirmPinScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPinProvider);
    final notifier = ref.read(resetPinProvider.notifier);

    return Scaffold(
      backgroundColor: HexColor("#141414"),
      appBar: buildTwoFaGradientAppBar(context, title: 'Confirm PIN'),
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
                'Re-enter your PIN',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8.0),

              Text(
                'Please re-enter your PIN to confirm',
                style: GoogleFonts.poppins(
                  color: HexColor("#9D9D9D"),
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40.0),

              // Confirm PIN input field
              TwoFaPinTextField(
                controller: notifier.confirmPinController,
                onChanged: notifier.updateConfirmPin,
                hintText: '------',
                letterSpacing: 8.0,
              ),

              if (state.errorMessage != null) ...[
                const SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.errorMessage!,
                    style: GoogleFonts.poppins(
                      color: HexColor("#E05252"),
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40.0),

              // Confirm — validate match then call API
              TwoFaActionButton(
                label: 'Confirm',
                isEnabled: state.isButtonEnabled,
                isLoading: state.isLoading,
                onTap: () async {
                  // Local PIN match check
                  if (notifier.confirmPinController.text !=
                      notifier.newPinController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'PINs do not match. Please try again.',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        backgroundColor: HexColor("#5C2E00"),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    return;
                  }

                  // Call API: verify OTP + set new PIN in one request
                  final success =
                      await notifier.verifyOtpAndSetPin(context);
                  if (success && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PinResetSuccessScreen(),
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
