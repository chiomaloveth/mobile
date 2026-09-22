import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';

class WallpaperPickerDialog extends StatefulWidget {
  final String? currentWallpaper;
  final Function(String wallpaperPath) onWallpaperSelected;

  const WallpaperPickerDialog({
    Key? key,
    this.currentWallpaper,
    required this.onWallpaperSelected,
  }) : super(key: key);

  @override
  State<WallpaperPickerDialog> createState() => _WallpaperPickerDialogState();
}

class _WallpaperPickerDialogState extends State<WallpaperPickerDialog> {
  final List<WallpaperOption> defaultWallpapers = [
    WallpaperOption(id: 'default_dark', name: 'Dark', color: Color(0xFF141414)),
    WallpaperOption(
      id: 'default_blue',
      name: 'Blue',
      gradient: LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    WallpaperOption(
      id: 'default_green',
      name: 'Green',
      gradient: LinearGradient(
        colors: [Color(0xFF065F46), Color(0xFF10B981)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    WallpaperOption(
      id: 'default_purple',
      name: 'Purple',
      gradient: LinearGradient(
        colors: [Color(0xFF6B21A8), Color(0xFFA855F7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    WallpaperOption(
      id: 'default_orange',
      name: 'Orange',
      gradient: LinearGradient(
        colors: [Color(0xFFEA580C), Color(0xFFFB923C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    WallpaperOption(
      id: 'default_light',
      name: 'Light',
      color: const Color(0xFFFAF5F0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? HexColor("#2E2E2E") : AppTheme.scaffoldBg(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose wallpaper',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Default wallpapers grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: defaultWallpapers.length,
              itemBuilder: (context, index) {
                final wallpaper = defaultWallpapers[index];
                final isSelected = widget.currentWallpaper == wallpaper.id;

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onWallpaperSelected(wallpaper.id);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: wallpaper.gradient,
                      color: wallpaper.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? HexColor("#FF6B00") : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            // Light tile: no dark overlay needed
                            color: wallpaper.id == 'default_light'
                                ? const Color(0x30000000)
                                : const Color(0x80000000),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            wallpaper.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              // Light tile needs dark text for readability
                              color: wallpaper.id == 'default_light'
                                  ? const Color(0xFF1A1008)
                                  : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Custom wallpaper button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _pickCustomWallpaper(context),
                icon: Icon(Icons.add_photo_alternate,
                    color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                label: Text(
                  'Choose from gallery',
                  style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: isDark ? Colors.white24 : AppTheme.border(isDark)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                      color: isDark ? Colors.grey : AppTheme.textSecondary(isDark)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomWallpaper(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    ProviderScope.containerOf(context).read(biometricAuthProvider.notifier).isPickerActive = true;
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    await ProviderScope.containerOf(context).read(biometricAuthProvider.notifier).onPickerReturned();

    if (image != null) {
      Navigator.pop(context);
      widget.onWallpaperSelected(image.path);
    }
  }
}

class WallpaperOption {
  final String id;
  final String name;
  final Color? color;
  final Gradient? gradient;

  WallpaperOption({
    required this.id,
    required this.name,
    this.color,
    this.gradient,
  });
}
