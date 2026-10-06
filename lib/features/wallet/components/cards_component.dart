import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/services.dart';
import '../../../utilities/helpers/date_formater.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class CardsComponent extends StatefulWidget {
  const CardsComponent({super.key});

  @override
  State<CardsComponent> createState() => _CardsComponentState();
}

class _CardsComponentState extends State<CardsComponent> {

  int currentIndex = 0;
  final int totalCards = 5;
  bool allSwiped = false;

  final _formKey = GlobalKey<FormState>();
  bool passwordVisible =  false;
  bool confirmPasswordVisible =  false;
  bool _isButtonEnabled = false;
  bool isLoadingVisible = true;
  String errorMessage = "";
  String email = "";



  // Function to validate the form and update button state
  void _validateFormField() {
    if (_formKey.currentState!.validate() == true) {
      setState(() {
        _isButtonEnabled = true;
      });
    } else {
      setState(() {
        _isButtonEnabled = false;
      });
    }
  }

  TextEditingController holderNameController = TextEditingController();
  TextEditingController expireDateController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController ccvController = TextEditingController();



  @override
  void dispose() {
    holderNameController .dispose();
    expireDateController.dispose();
    cardNumberController.dispose();
    ccvController.dispose();


    super.dispose();
  }

  void loading(){
    setState(() {
      isLoadingVisible = false;
    });
  }

