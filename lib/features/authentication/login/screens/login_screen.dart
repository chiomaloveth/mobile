import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/authentication/forgot_password/screens/forget_password_screen.dart';

import '../../register/screens/sign_up_screen.dart';
import '../provider/login_provider.dart';

class LogInScreen extends ConsumerStatefulWidget {
  const LogInScreen({super.key});

  @override
  ConsumerState<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends ConsumerState<LogInScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);

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
              clipBehavior: Clip.none,
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
                          "Sign In ",
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
                      onChanged: () => notifier.validateForm(_formKey),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 50.0,
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
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                              controller: notifier.emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: "Email",
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
                            padding: const EdgeInsets.only(
                              top: 25.0,
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
                                // if (trimmedValue.length < 8) {
                                //   return 'Password must be at least 8 characters long';
                                // }
                                // if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                //   return 'Password must contain at least one uppercase letter';
                                // }
                                return null;
                              },
                              cursorColor: Colors.white,
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                              controller: notifier.passwordController,
                              obscureText: !state.passwordVisible,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
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
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey,
                                    size: 20.0,
                                  ),
                                  onPressed: notifier.togglePasswordVisibility,
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

                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0, top: 20),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const ForgetPasswordScreen();
                                },
                              ),
                            );
                          },
                          child: Text(
                            "Forget Password?",
                            style: TextStyle(
                              color: HexColor("#1A7F4B"),
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: state.isButtonEnabled
                          ? () => notifier.login(context)
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
                                    "Sign In",
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

                    /// SIGN UP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              color: HexColor("#1A7F4B"),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
}
