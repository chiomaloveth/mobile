import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/broadcast/screens/create_broadcast_list_screen.dart';
import 'package:qik_talk/features/chat/group_chat/screens/create_new_group_screen.dart';
import 'package:qik_talk/features/community/screens/create_new_community_screen.dart';
import 'package:qik_talk/features/contact/screens/create_new_contact_screen.dart';
import 'package:qik_talk/features/chat/single_chat/screens/new_chat_screen.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class StartSomethingNewScreen extends StatefulWidget {
  const StartSomethingNewScreen({super.key});

  @override
  State<StartSomethingNewScreen> createState() =>
      _StartSomethingNewScreenState();
}

class _StartSomethingNewScreenState extends State<StartSomethingNewScreen> {
  int _selectedIndex = 0;

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
    final Color navBarBg = AppTheme.navBarBg(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
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
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Something New',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Choose what you want to create',
                  style: GoogleFonts.poppins(
                    color: HexColor("#B0B0B0"),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20.0),

            // Create New group
            _buildMenuItem(
              icon: Icons.group_outlined,
              title: 'Create New group',
              cardBg: cardBg,
              textPrimary: textPrimary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateNewGroupScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: 16.0),

            // Create New Broadcast List
            _buildMenuItem(
              icon: Icons.campaign_outlined,
              title: 'Create New Broadcast List',
              cardBg: cardBg,
              textPrimary: textPrimary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateBroadcastListScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: 16.0),

            // Create New community
            _buildMenuItem(
              icon: Icons.people_outline,
              title: 'Create New community',
              cardBg: cardBg,
              textPrimary: textPrimary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateCommunityScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: 16.0),

            // New Chat
            _buildMenuItem(
              icon: Icons.chat_bubble_outline,
              title: 'New Chat',
              cardBg: cardBg,
              textPrimary: textPrimary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewChatScreen()),
                );
              },
            ),

            SizedBox(height: 16.0),

            // Create New Contact
            _buildMenuItem(
              icon: Icons.person_add_outlined,
              title: 'Create New Contact',
              cardBg: cardBg,
              textPrimary: textPrimary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateNewContactScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBarBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10.0,
              offset: Offset(0, -2),
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
              icon: Image.asset(
                _selectedIndex == 0
                    ? 'images/chat_active.png'
                    : 'images/chat.png',
                width: 24.0,
                height: 24.0,
              ),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                _selectedIndex == 1
                    ? 'images/call_active.png'
                    : 'images/call.png',
                width: 24.0,
                height: 24.0,
              ),
              label: 'Calls',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                _selectedIndex == 2
                    ? 'images/status_active.png'
                    : 'images/status.png',
                width: 24.0,
                height: 24.0,
              ),
              label: 'Status',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                _selectedIndex == 3
                    ? 'images/feeds_active.png'
                    : 'images/feeds.png',
                width: 24.0,
                height: 24.0,
              ),
              label: 'Feeds',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                _selectedIndex == 4
                    ? 'images/wallet_active.png'
                    : 'images/wallet.png',
                width: 24.0,
                height: 24.0,
              ),
              label: 'Wallet',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color cardBg,
    required Color textPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: HexColor("#4CAF50"), size: 24.0),
            SizedBox(width: 16.0),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
