import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/wallet/features/savings/group_savings/screens/step_four_review.dart';
import 'package:qik_talk/features/wallet/features/savings/group_savings/screens/step_one_setup.dart';
import 'package:qik_talk/features/wallet/features/savings/group_savings/screens/step_three_payout_order.dart';
import 'package:qik_talk/features/wallet/features/savings/group_savings/screens/step_two_select_members.dart';
import '../../../../../../utilities/constants/app_colors.dart';
import '../../../../../authentication/provider/user_provider.dart';
import '../../../../../settings/theme/provider/theme_provider.dart';
import '../models/group_savings_data_model.dart';
import 'group_savings_success_screen.dart';

class GroupSavingsSetupWizardScreen extends ConsumerStatefulWidget {
  const GroupSavingsSetupWizardScreen({super.key});

  @override
  ConsumerState<GroupSavingsSetupWizardScreen> createState() => _GroupSavingsSetupWizardScreenState();
}

class _GroupSavingsSetupWizardScreenState extends ConsumerState<GroupSavingsSetupWizardScreen> {
  int currentStep = 1;
  final GroupData groupData = GroupData();

  void nextStep() {
    if (currentStep < 4) {
      setState(() => currentStep++);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GroupSavingsSuccessScreen(groupData: groupData)));
    }
  }

  void prevStep() {
    if (currentStep > 1) {
      setState(() => currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    switch (currentStep) {
      case 1: title = 'Setup Finance Group'; break;
      case 2: title = 'Select Members'; break;
      case 3: title = 'Payout Order'; break;
      case 4: title = 'Review & Confirm'; break;
    }
    final user = ref.watch(userProfileProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
            (currentThemeMode == ThemeMode.system &&
                systemBrightness == Brightness.dark);

    final double topPadding = MediaQuery.of(context).padding.top + 10;

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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: HexColor("#3A1D07"),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/app_bar_gredient.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: prevStep,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topPadding,
                            left: 16.0,
                            right: 40.0,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 22.0,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('Step $currentStep of 4', style: const TextStyle(fontSize: 12, color: AppColors.textGray, fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    switch (currentStep) {
      case 1: return StepOneSetup(data: groupData, onNext: nextStep);
      case 2: return StepTwoSelectMembers(data: groupData, onNext: nextStep);
      case 3: return StepThreePayoutOrder(data: groupData, onNext: nextStep);
      case 4: return StepFourReview(data: groupData, onNext: nextStep, onEdit: () => setState(() => currentStep = 1));
      default: return const SizedBox.shrink();
    }
  }
}