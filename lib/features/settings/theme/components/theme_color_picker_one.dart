import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeColorPickerOne extends StatelessWidget {
  final Color color;
  final String title;
  final String selected;
  final VoidCallback onClick;
  final bool isDark;

  const ThemeColorPickerOne({
    super.key,
    required this.color,
    required this.title,
    required this.selected,
    required this.onClick,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.1),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: MaterialButton(
        onPressed: onClick,
        child: Row(
          children: [
            Container(
              height: 35,
              width: 35,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 0.5, color: isDark ? Colors.white : Colors.grey),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white : null,
              ),
            ),
            Spacer(),
            Icon(
              Icons.check,
              color: title.trim().toLowerCase() == selected.trim().toLowerCase()
                  ? Colors.green
                  : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
