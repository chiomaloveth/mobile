import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/components/buttons/custom_default_button_one.dart';
import '../../../authentication/provider/user_provider.dart';
import '../../../settings/theme/provider/theme_provider.dart';
import '../../features/add_money/screens/deposit_successful_screen.dart';
import '../../features/withdraw/screen/withdraw_success_screen.dart';

class EnterPinScreen extends ConsumerStatefulWidget {
  const EnterPinScreen({super.key});

  @override
  ConsumerState<EnterPinScreen> createState() =>
      _SuccessfulTransferScreenState();
}

class _SuccessfulTransferScreenState extends ConsumerState<EnterPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _pin = "";

  @override
  void initState() {
    super.initState();
    _pinController.addListener(() {
      setState(() {
        _pin = _pinController.text;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleOnClick(int index) {
    _focusNode.requestFocus();
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
            "Enter OTP",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children:[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:[
                        Text(
                          "Enter Pin to Confirm",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Enter your six digits pin to continue",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 15,),

                        Stack(
                          alignment: Alignment.center,
                          children:[
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0,
                                child: TextField(
                                  controller: _pinController,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  autofocus: true,
                                  showCursor: false,
                                  inputFormatters:[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:[
                                for (int i = 0; i < 6; i++)...[
                                  _buildPINLayer(
                                      index: i,
                                      currentIndex: _pin.length,
                                      value: _pin.length > i ? _pin[i] : "",
                                      onClick: () => _handleOnClick(i)
                                  )
                                ]
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Spacer(),
                CustomDefaultButtonOne(title: "Continue", onClick: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => DepositSuccessScreen()));
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPINLayer({
    required int index,
    required int currentIndex,
    required String value,
    required VoidCallback onClick
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: GestureDetector(
        onTap: onClick,
        child: Container(
          height: 35,
          width: 35,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 1.5,
                  color: index == currentIndex ? Colors.deepOrange : Colors.grey.withOpacity(0.3)
              ),
              shape: BoxShape.circle
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}