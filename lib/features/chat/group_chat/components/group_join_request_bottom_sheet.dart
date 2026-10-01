import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class GroupJoinRequestBottomSheet extends StatelessWidget {
  final String groupName;
  final String groupImage;
  final int memberCount;

  const GroupJoinRequestBottomSheet({
    super.key,
    required this.groupName,
    required this.groupImage,
    required this.memberCount,
  });

  static void show(
    BuildContext context, {
    required String groupName,
    required String groupImage,
    required int memberCount,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GroupJoinRequestBottomSheet(
        groupName: groupName,
        groupImage: groupImage,
        memberCount: memberCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: BoxDecoration(
        color: HexColor("#201E1F"),
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

          SizedBox(height: 8.0),

          // Group icon
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: HexColor("#5A5A5A"),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.group, color: Colors.white, size: 40.0),
          ),

          SizedBox(height: 16.0),

          // Group name with emoji
          Text(
            groupName,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.0),

          // Member avatars
          SizedBox(
            height: 40.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HexColor("#201E1F"),
                        width: 2.0,
                      ),
                      image: DecorationImage(
                        image: AssetImage('images/guy1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  child: Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HexColor("#201E1F"),
                        width: 2.0,
                      ),
                      image: DecorationImage(
                        image: AssetImage('images/lady1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 10,
                  child: Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HexColor("#201E1F"),
                        width: 2.0,
                      ),
                      image: DecorationImage(
                        image: AssetImage('images/guy2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 + 10,
                  child: Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: HexColor("#3A3A3A"),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HexColor("#201E1F"),
                        width: 2.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '+$memberCount',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.0),

          // Admin approval message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'An admin must approve your request',
              style: GoogleFonts.poppins(
                color: HexColor("#A0A0A0"),
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 16.0),

          // Request to join button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: GestureDetector(
              onTap: () {
                // Handle request to join
                Navigator.pop(context);
                _showRequestSent(context);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [HexColor("#D32F2F"), HexColor("#B71C1C")],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: HexColor("#E57373").withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  'Request to join',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          SizedBox(height: 60.0),
        ],
      ),
    );
  }

  void _showRequestSent(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Join request sent! Waiting for admin approval.',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.0),
        ),
        backgroundColor: HexColor("#1A7F4B"),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}
