import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/components/switchs/custom_switch_one.dart';

class CustomNotificationSettingsSwitch extends StatelessWidget {
  final String title;
  final String subMessage;
  final bool value;
  final Function(bool) onClick;
  final bool isDark;
  const CustomNotificationSettingsSwitch({super.key, required this.title, required this.subMessage, required this.value, required this.onClick, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.grey : null,
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  subMessage,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.grey : null,
                    fontSize: 13,
                    fontWeight: FontWeight.w400
                  ),
                ),
              ],
            ),
            Spacer(),
            CustomSwitchOne(value: value, onChange: onClick, isDark: isDark,)
          ],
        ),
      ),
    );
  }
}
