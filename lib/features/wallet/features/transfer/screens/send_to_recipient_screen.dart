import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:qik_talk/utilities/components/buttons/custom_default_button_one.dart';
import '../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';
import 'confirm_transfer_screen.dart';

class SendToRecipientScreen extends ConsumerStatefulWidget {
  const SendToRecipientScreen({super.key});

  @override
  ConsumerState<SendToRecipientScreen> createState() => _SearchForRecipientScreenState();
}

class _SearchForRecipientScreenState extends ConsumerState<SendToRecipientScreen> {
  final TextEditingController _noteController = TextEditingController();

  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    ref.read(userProfileProvider.notifier).loadUser();
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
          centerTitle: true,
          leading: CustomBackButton(buildContext: context),
          title: Text(
            "Transfer",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : null,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.history, color: isDark ? Colors.white : null),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert, color: isDark ? Colors.white : null),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sending to",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 42,
                                width: 42,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    IconlyBold.profile,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Sarah Johnson",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                        ),
                                        child: Container(
                                          height: 7,
                                          width: 1,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Qik@user_o",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "QikTalk User",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter Amount",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: _noteController,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF8904)
                          ),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.transparent)
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.transparent)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.transparent)
                              ),
                              hintText: "0.00",
                              prefixText: "₦",
                              hintStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF8904)
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Quick Amounts",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _quickAmountCard(amount: "1,000"),
                          _quickAmountCard(amount: "2,000"),
                          _quickAmountCard(amount: "5,000"),
                          _quickAmountCard(amount: "10,000"),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 35,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Note: Optional",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.transparent)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.transparent)
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.transparent)
                            ),
                            hintText: "Whats this for?",
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white
                            )
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30,),
                  CustomDefaultButtonOne(title: "Continue", onClick: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ConfirmTransferScreen()));
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickAmountCard({required String amount}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
        child: Text(
          "₦$amount",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFF8904)
          ),
        ),
      ),
    );
  }

}