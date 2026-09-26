import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/bottom_nav/screen/custom_bottom_nav.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../utilities/components/dialogs/image_choice_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../utilities/constants/app_theme.dart';

import '../provider/add_profile_info_provider.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';



class AddProfileInfoScreen extends ConsumerWidget {
  const AddProfileInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProfileInfoProvider);
    final notifier = ref.read(addProfileInfoProvider.notifier);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    void showMessage(String msg) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }

    void navigate() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  CustomBottomNav()),
      );
    }

    void showImageOptions() {
      showModalBottomSheet(
        context: context,
        builder: (_) {
          return ImageChoiceDialog(
            onCameraButtonPressed: () async {
              Navigator.pop(context);
              ref.read(biometricAuthProvider.notifier).isPickerActive = true;
              await notifier.pickImage(ImageSource.camera);
              await ref.read(biometricAuthProvider.notifier).onPickerReturned();
            },
            onGalleryButtonPressed: () async {
              Navigator.pop(context);
              ref.read(biometricAuthProvider.notifier).isPickerActive = true;
              await notifier.pickImage(ImageSource.gallery);
              await ref.read(biometricAuthProvider.notifier).onPickerReturned();
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40.0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [

            Expanded(child: SizedBox()),
          ],
        ),
        backgroundColor:  HexColor("#101010"),
      ),
      backgroundColor:  HexColor("#101010"),

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          child: Stack(
            clipBehavior: Clip.none, // allows overlap
            children: [

              Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
                height: MediaQuery.of(context).size.height * 0.90,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage("images/waves.png",), fit: BoxFit.fill),
                  borderRadius: BorderRadius.only(),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text("Profile info", style: GoogleFonts.poppins(color: isDark ? Colors.white : AppTheme.textPrimary(isDark), fontSize: 16.0, fontWeight: FontWeight.bold),),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text("Please provide your profile photo", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.normal),),
                    ),
                  ),

                  Row(
                    children: [

                      Expanded(child: SizedBox()),

                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: CircleAvatar(
                              radius: 75.0,
                              backgroundColor: HexColor("#9D9D9D"),
                              backgroundImage: state.image != null ? FileImage(state.image!) : null,
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                // your action here
                                showImageOptions();
                              },
                              child: Image.asset(
                                "images/edit_image.png",
                                width: 33.0,
                                height: 33.0,
                              ),
                            ),
                          )

                        ],
                      ),

                      Expanded(child: SizedBox()),
                    ],
                  ),

                  Row(
                    children: [

                      Expanded(child: SizedBox()),

                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30.0, left: 20.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter Write up';
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: notifier.updateUsername,
                                keyboardType: TextInputType.text,
                                cursorColor: Colors.white,
                                style: TextStyle(fontSize: 16.0, color: Colors.white),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "Enter Username",
                                  hintStyle: TextStyle(
                                    color: HexColor("#ABABAB"),
                                    fontSize: 16.0,
                                  ),
                                  // REMOVE ALL BORDERS
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  counterText: '',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                              ),
                            ),
                          ),
                        ),


                      Expanded(child: SizedBox()),

                    ],
                  ),


                  GestureDetector(
                    onTap: state.isButtonEnabled
                        ? () => notifier.uploadUserProfile(showMessage, navigate)
                        : null,
                    child: Container(
                      width: double.infinity,
                      height: 55.0,
                      margin:const EdgeInsets.only(left: 20, right: 20, top: 100.0),
                      decoration: BoxDecoration(
                        gradient: state.isButtonEnabled
                            ? LinearGradient(
                          colors: [HexColor("#FF00A8"), HexColor("#00D1FF")],
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
                        ] : [],
                      ),
                      padding: const EdgeInsets.all(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        decoration: BoxDecoration(
                          color: HexColor("#1B1B1B"),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: const Center(
                          child: Text(
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
}












// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:http/http.dart' as http;
// import 'package:qik_talk/screens/dashboard/ui/custom_bottom_nav.dart';
//
// import '../../../database/app_pref_helper.dart';
// import '../../../database/save_values.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../../dialogs/image_choice_dialog.dart';
// import '../../webService/api_strings.dart';
//
//
//
//
// class AddProfileInfoPage extends StatefulWidget {
//   const AddProfileInfoPage({super.key});
//
//   @override
//   State<AddProfileInfoPage> createState() => _AddProfileInfoPageState();
// }
//
// class _AddProfileInfoPageState extends State<AddProfileInfoPage> {
//
//   int? otpCode;
//   String otpString = "";
//   bool isLoadingVisible = true;
//   String signUpEmail = "";
//   final _formKey = GlobalKey<FormState>();
//   bool _isButtonEnabled = false;
//   String token = "";
//   String message = "";
//   File? _image;
//   bool passwordVisible =  false;
//   bool confirmPasswordVisible =  false;
//
//
//
//   // Function to validate the form and update button state
//   void _validateFormField() {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isButtonEnabled = true;
//       });
//     } else {
//       setState(() {
//         _isButtonEnabled = false;
//       });
//     }
//   }
//
//
//   TextEditingController fullNameController = TextEditingController();
//   TextEditingController dobController = TextEditingController();
//   TextEditingController emailAddressController = TextEditingController();
//   TextEditingController aboutController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController confirmPasswordController = TextEditingController();
//   TextEditingController userNameController = TextEditingController();
//
//
//
//   @override
//   void dispose() {
//     fullNameController.dispose();
//     dobController.dispose();
//     emailAddressController.dispose();
//     aboutController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     userNameController.dispose();
//
//     super.dispose();
//   }
//
//
//
//
//   void loading(){
//     setState(() {
//       isLoadingVisible = false;
//     });
//   }
//
//   void isNotLoading(){
//     setState(() {
//       isLoadingVisible = true;
//     });
//   }
//
//   Future<void> dateOfBirth(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: DateTime.now(),
//         firstDate: DateTime(1940),
//         lastDate: DateTime(2100),
//
//         builder: (BuildContext context, Widget? child) {
//           return Theme(
//             data: Theme.of(context).copyWith(
//               colorScheme: const ColorScheme.light(
//                 primary: Color(0xFF0066FF),
//                 onPrimary: Colors.white,
//                 onSurface: Colors.black,
//               ),
//               textButtonTheme: TextButtonThemeData(
//                 style: TextButton.styleFrom(
//                   foregroundColor: Color(0xFF0066FF),
//                 ),
//               ),
//             ),
//             child: Builder(
//               builder: (context) => Dialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: child!,
//               ),
//             ),
//           );
//         }
//     );
//
//     if (picked != null) {
//       setState(() {
//         dobController.text = DateFormat('yyyy-MM-dd').format(picked);
//       });
//     }
//   }
//
//   Future<void> getImage(BuildContext context, ImageSource source) async {
//     var status = await Permission.photos.request(); // for iOS
//     var storageStatus = await Permission.storage.request(); // for Android <= 12
//
//     if (status.isGranted || storageStatus.isGranted) {
//       try {
//         final pickedImage = await ImagePicker().pickImage(
//           source: source,
//           imageQuality: 100,
//         );
//
//         if (pickedImage == null) return;
//
//         final croppedImage = await ImageCropper().cropImage(
//           sourcePath: pickedImage.path,
//           uiSettings: [
//             AndroidUiSettings(
//               toolbarTitle: 'Crop Image',
//               lockAspectRatio: false, // 🔑 Allow free resize
//               initAspectRatio: CropAspectRatioPreset.original,
//             ),
//             IOSUiSettings(
//               title: 'Crop Image',
//               aspectRatioLockEnabled: false, // iOS free resize
//             ),
//           ],
//         );
//
//         if (croppedImage != null) {
//           setState(() {
//             _image = File(croppedImage.path);
//           });
//           // openImage();
//         }
//       } catch (e) {
//         print('❌ Error selecting image: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to pick image: $e')),
//         );
//       }
//     } else {
//       // Permission denied
//       print("Permission not granted!");
//     }
//   }
//
//
//   void showImageOptions() {
//     showModalBottomSheet(
//       // isDismissible: false,
//       // enableDrag: false,
//         context: context,
//         builder: (BuildContext context) {
//           return ImageChoiceDialog(
//             onCameraButtonPressed: () async {
//
//               Navigator.pop(context);
//               await getImage(context, ImageSource.camera);
//             },
//             onGalleryButtonPressed: () async {
//
//               Navigator.pop(context); // dismiss first
//               await getImage(context, ImageSource.gallery);
//             },
//           );
//         });
//   }
//
//
//
//   Future<void> uploadUserName() async {
//     loading();
//     SaveValues mySaveValues = SaveValues();
//     String? token = await mySaveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
//     if (token == null) {
//       print('No token found. Please log in again.');
//       return;
//     }
//     String apiUrl = ApiConstant.uploadPhotoUsername;
//     try {
//
//       final uri = Uri.parse(apiUrl);
//       print('PUT: $apiUrl');
//       var request = http.MultipartRequest('PUT', uri);
//
//       request.headers['Authorization'] = 'Bearer $token';
//       request.headers['Accept'] = 'application/json';
//
//       // Handle image upload for both Web and Mobile
//         final mimeType = _getMimeType(_image!.path);
//         request.files.add(
//           http.MultipartFile.fromBytes('profilePicture', await _image!.readAsBytes(),
//             filename: _image!.path.split('/').last,
//             contentType: MediaType('image', mimeType),
//           ),
//         );
//
//       request.fields['username'] = userNameController.text;
//
//       print("request: $request");
//       final response = await request.send();
//       print(response.statusCode);
//
//       if (response.statusCode == 200) {
//         isNotLoading();
//         var responseData = await response.stream.toBytes();
//         var responseString = String.fromCharCodes(responseData);
//         print('Response Body: $responseString');
//         var jsonResponse = json.decode(responseString);
//         final Map<String, dynamic> data = jsonResponse;
//         message = data['message'];
//
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(message)));
//
//
//         Navigator.push(context, MaterialPageRoute(builder: (context){
//           return  DashboardPage();
//         }));
//
//
//       }
//       else {
//         isNotLoading();
//         var responseData = await response.stream.toBytes();
//         var responseString = String.fromCharCodes(responseData);
//         print('Response Body: $responseString');
//         var jsonResponse = json.decode(responseString);
//         final Map<String, dynamic> errorData = jsonResponse;
//         message = errorData['message'] ?? 'Unknown error occurred';
//         print(message);
//
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(message)));
//
//       }
//     } catch (e) {
//       isNotLoading();
//       print('Exception during image upload: $e');
//
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Network error occurred. Please try again.")));
//
//     }
//   }
//
// // Helper function for getting MIME type from file extension
//   // Function to get MIME type
//   String _getMimeType(String filePath) {
//     final extension = filePath.split('.').last.toLowerCase();
//     switch (extension) {
//       case 'jpg':
//       case 'jpeg':
//         return 'jpeg';
//       case 'png':
//         return 'png';
//       case 'gif':
//         return 'gif';
//       default:
//         return 'octet-stream';
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 40.0,
//         automaticallyImplyLeading: false,
//         title: Row(
//           children: [
//
//
//
//
//             Expanded(child: SizedBox()),
//
//             GestureDetector(
//               onTap: (){
//
//                 // Navigator.pop(context);
//               },
//               child:Container(
//                 height: 50,
//                 width: 50.0,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//
//                     GestureDetector(
//                       onTap: (){
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (context) => DashboardPage()),
//                         );
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 20.0, right: 10.0),
//                         child: Text("Skip",style: GoogleFonts.poppins(color: HexColor("#1A7F4B"), fontWeight: FontWeight.normal, fontSize:15.0,),),
//                       ),
//                     ),
//
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor:  HexColor("#101010"),
//       ),
//       backgroundColor:  HexColor("#101010"),
//
//       body:SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//
//         child: SizedBox(
//           child: Stack(
//             clipBehavior: Clip.none, // allows overlap
//             children: [
//
//               Container(
//                 margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
//                 height: MediaQuery.of(context).size.height * 0.90,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(image: AssetImage("images/waves.png",), fit: BoxFit.fill),
//                   borderRadius: BorderRadius.only(),
//                 ),
//               ),
//
//               Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//
//
//                     Center(
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 20.0),
//                         child: Text("Fill Your Profile", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),),
//                       ),
//                     ),
//
//                     // Center(
//                     //   child: Padding(
//                     //     padding: const EdgeInsets.only(top: 10.0),
//                     //     child: Text("Please provide your profile photo", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.normal),),
//                     //   ),
//                     // ),
//
//
//
//                     Row(
//                       children: [
//
//                         Expanded(child: SizedBox()),
//
//                         Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(top: 30.0),
//                               child: CircleAvatar(
//                                 radius: 70.0,
//                                 backgroundColor: HexColor("#575A58"),
//                                 backgroundImage: _image != null ? FileImage(_image!) : null,
//                                 child: _image == null
//                                     ?  Image.asset(
//                                   'images/profile_logo.png',
//                                   width: 120,
//                                   height: 120,
//                                   fit: BoxFit.contain,
//                                 )
//                                     : null,
//                               ),
//                             ),
//
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   // your action here
//                                   showImageOptions();
//                                 },
//                                 child: Image.asset(
//                                   "images/edit_image.png",
//                                   width: 33.0,
//                                   height: 33.0,
//                                 ),
//                               ),
//                             )
//
//                           ],
//                         ),
//
//                         Expanded(child: SizedBox()),
//
//                       ],
//                     ),
//
//
//                     Form(
//                       key: _formKey,
//                       onChanged: _validateFormField,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//
//                           Padding(
//                             padding: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
//                             child: TextFormField(
//                               validator: (value) {
//                                 final regex = RegExp(r'^[a-zA-Z]+$');
//                                 final trimmedValue = value?.trim() ?? '';
//                                 if (trimmedValue  == null || trimmedValue .isEmpty) {
//                                   return 'Enter First name';
//                                 }
//                                 if (trimmedValue .length < 2) {
//                                   return 'Enter a valid name';
//                                 }
//                                 if (!regex.hasMatch(trimmedValue)) {
//                                   return 'Enter only letters';
//                                 }
//                                 else{
//                                   return null; // Return null if the input is valid
//                                 }
//                               },
//                               cursorColor: Colors.black,
//                               controller: fullNameController,
//                               keyboardType:TextInputType.text,
//                               style: TextStyle(fontSize: 13.0, color: Colors.white),
//                               decoration: InputDecoration(
//                                 hintText: "Full Name",
//                                 hintStyle: TextStyle(color: HexColor("#9D9D9D"), fontSize: 14.0, fontWeight: FontWeight.normal),
//                                 filled: true, // Set this to true to enable the background color
//                                 fillColor: HexColor("#141414"), // Set the desired background color
//                                 contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: HexColor("#34393A"), width: 0.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color:HexColor("#34393A"), width: 0.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 counterText: '',
//                               ),
//                             ),
//                           ),
//
//
//                           Padding(
//                             padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
//                             child: TextFormField(
//                               validator: (value) {
//                                 // final regex = RegExp(r'^[a-zA-Z]+$');
//                                 // final trimmedValue = value?.trim() ?? '';
//                                 // if (trimmedValue  == null || trimmedValue .isEmpty) {
//                                 //   return 'Enter First name';
//                                 // }
//                                 // if (trimmedValue .length < 2) {
//                                 //   return 'Enter a valid name';
//                                 // }
//                                 // if (!regex.hasMatch(trimmedValue)) {
//                                 //   return 'Enter only letters';
//                                 // }
//                                 // else{
//                                 //   return null; // Return null if the input is valid
//                                 // }
//                               },
//                               cursorColor: Colors.black,
//                               controller: userNameController,
//                               keyboardType:TextInputType.text,
//                               style: TextStyle(fontSize: 13.0, color: Colors.white),
//                               decoration: InputDecoration(
//                                 hintText: "Username",
//                                 hintStyle: TextStyle(color: HexColor("#9D9D9D"), fontSize: 14.0, fontWeight: FontWeight.normal),
//                                 filled: true, // Set this to true to enable the background color
//                                 fillColor: HexColor("#141414"), // Set the desired background color
//                                 contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: HexColor("#34393A"), width: 0.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color:HexColor("#34393A"), width: 0.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 counterText: '',
//                               ),
//                             ),
//                           ),
//
//
//                           GestureDetector(
//                             onTap: (){
//                               dateOfBirth(context);
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
//                               child: TextFormField(
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Cannot be empty';
//
//                                   }
//                                   if (value.length < 2) {
//                                     return '';
//                                   }
//
//                                   else{
//                                     return null; // Return null if the input is valid
//                                   }
//                                 },
//                                 controller: dobController,
//                                 keyboardType:TextInputType.text,
//                                 cursorColor: Colors.white,
//                                 style: TextStyle(fontSize: 13.0, color: Colors.white),
//                                 decoration: InputDecoration(
//                                   hintText: "Date of Birth",
//                                   hintStyle: TextStyle(color: HexColor("#9D9D9D"), fontSize: 14.0, fontWeight: FontWeight.normal),
//                                   filled: true, // Set this to true to enable the background color
//                                   fillColor: HexColor("#141414"), // Set the desired background color
//                                   suffixIcon: IconButton(icon: Icon(Icons.calendar_month, color: HexColor("#9D9D9D"), size: 18.0,),
//                                     onPressed: () => dateOfBirth(context),),
//                                   contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10.0),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color: HexColor("#34393A"), width: 0.0),
//                                     borderRadius: BorderRadius.circular(10.0),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(color:HexColor("#34393A"), width: 0.0),
//                                     borderRadius: BorderRadius.circular(10.0),
//                                   ),
//                                   counterText: '',
//                                 ),
//                                 // enabled: false,
//                                 readOnly: true,
//                               ),
//                             ),
//                           ),
//
//
//
//
//                           Padding(
//                             padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
//                             child: TextFormField(
//                               validator: (value) {
//                                 final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//                                 final trimmedValue = value?.trim() ?? '';
//                                 if (trimmedValue == null || trimmedValue.isEmpty) {
//                                   return 'Please enter your email';
//                                   // return null;
//                                 }
//                                 if (trimmedValue.length < 8) {
//                                   return 'Please enter a valid email address';
//                                 }
//                                 if (!regex.hasMatch(trimmedValue)) {
//                                   return 'Please enter a valid email address';
//                                 }
//                                 else{
//                                   return null; // Return null if the input is valid
//                                 }
//                               },
//                               cursorColor: Colors.black,
//                               controller: emailAddressController,
//                               keyboardType:TextInputType.emailAddress,
//                               style: TextStyle(fontSize: 13.0, color: Colors.white),
//                               decoration: InputDecoration(
//                                 hintText: "Email",
//                                 hintStyle: TextStyle(color: HexColor("#9D9D9D"), fontSize: 14.0, fontWeight: FontWeight.normal),
//                                 filled: true, // Set this to true to enable the background color
//                                 fillColor: HexColor("#141414"), // Set the desired background color
//                                 suffixIcon: Icon(Icons.mail_outline_rounded, color: HexColor("#9D9D9D"),size: 18.0,),
//                                 contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: HexColor("#34393A"), width: 0.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color:HexColor("#34393A"), width: 0.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 counterText: '',
//                               ),
//                             ),
//                           ),
//
//
//                           Padding(
//                             padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
//                             child: TextFormField(
//                               validator: (value) {
//                                 // final regex = RegExp(r'^[a-zA-Z]+$');
//                                 // final trimmedValue = value?.trim() ?? '';
//                                 // if (trimmedValue  == null || trimmedValue .isEmpty) {
//                                 //   return 'Enter First name';
//                                 // }
//                                 // if (trimmedValue .length < 2) {
//                                 //   return 'Enter a valid name';
//                                 // }
//                                 // if (!regex.hasMatch(trimmedValue)) {
//                                 //   return 'Enter only letters';
//                                 // }
//                                 // else{
//                                 //   return null; // Return null if the input is valid
//                                 // }
//                               },
//                               cursorColor: Colors.black,
//                               controller: aboutController,
//                               keyboardType:TextInputType.text,
//                               style: TextStyle(fontSize: 13.0, color: Colors.white),
//                               decoration: InputDecoration(
//                                 hintText: "About",
//                                 hintStyle: TextStyle(color: HexColor("#9D9D9D"), fontSize: 14.0, fontWeight: FontWeight.normal),
//                                 filled: true, // Set this to true to enable the background color
//                                 fillColor: HexColor("#141414"), // Set the desired background color
//                                 contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: HexColor("#34393A"), width: 0.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color:HexColor("#34393A"), width: 0.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 counterText: '',
//                               ),
//                             ),
//                           ),
//
//
//
//
//                           Padding(
//                             padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
//                             child: TextFormField(
//                               validator: (value) {
//                                 final trimmedValue = value?.trim() ?? '';
//                                 if (trimmedValue == null || trimmedValue.isEmpty) {
//                                   return 'Please enter your password';
//                                 }
//                                 // if (trimmedValue.length < 8) {
//                                 //   return 'Password must be at least 8 characters long';
//                                 // }
//                                 // if (!RegExp(r'[A-Z]').hasMatch(value)) {
//                                 //   return 'Password must contain at least one uppercase letter';
//                                 // }
//                                 return null;
//                               },
//                               cursorColor: Colors.black,
//                               controller: passwordController,
//                               obscureText: passwordVisible,
//                               keyboardType: TextInputType.visiblePassword,
//                               textInputAction: TextInputAction.done,
//                               style: TextStyle(fontSize: 13.0, color: Colors.white),
//                               decoration: InputDecoration(
//                                 hintText: "Password",
//                                 hintStyle: TextStyle(color: HexColor("#9D9D9D"), fontSize: 14.0, fontWeight: FontWeight.normal),
//                                 filled: true, // Set this to true to enable the background color
//                                 fillColor: HexColor("#141414"), // Set the desired background color
//                                 // prefixIcon: Icon(Icons.lock_outline_rounded, color: HexColor("#9D9D9D"),size: 20.0,),
//                                 contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
//                                 suffixIcon: IconButton(icon: Icon(passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,size: 17.0, color: HexColor("#ACADB9"),),
//                                   onPressed: (){
//                                     setState(() {
//                                       passwordVisible = !passwordVisible;
//                                     },
//                                     );
//                                   },
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: HexColor("#34393A"), width: 0.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color:HexColor("#34393A"), width: 0.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 counterText: '',
//                               ),
//                             ),
//                           ),
//
//
//                           Padding(
//                             padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
//                             child: TextFormField(
//                               validator: (value) {
//                                 final trimmedValue = value?.trim() ?? '';
//                                 if (trimmedValue == null || trimmedValue.isEmpty) {
//                                   return 'Enter confirm  password';
//                                   return null;
//                                 }
//                                 if (trimmedValue.length < 8) {
//                                   return 'must be at least 8 characters long';
//                                 }
//                                 if (trimmedValue != passwordController.text) {
//                                   return 'Confirm Passwords do not match with new password';
//                                 }
//                                 else{
//                                   return null; // Return null if the input is valid
//                                 }
//                               },
//                               cursorColor: Colors.black,
//                               controller: confirmPasswordController,
//                               obscureText: confirmPasswordVisible,
//                               keyboardType: TextInputType.visiblePassword,
//                               textInputAction: TextInputAction.done,
//                               style: TextStyle(fontSize: 13.0, color: Colors.white),
//                               decoration: InputDecoration(
//                                 hintText: "Confirm Password",
//                                 hintStyle: TextStyle(color: HexColor("#9D9D9D"), fontSize: 14.0, fontWeight: FontWeight.normal),
//                                 filled: true, // Set this to true to enable the background color
//                                 fillColor: HexColor("#141414"), // Set the desired background color
//                                 // prefixIcon: Icon(Icons.lock_outline_rounded, color: HexColor("#9D9D9D"),size: 20.0,),
//                                 contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
//                                 suffixIcon: IconButton(icon: Icon(confirmPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,size: 17.0, color: HexColor("#ACADB9"),),
//                                   onPressed: (){
//                                     setState(() {
//                                       confirmPasswordVisible = !confirmPasswordVisible;
//                                     },
//                                     );
//                                   },
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color: HexColor("#34393A"), width: 0.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: BorderSide(color:HexColor("#34393A"), width: 0.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 counterText: '',
//                               ),
//                             ),
//                           ),
//
//                         ],
//                       ),
//                     ),
//
//
//                     Stack(
//                       children: [
//
//                         GestureDetector(
//                           onTap: _isButtonEnabled
//                               ? () {
//                             uploadUserName();
//
//                           }
//                               : null, // ❌ disables tap
//                           child: Container(
//                             width: double.infinity, // makes sure it takes the full width
//                             height: 55.0,
//                             margin:const EdgeInsets.only(left: 20, right: 20, top: 50.0, bottom: 100.0),
//                             decoration: BoxDecoration(
//                               gradient: _isButtonEnabled
//                                   ? LinearGradient(
//                                 colors: [HexColor("#FF00A8"), HexColor("#00D1FF")],
//                               )
//                                   : LinearGradient(
//                                 colors: [
//                                   Colors.grey.shade700,
//                                   Colors.grey.shade700,
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(20),
//                               boxShadow: _isButtonEnabled
//                                   ? [
//                                 BoxShadow(
//                                   color: HexColor("#FB8830").withOpacity(0.4),
//                                   blurRadius: 25,
//                                   spreadRadius: 2,
//                                   offset: Offset(0, 10),
//                                 ),
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.4),
//                                   blurRadius: 30,
//                                   offset: Offset(0, 20),
//                                 ),
//                               ] : [], // ❌ no glow when disabled
//                             ),
//                             padding: const EdgeInsets.all(1),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
//                               decoration: BoxDecoration(
//                                 color: HexColor("#1B1B1B"),
//                                 borderRadius: BorderRadius.circular(19),
//                               ),
//                               child: Center(
//                                 child: Text("Continue",
//                                   style: const TextStyle(
//                                     fontFamily: 'DM Sans',
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//
//
//
//                         Visibility(
//                           visible: !isLoadingVisible,
//                           child: Container(
//                             width: double.infinity, // makes sure it takes the full width
//                             height: 55.0,
//                             margin:const EdgeInsets.only(left: 20, right: 20, top: 100.0, bottom: 100.0),
//                             decoration: BoxDecoration(
//                               gradient:  LinearGradient(
//                                 colors: [HexColor("#FF00A8"), HexColor("#00D1FF")],
//                               ),
//                               borderRadius: BorderRadius.circular(20),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: HexColor("#FB8830").withOpacity(0.4),
//                                   blurRadius: 25, // 🔥 increase blur
//                                   spreadRadius: 2,
//                                   offset: Offset(0, 10),
//                                 ),
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.4),
//                                   blurRadius: 30, // 🔥 soft ambient blur
//                                   offset: Offset(0, 20),
//                                 ),
//                               ],
//                             ),
//                             padding: const EdgeInsets.all(1),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
//                               decoration: BoxDecoration(
//                                 color: HexColor("#1B1B1B"),
//                                 borderRadius: BorderRadius.circular(19),
//                               ),
//                               child: Center(
//                                 child: SizedBox(
//                                   height: 20,
//                                   width: 20,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2.5,
//                                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//
//                       ],
//                     ),
//
//
//                   ]
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
