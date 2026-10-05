import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';

import '../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';

class SuccessfulTransferScreen extends ConsumerStatefulWidget {
  const SuccessfulTransferScreen({super.key});

  @override
  ConsumerState<SuccessfulTransferScreen> createState() => _SuccessfulTransferScreenState();
}

class _SuccessfulTransferScreenState extends ConsumerState<SuccessfulTransferScreen> {
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
          actions: [
            TextButton(onPressed: (){}, child: Text(
              "Transaction Receipt",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white
              ),
            ))
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Image.asset("images/successful_transfer.png")),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "₦250,000",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF8904)
                          ),
                        ),
                        Text(
                          "Payment Successful",
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white
                          ),
                        ),
                        Text(
                          "Feb 27th, 2026  15:44:37",
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.5)
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40,),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
                      child: Column(
                        children: [
                          _detailsSum(title: "Transaction ID", value: "9786789786735656778"),
                          const SizedBox(height: 18),
                          _detailsSum(title: "Recipient Details", value: "SARAH JOHNSON", valueTwo: "Wallet | Qik@hilary_o"),
                          const SizedBox(height: 18),
                          _detailsSum(title: "Sender Details", value: "ODOGWU HILARY DAN", valueTwo: "QIKTAG |  Qik@hilarydan"),
                          const SizedBox(height: 18),
                          _detailsSum(title: "Session ID", value: "9786789786735656778", isBold: false),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40,),
                  CustomButtonTwo(title: "Download Receipt", onClick: (){}, isLoading: false, hasMargin: false,),
                  const SizedBox(height: 15,),
                  _customButtons(title: "Share Recipient", icon: "", onClick: (){}),
                  const SizedBox(height: 10,),
                  _customButtons(title: "Back to Chat", icon: "", onClick: (){}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailsSum({required String title, required String value, bool? isBold, String? valueTwo}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.5)
          ),
        ),
        Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold != null && isBold == true ? FontWeight.bold : FontWeight.w500
              ),
            ),
            if (valueTwo != null)...[
              Text(
                valueTwo,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400
                ),
              ),
            ]
          ],
        )
      ],
    );
  }

  Widget _customButtons({required String title, required String icon, required VoidCallback onClick}) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500
              ),
            )
          ],
        ),
      ),
    );
}

}
