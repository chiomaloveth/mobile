import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/authentication/verify_phone_number/provider/verify_phone_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../utilities/components/dialogs/verify_option_dialog.dart';

class VerifyPhoneScreen extends ConsumerStatefulWidget {
  const VerifyPhoneScreen({super.key});

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends ConsumerState<VerifyPhoneScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyPhoneProvider);
    final notifier = ref.read(verifyPhoneProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40.0,
        automaticallyImplyLeading: false,
        title: Row(children: [Expanded(child: SizedBox())]),
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
                        "Verifying your number",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        left: 15.0,
                        right: 15.0,
                      ),
                      child: Text(
                        "Waiting to automatically verify the 6-digit code sent to your phone",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12.0,
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
                          state.phone + ".",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
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
                            "Wrong number?",
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

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          // height: 50.0,
                          margin: const EdgeInsets.only(
                            top: 40.0,
                            left: 14.0,
                            right: 10.0,
                          ),
                          child: OtpTextField(
                            numberOfFields: 6, // Set this to 6
                            // Set the number of OTP fields you want
                            // margin: EdgeInsets.symmetric(horizontal: 3),
                            // borderColor: HexColor("#F0F5FA"),
                            fillColor: HexColor("#D9D9D9"),
                            filled: true,
                            enabledBorderColor: HexColor("#D9D9D9"),
                            focusedBorderColor: HexColor("#D9D9D9"),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            fieldHeight:
                                50.0, // Set the border color for the OTP field
                            fieldWidth: 45.0,
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
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap: () {
                      // resendCode();
                      _openLogOutDialog(context);
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

                  GestureDetector(
                    onTap: state.isButtonEnabled && !state.isLoading
                        ? () => notifier.verifyPhone(context)
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

  void _openLogOutDialog(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => VerifyOptionDialog(),
    );
  }
}
