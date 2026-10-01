import 'package:flutter/material.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';

class GroupCompositeAvatar extends StatelessWidget {
  final List<String> imageUrls;
  final int totalMemberCount;
  final double size;
  final List<String> userIds;
  final Map<String, bool> statusRings;

  const GroupCompositeAvatar({
    super.key,
    required this.imageUrls,
    this.totalMemberCount = 0,
    this.size = 52,
    this.userIds = const [],
    this.statusRings = const {},
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final displayed = imageUrls.where((u) => u.isNotEmpty).take(3).toList();
    final int effectiveTotal = totalMemberCount > displayed.length
        ? totalMemberCount
        : 0;
    final int extra = effectiveTotal > 3 ? effectiveTotal - 3 : 0;
    final bool showCount = extra > 0;

    if (displayed.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
        child: Icon(Icons.group, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
      );
    }

    final double diameter = size * 0.98;
    final double overlap = diameter * 0.20;

    final int visibleCount = displayed.length + (showCount ? 1 : 0);
    final double totalWidth = diameter + overlap * (visibleCount - 1);
    final double totalHeight = diameter;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < displayed.length; i++)
            Positioned(
              left: i * overlap,
              top: 0,
              child: _avatarWithStatus(
                url: displayed[i],
                diameter: diameter,
                userId: i < userIds.length ? userIds[i] : null,
                isDark: isDark,
              ),
            ),

          if (showCount)
            Positioned(
              left: displayed.length * overlap,
              top: 0,
              child: _countChip(extra, diameter, isDark),
            ),
        ],
      ),
    );
  }

  Widget _avatarWithStatus({
    required String url,
    required double diameter,
    String? userId,
    required bool isDark,
  }) {
    final bool hasStatus = userId != null && statusRings.containsKey(userId);
    final bool hasUnviewed = userId != null && (statusRings[userId] ?? false);

    final avatarWidget = _avatar(url, diameter, isDark);

    if (!hasStatus) return avatarWidget;

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasUnviewed
            ? const LinearGradient(
                colors: [Color(0xFF65D2E9), Color(0xFF00A8CC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasUnviewed ? null : Colors.grey.shade600,
        boxShadow: hasUnviewed
            ? [
                BoxShadow(
                  color: const Color(0xFF65D2E9).withOpacity(0.65),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF141414) : AppTheme.scaffoldBg(isDark),
        ),
        child: avatarWidget,
      ),
    );
  }

  Widget _avatar(String url, double diameter, bool isDark) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
        border: Border.all(
          color: isDark ? const Color(0xFF1A1A1A) : AppTheme.scaffoldBg(isDark),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: OfflineCachedImage(
          imageUrl: url,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          errorWidget: Container(
            color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
            alignment: Alignment.center,
            child: Icon(Icons.person, color: isDark ? Colors.white : AppTheme.textPrimary(isDark), size: 10),
          ),
        ),
      ),
    );
  }

  Widget _countChip(int count, double diameter, bool isDark) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.black : const Color(0xFFE0E0E0),
        border: Border.all(
          color: isDark ? const Color(0xFF1A1A1A) : AppTheme.scaffoldBg(isDark),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
          fontSize: diameter * 0.30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
