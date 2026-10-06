import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

import '../../../utilities/components/buttons/custom_button_two.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../authentication/provider/user_provider.dart';
import '../../settings/theme/provider/theme_provider.dart';
import '../features/verification/screens/account_verification_screen.dart';

class WalletProfileScreen extends ConsumerStatefulWidget {
  const WalletProfileScreen({super.key});

  @override
  ConsumerState<WalletProfileScreen> createState() => _WalletProfileScreenState();
}

class _WalletProfileScreenState extends ConsumerState<WalletProfileScreen> {
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
            : AppTheme.scaffoldBg(isDark),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppTheme.scaffoldBg(isDark),
        appBar: AppBar(
          backgroundColor: isDark
              ? Color(AppColors.primaryBackgroundColor)
              : AppTheme.scaffoldBg(isDark),
          surfaceTintColor: isDark
              ? Color(AppColors.primaryBackgroundColor)
              : AppTheme.scaffoldBg(isDark),
          automaticallyImplyLeading: false,
          leading: CustomBackButton(buildContext: context),
          centerTitle: true,
          title: Text(
            "My Profile",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Center(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Stack(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              shape: BoxShape.circle
                            ),
                            child: Image.network(user.profilePictureUrl, key: ValueKey(user.profilePictureUrl), fit: BoxFit.cover, errorBuilder: (context, err, st) {
                              return Center(
                                child: Icon(IconlyBold.profile, size: 40, color: Colors.grey,),
                              );
                            },),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: Center(
                                child: Icon(Icons.edit, size: 19, color: Colors.black,),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Text(
                      user.username,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                        fontSize: 18
                      ),
                    ),
                    const SizedBox(height: 25,),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "QikTag",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    Text(
                                      "Qik@odogwuhilary",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: isDark ? Colors.white.withOpacity(0.5) : AppTheme.textSecondary(isDark),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                        child: Image.asset("images/copy_icon.png", color: Colors.grey,))
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  "Account Tier",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AccountVerificationScreen()));
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(50)
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                height: 18,
                                                  width: 18,
                                                  child: Image.asset("images/tier_3_icon.png", color: Colors.orange,)),
                                              const SizedBox(width: 5),
                                              Text(
                                                "Tier 3",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.w500
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5,),
                                      Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white.withOpacity(0.5) : AppTheme.iconColorSubtle(isDark), size: 20,)
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  "Wallet Mood",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  "Sapa Mood",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? Colors.white.withOpacity(0.5) : AppTheme.textSecondary(isDark),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  "Bank Details",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  "Add",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.orange
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 50,),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
                        child: Column(
                          children: [
                            _detailsRow(title: "Full Name", value: "ODOGWU HILARY DAN", hasArrow: false),
                            const SizedBox(height: 20),
                            _detailsRow(title: "Mobile Number", value: "+23480672875784", hasArrow: true),
                            const SizedBox(height: 20),
                            _detailsRow(title: "Nickname", value: "Enter Nickname", hasArrow: true),
                            const SizedBox(height: 20),
                            _detailsRow(title: "Gender", value: "Male", hasArrow: false),
                            const SizedBox(height: 20),
                            _detailsRow(title: "Date of birth", value: "**-**-27", hasArrow: false),
                            const SizedBox(height: 20),
                            _detailsRow(title: "Email", value: "h*gmail.com", hasArrow: false),
                            const SizedBox(height: 20),
                            _detailsRow(title: "Address", value: "", hasArrow: true),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailsRow({required String title, required String value, required bool hasArrow}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isDark ? Colors.white.withOpacity(0.5) : AppTheme.textSecondary(isDark),
              ),
            ),
            hasArrow
                ? Icon(Icons.arrow_forward_ios_rounded,
                    color: isDark ? Colors.white.withOpacity(0.5) : AppTheme.iconColorSubtle(isDark),
                    size: 18)
                : const SizedBox.shrink(),
          ],
        )
      ],
    );
  }
}
