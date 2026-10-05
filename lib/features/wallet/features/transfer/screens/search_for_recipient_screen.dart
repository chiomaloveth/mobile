import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:iconly/iconly.dart';
import '../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../authentication/provider/user_provider.dart';
import '../../../../settings/theme/provider/theme_provider.dart';
import '../components/search_recipient_item_card.dart';

class SearchForRecipientScreen extends ConsumerStatefulWidget {
  const SearchForRecipientScreen({super.key});

  @override
  ConsumerState<SearchForRecipientScreen> createState() => _SearchForRecipientScreenState();
}

class _SearchForRecipientScreenState extends ConsumerState<SearchForRecipientScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  int _currentTabIndex = 0;

  void _handleTabClick(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

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
          leading: CustomBackButton(buildContext: context),
          title: Text(
            "Send Money",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : null,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)
                      ),
                      hintText: "Search recipient",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400
                      ),
                      prefixIcon: Icon(IconlyLight.search, color: Colors.white,)
                    ),
                  ),
                ),
                const SizedBox(height: 15,),
                Expanded(child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      for (int i = 0; i < 9; i++)...[
                        SearchRecipientItemCard()
                      ]
                    ],
                  ),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }

}