import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_story_response_data.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class StoryViewersSheet extends StatelessWidget {
  final List<StoryViewer> viewers;
  final int totalUpdates;

  const StoryViewersSheet({
    super.key,
    required this.viewers,
    required this.totalUpdates,
  });

  static void show(
    BuildContext context,
    List<StoryViewer> viewers,
    int totalUpdates,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.popupBg(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) =>
          StoryViewersSheet(viewers: viewers, totalUpdates: totalUpdates),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    color: AppTheme.iconColorSubtle(isDark),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${viewers.length} ${viewers.length == 1 ? 'view' : 'views'}",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: AppTheme.divider(isDark), height: 1),

            // Viewers list
            Expanded(
              child: viewers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_off_outlined,
                            color: isDark ? Colors.white30 : Colors.black26,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No views yet",
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary(isDark),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "When someone views your story,\nthey'll appear here",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textHint(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: controller,
                      itemCount: viewers.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final viewer = viewers[index];
                        final username = viewer.username ?? 'Unknown';
                        final profilePicture = viewer.profilePicture ?? '';

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppTheme.cardBgAlt(isDark),
                            backgroundImage: profilePicture.isNotEmpty
                                ? NetworkImage(profilePicture)
                                : null,
                            child: profilePicture.isEmpty
                                ? Text(
                                    username.isNotEmpty
                                        ? username[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary(isDark),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            username,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 15,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.greenAccent,
                            size: 18,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
