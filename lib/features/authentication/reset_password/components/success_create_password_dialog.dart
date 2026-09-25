import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qik_talk/features/broadcast/screens/create_broadcast_list_screen.dart';
import 'package:qik_talk/features/chat/group_chat/screens/create_new_group_screen.dart';
import 'package:qik_talk/features/community/screens/create_new_community_screen.dart';
import 'package:qik_talk/features/contact/screens/contact_screen.dart';

class SuccessCreatePasswordDialog extends StatefulWidget {
  @override
  State<SuccessCreatePasswordDialog> createState() =>
      _SuccessCreatePasswordDialogState();
}

class _SuccessCreatePasswordDialogState
    extends State<SuccessCreatePasswordDialog> {
  // ── Navigate helper — closes dialog first ─────────────────────────────────
  void _navigateToScreen(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ── Contact onboarding flow ────────────────────────────────────────────────
  static const String _contactOnboardingKey = 'contact_onboarding_shown';

  Future<void> _openNewChat() async {
    // Close the dialog first
    Navigator.pop(context);

    // Mark onboarding as shown
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_contactOnboardingKey, true);

    if (!mounted) return;

    // Show loading while fetching contacts
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              CircularProgressIndicator(
                color: Color(0xFF1A7F4B),
                strokeWidth: 2.5,
              ),
              SizedBox(width: 18),
              Text(
                'Loading contacts...',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final granted = await FlutterContacts.requestPermission();
      if (!mounted) return;
      Navigator.pop(context); // close loading dialog

      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact permission denied'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final contacts = await FlutterContacts.getContacts(withProperties: true);
      final filtered = contacts.where((c) => c.displayName.isNotEmpty).toList();

      if (!mounted) return;

      if (filtered.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No contacts found on this device'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Contact_screen(contacts: filtered)),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loading if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contacts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 25.0),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [HexColor("#FF00A8"), HexColor("#00D1FF")],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: HexColor("#FF00A8").withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(-10, -10),
              ),
              BoxShadow(
                color: HexColor("#FB8830").withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(10, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(1.0),
          child: Container(
            padding: const EdgeInsets.only(bottom: 30.0),
            decoration: BoxDecoration(
              color: HexColor("#101010"),
              borderRadius: BorderRadius.circular(19.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Close button ───────────────────────────────────────────
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, right: 10.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // ── Title ──────────────────────────────────────────────────
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Start Something New?",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // ── Subtitle ───────────────────────────────────────────────
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 4.0,
                      left: 20.0,
                      right: 20.0,
                    ),
                    child: Text(
                      "Choose what you want to create",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: HexColor("#F5F6F7"),
                        fontSize: 13.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),

                // ── Create New Group ───────────────────────────────────────
                _buildItem(
                  imagePath: "images/create_group.png",
                  label: "Create New Group",
                  onTap: () => _navigateToScreen(CreateNewGroupScreen()),
                ),

                // ── Create New Broadcast List ──────────────────────────────
                _buildItem(
                  imagePath: "images/create_broadcast.png",
                  label: "Create New Broadcast List",
                  onTap: () => _navigateToScreen(CreateBroadcastListScreen()),
                ),

                // ── Create New Community ───────────────────────────────────
                _buildItem(
                  imagePath: "images/create_community.png",
                  label: "Create New Community",
                  onTap: () => _navigateToScreen(CreateCommunityScreen()),
                ),

                // ── New Chat — opens contact discovery ─────────────────────
                _buildItem(
                  imagePath: "images/create_chat.png",
                  label: "New Chat",
                  onTap: _openNewChat,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Reusable list item ─────────────────────────────────────────────────────
  Widget _buildItem({
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 30.0),
            child: Image(
              image: AssetImage(imagePath),
              width: 28.0,
              height: 28.0,
              color: HexColor("#00D180"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 10.0),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: HexColor("#F5F6F7"),
                fontSize: 13.5,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
