import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/authentication/reset_password/provider/password_reset_provider.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetProvider);
    final notifier = ref.read(passwordResetProvider.notifier);

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
                        "Create a new password",
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
                        "Choose a strong password you haven’t used ",
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
                        "before.",
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
                            "New password",
                            style: GoogleFonts.sora(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 15.0,
                            left: 20.0,
                            right: 20.0,
                          ),
                          child: TextFormField(
                            validator: (value) {
                              final trimmedValue = value?.trim() ?? '';
                              if (trimmedValue == null ||
                                  trimmedValue.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (trimmedValue.length < 8) {
                                return 'Password must be at least 8 characters long';
                              }
                              // if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              //   return 'Password must contain at least one uppercase letter';
                              // }
                              return null;
                            },
                            controller: notifier.passwordController,
                            obscureText: state.passwordVisible,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: TextStyle(
                                color: HexColor("#9D9D9D"),
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                              filled:
                                  true, // Set this to true to enable the background color
                              fillColor: HexColor(
                                "#141414",
                              ), // Set the desired background color
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: HexColor("#9D9D9D"),
                                size: 20.0,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 16.0,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  state.passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: HexColor("#ACADB9"),
                                ),
                                onPressed: () =>
                                    notifier.togglePasswordVisibility(),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: HexColor("#34393A"),
                                  width: 0.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: HexColor("#34393A"),
                                  width: 0.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              counterText: '',
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, left: 25.0),
                          child: Text(
                            "Confirm new password",
                            style: GoogleFonts.sora(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            top: 15.0,
                            left: 20.0,
                            right: 20.0,
                          ),
                          child: TextFormField(
                            validator: (value) {
                              final confirm = value?.trim() ?? '';
                              final password = notifier.passwordController.text
                                  .trim();

                              if (confirm.isEmpty) {
                                return 'Enter confirm password';
                              }

                              if (confirm.length < 8) {
                                return 'Password must be at least 8 characters long';
                              }

                              if (confirm != password) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                            cursorColor: Colors.white,
                            controller: notifier.confirmPasswordController,
                            obscureText: state.confirmPasswordVisible,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: "Confirm Password",
                              hintStyle: TextStyle(
                                color: HexColor("#9D9D9D"),
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                              filled:
                                  true, // Set this to true to enable the background color
                              fillColor: HexColor(
                                "#141414",
                              ), // Set the desired background color
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: HexColor("#9D9D9D"),
                                size: 20.0,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 16.0,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  state.confirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: HexColor("#ACADB9"),
                                ),
                                onPressed: () =>
                                    notifier.toggleConfirmPasswordVisibility(),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: HexColor("#34393A"),
                                  width: 0.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: HexColor("#34393A"),
                                  width: 0.0,
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
                        ? () => notifier.submitPassword(context)
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
                                  "Reset",
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
