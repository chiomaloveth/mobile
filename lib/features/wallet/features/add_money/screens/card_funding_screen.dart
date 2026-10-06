import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/wallet/general/screens/enter_pin_screen.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';
import 'package:qik_talk/utilities/components/buttons/custom_default_button_one.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';

class CardFundingScreen extends ConsumerStatefulWidget {
  const CardFundingScreen({super.key});

  @override
  ConsumerState<CardFundingScreen> createState() => _CardFundingScreenState();
}

class _CardFundingScreenState extends ConsumerState<CardFundingScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

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
            "Card Deposit",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.refresh)),
            IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 1, color: Colors.blue),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "images/card_icon.png",
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Debit Card",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),
                          Row(
                            children: [
                              for (int i = 0; i < 4; i++) ...[
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Row(
                                    children: [
                                      for (int i = 0; i < 4; i++) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2.0,
                                          ),
                                          child: Container(
                                            height: 6,
                                            width: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Spacer(),
                          Row(
                            children: [
                              Text(
                                "MM/YY",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  Text(
                                    "CVV : ",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      for (int i = 0; i < 4; i++) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2.0,
                                          ),
                                          child: Container(
                                            height: 6,
                                            width: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  _buildCustomCardTextField(
                    title: "Enter Amount",
                    hintText: "",
                    controller: _amountController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildCustomCardTextField(
                    title: "Card Number",
                    hintText: "1234   5678   9098    4567",
                    controller: _cardNumberController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCustomCardTextField(
                          title: "Expiry Date",
                          hintText: "MM/YY",
                          controller: _amountController,
                          isDark: isDark,
                        ),
                      ),
                      Expanded(child: Container()),
                      Expanded(
                        child: _buildCustomCardTextField(
                          title: "CVV",
                          hintText: "123",
                          controller: _amountController,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  CustomDefaultButtonOne(
                    title: "Continue",
                    onClick: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EnterPinScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCardTextField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDark
                ? Colors.white.withOpacity(0.5)
                : Colors.grey.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
