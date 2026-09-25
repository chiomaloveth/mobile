import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import '../../../../utilities/constants/app_strings/api_strings.dart';
import '../../../../utilities/database/save_values.dart';
import '../../../../utilities/services/app_pref_helper.dart';

class VerifyEmailDialog extends StatefulWidget {
  final String email;
  final String password;

  const VerifyEmailDialog({
    Key? key,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<VerifyEmailDialog> createState() => _VerifyEmailDialogState();
}

class _VerifyEmailDialogState extends State<VerifyEmailDialog> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isLoading = false;      // for the OTP verify API call
  bool _isSendingOtp = false;   // for the OTP send / resend API call
  String _message = "";
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _focusedIndex = i;
          });
        }
      });
    }
    // Auto-send OTP as soon as the dialog is visible.
    // The backend is called HERE — not in CreateLoginDetailsDialog —
    // so the email only reaches the backend when the user arrives at
    // this verification screen.
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode {
    return _controllers.map((c) => c.text).join();
  }

  bool get _isButtonEnabled {
    return _otpCode.length == 6;
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    setState(() {});
  }

  /// Requests a 6-digit OTP to be sent to [widget.email].
  /// Called automatically in initState and when the user taps "Didn't get a code?".
  Future<void> _sendOtp() async {
    if (_isSendingOtp) return; // prevent concurrent requests
    setState(() {
      _isSendingOtp = true;
      _message = "";
    });

    final String apiUrl =
        "${ApiStrings.baseUri}auth/onboarding/email-verification/request";
    final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          "Content-type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(<String, String>{
          "email": widget.email,
          "password": widget.password,
        }),
      );

      if (!mounted) return;
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      setState(() {
        _isSendingOtp = false;
        _message = response.statusCode == 200
            ? responseData['message'] ?? "Verification code sent!"
            : responseData['message'] ?? "Failed to send code.";
      });

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSendingOtp = false;
        _message = "Network error. Please try again.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to send code. Please try again.")),
      );
    }
  }

  /// Resend the OTP (tapped on "Didn't get a code?").
  Future<void> _resendCode() => _sendOtp();

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _message = "";
    });

    final String apiUrl = "${ApiStrings.baseUri}auth/onboarding/email-verification/verify";
    final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          "Content-type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(<String, String>{
          "email": widget.email,
          "otp": _otpCode,
          "password": widget.password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() { _isLoading = false; });

        // Save new authentication details locally.
        final String newToken = responseData['token'];
        final bool hasPassword = responseData['user']['hasPassword'] ?? true;

        await SaveValues().saveString(AppPreferenceHelper.AUTH_TOKEN, newToken);
        await SaveValues().saveBool(AppPreferenceHelper.HAS_PASSWORD, hasPassword);

        // Return `true` to CreateLoginDetailsDialog which is awaiting this result.
        // It will pop itself (resolving chat_screen's await with HAS_PASSWORD=true)
        // and then show SuccessCreatePasswordDialog via its captured navigator context.
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() {
          _isLoading = false;
          _message = responseData['message'] ?? "Incorrect verification code.";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_message)),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error occurred. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Allow hardware back button to navigate backwards
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 25.0),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [HexColor("#FF00A8"), HexColor("#00D1FF")],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: HexColor("#FF00A8").withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(-10, -10),
                ),
                BoxShadow(
                  color: HexColor("#FB8830").withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(10, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(1.0), // 1px padding for gradient outline
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                color: HexColor("#101010"),
                borderRadius: BorderRadius.circular(19.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Row with Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22.0),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        "Verify Email",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0, left: 30.0, right: 30.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "We sent a 6-digit verification code to\n${widget.email}",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: HexColor("#ACADB9"),
                              fontSize: 13.0,
                              fontWeight: FontWeight.normal,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context, false);
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
                        ],
                      ),
                    ),
                  ),

              const SizedBox(height: 35.0),

              // OTP Circles Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final bool isFocused = _focusedIndex == index;
                    return Container(
                      width: 42.0,
                      height: 42.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFocused
                              ? HexColor("#FB8830")
                              : HexColor("#505050"),
                          width: 1.5,
                        ),
                        color: Colors.transparent,
                      ),
                      child: Center(
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          cursorColor: HexColor("#FB8830"),
                          decoration: const InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) => _onOtpChanged(index, value),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 35.0),

              GestureDetector(
                onTap: (_isLoading || _isSendingOtp) ? null : _resendCode,
                child: Center(
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

              const SizedBox(height: 35.0),

              // Verify Email Button
              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () {
                        if (_otpCode.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter the 6-digit verification code")),
                          );
                        } else {
                          _verifyOtp();
                        }
                      },
                child: Container(
                  width: double.infinity,
                  height: 55.0,
                  margin: const EdgeInsets.only(left: 20, right: 20, bottom: 15.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [HexColor("#FF00A8"), HexColor("#00D1FF")],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: HexColor("#FB8830").withOpacity(0.4),
                        blurRadius: 25,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: HexColor("#1B1B1B"),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              "Verify Email",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }
}
