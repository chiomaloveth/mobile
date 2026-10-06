import 'package:flutter/material.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

const Color appBackground = Colors.black;
const Color cardColor = Color(0xFF1A1A1C);
const Color textColor = Colors.white;
const Color subTextColor = Color(0xFF8E8E93);
const Color successGreen = Color(0xFF4CAF50);
const Color errorRed = Color(0xFFF44336);

class GradientOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientOutlineButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFF00BCD4)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE91E63).withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 5),
              )
            ]
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E20),
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class CustomInputField extends StatelessWidget {
  final String hintText;
  final String? prefixText;
  final Widget? suffixIcon;
  final bool isDropdown;
  final int maxLines;

  const CustomInputField({
    Key? key,
    required this.hintText,
    this.prefixText,
    this.suffixIcon,
    this.isDropdown = false,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? cardColor : AppTheme.inputFill(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.transparent : AppTheme.inputBorder(isDark),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        maxLines: maxLines,
        style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: isDark ? subTextColor : AppTheme.textHint(isDark)),
          prefixText: prefixText != null ? '$prefixText  ' : null,
          prefixStyle: TextStyle(
            color: isDark ? subTextColor : AppTheme.textSecondary(isDark),
            fontSize: 16,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          suffixIcon: isDropdown
              ? Icon(Icons.keyboard_arrow_down,
                  color: isDark ? subTextColor : AppTheme.iconColorSubtle(isDark))
              : suffixIcon,
        ),
      ),
    );
  }
}

Future<void> showPinConfirmationModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.only(top: 30, bottom: 50, left: 20, right: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter Pin to Confirm",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your six (6) digits pin to continue",
              style: TextStyle(color: subTextColor, fontSize: 14),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: index == 0 ? Colors.orange : subTextColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}