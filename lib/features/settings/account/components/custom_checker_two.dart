import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCheckerTwo extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onClick;
  final bool isDark;
  const CustomCheckerTwo({super.key, required this.title, required this.value, required this.onClick, required this.isDark});

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
            Container(
              height: 21,
              width: 21,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 1.1, color: Colors.green),
                shape: BoxShape.circle
              ),
              child: value.toLowerCase().trim() == title.toLowerCase().trim() ? Center(
                child: Container(
                  height: 17,
                  width: 17,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle
                  ),
                ),
              ) : const SizedBox.shrink(),
            ),
            const SizedBox(width: 10,),
            Text(
              title,
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white.withOpacity(0.7) : null
              ),
            ),
          ],
        ),
      ),
    );
  }
}
