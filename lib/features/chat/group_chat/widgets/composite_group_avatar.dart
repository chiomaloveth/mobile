// ─────────────────────────────────────────────────────────────────────────────
// COMPOSITE GROUP AVATAR WIDGET
// Drop this widget anywhere you need the stacked member avatars.
// Place this file at: lib/features/chat/group_chat/widgets/composite_group_avatar.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:qik_talk/features/chat/general/model/group_model.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';

class CompositeGroupAvatar extends StatelessWidget {
  final List<GroupMember> members;
  final double avatarRadius;
  final double overlap;
  final Color fallbackColor;

  const CompositeGroupAvatar({
    super.key,
    required this.members,
    this.avatarRadius = 14,
    this.overlap = 8,
    this.fallbackColor = const Color(0xFF3A3A3A),
  });

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final displayed = members.take(3).toList();
    final overflow = members.length - 3;

    final int visibleCount = displayed.length + (overflow > 0 ? 1 : 0);
    final double totalWidth = visibleCount == 0
        ? avatarRadius * 2
        : (avatarRadius * 2) + (overlap * (visibleCount - 1));
    final double height = avatarRadius * 2;

    return SizedBox(
      width: totalWidth,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < displayed.length; i++)
            Positioned(left: i * overlap, child: _buildAvatar(displayed[i], i, isDark)),

          if (overflow > 0)
            Positioned(
              left: displayed.length * overlap,
              child: Container(
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A7F4B),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1A1A1A) : AppTheme.scaffoldBg(isDark),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$overflow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: avatarRadius * 0.65,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(GroupMember member, int index, bool isDark) {
    final imageUrl = _getFullImageUrl(member.profilePicture);
    return Container(
      width: avatarRadius * 2,
      height: avatarRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
        border: Border.all(
          color: isDark ? const Color(0xFF1A1A1A) : AppTheme.scaffoldBg(isDark),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? OfflineCachedImage(
                imageUrl: imageUrl,
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                fit: BoxFit.cover,
                errorWidget: _fallbackText(member, isDark),
              )
            : _fallbackText(member, isDark),
      ),
    );
  }

  Widget _fallbackText(GroupMember member, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
      alignment: Alignment.center,
      child: Text(
        member.username.isNotEmpty ? member.username[0].toUpperCase() : '?',
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
          fontSize: avatarRadius * 0.75,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


