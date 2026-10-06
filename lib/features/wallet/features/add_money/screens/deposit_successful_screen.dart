import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';

import '../../../../../utilities/constants/app_colors.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';

class DepositSuccessScreen extends ConsumerStatefulWidget {
  const DepositSuccessScreen({super.key});

  @override
  ConsumerState<DepositSuccessScreen> createState() =>
      _SuccessfulTransferScreenState();
}

class _SuccessfulTransferScreenState
    extends ConsumerState<DepositSuccessScreen> {
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
          actions: [],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Image.asset("images/successful_transfer.png")),
                const SizedBox(height: 15),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Deposit Successful!",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,

                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        "₦50,000has been added to your wallet",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,

                          color: isDark
                              ? Colors.white.withOpacity(0.5)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                CustomButtonTwo(
                  title: "Back to Wallet",
                  onClick: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  isLoading: false,
                  hasMargin: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
