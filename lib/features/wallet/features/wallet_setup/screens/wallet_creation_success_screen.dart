import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/bottom_nav/screen/custom_bottom_nav.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';

class WalletCreationSuccessScreen extends ConsumerStatefulWidget {
  const WalletCreationSuccessScreen({super.key});

  @override
  ConsumerState<WalletCreationSuccessScreen> createState() =>
      _WalletCreationSuccessScreenState();
}

class _WalletCreationSuccessScreenState
    extends ConsumerState<WalletCreationSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final backgroundColor = isDark
        ? Color(AppColors.primaryBackgroundColor)
        : Colors.white;
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(),
                child: Image.asset(
                  'images/success_card_card.dart.png',
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                "Wallet Created!",
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                "Your secure wallet has been successfully created. You can now send and receive money.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    width: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.grey.withOpacity(0.2), Colors.black],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 15,
                  ),
                  child: Column(
                    children: [
                      _itemList(title: "Account Name", value: "Odogwu Hillary"),
                      const SizedBox(height: 15),
                      _itemList(title: "Wallet ID", value: "PF-8467239"),
                      const SizedBox(height: 15),
                      _itemList(title: "Balance", value: "₦0.00"),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Container(
                height: 55,
                width: MediaQuery.of(context).size.width,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E1A0B), Color(0xFF6A3710)],
                  ),
                ),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => CustomBottomNav(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Center(
                    child: Text(
                      "Continue to Dashboard",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemList({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
