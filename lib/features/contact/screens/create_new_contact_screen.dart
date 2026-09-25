import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:country_picker/country_picker.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class CreateNewContactScreen extends StatefulWidget {
  const CreateNewContactScreen({super.key});

  @override
  State<CreateNewContactScreen> createState() => _CreateNewContactScreenState();
}

class _CreateNewContactScreenState extends State<CreateNewContactScreen> {
  int _selectedIndex = 0;
  bool _syncToPhone = false;
  String _selectedCountryCode = '+234';
  String _selectedCountryFlag = '🇳🇬';

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedCountryCode = '+${country.phoneCode}';
          _selectedCountryFlag = country.flagEmoji;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = AppTheme.scaffoldBg(isDark);
    final Color cardBg = AppTheme.cardBg(isDark);
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textHint = AppTheme.textHint(isDark);
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
              'Create New Contact',
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

              // First name field
              Text('First name', style: GoogleFonts.poppins(color: textPrimary, fontSize: 14.0, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12.0)),
                child: TextField(
                  controller: _firstNameController,
                  style: GoogleFonts.poppins(color: textPrimary, fontSize: 14.0),
                  decoration: InputDecoration(
                    hintText: 'Enter first name',
                    hintStyle: GoogleFonts.poppins(color: textHint, fontSize: 14.0),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // Last name field
              Text('Last name', style: GoogleFonts.poppins(color: textPrimary, fontSize: 14.0, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12.0)),
                child: TextField(
                  controller: _lastNameController,
                  style: GoogleFonts.poppins(color: textPrimary, fontSize: 14.0),
                  decoration: InputDecoration(
                    hintText: 'Enter last name',
                    hintStyle: GoogleFonts.poppins(color: textHint, fontSize: 14.0),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // Phone number field
              Text('Phone number', style: GoogleFonts.poppins(color: textPrimary, fontSize: 14.0, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12.0)),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickCountry,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                        child: Row(
                          children: [
                            Text(_selectedCountryFlag, style: const TextStyle(fontSize: 20.0)),
                            const SizedBox(width: 4.0),
                            Icon(Icons.arrow_drop_down, color: textPrimary),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1.0, height: 30.0, color: dividerColor),
                    const SizedBox(width: 8.0),
                    Text(_selectedCountryCode, style: GoogleFonts.poppins(color: textPrimary, fontSize: 14.0)),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.poppins(color: textPrimary, fontSize: 14.0),
                        decoration: InputDecoration(
                          hintText: 'Phone number',
                          hintStyle: GoogleFonts.poppins(color: textHint, fontSize: 14.0),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20.0),

              // Sync contact to phone
              Container(
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12.0)),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sync contact to phone', style: GoogleFonts.poppins(color: textPrimary, fontSize: 14.0, fontWeight: FontWeight.w500)),
                    Switch(
                      value: _syncToPhone,
                      onChanged: (value) => setState(() => _syncToPhone = value),
                      activeColor: HexColor("#4CAF50"),
                      inactiveThumbColor: isDark ? HexColor("#757575") : Colors.grey.shade400,
                      inactiveTrackColor: isDark ? HexColor("#3A3A3A") : Colors.grey.shade200,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20.0),

              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.qr_code_scanner, color: HexColor("#4CAF50"), size: 20.0),
                  label: Text('Add via QR code', style: GoogleFonts.poppins(color: HexColor("#4CAF50"), fontSize: 14.0, fontWeight: FontWeight.w500)),
                ),
              ),

              const SizedBox(height: 40.0),

              // Done button
              SizedBox(
                width: double.infinity,
                height: 55.0,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor("#1A7F4B"),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text('Done', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600)),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10.0, offset: const Offset(0, -2))],
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
            BottomNavigationBarItem(icon: Image.asset(_selectedIndex == 0 ? 'images/chat_active.png' : 'images/chat.png', width: 24.0, height: 24.0), label: 'Chats'),
            BottomNavigationBarItem(icon: Image.asset(_selectedIndex == 1 ? 'images/call_active.png' : 'images/call.png', width: 24.0, height: 24.0), label: 'Calls'),
            BottomNavigationBarItem(icon: Image.asset(_selectedIndex == 2 ? 'images/status_active.png' : 'images/status.png', width: 24.0, height: 24.0), label: 'Status'),
            BottomNavigationBarItem(icon: Image.asset(_selectedIndex == 3 ? 'images/feeds_active.png' : 'images/feeds.png', width: 24.0, height: 24.0), label: 'Feeds'),
            BottomNavigationBarItem(icon: Image.asset(_selectedIndex == 4 ? 'images/wallet_active.png' : 'images/wallet.png', width: 24.0, height: 24.0), label: 'Wallet'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
