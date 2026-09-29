import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryRed = HexColor("#FE2B54");

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        appBar: AppBar(
          backgroundColor: AppTheme.scaffoldBg(isDark),
          elevation: 0,
          titleSpacing: 0,
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(isDark)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Activity Log",
            style: TextStyle(
              color: AppTheme.textPrimary(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48 + 37),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 37),
                child: TabBar(
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: primaryRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textSecondary(isDark),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: "All Activity"),
                    Tab(text: "Login Events"),
                    Tab(text: "Security Changes"),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildAllActivityTab(isDark),
                _buildLoginEventsTab(isDark),
                _buildSecurityChangesTab(isDark),
              ],
            ),
            // Floating Export Button
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Export Activity Log",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllActivityTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        _buildLogItem(
          icon: Icons.smartphone,
          title: "Login from iPhone 14 Pro",
          subtitle: "Successful login",
          time: "2 hours ago • Lagos, NG • 192.168.1.1",
          isDark: isDark,
        ),
        _buildLogItem(
          icon: Icons.key_outlined,
          title: "PIN Changed",
          subtitle: "Security PIN was updated",
          time: "5 hours ago • Lagos, NG • 192.168.1.1",
          isDark: isDark,
        ),
        _buildLogItem(
          icon: Icons.laptop_mac,
          title: "Browser Login",
          subtitle: "Chrome on MacBook Pro",
          time: "Yesterday at 3:45 PM • Lagos, NG • 192.168.1.2",
          isDark: isDark,
        ),
        _buildLogItem(
          icon: Icons.warning_amber_rounded,
          title: "Failed Login Attempt",
          subtitle: "Incorrect password",
          time: "Yesterday at 2:30 PM • Unknown • 203.45.67.89",
          status: "Failed",
          isDark: isDark,
        ),
        _buildLogItem(
          icon: Icons.verified_user_outlined,
          title: "Two-Step Verification Enabled",
          subtitle: "Additional security layer activated",
          time: "2 days ago • Lagos, NG • 192.168.1.1",
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildLoginEventsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        _buildLogItem(
          icon: Icons.smartphone,
          title: "Login from iPhone 14 Pro",
          subtitle: "Successful login",
          time: "2 hours ago • Lagos, NG • 192.168.1.1",
          isDark: isDark,
        ),
        _buildLogItem(
          icon: Icons.laptop_mac,
          title: "Browser Login",
          subtitle: "Chrome on MacBook Pro",
          time: "Yesterday at 3:45 PM • Lagos, NG • 192.168.1.2",
          isDark: isDark,
        ),
        _buildLogItem(
          icon: Icons.warning_amber_rounded,
          title: "Failed Login Attempt",
          subtitle: "Incorrect password",
          time: "Yesterday at 2:30 PM • Unknown • 203.45.67.89",
          status: "Failed",
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSecurityChangesTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        _buildLogItem(
          icon: Icons.key_outlined,
          title: "PIN Changed",
          subtitle: "Security PIN was updated",
          time: "5 hours ago • Lagos, NG • 192.168.1.1",
          isDark: isDark,
        ),
        _buildLogItem(
          icon: Icons.verified_user_outlined,
          title: "Two-Step Verification Enabled",
          subtitle: "Additional security layer activated",
          time: "2 days ago • Lagos, NG • 192.168.1.1",
          isDark: isDark,
        ),
        _buildLogItem(
          icon: Icons.settings_outlined,
          title: "Security Notification Settings Updated",
          subtitle: "Changed notification preferences",
          time: "1 week ago • Lagos, NG • 192.168.1.1",
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildLogItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    String? status,
    required bool isDark,
  }) {
    final isFailed = status == "Failed";
    final failedColor = HexColor("#FF6467");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isFailed
                  ? failedColor.withValues(alpha: 0.1)
                  : Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isFailed ? failedColor : Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isFailed
                              ? failedColor.withValues(alpha: 0.1)
                              : Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.poppins(
                            color: isFailed ? failedColor : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: Colors.white24,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
