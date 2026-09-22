import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = 0xFF242424;
  static const primaryBackgroundColor = 0xFF141414;
  static const gradientColorsOne = 0xFF3A1D07;
  static const gradientColorsTwo = 0xFF171516;

  // ── Light Mode Palette ─────────────────────────────────────────────────────
  // Using the same light background color as CustomBottomNav for consistency
  static const Color lightBackground = Color(0xFFFAF5F0);      // same as CustomBottomNav
  static const Color lightSurface = Color(0xFFF2EDE8);         // warm cream card
  static const Color lightSurfaceAlt = Color(0xFFF5EEE4);      // slightly deeper card
  static const Color lightAppBar = Color(0xFF3A1D07);          // same dark brown as dark mode
  static const Color lightDivider = Color(0xFFD9CFC4);         // warm grey divider
  static const Color lightTextPrimary = Color(0xFF1A1008);     // near-black warm
  static const Color lightTextSecondary = Color(0xFF4A4A4A);   // darker grey for better visibility
  static const Color lightTextHint = Color(0xFF6B6B6B);        // darker hint text for visibility
  static const Color lightInputBg = Color(0xFFF5EEE4);         // warm input fill
  static const Color lightCardBg = Color(0xFFF5EEE4);          // warm card
  static const Color lightIconBg = Color(0xFFDDD3C5);          // icon container
  static const Color lightBorder = Color(0xFFCFC4B5);          // subtle border
  static const Color lightNavBar = Color(0xFFFAF5F0);          // bottom nav warm

  // ── Light Mode Accent (orange — same as Wallet FAB) ────────────────────────
  static const Color lightAccent = Color(0xFFFF8C00);          // primary orange accent
  static const Color lightAccentSoft = Color(0xFFFFF0DC);      // soft orange tint bg
  static const Color lightSenderBubble = Color(0xFFFF8C00);    // sender chat bubble
  static const Color lightReceiverBubble = Color(0xFFE8DDD0);  // receiver chat bubble
  static const Color lightInputBorder = Color(0xFFCFC4B5);     // input border
  static const Color lightIconColor = Color(0xFF2A2A2A);       // darker icon color for better visibility
  static const Color lightDividerStrong = Color(0xFFBFB0A0);   // stronger divider
  
  // ── Green Colors (for success, active states) ──────────────────────────────
  // Dark mode uses #1A7F4B, light mode uses a darker, more visible green
  static const Color darkGreen = Color(0xFF1A7F4B);            // dark mode green
  static const Color lightGreen = Color(0xFF0D6B3A);           // light mode green (darker for visibility)










  static const Color background = Color(0xFF0A0808);
  static const Color surface = Color(0xFF1E1A17);
  static const Color surfaceLight = Color(0xFF2A2522);
  static const Color primary = Color(0xFF6A3110);
  static const Color textMain = Colors.white;
  static const Color textSub = Color(0xFF9E9E9E);
  static const Color successBg = Color(0xFF102817);
  static const Color successBorder = Color(0xFF1E502B);
  static const Color successText = Color(0xFF4ADE80);
  static const Color progressActive = Color(0xFFFF5500);
  static const Color progressTrack = Color(0xFF2A2A2A);
  static const Color errorDot = Color(0xFFEF4444);



  static const Color cardDark = Color(0xFF1A1A1C);
  static const Color textGrey = Color(0xFFA3A3A3);
  static const Color textLight = Color(0xFFE5E5E5);
  static const Color greenAmount = Color(0xFF00D26A);
  static const Color redText = Color(0xFFD64A4A);
  static const Color iconBg = Color(0xFF262626);
  static const Color borderFaint = Color(0xFF2A2A2A);





  static const Color cardOrangeTop = Color(0xFFF38435);
  static const Color cardOrangeBottom = Color(0xFFBD4633);
  static const Color cardDarkBottom = Color(0xFF151515);
  static const Color appBarButtonBg = Color(0xFF1E1E1E);
  static const Color textFaint = Color(0xB3FFFFFF);



  static const Color inputBg = Color(0xFF151515);
  static const Color buttonDarkBg = Color(0xFF1E1E1E);
  static const Color borderPink = Color(0xFF8E105C);
  static const Color btnGradStart = Color(0xFFFF007A);
  static const Color btnGradEnd = Color(0xFF00D2FF);
  static const Color orangeText = Color(0xFFFF9800);
  static const Color chipBg = Color(0xFF141414);


  // static const Color background = Color(0xFF0F0906); // Deep dark brown/black
  // static const Color cardDark = Color(0xFF1E1611);
  static const Color cardLighter = Color(0xFF2A1F18);
  static const Color primaryOrange = Color(0xFFC65800); // Active states
  static const Color buttonBrown = Color(0xFF4A2511);
  static const Color textWhite = Colors.white;
  // static const Color textGrey = Color(0xFFA39A96);
  static const Color successGreen = Color(0xFF00C853);
  static const Color errorRed = Color(0xFFD50000);
  static const Color pendingOrange = Color(0xFFF57C00);





  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA0A0A0);

  // Total Savings Card Colors
  static const Color totalCardBg = Color(0xFF33261C);
  static const Color totalCardBorder = Color(0xFF4A3A2A);
  static const Color iconBgOrange = Color(0xFF8B5A2B);
  static const Color subCardBg = Color(0xFF423326);
  static const Color greenText = Color(0xFF00FF7F);

  // Plan Cards Colors
  static const Color planCardBg = Color(0xFF1C1C1E);
  static const Color planCardBorder = Color(0xFF2C2C2E);
  static const Color progressBarTrack = Color(0xFF38383A);


  static const Color cardBg = Color(0xFF161618);
  static const Color cardBorder = Color(0xFF2C2C2E);
  static const Color textHint = Color(0xFF666666);
  static const Color accentOrange = Color(0xFFD27C38);

  // Active/Selected States
  static const Color activeCardBg = Color(0xFF2A1C12);
  static const Color activeCardBorder = Color(0xFF4A3424);

  // Calendar Colors
  static const Color calBg = Colors.white;
  static const Color calTextPrimary = Colors.black;
  static const Color calTextSecondary = Color(0xFF999999);
  static const Color calRangeBg = Color(0xFFF4F4F5);
  static const Color calSelectedCircle = Color(0xFF333333);


  // The vibrant green used for the main icon and button
  static const Color primaryGreen = Color(0xFF17C665);

  // Specific tints for the Amount Card
  static const Color amountCardBg = Color(0xFF121D14);
  static const Color amountCardBorder = Color(0xFF1E3D25);

  // Specific tints for the Motivational Card & Bottom Button
  static const Color secondaryCardBg = Color(0xFF231C18);
  static const Color secondaryCardBorder = Color(0xFF3B3028);


  // Active/Selected States (matching the second image)
  static const Color activeBorderOrange = Color(0xFFE06C00);
  static const Color filledInputBg = Color(0xFF1E1511);

  // Button States
  static const Color buttonInactiveBg = Color(0xFF1E1E1E);
  static const Color buttonActiveBg = Color(0xFF4A2511);
  static const Color buttonActiveText = Colors.white;

  // Navy Blue Card Theme
  static const Color navyCardBg = Color(0xFF0F172A);
  static const Color navyCardBorder = Color(0xFF1E293B);
  static const Color lightBlueText = Color(0xFF7DD3FC);
  static const Color darkGreyCard = Color(0xFF1C1C1E);
  static const Color darkGreyBorder = Color(0xFF2C2C2E);



  // Specific UI Elements
  static const Color warningBg = Color(0xFF2A1C0D);
  static const Color warningBorder = Color(0xFF6B420C);
  static const Color warningText = Color(0xFFEAB308);
  static const Color infoGreenBg = Color(0xFF062111);
  static const Color infoGreenBorder = Color(0xFF0D4A22);
  static const Color textRed = Color(0xFFEF4444);

  static const Color calTextLight = Color(0xFFC4C4C4);

  static const Color textSubtitle = Color(0xFFB58057);
  static const Color iconBgBlue = Color(0xFF14274E);
  static const Color iconBlue = Color(0xFF5B98D9);
  static const Color summaryValueText = Color(0xFFF3AB6B);
  static const Color buttonInactiveText = Color(0xFF4A4A4A);



  static const Color progressFillBlue = Color(0xFF2E8CFF);
  static const Color progressFillCyan = Color(0xFF00E5FF);
  static const Color buttonOrange = Color(0xFF5A2A0A);
  static const Color buttonGlow = Color(0xFFD96611);

  static const Color subtitleBrown = Color(0xFF8A6A4B);
  static const Color cardBottomBg = Color(0xFF0A0A0A);
  static const Color amountLargeText = Color(0xFF7A3E14);
  static const Color buttonCancelBg = Color(0xFF141414);


  static const Color bgColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color primaryRed = Color(0xFFE51D53);
  static const Color textGray = Color(0xFFA0A0A0);
}