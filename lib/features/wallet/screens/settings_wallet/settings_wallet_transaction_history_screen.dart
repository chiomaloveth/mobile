import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

import '../../../settings/theme/provider/theme_provider.dart';
import '../../components/transaction_history_card_one.dart';

class SettingsWalletTransactionHistoryScreen extends ConsumerStatefulWidget {
  const SettingsWalletTransactionHistoryScreen({super.key});

  @override
  ConsumerState<SettingsWalletTransactionHistoryScreen> createState() => _SettingsWalletTransactionHistoryScreenState();
}

class _SettingsWalletTransactionHistoryScreenState extends ConsumerState<SettingsWalletTransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system && systemBrightness == Brightness.dark);

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
        backgroundColor: isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightBackground,
          surfaceTintColor: isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightBackground,
          leading: CustomBackButton(buildContext: context),
          title: Text(
            "Transactions",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
            ),
          ),
          actions:[
            IconButton(onPressed:(){},icon: Icon(Icons.filter_list_rounded)),
            IconButton(onPressed:(){},icon: Icon(IconlyLight.search)),
          ]
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today, Mar 20",
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.grey : null,
                        ),
                      ),
                      for (int i = 0; i < 4; i++) ...[
                        TransactionHistoryCardOne(isDark: isDark),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Yesterday, Dec 28",
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.grey : null,
                        ),
                      ),
                      for (int i = 0; i < 2; i++) ...[
                        TransactionHistoryCardOne(isDark: isDark),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "December 28, 2025",
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.grey : null,
                        ),
                      ),
                      for (int i = 0; i < 5; i++) ...[
                        TransactionHistoryCardOne(isDark: isDark),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "December 25, 2025",
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.grey : null,
                        ),
                      ),
                      for (int i = 0; i < 17; i++) ...[
                        TransactionHistoryCardOne(isDark: isDark),
                      ],
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
