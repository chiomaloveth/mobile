import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class PermissionOption {
  final String title;
  final String subtitle;

  const PermissionOption({required this.title, required this.subtitle});
}

class PermissionDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final String iconPath;
  final List<PermissionOption> options;
  final String initialValue;

  const PermissionDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.options,
    required this.initialValue,
  });

  @override
  ConsumerState<PermissionDetailScreen> createState() => _PermissionDetailScreenState();
}

class _PermissionDetailScreenState extends ConsumerState<PermissionDetailScreen> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
    final primaryRed = HexColor("#EA4359");

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryRed.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        widget.iconPath,
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                          primaryRed,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white70 : AppTheme.textSecondary(isDark),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Options Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PERMISSION SETTINGS",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.options.map(
                    (option) => _buildOptionItem(option, primaryRed, isDark),
                  ),
                ],
              ),
            ),

            // Note Box
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                  ? Colors.blue.withValues(alpha: 0.1)
                  : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark 
                    ? Colors.blue.withValues(alpha: 0.2)
                    : const Color(0xFF2196F3).withValues(alpha: 0.3)
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline, 
                    color: isDark ? Colors.blue : const Color(0xFF1976D2), 
                    size: 20
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Note: You can change this permission in your device settings at any time.",
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.blue : const Color(0xFF1976D2),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(PermissionOption option, Color selectedColor, bool isDark) {
    final isSelected = _currentValue == option.title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentValue = option.title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: selectedColor.withValues(alpha: 0.5),
                  width: 1,
                )
              : (isDark ? null : Border.all(
                  color: AppTheme.border(isDark),
                  width: 0.5,
                )),
        ),
        child: Row(
          children: [
            // Custom Radio Icon
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? selectedColor : (isDark ? Colors.white24 : AppTheme.border(isDark)),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: GoogleFonts.poppins(
                      color: isSelected ? AppTheme.textPrimary(isDark) : AppTheme.textSecondary(isDark),
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  Text(
                    option.subtitle,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
