import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';

class SettingsWalletQuickActionCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final String? iconDataTwo;
  final double? iconTwoSize;
  final VoidCallback onClick;
  final double? radius;
  final bool isDark;
  final bool? isExpanded;

  const SettingsWalletQuickActionCard({
    super.key,
    required this.title,
    required this.iconData,
    required this.onClick,
    this.radius,
    this.iconDataTwo,
    this.iconTwoSize,
    required this.isDark, this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : const Color(0xFFFAF5F0),
        borderRadius: BorderRadius.circular(15),
        border: isExpanded! ? Border.all(width: 1, color: Colors.orange) : Border.all(width: 1, color: isDark ? Colors.transparent : const Color(0xFFDDD3C5)),
      ),
      child: MaterialButton(
        onPressed: onClick,
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: isExpanded! ? Colors.orange.withOpacity(0.2) : isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFEDE6DC),
                  borderRadius: BorderRadius.circular(radius ?? 360),
                  border: isExpanded! ? Border.all(width: 1, color: Colors.orange) : null
                ),
                child: Center(
                  child: iconDataTwo != null
                      ? SizedBox(
                          height: iconTwoSize ?? 25,
                          width: iconTwoSize ?? 25,
                          child: Image.asset("$iconDataTwo", color: isDark ? Colors.white : Colors.black,),
                        )
                      : Icon(
                          iconData,
                          size: 20,
                          color: isExpanded! ? Colors.orange : isDark ? Colors.white : Colors.black,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: isExpanded! ? Colors.orange : isDark ? Colors.white : null,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
