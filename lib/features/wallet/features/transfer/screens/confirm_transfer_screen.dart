import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/wallet/features/transfer/screens/successful_transfer_screen.dart';

import '../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../utilities/components/buttons/custom_default_button_one.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';

class ConfirmTransferScreen extends ConsumerStatefulWidget {
  const ConfirmTransferScreen({super.key});

  @override
  ConsumerState<ConfirmTransferScreen> createState() => _SearchForRecipientScreenState();
}

class _SearchForRecipientScreenState extends ConsumerState<ConfirmTransferScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(userProfileProvider.notifier).loadUser();
  }

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
          centerTitle: true,
          leading: CustomBackButton(buildContext: context),
          title: Text(
            "Confirm Transfer",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : null,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        children: [
                          Text(
                            "You're sending",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white
                            ),
                          ),
                          const SizedBox(height: 10,),
                          Text(
                            "₦20,000.00",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.deepOrange
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Transfer Details",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.orangeAccent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Center(
                                      child: Text(
                                        "SJ",
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.deepOrange
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Recipient",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white.withOpacity(0.5)
                                        ),
                                      ),
                                      const SizedBox(height: 4,),
                                      Row(
                                        children: [
                                          Text(
                                            "Sarah Johnson",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0,
                                            ),
                                            child: Container(
                                              height: 7,
                                              width: 1,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Qik@user_o",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 20,),
                              _detailsSum(title: "Note:", value: "For school fees"),
                              const SizedBox(height: 18),
                              _detailsSum(title: "Amount", value: "₦20,000.00"),
                              const SizedBox(height: 18),
                              _detailsSum(title: "Transfer fee", value: "₦10.00"),
                              const SizedBox(height: 18),
                              _detailsSum(title: "Total", value: "₦20,010.00", isBold: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  CustomDefaultButtonOne(title: "Confirm Transfer", onClick: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SuccessfulTransferScreen()));
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  
  Widget _detailsSum({required String title, required String value, bool? isBold}) {
    return Row(
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
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold != null && isBold == true ? FontWeight.bold : FontWeight.w500
          ),
        )
      ],
    );
  }
}