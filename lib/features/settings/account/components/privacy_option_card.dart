import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyOptionCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onClick;
  final bool isDark;
  const PrivacyOptionCard({super.key, required this.title, required this.value, required this.onClick, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.symmetric(horizontal: BorderSide(width: 0.5, color: Colors.black.withOpacity(0.5)))
      ),
      child: MaterialButton(
        onPressed: onClick,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white.withOpacity(0.7) : null
                  ),
                ),
                value.trim().isEmpty ? const SizedBox.shrink() : Text(
                  value,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey
                  ),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey, size: 20,)
          ],
        ),
      ),
    );
  }
}
