import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:qik_talk/features/wallet/features/withdraw/screen/select_bank_account_cont_screen.dart';

import '../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../utilities/components/buttons/custom_default_button_one.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';

class SelectBankScreen extends ConsumerStatefulWidget {
  const SelectBankScreen({super.key});

  @override
  ConsumerState<SelectBankScreen> createState() => _SearchForRecipientScreenState();
}

class _SearchForRecipientScreenState extends ConsumerState<SelectBankScreen> {
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
            "Select Bank Account",
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
                                          color: Colors.white.withOpacity(0.2),
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
                                            color: Colors.white.withOpacity(0.2),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "Qik@user_o",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "₦1,315.15",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "QikTalk",
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
                  const SizedBox(height: 30,),
                  CustomDefaultButtonOne(title: "Add New Bank Account", onClick: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SelectBankContScreen()));
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}