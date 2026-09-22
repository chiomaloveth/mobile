import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class MuteChatDialog extends StatelessWidget {
  final String chatTitle;
  final Function(DateTime? muteUntil) onMute;

  const MuteChatDialog({
    Key? key,
    required this.chatTitle,
    required this.onMute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HexColor("#2E2E2E"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Mute notifications',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mute notifications from $chatTitle',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 24),
          _buildMuteOption(
            context,
            icon: Icons.access_time,
            title: '8 hours',
            onTap: () {
              final muteUntil = DateTime.now().add(Duration(hours: 8));
              Navigator.pop(context);
              onMute(muteUntil);
            },
          ),
          SizedBox(height: 12),
          _buildMuteOption(
            context,
            icon: Icons.calendar_today,
            title: '1 week',
            onTap: () {
              final muteUntil = DateTime.now().add(Duration(days: 7));
              Navigator.pop(context);
              onMute(muteUntil);
            },
          ),
          SizedBox(height: 12),
          _buildMuteOption(
            context,
            icon: Icons.volume_off,
            title: 'Always',
            subtitle: 'Until you turn it back on',
            onTap: () {
              Navigator.pop(context);
              onMute(null); // null = muted forever
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildMuteOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HexColor("#3A3A3A"),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: HexColor("#FF6B00").withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: HexColor("#FF6B00"), size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
