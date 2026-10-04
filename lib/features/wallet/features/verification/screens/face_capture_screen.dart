import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/wallet/features/verification/screens/verification_success_screen.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';

import '../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';

class FaceCaptureScreen extends ConsumerStatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  ConsumerState<FaceCaptureScreen> createState() => _SuccessfulTransferScreenState();
}

class _SuccessfulTransferScreenState extends ConsumerState<FaceCaptureScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
            (currentThemeMode == ThemeMode.system &&
                systemBrightness == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark
              ? Color(AppColors.primaryBackgroundColor)
              : Colors.white,
          surfaceTintColor: isDark
              ? Color(AppColors.primaryBackgroundColor)
              : Colors.white,
          automaticallyImplyLeading: false,
          leading: CustomBackButton(buildContext: context),
          title: Text(
            "Face Capture",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : null,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(width: 0.5, color: Colors.deepOrange),
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
                    child: Text(
                      "Position your face within the frame and tap the capture button",
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
                Center(child: SizedBox(
                  height: 150,
                    width: 150,
                    child: Image.asset("images/Group 1261155631.png"))),
                const SizedBox(height: 20,),
                _detailsRow(message: "Warning !!!"),
                const SizedBox(height: 5),
                _detailsRow(message: "Ensure good lighting"),
                const SizedBox(height: 5),
                _detailsRow(message: "Remove glasses or cap"),
                const SizedBox(height: 5),
                _detailsRow(message: "Look directly at the camera"),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(width: 0.5, color: Colors.deepOrange),
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
                    child: Text(
                      "🔒 Your BVN is securely encrypted and will never be shared with third parties.",
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orange
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
                CustomButtonTwo(title: "Continue", onClick: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const VerificationSuccessScreen()));
                }, isLoading: false, hasMargin: false,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailsRow({required String message}) {
    return Center(
      child: SizedBox(
        width: 180,
        child: Row(
          children: [
            Image.asset("images/eos-icons_loading.png"),
            const SizedBox(width: 8,),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w400
              ),
            )
          ],
        ),
      ),
    );
  }
}
