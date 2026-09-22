import'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../services/app_pref_helper.dart';
import '../../database/save_values.dart';



class VerifyOptionDialog extends StatefulWidget {
  const VerifyOptionDialog({super.key});

  @override
  State<VerifyOptionDialog> createState() => _VerifyOptionDialogState();
}

class _VerifyOptionDialogState extends State<VerifyOptionDialog> {

  int _selectedIndex = 0; // ✅ STATE VARIABLE

  Future<void> logout(BuildContext context) async {
    SaveValues mySaveValues = SaveValues();


    // Clear all stored authentication data
    await mySaveValues.clearPrefValue(AppPreferenceHelper.AUTH_TOKEN);
    // await mySaveValues.clearPrefValue(AppPreferenceHelper.BUYER_ID);
    // await mySaveValues.clearPrefValue(AppPreferenceHelper.FARMER_ID);


    print("User logged out. Cleared token and IDs."); // Debugging log

    // Navigate back to Slider Screen and remove all previous routes
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => LoginPage()),
    //       (route) => false, // Remove all previous screens from stack
    // );
  }

  Widget smsOption({
    required int index,
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Image.asset(
              imagePath,
              width: 19,
              height: 18,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Radio<int>(
            value: index,
            groupValue: _selectedIndex,
            activeColor: Colors.white,
            onChanged: (value) {
              setState(() {
                _selectedIndex = value!;
              });
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 420.0,
    decoration: BoxDecoration(
      color: HexColor("#212121"),
    borderRadius: BorderRadius.circular(25),
    ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            width: 50.0,
            height: 10.0,
            decoration: BoxDecoration(
              color: HexColor("#FFFFFF"),
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20.0, left:20.0),
            child: Text("How would you like to verify?", style: TextStyle(color: HexColor("#FFFFFF"), fontSize: 15.0, fontWeight: FontWeight.normal,)),
          ),

          SizedBox(
            height: 20.0,
          ),


          Column(
            children: [
              smsOption(
                index: 0,
                imagePath: "images/sms_icon.png",
                title: "Receive New SMS",
                subtitle: "Try again in 55 : 35",
              ),
              const SizedBox(height: 10),

              smsOption(
                index: 1,
                imagePath: "images/missed_call_icon.png",
                title: "Missed call",
                subtitle: "Auto-verify on +1 832 456 12590",
              ),
              const SizedBox(height: 10),

              smsOption(
                index: 2,
                imagePath: "images/voice_call_icon.png",
                title: "Voice call",
                subtitle: "Get code at +1 832 456 12590 ",
              ),
            ],
          ),



          Stack(
            children: [

              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                child: Container(
                  decoration: BoxDecoration(
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
                  child: ElevatedButton(onPressed: (){

                  },
                    child: Text("Continue", style: TextStyle(fontSize: 16.0)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: HexColor("#201E1F"),
                      disabledBackgroundColor: HexColor("#D4D4D4"),
                      disabledForegroundColor: Colors.grey,
                      padding: const EdgeInsets.all(10.0),
                      minimumSize: Size(MediaQuery.of(context).size.width, 55.0),
                      textStyle: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 21.0,
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(width: 1, color: HexColor("#FF00A8"))
                      ),
                    ),
                  ),
                ),
              ),


              // Visibility(
              //   visible: !isLoadingVisible,
              //   child: Container(
              //     height: 20.0,
              //     width: MediaQuery.of(context).size.width,
              //     margin: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0, bottom: 10.0),
              //     decoration: BoxDecoration(
              //        color: HexColor("#007BFF"),
              //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //
              //         SizedBox(
              //           height: 20,
              //           width: 20,
              //           child: CircularProgressIndicator(
              //             strokeWidth: 2.5,
              //             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),



        ],
      ),
    );
  }
}