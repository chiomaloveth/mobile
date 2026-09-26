import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomStorageUsageBar extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final double percentage;
  final bool isDark;

  const CustomStorageUsageBar({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.percentage = 0.0, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final double activePercentage = percentage.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : null,
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : null,
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                ),
              ),
            ],
          ),
          const SizedBox(height: 5,),
          LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 11,
                  width: constraints.maxWidth,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        height: double.infinity,
                        width: constraints.maxWidth * activePercentage,
                        decoration: BoxDecoration(
                            color: color
                        ),
                      )
                    ],
                  ),
                );
              }
          )
        ],
      ),
    );
  }
}