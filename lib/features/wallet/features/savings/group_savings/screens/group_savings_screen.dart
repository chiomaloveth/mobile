import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../../../../../utilities/constants/app_colors.dart';
import '../../../../../authentication/provider/user_provider.dart';
import '../../../../../settings/theme/provider/theme_provider.dart';
import 'create_group_selection_sheet.dart';

class GroupSavingsScreen extends ConsumerStatefulWidget {
  const GroupSavingsScreen({super.key});

  @override
  ConsumerState<GroupSavingsScreen> createState() => _GroupSavingsScreenState();
}

class _GroupSavingsScreenState extends ConsumerState<GroupSavingsScreen> {
  void _showCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const CreateGroupSelectionSheet(),
    );
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
                        onTap: () {
                          Navigator.pop(context);
                        },
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
                        padding: EdgeInsets.only(top: topPadding, left: 0.0),
                        child: Text(
                          "Group",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(onPressed: () => _showCreateGroupSheet(context), icon: Icon(Icons.add))
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            _buildGroupCard('Monthly Savings Circle', 'Finance', '5 members', '2 hours ago', Colors.blueAccent),
            const SizedBox(height: 12),
            _buildGroupCard('Family Group', 'Family & Friends', '6 members', '1 day ago', Colors.purpleAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(String title, String type, String members, String time, Color iconColor) {
    bool isFinance = type == 'Finance';
    return Container(
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: iconColor,
            child: const Icon(Icons.people, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Icon(Icons.lock_outline, size: 16, color: AppColors.textGray),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFinance ? AppColors.primaryOrange.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(type, style: TextStyle(color: isFinance ? AppColors.primaryOrange : AppColors.primaryGreen, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Text(members, style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.textGray),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}