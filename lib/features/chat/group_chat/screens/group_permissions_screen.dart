import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class GroupPermissionsScreen extends StatefulWidget {
  const GroupPermissionsScreen({super.key});

  @override
  State<GroupPermissionsScreen> createState() => _GroupPermissionsScreenState();
}

class _GroupPermissionsScreenState extends State<GroupPermissionsScreen> {
  int _selectedIndex = 0;

  bool _approveNewMembers = false;
  bool _editGroupDetails = false;
  bool _allowMembersToSendMessages = true;
  bool _inviteViaQR = true;
  bool _pinMessages = false;
  bool _addOtherMembers = true;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = AppTheme.scaffoldBg(isDark);
    final Color cardBg = AppTheme.cardBg(isDark);
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);
    final Color dividerColor = AppTheme.dividerSubtle(isDark);
    final Color navBarBg = AppTheme.navBarBg(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HexColor("#3A1D07"), HexColor("#171516")],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Group Permissions',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),

              Text(
                'Admin Controls',
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12.0),

              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    _buildPermissionItem(
                      title: 'Approve New Members',
                      value: _approveNewMembers,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onChanged: (val) => setState(() => _approveNewMembers = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30.0),

              Text(
                'Members Access',
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12.0),

              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    _buildPermissionItem(
                      title: 'Edit Group Details',
                      value: _editGroupDetails,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onChanged: (val) => setState(() => _editGroupDetails = val),
                    ),
                    Divider(color: dividerColor, height: 1.0, thickness: 1.0),
                    _buildPermissionItem(
                      title: 'Allow Members to Send Messages',
                      value: _allowMembersToSendMessages,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onChanged: (val) => setState(() => _allowMembersToSendMessages = val),
                    ),
                    Divider(color: dividerColor, height: 1.0, thickness: 1.0),
                    _buildPermissionItem(
                      title: 'Invite via QR Code or Group Link',
                      value: _inviteViaQR,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onChanged: (val) => setState(() => _inviteViaQR = val),
                    ),
                    Divider(color: dividerColor, height: 1.0, thickness: 1.0),
                    _buildPermissionItem(
                      title: 'Pin Messages',
                      value: _pinMessages,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onChanged: (val) => setState(() => _pinMessages = val),
                    ),
                    Divider(color: dividerColor, height: 1.0, thickness: 1.0),
                    _buildPermissionItem(
                      title: 'Add other components',
                      value: _addOtherMembers,
                      textPrimary: textPrimary,
                      isDark: isDark,
                      onChanged: (val) => setState(() => _addOtherMembers = val),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20.0),

              GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Group Admins',
                        style: GoogleFonts.poppins(
                          color: textPrimary,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBarBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10.0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: navBarBg,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: isDark ? Colors.white : Colors.black87,
          unselectedItemColor: HexColor("#808080"),
          selectedFontSize: 12.0,
          unselectedFontSize: 12.0,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(_selectedIndex == 0 ? 'images/chat_active.png' : 'images/chat.png', width: 24.0, height: 24.0),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(_selectedIndex == 1 ? 'images/call_active.png' : 'images/call.png', width: 24.0, height: 24.0),
              label: 'Calls',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(_selectedIndex == 2 ? 'images/status_active.png' : 'images/status.png', width: 24.0, height: 24.0),
              label: 'Status',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(_selectedIndex == 3 ? 'images/feeds_active.png' : 'images/feeds.png', width: 24.0, height: 24.0),
              label: 'Feeds',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(_selectedIndex == 4 ? 'images/wallet_active.png' : 'images/wallet.png', width: 24.0, height: 24.0),
              label: 'Wallet',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required Color textPrimary,
    required bool isDark,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: HexColor("#4CAF50"),
            inactiveThumbColor: isDark ? HexColor("#757575") : Colors.grey.shade400,
            inactiveTrackColor: isDark ? HexColor("#3A3A3A") : Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}
