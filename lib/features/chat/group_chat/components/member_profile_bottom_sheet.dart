import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class MemberProfileBottomSheet extends StatelessWidget {
  final String name;
  final String phone;
  final String avatar;
  final String? role;

  const MemberProfileBottomSheet({
    super.key,
    required this.name,
    required this.phone,
    required this.avatar,
    this.role,
  });

  static void show(
    BuildContext context, {
    required String name,
    required String phone,
    required String avatar,
    String? role,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MemberProfileBottomSheet(
        name: name,
        phone: phone,
        avatar: avatar,
        role: role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor("#2A2A2A"),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: HexColor("#3A3A3A"),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 20.0),
                ),
              ),
            ),
          ),

          // Profile section
          Column(
            children: [
              // Avatar
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: HexColor("#1A7F4B"), width: 3.0),
                  image: DecorationImage(
                    image: AssetImage(avatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 12.0),

              // Name
              Text(
                name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 4.0),

              // Phone number
              Text(
                phone,
                style: GoogleFonts.poppins(
                  color: HexColor("#A0A0A0"),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(height: 20.0),

              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Message button
                  GestureDetector(
                    onTap: () {
                      // Handle message action
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: HexColor("#3A3A3A"),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.message_outlined,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                  ),

                  SizedBox(width: 20.0),

                  // Call button
                  GestureDetector(
                    onTap: () {
                      // Handle call action
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: HexColor("#3A3A3A"),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.call, color: Colors.white, size: 24.0),
                    ),
                  ),

                  SizedBox(width: 20.0),

                  // Video call button
                  GestureDetector(
                    onTap: () {
                      // Handle video call action
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: HexColor("#3A3A3A"),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.0),
            ],
          ),

          // Divider
          Container(
            height: 1.0,
            color: HexColor("#3A3A3A"),
            margin: EdgeInsets.symmetric(horizontal: 24.0),
          ),

          SizedBox(height: 8.0),

          // Info button
          GestureDetector(
            onTap: () {
              // Handle info action
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  Text(
                    'Info',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.info_outline, color: Colors.white, size: 20.0),
                ],
              ),
            ),
          ),

          // Make group moderator button
          GestureDetector(
            onTap: () {
              // Handle make moderator action
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  Text(
                    'Make group moderator',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.person_add_outlined,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ],
              ),
            ),
          ),

          // Remove from group button
          GestureDetector(
            onTap: () {
              // Handle remove from group action
              _showRemoveConfirmation(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: BoxDecoration(color: HexColor("#2A2A2A")),
              child: Row(
                children: [
                  Text(
                    'Remove from group',
                    style: GoogleFonts.poppins(
                      color: HexColor("#FF4444"),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 28.0,
                    height: 28.0,
                    decoration: BoxDecoration(
                      color: HexColor("#FF4444").withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.do_not_disturb_on_outlined,
                      color: HexColor("#FF4444"),
                      size: 18.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 44.0),
        ],
      ),
    );
  }

  void _showRemoveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HexColor("#2A2A2A"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Remove Member',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to remove $name from this group?',
          style: GoogleFonts.poppins(
            color: HexColor("#A0A0A0"),
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // Handle remove logic
            },
            child: Text(
              'Remove',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
