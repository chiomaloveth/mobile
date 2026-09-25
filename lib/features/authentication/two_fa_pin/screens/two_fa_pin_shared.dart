import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

// ── Gradient AppBar (brown gradient matching Figma) ───────────────────────────

AppBar buildTwoFaGradientAppBar(
  BuildContext context, {
  required String title,
  bool showBack = true,
}) {
  return AppBar(
    toolbarHeight: 56.0,
    automaticallyImplyLeading: false,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HexColor("#3A1D07"), HexColor("#1A0E03")],
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
    title: Row(
      children: [
        if (showBack)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.arrow_back, size: 22.0, color: Colors.white),
            ),
          ),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ── Lock icon circle ──────────────────────────────────────────────────────────

Widget buildTwoFaIconCircle({
  required Color color,
  required IconData icon,
  required Color iconColor,
  double size = 80.0,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: iconColor, size: size * 0.42),
  );
}

// ── Shared action button ──────────────────────────────────────────────────────

class TwoFaActionButton extends StatelessWidget {
  final String label;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onTap;

  const TwoFaActionButton({
    super.key,
    required this.label,
    required this.isEnabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled && !isLoading ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 56.0,
        decoration: BoxDecoration(
          color: isEnabled ? HexColor("#5C2E00") : HexColor("#2A1A00"),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: isEnabled ? Colors.white : HexColor("#666666"),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Shared PIN text field ─────────────────────────────────────────────────────

class TwoFaPinTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final double letterSpacing;

  const TwoFaPinTextField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Enter 6-digit PIN',
    this.letterSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor("#1E1E1E"),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: HexColor("#2E2E2E"), width: 1.0),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 22.0,
          fontWeight: FontWeight.w600,
          letterSpacing: letterSpacing,
        ),
        cursorColor: HexColor("#C8960C"),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: HexColor("#555555"),
            fontSize: hintText.length > 10 ? 16.0 : 22.0,
            fontWeight: FontWeight.normal,
            letterSpacing: hintText.length > 10 ? 0 : letterSpacing,
          ),
          filled: true,
          fillColor: HexColor("#1E1E1E"),
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18.0,
            horizontal: 20.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide(color: HexColor("#3A2A00"), width: 1.5),
          ),
        ),
      ),
    );
  }
}
