import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/authentication/reset_password/components/success_create_password_dialog.dart';
import 'verify_email_dialog.dart';


class CreateLoginDetailsDialog extends StatefulWidget {

  @override
  State<CreateLoginDetailsDialog> createState() => _CreateLoginDetailsDialogState();
}

class _CreateLoginDetailsDialogState extends State<CreateLoginDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;



  // Function to validate the form and update button state
  void _validateFormField() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isButtonEnabled = true;
      });
    } else {
      setState(() {
        _isButtonEnabled = false;
      });
    }
  }


  TextEditingController emailAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();




  @override
  void dispose() {
    emailAddressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }




  /// Called when the user taps "Proceed".
  /// Does NO backend call — just opens VerifyEmailDialog.
  /// The OTP is sent by VerifyEmailDialog when it opens (initState),
  /// so the email is only touched by the backend after the user reaches
  /// the verification screen. The email+password are saved only after
  /// successful OTP verification.
  Future<void> createLoginDetails() async {
    // Await result from the full VerifyEmail flow.
    // WillPopScope inside VerifyEmailDialog blocks accidental dismissal.
    final bool? verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => PopScope(
        canPop: true,
        child: VerifyEmailDialog(
          email: emailAddressController.text.trim(),
          password: passwordController.text.trim(),
        ),
      ),
    );

    if (verified == true && mounted) {
      // Capture navigator BEFORE popping so nav.context stays valid
      // for showing SuccessCreatePasswordDialog after self-dismiss.
      final nav = Navigator.of(context, rootNavigator: true);
      nav.pop(); // Close CreateLoginDetailsDialog → resolves CustomBottomNav's await
      showDialog(
        context: nav.context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) => SuccessCreatePasswordDialog(),
      );
    }
    // If verified is null/false, stay on this dialog so the user can retry.
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Block hardware back button
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
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              decoration: BoxDecoration(
                color: HexColor("#101010"),
                borderRadius: BorderRadius.circular(19.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        "Let’s get to know you better.",
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
                  padding: const EdgeInsets.only(top: 10.0, left: 24.0, right: 24.0),
                  child: Text(
                    "Save your details, these informations will be required when next you sign in.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: HexColor("#ACADB9"),
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              Form(
                key: _formKey,
                onChanged: _validateFormField,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 🔥 CRITICAL
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    Padding(
                      padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
                      child: TextFormField(
                        validator: (value) {
                          final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          final trimmedValue = value?.trim() ?? '';
                          if (trimmedValue == null || trimmedValue.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (trimmedValue.length < 8) {
                            return 'Please enter a valid email address';
                          }
                          if (!regex.hasMatch(trimmedValue)) {
                            return 'Please enter a valid email address';
                          }
                          else{
                            return null;
                          }
                        },
                        cursorColor: Colors.white,
                        controller: emailAddressController,
                        keyboardType:TextInputType.emailAddress,
                        style: TextStyle(fontSize: 15.0, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(color: HexColor("#9D9D9D"), fontSize: 14.0, fontWeight: FontWeight.normal),
                          filled: true,
                          fillColor: HexColor("#141414"),
                          prefixIcon: Icon(Icons.mail_outline_rounded, color: HexColor("#9D9D9D"),size: 20.0,),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: HexColor("#34393A"), width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color:HexColor("#34393A"), width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          counterText: '',
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
                      child: TextFormField(
                        validator: (value) {
                          final trimmedValue = value?.trim() ?? '';
                          if (trimmedValue == null || trimmedValue.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        cursorColor: Colors.white,
                        controller: passwordController,
                        obscureText: !passwordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(fontSize: 15.0, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Create password",
                          hintStyle: TextStyle(color: HexColor("#9D9D9D"), fontSize: 14.0, fontWeight: FontWeight.normal),
                          filled: true,
                          fillColor: HexColor("#141414"),
                          prefixIcon: Icon(Icons.lock_outline_rounded, color: HexColor("#9D9D9D"),size: 20.0,),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                          suffixIcon: IconButton(icon: Icon(passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,size: 17.0, color: HexColor("#ACADB9"),),
                            onPressed: (){
                              setState(() {
                                passwordVisible = !passwordVisible;
                              },
                              );
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: HexColor("#34393A"), width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color:HexColor("#34393A"), width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          counterText: '',
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
                      child: TextFormField(
                        validator: (value) {
                          final trimmedValue = value?.trim() ?? '';
                          if (trimmedValue == null || trimmedValue.isEmpty) {
                            return 'Enter confirm password';
                          }
                          if (trimmedValue.length < 8) {
                            return 'must be at least 8 characters long';
                          }
                          if (trimmedValue != passwordController.text) {
                            return 'Confirm Passwords do not match with new password';
                          }
                          else{
                            return null;
                          }
                        },
                        cursorColor: Colors.white,
                        controller: confirmPasswordController,
                        obscureText: !confirmPasswordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(fontSize: 15.0, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Re-enter password",
                          hintStyle: TextStyle(color: HexColor("#9D9D9D"), fontSize: 14.0, fontWeight: FontWeight.normal),
                          filled: true,
                          fillColor: HexColor("#141414"),
                          prefixIcon: Icon(Icons.lock_outline_rounded, color: HexColor("#9D9D9D"),size: 20.0,),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                          suffixIcon: IconButton(icon: Icon(confirmPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,size: 17.0, color: HexColor("#ACADB9"),),
                            onPressed: (){
                              setState(() {
                                confirmPasswordVisible = !confirmPasswordVisible;
                              },
                              );
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: HexColor("#34393A"), width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color:HexColor("#34393A"), width: 1.0),
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
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    createLoginDetails();
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 55.0,
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 30.0, bottom: 20.0),
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
                      child: const Text(
                        "Proceed",
                        style: TextStyle(
                          fontFamily: 'DM Sans',
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