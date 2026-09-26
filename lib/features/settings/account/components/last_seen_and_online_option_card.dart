import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LastSeenAndOnlineOptionCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onClick;
  final bool isDark;

  const LastSeenAndOnlineOptionCard({
    super.key,
    required this.title,
    required this.value,
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
        color: Colors.transparent,
        border: Border.symmetric(
          horizontal: BorderSide(
            width: 0.5,
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: MaterialButton(
        onPressed: onClick,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white.withOpacity(0.7) : null,
              ),
            ),
            Spacer(),
            Icon(
              Icons.check,
              color:
                  title.toLowerCase().trim() == value.toLowerCase().trim() ||
                      (title.toLowerCase().contains('except') &&
                          value == 'contacts_except')
                  ? Colors.green
                  : Colors.transparent,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
