import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/provider/two_fa_pin_provider.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/screens/confirm_pin_screen.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/screens/two_fa_pin_shared.dart';

class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPinProvider);
    final notifier = ref.read(resetPinProvider.notifier);

    return Scaffold(
      backgroundColor: HexColor("#141414"),
      appBar: buildTwoFaGradientAppBar(context, title: 'Create PIN'),
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
                'Create your PIN',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8.0),

              Text(
                'Choose a 6-digit PIN that only you will know',
                style: GoogleFonts.poppins(
                  color: HexColor("#9D9D9D"),
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40.0),

              // PIN input field
              TwoFaPinTextField(
                controller: notifier.newPinController,
                onChanged: notifier.updateNewPin,
                hintText: 'Enter 6-digit PIN',
              ),

              const SizedBox(height: 16.0),

              // Security tip banner (blue)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  color: HexColor("#0D1A2E"),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: HexColor("#1A2E4A"), width: 1.0),
                ),
                child: Text(
                  'Don\'t use easily guessable PINs like your birthday\nor "123456"',
                  style: GoogleFonts.poppins(
                    color: HexColor("#4A90D9"),
                    fontSize: 13.0,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40.0),

              // Next — go to confirm screen
              TwoFaActionButton(
                label: 'Next',
                isEnabled: state.isButtonEnabled,
                isLoading: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConfirmPinScreen(),
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
