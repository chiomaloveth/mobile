import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'ai_intro_screen.dart';

class AIWelcomeHomeScreen extends StatelessWidget {
  const AIWelcomeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#201E1F"), // ✅ UPDATED COLOR
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: HexColor("#1E1E1E"),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // QikTalk Logo
              Image.asset(
                "images/splash_screen_logo.png",
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 40),

              // Welcome Text
              Text(
                "Welcome to\nQik AI",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 36.0,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 20),

              // Subtitle
              Text(
                "Start chatting with QikAI now.\nYou can ask me anything.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: HexColor("#B0B0B0"),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),

              const Spacer(),

              // Get Started Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AIIntroScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [HexColor("#FF6B9D"), HexColor("#C74375")],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: HexColor("#FF6B9D").withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Get Started",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // Bottom Navigation Bar
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: HexColor("#1A1A1A"),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.chat_bubble_outline, "Chats", true),
                    _buildNavItem(Icons.call_outlined, "Calls", false),
                    _buildNavItem(Icons.circle_outlined, "Status", false),
                    _buildNavItem(Icons.rss_feed, "Feeds", false),
                    _buildNavItem(
                      Icons.account_balance_wallet_outlined,
                      "Wallet",
                      false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.white : HexColor("#606060"),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isActive ? Colors.white : HexColor("#606060"),
            fontSize: 11.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
