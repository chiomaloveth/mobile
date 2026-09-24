import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import'package:flutter/material.dart';

import '../../../../utilities/constants/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() =>
      _SplashScreenPageState();
}

class _SplashScreenPageState
    extends ConsumerState<SplashScreen> {

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Color(AppColors.primaryColor),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
          backgroundColor: Color(AppColors.primaryColor),
        ),
        backgroundColor: Color(AppColors.primaryColor),
        body: Center(
          child: Image(image: AssetImage("images/splash_screen_logo.png"), width: 155.0,height: 80.0,),
        ),
      ),
    );
  }
}
