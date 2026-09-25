import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/authentication/reset_password/components/success_password_reset_dialog.dart';
import 'package:qik_talk/features/authentication/verify_otp/providers/verifyOtpProvider.dart';
import 'package:qik_talk/features/authentication/verify_phone_number/provider/verify_phone_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyOtpProvider);
    final notifier = ref.read(verifyOtpProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40.0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.only(top: 0.0, left: 16.0, right: 40.0),
                child: Icon(Icons.arrow_back, size: 22.0, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: HexColor("#161616"),
      ),
      backgroundColor: HexColor("#161616"),
      body: SizedBox(
        child: SingleChildScrollView(
          child: Stack(
            clipBehavior: Clip.none, // allows overlap
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.35,
                ),
                height: MediaQuery.of(context).size.height * 0.79,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/wsp_logo.png"),
                    fit: BoxFit.fitWidth,
                  ),
                  borderRadius: BorderRadius.only(),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        "Check your email",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Enter the 6-digit code sent to your email.",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(child: SizedBox()),

                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          state.email + ".",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 2.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Wrong email?",
                            style: GoogleFonts.poppins(
                              color: HexColor("#FB8830"),
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      Expanded(child: SizedBox()),
                    ],
                  ),

                  Container(
                    // height: 50.0,
                    margin: const EdgeInsets.only(
                      top: 40.0,
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: OtpTextField(
                      numberOfFields: 6, // Set this to 6
                      // Set the number of OTP fields you want
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      // borderColor: HexColor("#F0F5FA"),
                      fillColor: HexColor("#D9D9D9"),
                      filled: true,
                      enabledBorderColor: HexColor("#D9D9D9"),
                      focusedBorderColor: HexColor("#D9D9D9"),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      fieldHeight:
                          45.0, // Set the border color for the OTP field
                      fieldWidth: 42.0,
                      cursorColor: Colors.black,
                      // obscureText: true,
                      textStyle: TextStyle(
                        fontFamily: 'DM Sans',
                        color: Colors.black,
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                      ),
                      showFieldAsBox:
                          true, // If true, show the fields with a box
                      onSubmit: notifier.updateOtp,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      // resendCode();
                      // _openLogOutDialog(context);
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Text(
                          "Didnt get a code?",
                          style: GoogleFonts.poppins(
                            color: HexColor("#FB8830"),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Text(
                        "0:${state.secondsRemaining.toString().padLeft(2, '0')}",
                        style: GoogleFonts.poppins(
                          color: HexColor("#434141"),
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: state.isButtonEnabled && !state.isLoading
                        ? () => notifier.verifyEmailOtp(context)
                        : null,
                    child: Container(
                      width:
                          double.infinity, // makes sure it takes the full width
                      height: 55.0,
                      margin: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 200.0,
                      ),
                      decoration: BoxDecoration(
                        gradient: state.isButtonEnabled
                            ? LinearGradient(
                                colors: [
                                  HexColor("#FF00A8"),
                                  HexColor("#00D1FF"),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade700,
                                  Colors.grey.shade700,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: state.isButtonEnabled
                            ? [
                                BoxShadow(
                                  color: HexColor("#FB8830").withOpacity(0.4),
                                  blurRadius: 25,
                                  spreadRadius: 2,
                                  offset: Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: Offset(0, 20),
                                ),
                              ]
                            : [], // ❌ no glow when disabled
                      ),
                      padding: const EdgeInsets.all(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: HexColor("#1B1B1B"),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Center(
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Continue",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
