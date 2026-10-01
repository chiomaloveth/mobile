import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class EditGroupAdminsScreen extends StatefulWidget {
  const EditGroupAdminsScreen({super.key});

  @override
  State<EditGroupAdminsScreen> createState() => _EditGroupAdminsScreenState();
}

class _EditGroupAdminsScreenState extends State<EditGroupAdminsScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedAdmins = [];

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

  void _toggleSelection(String name) {
    setState(() {
      if (_selectedAdmins.contains(name)) {
        _selectedAdmins.remove(name);
      } else {
        _selectedAdmins.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = AppTheme.scaffoldBg(isDark);
    final Color cardBg = AppTheme.cardBg(isDark);
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textHint = AppTheme.textHint(isDark);
    final Color navBarBg = AppTheme.navBarBg(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Group Admins',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_selectedAdmins.length} Selected',
                  style: GoogleFonts.poppins(
                    color: HexColor("#B0B0B0"),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Done',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
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
                    style: GoogleFonts.poppins(color: textPrimary, fontSize: 14.0),
                    decoration: InputDecoration(
                      hintText: 'Search names or numbers',
                      hintStyle: GoogleFonts.poppins(color: textHint, fontSize: 14.0),
                      prefixIcon: Icon(Icons.search, color: textHint),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    ),
                  ),
                ),
              ),

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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            letter,
                            style: GoogleFonts.poppins(
                              color: textPrimary,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: contactList.length,
                          itemBuilder: (context, idx) {
                            final contact = contactList[idx];
                            final isSelected = _selectedAdmins.contains(contact['name']);

                            return GestureDetector(
                              onTap: () => _toggleSelection(contact['name']),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 30.0,
                                        backgroundImage: AssetImage(contact['image']),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 20.0,
                                          height: 20.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected ? HexColor("#4CAF50") : AppTheme.cardBgAlt(isDark),
                                            border: Border.all(color: Colors.white, width: 2.0),
                                          ),
                                          child: isSelected
                                              ? const Icon(Icons.check, color: Colors.white, size: 12.0)
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    contact['name'],
                                    style: GoogleFonts.poppins(color: textPrimary, fontSize: 12.0),
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
            top: 100,
            bottom: 100,
            child: SizedBox(
              width: 20.0,
              child: ListView.builder(
                itemCount: alphabet.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {},
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
