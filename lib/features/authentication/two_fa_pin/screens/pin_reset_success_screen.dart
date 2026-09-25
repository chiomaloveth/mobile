import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/authentication/two_fa_pin/screens/two_fa_pin_shared.dart';
import 'package:qik_talk/utilities/bottom_nav/screen/custom_bottom_nav.dart';

class PinResetSuccessScreen extends StatelessWidget {
  const PinResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#141414"),
      appBar: buildTwoFaGradientAppBar(context, title: 'All set!'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60.0),

              // Success checkmark circle (green)
              Container(
                width: 90.0,
                height: 90.0,
                decoration: BoxDecoration(
                  color: HexColor("#0D3A1E"),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: HexColor("#2ECC71"),
                  size: 44.0,
                ),
              ),

              const SizedBox(height: 32.0),

              Text(
                'PIN reset was successful',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10.0),

              Text(
                'Your PIN has been successfully reset.',
                style: GoogleFonts.poppins(
                  color: HexColor("#9D9D9D"),
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Done — navigate to home (auth token already saved by verifyOtpAndSetPin)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => CustomBottomNav()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56.0,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: HexColor("#5C2E00"),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Center(
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.0,
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
    );
  }
}
