import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/wallet/features/transfer/screens/new_transfer_screens/transfer_account_details_screen.dart';
import '../../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../../utilities/constants/app_colors.dart';
import '../../../../../authentication/provider/user_provider.dart';
import '../../../../../settings/theme/provider/theme_provider.dart';

class EnterTransferAmountScreen extends ConsumerStatefulWidget {
  const EnterTransferAmountScreen({super.key});

  @override
  ConsumerState<EnterTransferAmountScreen> createState() => _EnterTransferAmountScreenState();
}

class _EnterTransferAmountScreenState extends ConsumerState<EnterTransferAmountScreen> {
  String _amount = "0";

  void _handleKeyPress(String value) {
    setState(() {
      if (value == '<') {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = "0";
        }
      } else if (value == '') {
      } else {
        if (_amount == "0") {
          _amount = value;
        } else {
          if (_amount.length < 12) {
            _amount += value;
          }
        }
      }
    });
  }

  String get _formattedAmount {
    if (_amount.isEmpty) return "0";
    return _amount.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
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

    final textColor = isDark ? Colors.white : Colors.black;

    final List<List<String>> keypadRows = [['1', '2', '3'],
      ['4', '5', '6'],['7', '8', '9'],
      ['', '0', '<'],
    ];

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
            "Enter Amount",
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
              children:[
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Amount",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.withOpacity(0.4),
                            ),
                          ),
                          // Wrap with SizedBox to give it a defined horizontal space
                          // and FittedBox to scale the text down.
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9, // Constraints the width
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // This is the magic line
                              alignment: Alignment.center,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "₦",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: textColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: _formattedAmount,
                                      style: GoogleFonts.poppins(
                                        fontSize: 70, // This is the base size; it will shrink from here
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    children:[
                      for (var row in keypadRows)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:[
                            for (var key in row)
                              _buildCustomButton(
                                value: key,
                                textColor: textColor,
                              )
                          ],
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(colors: [Color(0xFF2E1A0B), Color(0xFF6A3710)])
                  ),
                  child: MaterialButton(
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransferAccountDetailsScreen(amount: _formattedAmount)));
                    },
                    child: Center(
                      child: Text(
                        "Continue",
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton({required String value, required Color textColor}) {
    if (value.isEmpty) {
      return Expanded(child: const SizedBox.shrink());
    }

    bool isCancelBtn = value == '<';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () => _handleKeyPress(value),
            child: Container(
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(width: 1, color: Colors.grey.withOpacity(0.3))
              ),
              child: isCancelBtn
                  ? Icon(
                  Icons.backspace_outlined,
                  color: textColor,
                  size: 28
              )
                  : Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}