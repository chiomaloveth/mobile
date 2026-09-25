import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/provider/two_fa_pin_provider.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/screens/reset_pin_email_screen.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/screens/two_fa_pin_shared.dart';

import '../../provider/user_provider.dart';

class TwoFaPinScreen extends ConsumerStatefulWidget {
  const TwoFaPinScreen({super.key});

  @override
  ConsumerState<TwoFaPinScreen> createState() => _TwoFaPinScreenState();
}

class _TwoFaPinScreenState extends ConsumerState<TwoFaPinScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(twoFaPinProvider);
    final notifier = ref.read(twoFaPinProvider.notifier);
    final user = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: HexColor("#141414"),
      appBar: buildTwoFaGradientAppBar(
        context,
        title: 'Enter 2FA PIN',
        showBack: false,
      ),
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

              // Title
              Text(
                'Enter your PIN',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8.0),

              // Subtitle
              Text(
                'Enter your 6-digit Secret PIN',
                style: GoogleFonts.poppins(
                  color: HexColor("#9D9D9D"),
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
              ),

              const SizedBox(height: 40.0),

              // PIN input field
              TwoFaPinTextField(
                controller: notifier.pinController,
                onChanged: notifier.updatePin,
                hintText: 'Enter 6-digit PIN',
              ),

              const SizedBox(height: 20.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Forgot PIN? ',
                    style: GoogleFonts.poppins(
                      color: HexColor("#9D9D9D"),
                      fontSize: 14.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ResetPinEmailScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Reset PIN',
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

              // Authenticate button
              TwoFaActionButton(
                label: 'Authenticate',
                isEnabled: state.isButtonEnabled,
                isLoading: state.isLoading,
                onTap: () => notifier.authenticate(context: context, userID: user.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
