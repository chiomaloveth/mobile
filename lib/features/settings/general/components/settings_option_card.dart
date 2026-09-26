import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class SettingsOptionCard extends StatelessWidget {
  final String title;
  final String value;
  final String icon;
  final VoidCallback onClick;
  final bool isDark;

  const SettingsOptionCard({
    super.key,
    required this.title,
    required this.value,
    required this.onClick,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            icon.trim().isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      top: 30.0,
                      bottom: 10.0,
                    ),
                    child: Image(
                      image: AssetImage(icon),
                      width: 30.0,
                      height: 30.0,
                      color: isDark ? null : Colors.black,
                    ),
                  ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 15.0),
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: isDark ? HexColor("#AEAEB2") : Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                  value.trim().isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                          child: Text(
                            value,
                            style: GoogleFonts.poppins(
                              color: isDark ? HexColor("#AEAEB2") : Colors.grey,
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 10.0),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 20.0,
                color: isDark ? HexColor("#AEAEB2") : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
