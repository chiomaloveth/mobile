import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/wallet/features/transfer/screens/new_transfer_screens/components/bank_list_bottom_sheet.dart';

import '../../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../../utilities/constants/app_colors.dart';
import '../../../../../authentication/provider/user_provider.dart';
import '../../../../../settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/features/wallet/features/transfer/screens/new_transfer_screens/select_transfer_method_screen.dart';

import '../../model/bank_list_model.dart';
import '../../model/local_account_number_response_model.dart';
import '../../services/transfer_services.dart';

class TransferAccountDetailsScreen extends ConsumerStatefulWidget {
  final String amount;

  const TransferAccountDetailsScreen({required this.amount, super.key});

  @override
  ConsumerState<TransferAccountDetailsScreen> createState() =>
      _TransferAccountDetailsScreenState();
}

class _TransferAccountDetailsScreenState
    extends ConsumerState<TransferAccountDetailsScreen> {
  final TextEditingController _accountNumberController =
  TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  late Future<List<BankListModel>> _futureBanks;

  BankListModel? _selectedBank;
  String _selectedBankCode = "";
  final TransferServices _transferServices = TransferServices();

  bool _isLoading = false;
  String? _errorMessage;

  LocalAccountNumberResponseModel? _fetchedAccountDetails;

  @override
  void initState() {
    _futureBanks = _transferServices.getBankList(context: context);
    super.initState();
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _performVerification(String accountNumber) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _fetchedAccountDetails = null;
    });

    try {
      final response = await _transferServices.verifyLocalAccountNumber(
        context: context,
        accNo: accountNumber,
        bankCode: _selectedBankCode,
      );

      if (response != null) {
        setState(() {
          _fetchedAccountDetails = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Account not found. Please check the number.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred while verifying the account.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final textColor = isDark ? Colors.white : Colors.black;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? const Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark
              ? const Color(AppColors.primaryBackgroundColor)
              : Colors.white,
          surfaceTintColor: isDark
              ? const Color(AppColors.primaryBackgroundColor)
              : Colors.white,
          automaticallyImplyLeading: false,
          leading: CustomBackButton(buildContext: context),
          title: Text(
            "Account Details",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                width: 1,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 20,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Sending",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.withOpacity(0.9),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "₦",
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: textColor,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        TextSpan(
                                          text: widget.amount,
                                          style: GoogleFonts.poppins(
                                            fontSize: 40,
                                            color: textColor,
                                            fontWeight: FontWeight.w500,
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
                        const SizedBox(height: 25),

                        // Dropdown handles Future internally now
                        _buildBankDropdown(_futureBanks),

                        const SizedBox(height: 15),

                        if (_selectedBank != null) ...[
                          _buildCustomTextField(
                            title: "Account Number / Phone Number",
                            hintText: "0000000000",
                            controller: _accountNumberController,
                            keyboardType: TextInputType.number,
                            maxLength: 11,
                            showLoadingIndicator: _isLoading,
                            onChange: (value) {
                              // Trigger verification
                              if (value.length == 10 || value.length == 11) {
                                _performVerification(value);
                              } else {
                                if (_fetchedAccountDetails != null ||
                                    _errorMessage != null) {
                                  setState(() {
                                    _fetchedAccountDetails = null;
                                    _errorMessage = null;
                                  });
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                        ],

                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),

                        if (_fetchedAccountDetails != null) ...[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                width: 1,
                                color: Colors.green.withOpacity(0.5),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18.0,
                                vertical: 15,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Account Name",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    _fetchedAccountDetails!.accountName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    _fetchedAccountDetails!.bankName.isNotEmpty
                                        ? _fetchedAccountDetails!.bankName
                                        : "Qik Talk Wallet",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    _fetchedAccountDetails!.accountNumber,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          _buildCustomTextField(
                            title: "Reason for transfer (Optional)",
                            hintText: "What is this for?",
                            controller: _reasonController,
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),

                if (_fetchedAccountDetails != null)
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E1A0B), Color(0xFF6A3710)],
                      ),
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SelectTransferMethodScreen(
                              amount: widget.amount,
                              receiverName: _fetchedAccountDetails!.accountName,
                              description: _reasonController.text.trim(),
                              accountNumber: _accountNumberController.text
                                  .trim(),
                              bankName: _fetchedAccountDetails!.bankName,
                              bankCode: _fetchedAccountDetails!.bankCode,
                            ),
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          "Continue",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankDropdown(Future<List<BankListModel>> futureBanks) {
    return BankListBottomSheet(
      selected: _selectedBank,
      futureBanks: futureBanks,
      onSelected: (BankListModel? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedBank = newValue;
            _selectedBankCode = newValue.code;
            _accountNumberController.clear();
            _fetchedAccountDetails = null;
            _errorMessage = null;
          });
        }
      },
    );
  }

  Widget _buildCustomTextField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    Function(String value)? onChange,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool showLoadingIndicator = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(width: 1, color: Colors.grey.withOpacity(0.5)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            decoration: InputDecoration(
              counterText: "",
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.withOpacity(0.5),
              ),
              suffixIcon: showLoadingIndicator
                  ? const Padding(
                padding: EdgeInsets.all(15.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : null,
            ),
            onChanged: onChange,
          ),
        ),
      ],
    );
  }
}