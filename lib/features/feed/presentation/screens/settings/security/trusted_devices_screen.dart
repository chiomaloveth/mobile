import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class TrustedDevicesScreen extends StatelessWidget {
  const TrustedDevicesScreen({super.key});

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
          "Trusted Devices",
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
                      "Manage devices that have access to your QikTalk account. Remove any device you don't recognize.",
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ACTIVE DEVICES (4)",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Remove All Others",
                      style: GoogleFonts.poppins(
                        color: HexColor("#EA4359"),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildDeviceItem(
              context,
              icon: Icons.smartphone,
              name: "iPhone 14 Pro",
              location: "Lagos, NG",
              status: "Current",
              isCurrent: true,
              isDark: isDark,
            ),
            _buildDeviceItem(
              context,
              icon: Icons.laptop_mac,
              name: "MacBook Pro 2023",
              location: "Lagos, NG",
              status: "Active now",
              isDark: isDark,
            ),
            _buildDeviceItem(
              context,
              icon: Icons.tablet_mac,
              name: "iPad Pro",
              location: "Lagos, NG",
              status: "3 days ago",
              isDark: isDark,
            ),
            _buildDeviceItem(
              context,
              icon: Icons.smartphone,
              name: "Samsung Galaxy S23",
              location: "Lagos, NG",
              status: "1 week ago",
              isDark: isDark,
            ),

            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "If you see a device you don't recognize, remove it immediately and change your security PIN.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white24,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String location,
    required String status,
    bool isCurrent = false,
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCurrent ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isCurrent ? Colors.green : Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Current",
                          style: GoogleFonts.poppins(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "$location • $status",
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              cardColor: const Color(0xFF2C2C2C),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz, color: Colors.white24),
              color: const Color(0xFF2C2C2C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              offset: const Offset(0, 40),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "remove",
                  child: Text(
                    "Remove Device",
                    style: GoogleFonts.poppins(
                      color: HexColor("#EA4359"),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              onSelected: (val) {
                if (val == "remove") {
                  // TODO: Implement device removal
                  debugPrint("Removing device: $name");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
