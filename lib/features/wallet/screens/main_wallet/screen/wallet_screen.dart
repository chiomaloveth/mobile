import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:qik_talk/features/wallet/screens/main_wallet/components/balance_card.dart';
import 'package:qik_talk/features/wallet/screens/main_wallet/sections/services_section.dart';
import 'package:qik_talk/features/wallet/screens/wallet_profile_screen.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../../utilities/constants/app_theme.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';
import '../../../features/transaction_history/model/transaction_history_model.dart';
import '../../../features/transaction_history/services/transaction_history_services.dart';
import '../../../features/transfer/screens/new_transfer_screens/enter_transfer_amount_screen.dart';
import '../../../model/wallet_balance_model.dart';
import '../../../services/wallet_services.dart';
import '../../../features/transaction_history/components/transaction_history_card.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final WalletServices _walletServices = WalletServices();
  late Future<WalletBalanceModel> _futureBalance;
  final TransactionHistoryServices _transactionHistoryServices =
      TransactionHistoryServices();
  late Future<List<TransactionHistoryModel>> _futureTransactions;

  @override
  void initState() {
    super.initState();
    _futureBalance = _walletServices.getWalletBalance(context: context);
    _futureTransactions = _transactionHistoryServices.getUserTransactions(
      context: context,
    );
    Future.microtask(() {
      ref.read(userProfileProvider.notifier).loadUser();
    });
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

    final backgroundColor = isDark
        ? Color(AppColors.primaryBackgroundColor)
        : const Color(0xFFFAF5F0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Stack(
        children: [
          Container(color: backgroundColor),
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leadingWidth: MediaQuery.of(context).size.width,
              leading: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WalletProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 45,
                        width: 45,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          user.profilePicture,
                          fit: BoxFit.cover,
                          errorBuilder: (context, err, st) {
                            return const Center(
                              child: Icon(
                                IconlyBold.profile,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Good Morning",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? Colors.grey : AppColors.lightTextSecondary,
                          ),
                        ),
                        Text(
                          user.username,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.12)
                          : const Color(0xFFEDE6DC),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        IconlyLight.notification,
                        color: isDark ? Colors.white : const Color(0xFF1A1008),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const BalanceCard(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.withOpacity(0.2)
                              : const Color(0xFFF0EAE2),
                          borderRadius: BorderRadius.circular(360),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _quickAccessCard(
                                  title: "Transfer",
                                  onClick: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const EnterTransferAmountScreen(),
                                      ),
                                    );
                                  },
                                  icon: IconlyLight.send,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _quickAccessCard(
                                  title: "Vault",
                                  onClick: () {},
                                  icon: IconlyLight.lock,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Column(
                              children: [
                                const ServicesSection(),
                                const SizedBox(height: 25),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Transaction History",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: isDark ? Colors.white : const Color(0xFF1A1008),
                                        fontWeight: FontWeight.w600,
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
                                          for (int i = 0; i < 3; i++) ...[
                                            Row(
                                              children: [
                                                for (int j = 0; j < 2; j++) ...[
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      child: Container(
                                                        height: 150,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey
                                                              .withOpacity(
                                                                0.15,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                15,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ],
                                      );
                                    } else if (snapshot.hasError) {
                                      return const Center(
                                        child: Text(
                                          "Failed to load transactions",
                                        ),
                                      );
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                        child: Text("No transactions yet"),
                                      );
                                    }

                                    final transactions = snapshot.data!;
                                    final maxItems = transactions.length.clamp(0, 6);

                                    return Column(
                                      children: [
                                        for (int i = 0; i < maxItems; i += 2) ...[
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(0),
                                                  child: _transactionCard(transactions[i]),
                                                ),
                                              ),

                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(0),
                                                  child: (i + 1 < maxItems)
                                                      ? _transactionCard(transactions[i + 1])
                                                      : const SizedBox(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(TransactionHistoryModel transaction) {
    return TransactionHistoryCard(transactionHistoryModel: transaction);
  }

  Widget _quickAccessCard({
    required String title,
    required VoidCallback onClick,
    required IconData icon,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onClick,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.withOpacity(0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(360),
          border: Border.all(width: 1, color: isDark ? Colors.white.withOpacity(0.3) : const Color(0xFFCFC4B5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white : const Color(0xFF1A1008),
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white : const Color(0xFF1A1008),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
