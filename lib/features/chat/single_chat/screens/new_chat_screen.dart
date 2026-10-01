import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Dummy data for recent chats
  final List<Map<String, dynamic>> recentChats = [
    {'name': 'Blessing', 'image': 'images/lady1.png'},
    {'name': 'Daniel', 'image': 'images/guy_image.png'},
    {'name': 'Michael', 'image': 'images/guy1.png'},
    {'name': 'Jumoke', 'image': 'images/lady2.png'},
    {'name': 'Christopher', 'image': 'images/guy2.png'},
  ];

  // Dummy data for contacts grouped alphabetically
  final Map<String, List<Map<String, dynamic>>> contacts = {
    'A': [
      {'name': 'Abayomi', 'image': 'images/guy_image.png'},
      {'name': 'Abigail', 'image': 'images/lady1.png'},
      {'name': 'Ade', 'image': 'images/guy1.png'},
      {'name': 'Adedayo', 'image': 'images/lady2.png'},
      {'name': 'Adedeti', 'image': 'images/guy2.png'},
      {'name': 'Adejare', 'image': 'images/lady1.png'},
      {'name': 'Ajayi', 'image': 'images/guy3.png'},
      {'name': 'Anthonia', 'image': 'images/lady2.png'},
      {'name': 'Anothony', 'image': 'images/guy_image.png'},
      {'name': 'Anthony 2', 'image': 'images/lady1.png'},
      {'name': 'Asta', 'image': 'images/guy1.png'},
      {'name': 'Awa', 'image': 'images/lady2.png'},
    ],
    'B': [
      {'name': 'Anothony', 'image': 'images/guy_image.png'},
      {'name': 'Anthony 2', 'image': 'images/lady1.png'},
      {'name': 'Asta', 'image': 'images/guy1.png'},
      {'name': 'Awa', 'image': 'images/lady2.png'},
    ],
  };

  // Alphabet letters for side index
  final List<String> alphabet = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
    final Color scaffoldBg = AppTheme.scaffoldBg(isDark);
    final Color cardBg = AppTheme.cardBg(isDark);
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);
    final Color textHint = AppTheme.textHint(isDark);
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
              colors: isDark 
                ? [HexColor("#3A1D07"), HexColor("#171516")]
                : [const Color(0xFFF5EEE4), const Color(0xFFFAF5F0)],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back, 
                color: isDark ? Colors.white.withOpacity(0.85) : textPrimary
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Chat',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white.withOpacity(0.85) : textPrimary,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '0/580',
                  style: GoogleFonts.poppins(
                    color: isDark ? HexColor("#B0B0B0") : textSecondary,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.poppins(
                      color: textPrimary,
                      fontSize: 14.0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search names or numbers',
                      hintStyle: GoogleFonts.poppins(
                        color: textHint,
                        fontSize: 14.0,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: textHint,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                ),
              ),

              // Recent Chats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Chats',
                    style: GoogleFonts.poppins(
                      color: textSecondary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.0),
              SizedBox(
                height: 100.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: recentChats.length,
                  itemBuilder: (context, index) {
                    final chat = recentChats[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30.0,
                            backgroundImage: AssetImage(chat['image']),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            chat['name'],
                            style: GoogleFonts.poppins(
                              color: textPrimary,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.0),

              // Contacts list
              Expanded(
                child: ListView.builder(
                  itemCount: contacts.keys.length,
                  itemBuilder: (context, index) {
                    String letter = contacts.keys.elementAt(index);
                    List<Map<String, dynamic>> contactList = contacts[letter]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Letter header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            letter,
                            style: GoogleFonts.poppins(
                              color: textPrimary,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Contacts grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 16.0,
                                crossAxisSpacing: 16.0,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: contactList.length,
                          itemBuilder: (context, idx) {
                            final contact = contactList[idx];

                            return GestureDetector(
                              onTap: () {
                                // Navigate to chat
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 30.0,
                                    backgroundImage: AssetImage(
                                      contact['image'],
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    contact['name'],
                                    style: GoogleFonts.poppins(
                                      color: textPrimary,
                                      fontSize: 12.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          // Alphabet side index
          Positioned(
            right: 0,
            top: 200,
            bottom: 100,
            child: Container(
              width: 20.0,
              child: ListView.builder(
                itemCount: alphabet.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Scroll to section
                    },
                    child: Center(
                      child: Text(
                        alphabet[index],
                        style: GoogleFonts.poppins(
                          color: HexColor("#4CAF50"),
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
