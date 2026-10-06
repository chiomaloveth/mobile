import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import '../../../settings/theme/provider/theme_provider.dart';

class SettingsWalletTransactionReceiptScreen extends ConsumerStatefulWidget {
  const SettingsWalletTransactionReceiptScreen({super.key});

  @override
  ConsumerState<SettingsWalletTransactionReceiptScreen> createState() => _SettingsWalletTransactionReceiptScreenState();
}

class _SettingsWalletTransactionReceiptScreenState extends ConsumerState<SettingsWalletTransactionReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system && systemBrightness == Brightness.dark);

    final backgroundColor = isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightBackground;
    final cardColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05);
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white.withOpacity(0.5) : Colors.grey;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          elevation: 0,
          leading: CustomBackButton(buildContext: context),
          title: Text(
            "Transaction Details",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(IconlyBold.tick_square, color: Colors.green, size: 28),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Transfer Successful",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Mar 20, 2026 • 11:45 AM",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          "-₦10.00",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 25),

                        Divider(color: secondaryTextColor.withOpacity(0.2), thickness: 1),
                        const SizedBox(height: 25),

                        _ReceiptRow(
                          label: "Transaction Type",
                          value: "Airtime Purchase",
                          isDark: isDark,
                        ),
                        _ReceiptRow(
                          label: "Recipient",
                          value: "09012345678",
                          isDark: isDark,
                        ),
                        _ReceiptRow(
                          label: "Network",
                          value: "MTN Nigeria",
                          isDark: isDark,
                        ),
                        _ReceiptRow(
                          label: "Payment Method",
                          value: "Wallet Balance",
                          isDark: isDark,
                        ),
                        _ReceiptRow(
                          label: "Reference ID",
                          value: "REF-829302930",
                          isCopyable: true,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: IconlyLight.upload,
                          label: "Share Receipt",
                          isDark: isDark,
                          onTap: () {},
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _ActionButton(
                          icon: IconlyLight.document,
                          label: "Report Issue",
                          isDark: isDark,
                          onTap: () {},
                          isPrimary: false,
                        ),
                      ),
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

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isCopyable;

  const _ReceiptRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isCopyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey,
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: isPrimary
              ? (isDark ? Colors.white : Colors.black)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: isPrimary
              ? null
              : Border.all(
              color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3)
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isPrimary
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}