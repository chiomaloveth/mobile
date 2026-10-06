import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:qik_talk/features/wallet/features/account_statement/screens/account_statement_screen.dart';
import 'package:qik_talk/features/wallet/features/e_bills/cable/screens/cable_tv_screen.dart';
import 'package:qik_talk/features/wallet/features/e_bills/electricity/screens/electricity_bill_screen.dart';
import 'package:qik_talk/features/wallet/features/e_bills/mobile_data/mobile_data_screen.dart';
import 'package:qik_talk/features/wallet/features/savings/screens/savings_screen.dart';
import 'package:qik_talk/features/wallet/features/virtual_card/screens/virtual_card_screen.dart';

import '../../../../../utilities/constants/app_icons.dart';
import '../../../../settings/theme/provider/theme_provider.dart';
import '../../../components/settings_wallet_quick_action_card.dart';
import '../../../features/e_bills/airtime/screens/airtime_screen.dart';

class ServicesSection extends ConsumerStatefulWidget {
  const ServicesSection({super.key});

  @override
  ConsumerState<ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends ConsumerState<ServicesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(
          "Quick Actions",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A1008),
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: SettingsWalletQuickActionCard(
                title: "Airtime",
                iconData: Icons.phone_android,
                iconDataTwo: AppIcons.airtimeIcon,
                onClick: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => BuyAirtimeScreen()),
                  );
                },
                radius: 15,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SettingsWalletQuickActionCard(
                title: "Electricity",
                iconData: Icons.power_sharp,
                iconDataTwo: AppIcons.billsIcon,
                onClick: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ElectricityBillScreen(),
                    ),
                  );
                },
                radius: 15,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SettingsWalletQuickActionCard(
                title: "Cards",
                iconData: Icons.credit_card,
                iconDataTwo: AppIcons.cardIcon,
                onClick: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VirtualCardsScreen(),
                    ),
                  );
                },
                radius: 15,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SettingsWalletQuickActionCard(
                title: _isExpanded ? "Less" : "More",
                iconData: _isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                onClick: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                radius: 15,
                isDark: isDark,
                isExpanded: _isExpanded,
              ),
            ),
          ],
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SettingsWalletQuickActionCard(
                            title: "Data",
                            iconData: Icons.wifi,
                            onClick: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MobileDataScreen(),
                                ),
                              );
                            },
                            radius: 15,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SettingsWalletQuickActionCard(
                            title: " Cable",
                            iconData: Icons.tv,
                            onClick: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CableTVScreen(),
                                ),
                              );
                            },
                            radius: 15,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SettingsWalletQuickActionCard(
                            title: "Savings",
                            iconData: Icons.savings_outlined,
                            onClick: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SavingsScreen(),
                                ),
                              );
                            },
                            radius: 15,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SettingsWalletQuickActionCard(
                            title: "Invoice",
                            iconData: IconlyLight.document,
                            onClick: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AccountStatementsScreen(),
                                ),
                              );
                            },
                            radius: 15,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
