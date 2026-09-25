import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../provider/forget_password_provider.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgetPasswordProvider);
    final notifier = ref.read(forgetPasswordProvider.notifier);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        "Forgot Your Password?",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Enter your email and we’ll help you reset your ",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Text(
                        "password.",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),

                  Form(
                    key: _formKey,
                    onChanged: () => notifier.validateForm(_formKey),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 100.0,
                            left: 25.0,
                          ),
                          child: Text(
                            "Email Address",
                            style: GoogleFonts.sora(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            left: 20.0,
                            right: 20.0,
                          ),
                          child: TextFormField(
                            validator: (value) {
                              final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              final trimmedValue = value?.trim() ?? '';
                              if (trimmedValue == null ||
                                  trimmedValue.isEmpty) {
                                return 'Please enter your email';
                                // return null;
                              }
                              if (trimmedValue.length < 8) {
                                return 'Please enter a valid email address';
                              }
                              if (!regex.hasMatch(trimmedValue)) {
                                return 'Please enter a valid email address';
                              } else {
                                return null; // Return null if the input is valid
                              }
                            },
                            cursorColor: Colors.white,
                            controller: notifier.emailController,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: "example@gmail.com",
                              hintStyle: TextStyle(
                                color: HexColor("#A0A5BA"),
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                              filled:
                                  true, // Set this to true to enable the background color
                              fillColor: HexColor(
                                "#141414",
                              ), // Set the desired background color
                              prefixIcon: Icon(
                                Icons.mail_outline_rounded,
                                color: HexColor("#9D9D9D"),
                                size: 20.0,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: HexColor("#34393A"),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: HexColor("#34393A"),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              counterText: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: state.isButtonEnabled && !state.isLoading
                        ? () => notifier.forgetPassword(context)
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
                                  "Send Code",
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
