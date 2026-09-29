import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/media_utils.dart';

class StoryBubble extends StatelessWidget {
  final String username;
  final String imageUrl;
  final bool isLive;
  final bool isCreate;
  final VoidCallback? onTap;
  final VoidCallback? onPlusTap;

  const StoryBubble({
    super.key,
    required this.username,
    required this.imageUrl,
    this.isLive = false,
    this.isCreate = false,
    this.onTap,
    this.onPlusTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isLive
                        ? LinearGradient(
                            colors: [HexColor("#FE2C55"), HexColor("#EE3190")],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          )
                        : (!isCreate
                              ? LinearGradient(
                                  colors: [
                                    HexColor("#65D2E9"),
                                    HexColor("#00F2EA"),
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                )
                              : null),
                    color: isCreate ? Colors.transparent : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isCreate ? 0 : 2.5),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? HexColor("#141414") : AppTheme.scaffoldBg(isDark),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isCreate ? 0 : 2.5),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFD9CFC4),
                          backgroundImage:
                              imageUrl.isNotEmpty && imageUrl.startsWith('http')
                              ? NetworkImage(
                                  MediaUtils.getThumbnailUrl(imageUrl),
                                )
                              : null,
                          child:
                              (imageUrl.isNotEmpty &&
                                  !imageUrl.startsWith('http'))
                              ? Text(
                                  imageUrl.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : (imageUrl.isEmpty
                                    ? Text(
                                        username.trim().isNotEmpty
                                            ? username.trim()[0].toUpperCase()
                                            : 'U',
                                        style: GoogleFonts.poppins(
                                          color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null),
                        ),
                      ),
                    ),
                  ),
                ),

                // "Create" badge
                if (isCreate)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onPlusTap,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: HexColor("#00D1FF"),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? HexColor("#141414") : AppTheme.scaffoldBg(isDark),
                            width: 2.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                // "LIVE" badge
                if (isLive)
                  Positioned(
                    bottom: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [HexColor("#FE2C55"), HexColor("#EE3190")],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDark ? HexColor("#141414") : AppTheme.scaffoldBg(isDark),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        "LIVE",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              username,
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
