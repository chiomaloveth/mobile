import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class AISupportScreen extends StatelessWidget {
  const AISupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: HexColor("#2A1810"),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: HexColor("#3A3A3A"),
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Grey",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Online",
                  style: GoogleFonts.poppins(
                    color: HexColor("#B0B0B0"),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(
                Icons.videocam_outlined,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.call, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [HexColor("#2A1810"), Colors.black],
          ),
        ),
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMessageBubble(
                    "Hi, I just wanna know that how much time you'll be updated.",
                    true,
                    "10:52",
                  ),
                  const SizedBox(height: 16),
                  _buildMessageBubble(
                    "Maybe, Nearly July, 2022",
                    false,
                    "10:53",
                  ),
                  const SizedBox(height: 16),
                  _buildMessageBubble("Okay, I'm Waiting....", true, "10:53"),
                ],
              ),
            ),

            // Input Field - ✅ FIXED WITH SAFEAREA
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: HexColor("#1A1A1A"),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: HexColor("#2A2A2A"), width: 1),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
                          decoration: InputDecoration(
                            hintText: "Send a message.",
                            hintStyle: GoogleFonts.poppins(
                              color: HexColor("#7A7A7A"),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18.0,
                            ),
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Icon(
                            Icons.arrow_forward,
                            color: HexColor("#7A7A7A"),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, String time) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? HexColor("#2A2A2A") : HexColor("#1A1A1A"),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HexColor("#3A3A3A"), width: 1),
            ),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: GoogleFonts.poppins(
              color: HexColor("#7A7A7A"),
              fontSize: 11.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
