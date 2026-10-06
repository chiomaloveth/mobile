import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/features/wallet/components/settings_wallet_quick_action_card.dart';
import 'package:qik_talk/features/wallet/components/wallet_animated_balance.dart';
import 'package:qik_talk/features/wallet/features/add_money/screens/add_money_screen.dart';
import 'package:qik_talk/features/wallet/features/e_bills/airtime/screens/airtime_screen.dart';
import 'package:qik_talk/features/wallet/features/transaction_history/services/transaction_history_services.dart';
import 'package:qik_talk/features/wallet/features/virtual_card/screens/virtual_card_screen.dart';
import 'package:qik_talk/features/wallet/model/wallet_balance_model.dart';
import 'package:qik_talk/features/wallet/screens/settings_wallet/new_deposit_funds_screen.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/constants/app_icons.dart';

import '../../../../utilities/constants/app_colors.dart';
import '../../../authentication/provider/user_provider.dart';
import '../../features/transaction_history/components/transaction_history_card_one.dart';
import '../../components/transaction_history_screen.dart';
import '../../features/e_bills/mobile_data/mobile_data_screen.dart';
import '../../features/transaction_history/model/transaction_history_model.dart';
import '../../features/transaction_history/screens/wallet_transaction_history_screen.dart';
import '../../features/transfer/screens/transfer_screen.dart';
import '../../features/withdraw/screen/withdrawal_screen.dart';
import '../../section/make_transfer_section/sheets/make_transfer_bottom_sheet.dart';
import '../../services/wallet_services.dart';

class SettingsWalletScreen extends ConsumerStatefulWidget {
  const SettingsWalletScreen({super.key});

  @override
  ConsumerState<SettingsWalletScreen> createState() =>
      _SettingsWalletScreenState();
}

class _SettingsWalletScreenState extends ConsumerState<SettingsWalletScreen> {
  bool _isBalanceVisible = true;
  final WalletServices _walletServices = WalletServices();
  final TransactionHistoryServices _transactionHistoryServices =
  TransactionHistoryServices();
  late Future<WalletBalanceModel> _futureBalance;
  late Future<List<TransactionHistoryModel>> _futureTransactions;

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    _futureBalance = _walletServices.getWalletBalance(context: context);
    _futureTransactions =
        _transactionHistoryServices.getUserTransactions(context: context);
    ref.read(userProfileProvider.notifier).loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
        isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightBackground,
        systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _futureBalance = _walletServices.getWalletBalance(context: context);
            _futureTransactions =
                _transactionHistoryServices.getUserTransactions(context: context);
          });
        },
        child: Scaffold(
          backgroundColor:
          isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightBackground,
          appBar: AppBar(
            backgroundColor:
            isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightBackground,
            surfaceTintColor:
            isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightBackground,
            automaticallyImplyLeading: false,
            leading: CustomBackButton(buildContext: context),
            title: Text(
              "Wallet",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_horiz, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Available Balance",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white.withOpacity(0.4)
                                    : null,
                              ),
                            ),
                            FutureBuilder<WalletBalanceModel>(
                              future: _futureBalance,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return WalletAnimatedBalance(
                                    balance: 0.00,
                                    isVisible: _isBalanceVisible,
                                  );
                                }
                                if (snapshot.hasError ||
                                    !snapshot.hasData ||
                                    snapshot.data == null) {
                                  return WalletAnimatedBalance(
                                    balance: 0.00,
                                    isVisible: _isBalanceVisible,
                                  );
                                }
                                final data = snapshot.data!;
                                return WalletAnimatedBalance(
                                  balance: data.balance,
                                  isVisible: _isBalanceVisible,
                                );
                              },
                            )
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _toggleBalanceVisibility,
                          child: Container(
                            height: 23,
                            width: 23,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Icon(
                                _isBalanceVisible
                                    ? Icons.remove_red_eye_outlined
                                    : Icons.remove_red_eye,
                                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.sort_up,
                          color: isDark ? Colors.greenAccent : Colors.green,
                          size: 15,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "+₦0.00 (0.0%)",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.greenAccent : Colors.green,
                          ),
                        ),
                        const Text(
                          "this month",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: SettingsWalletQuickActionCard(
                            title: "Add Money",
                            iconData: Icons.add,
                            onClick: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                  const NewDepositFundsScreen()));
                            },
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SettingsWalletQuickActionCard(
                            title: "Send",
                            iconData: Icons.send_rounded,
                            iconDataTwo: AppIcons.sendIcon,
                            onClick: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const TransferScreen()));
                            },
                            iconTwoSize: 18,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SettingsWalletQuickActionCard(
                            title: "Withdraw",
                            iconData: CupertinoIcons.down_arrow,
                            iconDataTwo: AppIcons.withdrawIcon,
                            onClick: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const WithdrawalScreen()));
                            },
                            iconTwoSize: 20,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Services",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
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
                                MaterialPageRoute(
                                  builder: (context) => BuyAirtimeScreen(),
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
                            title: "Bills",
                            iconData: Icons.power_sharp,
                            iconDataTwo: AppIcons.billsIcon,
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
                            title: "More",
                            iconData: Icons.more_horiz,
                            onClick: () {},
                            radius: 15,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Transactions",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                const WalletTransactionHistoryScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "See All",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<TransactionHistoryModel>>(
                      future: _futureTransactions,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            children: [
                              for (int i = 0; i < 8; i++)...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Container(
                                    height: 75,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15)
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Error loading transactions",
                                  textAlign: TextAlign.center,
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _futureTransactions = _transactionHistoryServices.getUserTransactions(context: context);
                                    });
                                  },
                                  child: const Text("Try Again"),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: const Text("No transactions yet"));
                        }
                        final transactions = snapshot.data!;
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length > 6 ? 6 : transactions.length,
                          separatorBuilder: (c, i) => const SizedBox(height: 0),
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];

                            return TransactionHistoryCardOne(isDark: isDark, transactionHistoryModel: transaction,);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}