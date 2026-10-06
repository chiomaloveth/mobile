import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/wallet/services/wallet_services.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';

class KoraPayDepositScreen extends ConsumerStatefulWidget {
  const KoraPayDepositScreen({super.key});

  @override
  ConsumerState<KoraPayDepositScreen> createState() => _SuccessfulTransferScreenState();
}

class _SuccessfulTransferScreenState extends ConsumerState<KoraPayDepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  final WalletServices _walletServices = WalletServices();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _initializeFunding({required BuildContext context, required String amount}) async {
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final doubleAmount = double.tryParse(amount);
    if (doubleAmount == null || doubleAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      // final response = await _walletServices.fundWallet(
      //   context: context,
      //   amount: amount,
      // );
      //
      // String checkoutUrl = response.checkoutUrl ?? "";
      // checkoutUrl = checkoutUrl.trim();
      //
      // if (checkoutUrl.isNotEmpty) {
      //   if (!checkoutUrl.startsWith('http://') && !checkoutUrl.startsWith('https://')) {
      //     checkoutUrl = 'https://$checkoutUrl';
      //   }
      //
      //   final Uri url = Uri.parse(checkoutUrl);
      //   bool launched = await launchUrl(
      //     url,
      //     mode: LaunchMode.externalApplication,
      //   );
      //
      //   if (!launched) {
      //     if (mounted) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(content: Text('Could not open the payment browser.')),
      //       );
      //     }
      //   }
      // } else {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Payment URL not found in response.')),
      //     );
      //   }
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception:", "").trim())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final user = ref.watch(userProfileProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
            (currentThemeMode == ThemeMode.system &&
                systemBrightness == Brightness.dark);

    final textColor = isDark ? Colors.white : Colors.black;

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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const SizedBox(height: 20),
                Text(
                  "Fund Wallet",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter the amount you want to deposit into your wallet.",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    labelText: "Amount",
                    hintText: "0.00",
                    labelStyle: GoogleFonts.inter(color: textColor.withOpacity(0.5)),
                    prefixText: "₦ ",
                    prefixStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: textColor.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white : Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButtonTwo(
                  title: "Proceed to Pay",
                  onClick: () {
                    FocusScope.of(context).unfocus();
                    _initializeFunding(
                        context: context,
                        amount: _amountController.text.trim()
                    );
                  },
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}