import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/authentication/register/provider/signUpProvider.dart';

import '../../login/screens/login_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpProvider);
    final notifier = ref.read(signUpProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
          backgroundColor: HexColor("#161616"),
        ),
        backgroundColor: HexColor("#161616"),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            child: Stack(
              clipBehavior: Clip.none, // allows overlap
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.20,
                  ),
                  height: MediaQuery.of(context).size.height * 0.79,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/waves.png"),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.only(),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 0.0,
                          left: 0.0,
                          top: 40.0,
                        ),
                        child: Image(
                          image: AssetImage("images/sign_up_logo.png"),
                          width: 210.0,
                          height: 155.0,
                        ),
                      ),
                    ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.0, left: 0.0),
                        child: Text(
                          "Welcome to Qikchat",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 21.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 0.0),
                        child: Text(
                          "Join the conversation. ",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0.0, left: 0.0),
                        child: Text(
                          "Enter your phone number to get started.",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),

                    Form(
                      key: _formKey,
                      onChanged: () => notifier.onPhoneChanged(
                        notifier.phoneController.text,
                        _formKey,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 50.0,
                              left: 20.0,
                              right: 20.0,
                            ),
                            child: TextFormField(
                              validator: (value) {
                                final regex = RegExp(r'^[+-]?\d+(\.\d+)?$');
                                final trimmedValue = value?.trim() ?? '';
                                if (trimmedValue == null ||
                                    trimmedValue.isEmpty) {
                                  return 'Enter phone Number';
                                }
                                // if (trimmedValue.length < 10) {
                                //   return 'Enter a valid Phone Number';
                                // }
                                if (!regex.hasMatch(trimmedValue)) {
                                  return 'Enter a valid Phone Number';
                                } else {
                                  return null; // Return null if the input is valid
                                }
                              },
                              cursorColor: Colors.black,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                              controller: notifier.phoneController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Phone number",
                                hintStyle: TextStyle(
                                  color: HexColor("#9D9D9D"),
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        state
                                            .country
                                            .flagEmoji, // Nigerian flag emoji
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      GestureDetector(
                                        onTap: () => _showCountryPicker(
                                          context,
                                          notifier,
                                        ),
                                        child: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                          size: 24.0,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '+${state.country.phoneCode}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: 0,
                                  minHeight: 0,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: HexColor("#000000"),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: HexColor("#000000"),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                counterText: '',
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Checkbox(
                                    value: state.rememberMe,
                                    onChanged: (v) =>
                                        notifier.toggleRememberMe(v!),
                                    activeColor: Colors
                                        .white, // color of the checkbox when selected
                                    checkColor: Colors
                                        .black, // color of the checkmark itself
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 0.0),
                                  child: Text(
                                    "Remember me",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: state.isButtonEnabled
                                ? () => notifier.requestOtp(context)
                                : null,
                            child: Container(
                              width: double
                                  .infinity, // makes sure it takes the full width
                              height: 55.0,
                              margin: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 30.0,
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
                                          color: HexColor(
                                            "#FB8830",
                                          ).withOpacity(0.4),
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
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          "Sign Up",
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

                          const SizedBox(height: 20),

                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Text(
                                "By continuing, you agree to our Terms & Privacy Policy.",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10.50,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),

                          Container(
                            margin: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.0,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return const LogInScreen();
                                          },
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: HexColor("#1A7F4B"),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 40.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------- COUNTRY PICKER ----------------
  void _showCountryPicker(BuildContext context, SignUpNotifier notifier) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: notifier.changeCountry, // ✅ PROVIDER USED HERE
    );
  }
}
