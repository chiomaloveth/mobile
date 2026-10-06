import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';
import 'package:qik_talk/utilities/components/custom_countdown_timer.dart';

import '../../../../../utilities/constants/app_colors.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';

class DialUSSDCodeScreen extends ConsumerStatefulWidget {
  const DialUSSDCodeScreen({super.key});

  @override
  ConsumerState<DialUSSDCodeScreen> createState() => _SuccessfulTransferScreenState();
}

class _SuccessfulTransferScreenState extends ConsumerState<DialUSSDCodeScreen> {
  final TextEditingController _textEditingController = TextEditingController();
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
            "Bank USSD",
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500
            ),
          ),
          actions: [],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Fund your QikTalk Account with your other bank’s  USSD code",
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400
                  ),
                ),
                Text(
                  "₦10,000.00",
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    color: Colors.deepOrange
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 18,
                              width: 18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle
                              ),
                            ),
                            const SizedBox(width: 5,),
                            Text(
                              "Access Bank",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Text(
                          "*901*000*9575#",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(height: 15,),
                        Text(
                          "Dial the code & fund your account within the validity period",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.deepOrange
                          ),
                        ),
                        const SizedBox(height: 15,),
                        CustomCountdownTimer()
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100,),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Center(
                    child: Text(
                      "Copy Code",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                CustomButtonTwo(title: "Next", onClick: (){
                }, isLoading: false, hasMargin: false,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
