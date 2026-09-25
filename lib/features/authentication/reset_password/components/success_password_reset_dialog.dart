import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/group_chat/screens/create_new_group_screen.dart';
import 'package:qik_talk/features/community/screens/create_new_community_screen.dart';
import 'package:qik_talk/features/broadcast/screens/create_new_broadcast_list_screen.dart';
import 'package:qik_talk/features/contact/screens/create_new_contact_screen.dart';
import 'package:qik_talk/features/chat/single_chat/screens/new_chat_screen.dart';
import 'package:qik_talk/features/authentication/login/screens/login_screen.dart';

class SuccessPasswordResetDialog extends StatefulWidget {
  @override
  State<SuccessPasswordResetDialog> createState() =>
      _SuccessPasswordResetDialogState();
}

class _SuccessPasswordResetDialogState
    extends State<SuccessPasswordResetDialog> {
  bool isLoadingVisible = true;
  String signUpEmail = "";

  String token = "";
  String message = "";
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  void _navigateToScreen(Widget screen) {
    Navigator.pop(context); // Close the dialog first
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // insetPadding: EdgeInsets.symmetric(horizontal: 25.0),
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            color: HexColor("#212121"),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: HexColor("#212121"), width: 1.0),
          ),
          child: Column(
            children: [

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0, right: 20.0),
                    child: Image(
                      image: AssetImage("images/cancel_icon.png"),
                      width: 20.0,
                      height: 20.0,
                    ),
                  ),
                ),
              ),



              Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Image(
                      image: AssetImage("images/password_reset_icon.png"),
                      width: 100.0,
                      height: 100.0,
                    ),
                  ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0, left: 0.0),
                  child: Text(
                    "Password reset successful",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Text(
                    "You can now sign in with your",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: HexColor("#F5F6F7"),
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),


              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 0.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Text(
                    "new password.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: HexColor("#F5F6F7"),
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),


              GestureDetector(
                onTap:(){

                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return LogInScreen();
                  }));
                },
                child: Container(
                  width: double.infinity, // makes sure it takes the full width
                  height: 55.0,
                  margin:const EdgeInsets.only(left: 16, right: 16, top: 50.0, bottom: 10.0),
                  decoration: BoxDecoration(
                    gradient:  LinearGradient(
                      colors: [HexColor("#FF00A8"), HexColor("#00D1FF")],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: HexColor("#FB8830").withOpacity(0.4),
                        blurRadius: 25, // 🔥 increase blur
                        spreadRadius: 2,
                        offset: Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30, // 🔥 soft ambient blur
                        offset: Offset(0, 20),
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
                      child: Text("Sign in",
                        style: const TextStyle(
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
          // child: Center(child: Text('Error: ${snapshot.error}')),
        ),
      ),
    );
  }
}
