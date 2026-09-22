import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButtonOne extends StatelessWidget {
  final String title;
  final String? icon;
  final TextStyle? style;
  final Color? backgroundColor;
  final VoidCallback onClick;

  const CustomButtonOne({
    super.key,
    required this.title,
    this.style,
    required this.onClick,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final iconPath = icon?.trim();

    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: MaterialButton(
        onPressed: onClick,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null && iconPath.isNotEmpty) ...[
              Image.asset(iconPath, width: 30, height: 30),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style:
                  style ?? GoogleFonts.poppins(fontSize: 16, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
