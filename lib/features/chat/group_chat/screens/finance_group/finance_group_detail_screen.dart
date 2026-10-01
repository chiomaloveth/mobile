import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/group_chat/screens/finance_group/tabs/finance_group_activity_tab.dart';
import 'package:qik_talk/features/chat/group_chat/screens/finance_group/tabs/finance_group_members_tab.dart';
import 'package:qik_talk/features/chat/group_chat/screens/finance_group/tabs/finance_group_overview_tab.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class FinanceGroupDetailScreen extends ConsumerStatefulWidget {
  final String groupName;
  final bool isAdmin;

  const FinanceGroupDetailScreen({
    super.key,
    required this.groupName,
    this.isAdmin = true,
  });

  @override
  ConsumerState<FinanceGroupDetailScreen> createState() =>
      _FinanceGroupDetailScreenState();
}

class _FinanceGroupDetailScreenState extends ConsumerState<FinanceGroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [HexColor('#3A1D07'), HexColor('#171516')],
                  )
                : null,
            color: isDark ? null : AppTheme.scaffoldBg(isDark),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groupName,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Finance Group',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.account_balance_wallet_outlined,
                    color: isDark ? Colors.white70 : AppTheme.textSecondary(isDark),
                    size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.settings_outlined,
                    color: isDark ? Colors.white70 : AppTheme.textSecondary(isDark),
                    size: 22),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: AppTheme.scaffoldBg(isDark),
            child: TabBar(
              controller: _tabController,
              indicatorColor: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              indicatorWeight: 2,
              labelColor: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              unselectedLabelColor:
                  isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Members'),
                Tab(text: 'Activity'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const FinanceGroupOverviewTab(),
                FinanceGroupMembersTab(isAdmin: widget.isAdmin),
                const FinanceGroupActivityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
