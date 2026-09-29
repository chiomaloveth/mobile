import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'activity_log_screen.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class SecurityAlertsScreen extends StatefulWidget {
  const SecurityAlertsScreen({super.key});

  @override
  State<SecurityAlertsScreen> createState() => _SecurityAlertsScreenState();
}

class _SecurityAlertsScreenState extends State<SecurityAlertsScreen> {
  bool _newLoginAlerts = true;
  bool _newDeviceAdded = true;
  bool _locationChanges = false;
  bool _securityChanges = true;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                ? [HexColor("#171516"), HexColor("#3A1D07")]
                : [const Color(0xFFF5EEE4), const Color(0xFFFAF5F0)],
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Login Activity",
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Info Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Stay informed about important security events on your account",
                      style: GoogleFonts.poppins(
                        color: Colors.blue,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader("ALERT PREFERENCES", isDark),
            _buildAlertToggle(
              icon: Icons.notifications_none_outlined,
              title: "New Login Alerts",
              subtitle: "Get notified when you log in from a new device",
              value: _newLoginAlerts,
              onChanged: (val) => setState(() => _newLoginAlerts = val),
              isDark: isDark,
            ),
            _buildAlertToggle(
              icon: Icons.devices_outlined,
              title: "New Device Added",
              subtitle: "Alert when a new device is added to your account",
              value: _newDeviceAdded,
              onChanged: (val) => setState(() => _newDeviceAdded = val),
              isDark: isDark,
            ),
            _buildAlertToggle(
              icon: Icons.location_on_outlined,
              title: "Location Changes",
              subtitle: "Notify me when logging in from a new location",
              value: _locationChanges,
              onChanged: (val) => setState(() => _locationChanges = val),
              isDark: isDark,
            ),
            _buildAlertToggle(
              icon: Icons.security_outlined,
              title: "Security Changes",
              subtitle: "Alert for password or PIN changes",
              value: _securityChanges,
              onChanged: (val) => setState(() => _securityChanges = val),
              isDark: isDark,
            ),

            const SizedBox(height: 24),
            _buildSectionHeader("RECENT ACTIVITY", isDark),
            _buildActivityItem(
              icon: Icons.smartphone,
              title: "New Device Login",
              subtitle: "iPhone 14 Pro • Lagos, NG",
              time: "2 hours ago",
              isDark: isDark,
            ),
            _buildActivityItem(
              icon: Icons.laptop_mac,
              title: "Browser Login",
              subtitle: "Chrome on MacBook Pro",
              time: "Yesterday • Lagos, NG",
              isDark: isDark,
            ),
            _buildActivityItem(
              icon: Icons.location_on_outlined,
              title: "Location Change",
              subtitle: "Login from new location",
              time: "3 days ago",
              isDark: isDark,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ActivityLogScreen()),
                  );
                },
                child: Text(
                  "View Complete Activity Log",
                  style: GoogleFonts.poppins(
                    color: HexColor("#EA4359"),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppTheme.textSecondary(isDark),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAlertToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white24 : AppTheme.textHint(isDark),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
