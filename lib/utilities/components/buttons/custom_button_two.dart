import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class CustomButtonTwo extends StatelessWidget {
  final String title;
  final VoidCallback onClick;
  final bool isLoading;
  final bool? hasMargin;

  const CustomButtonTwo({
    super.key,
    required this.title,
    required this.onClick,
    required this.isLoading, this.hasMargin,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 55.0,
        margin: hasMargin == false && hasMargin != null ?  null : const EdgeInsets.only(left: 20, right: 20, top: 30.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [HexColor("#FF00A8"), HexColor("#00D1FF")],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: HexColor("#FB8830").withOpacity(isDark ? 0.4 : 0.2),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        padding: const EdgeInsets.all(1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? HexColor("#1B1B1B") : AppTheme.scaffoldBg(isDark),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.white : AppTheme.textPrimary(isDark),
                      ),
                    ),
                  )
                : Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