  void isNotLoading(){
    setState(() {
      isLoadingVisible = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [

            Row(
              children: [

                Expanded(child: SizedBox()),

                Padding(
                  padding: const EdgeInsets.only(top: 10.0, right: 20.0,bottom: 20.0),
                  child: Text("Transaction History", style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 15.0, fontWeight: FontWeight.normal),),
                  // child: Image(image: AssetImage("images/splash_screen_logo.png"), width: 55.0,height: 55.0,),
                ),
              ],
            ),


            Container(
              child: allSwiped
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(Icons.check_circle, color: Colors.green, size: 80),
                    SizedBox(height: 180.0),
                    Text("No more available Cards!",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          allSwiped = false;
                        });
                      },
                      child: Text("Reload Cards"),
                    )
                  ],
                ),
              )
                  : Center(
                child: SizedBox(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  child: CardSwiper(
                    cardsCount: 5,
                    numberOfCardsDisplayed: 3,

                    // 👇 NEGATIVE Y moves stack upward
                    backCardOffset: const Offset(0, -20),

                    // optional: slightly scale back cards
                    scale: 0.96,

                    onSwipe: (previousIndex, targetIndex, direction) {
                      setState(() {
                        currentIndex = previousIndex + 1;

                        if (currentIndex >= totalCards) {
                          allSwiped = true;
                        }
                      });
                      return true;
                    },

                    cardBuilder: (context, index, percentThresholdX, percentThresholdY) {

                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 400,
                              margin: const EdgeInsets.only(
                                top: 20,
                                bottom: 10,
                                left: 3,
                                right: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(100),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  "images/credit_card.png",
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),

                        ],
                      );
                    },
                  ),
                ),
              ),
            ),


            const SizedBox(height: 1),

            // 👇 PAGE INDICATOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalCards,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == index ? 8 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? HexColor("#0EA6C2")
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                SizedBox(
                  width: 0.5,
                ),


                Column(
                  children: [
                    GestureDetector(
                      onTap: (){

                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 20.0),
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg(isDark),
                          border: Border.all(color: HexColor("#F5F6F7"), width: 1.0),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Image(image: AssetImage("images/send.png"), width: 40.0, height: 50.0),
                            ),


                          ],
                        ),
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.only(top: 7.0, bottom: 10.0),
                      child: Text("Send", style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 14.0, fontWeight: FontWeight.normal),),
                    ),

                  ],
                ),

                Column(
                  children: [
                    GestureDetector(
                      onTap: (){

                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 20.0),
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg(isDark),
                          border: Border.all(color: HexColor("#F5F6F7"), width: 1.0),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Image(image: AssetImage("images/top_up.png"), width: 40.0, height: 50.0),
                            ),


                          ],
                        ),
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.only(top: 7.0, bottom: 10.0),
                      child: Text("Top up", style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 14.0, fontWeight: FontWeight.normal),),
                    ),
                  ],
                ),

                Column(
                  children: [
                    GestureDetector(
                      onTap: (){

                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 20.0),
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg(isDark),
                          border: Border.all(color: HexColor("#F5F6F7"), width: 1.0),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Image(image: AssetImage("images/receive.png"), width: 100.0, height: 50.0),
                            ),


                          ],
                        ),
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.only(top: 7.0, bottom: 10.0),
                      child: Text("Receive", style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 14.0, fontWeight: FontWeight.normal),),
                    ),

                  ],
                ),

                Column(
                  children: [
                    GestureDetector(
                      onTap: (){

                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 20.0),
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg(isDark),
                          border: Border.all(color: HexColor("#F5F6F7"), width: 1.0),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Image(image: AssetImage("images/run_adds.png"), width: 40.0, height: 50.0),
                            ),

                          ],
                        ),
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.only(top: 7.0, bottom: 10.0),
                      child: Text("Run Adds", style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 14.0, fontWeight: FontWeight.normal),),
                    ),
                  ],
                ),

                SizedBox(
                  width: 0.5,
                ),

              ],
            ),


            Container(
              margin: EdgeInsets.only(top: 25.0, left: 16.0, right: 16.0),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                border: Border.all(color: HexColor("#F5F6F7"), width: 1.0),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                        child: Icon(Icons.add, size: 25.0, color: Colors.white,),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 10.0),
                        child: Text("Add Card", style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 19.0, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 0.0, left: 55.0),
                    child: Text("Add your debit/credit card", style: GoogleFonts.poppins(color: HexColor("#7B78AA"), fontSize: 13.5, fontWeight: FontWeight.normal),),
                  ),


                  Form(
                    key: _formKey,
                    onChanged: _validateFormField,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Padding(
                          padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
                          child: TextFormField(
                            validator: (value) {
                              final regex = RegExp(r'^[+-]?\d+(\.\d+)?$');
                              final trimmedValue = value?.trim() ?? '';
                              if (trimmedValue == null || trimmedValue.isEmpty) {
                                return 'Enter Card Number';
                              }
                              if (trimmedValue.length < 16) {
                                return 'Enter a valid card Number';
                              }
                              if (!regex.hasMatch(trimmedValue)) {
                                return 'Enter a valid Phone Number';
                              } else {
                                return null; // Return null if the input is valid
                              }
                            },
                            controller: cardNumberController,
                            keyboardType:TextInputType.number,
                            maxLength: 16,
                            cursorColor: Colors.white,
                            style: TextStyle(fontSize: 14.0, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Card number",
                              hintStyle: TextStyle(color: HexColor("#7B78AA"), fontSize: 14.0, fontWeight: FontWeight.normal),
                              filled: true, // Set this to true to enable the background color
                              fillColor: HexColor("#19173D80"), // Set the desired background color
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: HexColor("#19173D80"), width: 0.0),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color:HexColor("#19173D80"), width: 0.0),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              counterText: '',
                            ),
                          ),
                        ),



                        Padding(
                          padding: const EdgeInsets.only(top: 25.0, left: 20.0, right: 20.0),
                          child: TextFormField(
                            validator: (value) {
                              final regex = RegExp(r'^[a-zA-Z]+$');
                              // final trimmedValue = value?.trim() ?? '';
                              if (value  == null || value .isEmpty) {
                                return 'Enter Holder name';
                              }
                              if (value .length < 2) {
                                return 'Enter a valid holder name';
                              }
                              // if (!regex.hasMatch(trimmedValue)) {
                              //   return 'Enter only letters';
                              // }
                              else{
                                return null; // Return null if the input is valid
                              }
                            },
                            controller: holderNameController,
                            keyboardType:TextInputType.name,
                            cursorColor: Colors.white,
                            style: TextStyle(fontSize: 14.0, color: Colors.white),
                            maxLength: 20,
                            decoration: InputDecoration(
                              hintText: "Card holder name",
                              hintStyle: TextStyle(color: HexColor("#7B78AA"), fontSize: 14.0, fontWeight: FontWeight.normal),
                              filled: true, // Set this to true to enable the background color
                              fillColor: HexColor("#19173D80"), // Set the desired background color
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: HexColor("#19173D80"), width: 0.0),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color:HexColor("#19173D80"), width: 0.0),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              counterText: '',
                            ),
                          ),
                        ),


                        Row(
                          children: [

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 10.0),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter expiry date';
                                    }

                                    final parts = value.split('/');
                                    if (parts.length != 2) return 'Invalid format';

                                    final month = int.tryParse(parts[0]);
                                    final year = int.tryParse(parts[1]);

                                    if (month == null || year == null) return 'Invalid date';
                                    if (month < 1 || month > 12) return 'Invalid month';

                                    return null;
                                  },
                                  controller: expireDateController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    ExpiryDateFormatter(),
                                  ],
                                  maxLength: 7, // MM/YY
                                  cursorColor: Colors.white,
                                  style: const TextStyle(fontSize: 14, color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "Exp Date",
                                    hintStyle: TextStyle(color: HexColor("#7B78AA"), fontSize: 14.0, fontWeight: FontWeight.normal),
                                    filled: true, // Set this to true to enable the background color
                                    fillColor: HexColor("#19173D80"), // Set the desired background color
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: HexColor("#19173D80"), width: 0.0),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color:HexColor("#19173D80"), width: 0.0),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    counterText: '',
                                  ),
                                ),
                              ),
                            ),


                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 30.0, left: 10.0, right: 20.0),
                                child: TextFormField(
                                  validator: (value) {
                                    final regex = RegExp(r'^[+-]?\d+(\.\d+)?$');
                                    final trimmedValue = value?.trim() ?? '';
                                    if (trimmedValue == null || trimmedValue.isEmpty) {
                                      return 'Enter CCV';
                                    }
                                    if (trimmedValue.length < 3) {
                                      return 'Enter a valid CCV';
                                    }
                                    if (!regex.hasMatch(trimmedValue)) {
                                      return 'Enter a valid CCV';
                                    } else {
                                      return null; // Return null if the input is valid
                                    }
                                  },
                                  controller: ccvController,
                                  keyboardType:TextInputType.number,
                                  maxLength: 3,
                                  cursorColor: Colors.white,
                                  style: TextStyle(fontSize: 14.0, color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "CVV",
                                    hintStyle: TextStyle(color: HexColor("#7B78AA"), fontSize: 14.0, fontWeight: FontWeight.normal),
                                    filled: true, // Set this to true to enable the background color
                                    fillColor: HexColor("#19173D80"), // Set the desired background color
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: HexColor("#19173D80"), width: 0.0),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color:HexColor("#19173D80"), width: 0.0),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    counterText: '',
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),


                  GestureDetector(
                    onTap:(){

                      // Navigator.push(context, MaterialPageRoute(builder: (context){
                      //   return DashboardPage();
                      // }));
                    },
                    child: Container(
                      width: double.infinity, // makes sure it takes the full width
                      height: 55.0,
                      margin:const EdgeInsets.only(left: 16, right: 16, top: 50.0, bottom: 50.0),
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
                          color: AppTheme.cardBg(isDark),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Center(
                          child: Text("Continue",
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


                  // Padding(
                  //   padding: const EdgeInsets.only(left:16.0, right: 16.0, top: 50.0, bottom: 50.0),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(20),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: HexColor("#FB8830").withOpacity(0.4),
                  //           blurRadius: 25, // 🔥 increase blur
                  //           spreadRadius: 2,
                  //           offset: Offset(0, 10),
                  //         ),
                  //         BoxShadow(
                  //           color: Colors.black.withOpacity(0.4),
                  //           blurRadius: 30, // 🔥 soft ambient blur
                  //           offset: Offset(0, 20),
                  //         ),
                  //       ],
                  //     ),
                  //     child: ElevatedButton(
                  //       onPressed: (){
                  //
                  //         // Navigator.push(context, MaterialPageRoute(builder: (context){
                  //         //   return DashboardPage();
                  //         // }));
                  //
                  //       },
                  //       child: Text("Continue", style: const TextStyle(fontSize: 18.0),
                  //       ),
                  //       style: ElevatedButton.styleFrom(
                  //         foregroundColor: Colors.white,
                  //         backgroundColor: HexColor("#201E1F"),
                  //         padding: const EdgeInsets.all(10.0),
                  //         minimumSize: Size(MediaQuery.of(context).size.width, 55.0),
                  //         textStyle: const TextStyle(
                  //           fontFamily: 'DM Sans',
                  //           fontSize: 18.0,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //         elevation: 5,
                  //         shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(20.0),
                  //             side: BorderSide(width: 1, color: HexColor("#FF00A8"))
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                ],
              ),
            ),

            const SizedBox(
              height: 100.0,
            ),

          ],
        ),
      ),
    );
  }
}
