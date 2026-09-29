import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../../state/provider/feed_provider.dart';
import '../../../data/models/update_privacy_settings_dto.dart';

class WhoCanSeeContentScreen extends ConsumerStatefulWidget {
  const WhoCanSeeContentScreen({super.key});

  @override
  ConsumerState<WhoCanSeeContentScreen> createState() => _WhoCanSeeContentScreenState();
}

class _WhoCanSeeContentScreenState extends ConsumerState<WhoCanSeeContentScreen> {
  // Local optimistic state
  final Map<String, String> _optimisticValues = {};

  String _toUi(String? val) {
    if (val == null) return "Everyone";
    switch (val.toLowerCase()) {
      case "everyone":
        return "Everyone";
      case "contacts":
      case "friends":
        return "Friends";
      case "only_me":
      case "nobody":
        return "Only me";
      case "no_one":
        return "No one";
      default:
        return "Everyone";
    }
  }

  String _toBackend(String val) {
    switch (val) {
      case "Everyone":
        return "everyone";
      case "Friends":
        return "contacts"; // Changed from 'friends' to 'contacts' to match backend
      case "Only me":
        return "nobody"; // Changed from 'only_me' to 'nobody' to match backend
      case "No one":
        return "nobody"; // Consistent with other screens
      default:
        return "everyone";
    }
  }

  void _updateSetting(String sectionKey, String uiValue, UpdatePrivacySettingsDto dto) async {
    setState(() {
      _optimisticValues[sectionKey] = uiValue;
    });
    
    final success = await ref.read(feedProvider.notifier).updatePrivacySettings(dto);
    
    if (mounted) {
      setState(() {
        _optimisticValues.remove(sectionKey);
      });
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update privacy setting")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final feedState = ref.watch(feedProvider);
    final privacy = feedState.fetchedPrivacySettings?.data.privacy;

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
          "Settings and Privacy",
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue Info Box
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Control who can see your content and interact with you on QikTalk.",
                      style: GoogleFonts.poppins(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildSelectionSection(
              title: "Who can see my videos",
              subtitle: "Choose who can view your posted videos",
              currentValue: _optimisticValues["videosVisibility"] ?? _toUi(privacy?.videosVisibility),
              onChanged: (val) {
                _updateSetting(
                  "videosVisibility",
                  val,
                  UpdatePrivacySettingsDto(
                    privacy: PrivacySettingsDto(videosVisibility: _toBackend(val)),
                  ),
                );
              },
              isDark: isDark,
            ),

            _buildSelectionSection(
              title: "Who can view my liked videos",
              subtitle: "Control visibility of videos you've liked",
              currentValue: _optimisticValues["likedVideosVisibility"] ?? _toUi(privacy?.likedVideosVisibility),
              onChanged: (val) {
                _updateSetting(
                  "likedVideosVisibility",
                  val,
                  UpdatePrivacySettingsDto(
                    privacy: PrivacySettingsDto(likedVideosVisibility: _toBackend(val)),
                  ),
                );
              },
              isDark: isDark,
            ),

            _buildSelectionSection(
              title: "Who can comment on my videos",
              subtitle: "Choose who can leave comments",
              currentValue: _optimisticValues["commentPermissions"] ?? _toUi(privacy?.commentPermissions),
              onChanged: (val) {
                _updateSetting(
                  "commentPermissions",
                  val,
                  UpdatePrivacySettingsDto(
                    privacy: PrivacySettingsDto(commentPermissions: _toBackend(val)),
                  ),
                );
              },
              isDark: isDark,
            ),

            _buildSelectionSection(
              title: "Who can duet with my videos",
              subtitle: "Allow others to create duets with your content",
              currentValue: _optimisticValues["duetPermissions"] ?? _toUi(privacy?.duetPermissions),
              onChanged: (val) {
                _updateSetting(
                  "duetPermissions",
                  val,
                  UpdatePrivacySettingsDto(
                    privacy: PrivacySettingsDto(duetPermissions: _toBackend(val)),
                  ),
                );
              },
              isDark: isDark,
            ),

            _buildSelectionSection(
              title: "Who can send me messages",
              subtitle: "Control who can send you direct messages",
              currentValue: _optimisticValues["messagePermissions"] ?? _toUi(privacy?.messagePermissions),
              onChanged: (val) {
                _updateSetting(
                  "messagePermissions",
                  val,
                  UpdatePrivacySettingsDto(
                    privacy: PrivacySettingsDto(messagePermissions: _toBackend(val)),
                  ),
                );
              },
              isDark: isDark,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSection({
    required String title,
    required String subtitle,
    required String currentValue,
    required ValueChanged<String> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark), fontSize: 11),
              ),
            ],
          ),
        ),
        _buildSelectionItem("Everyone", currentValue, onChanged, isDark),
        _buildSelectionItem("Friends", currentValue, onChanged, isDark),
        _buildSelectionItem("Only me", currentValue, onChanged, isDark),
      ],
    );
  }

  Widget _buildSelectionItem(
    String title,
    String currentValue,
    ValueChanged<String> onTap,
    bool isDark,
  ) {
    final isSelected = currentValue == title;
    final selectedColor = HexColor("#EA4359");

    return GestureDetector(
      onTap: () => onTap(title),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.2)
              : AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: selectedColor, width: 1.43)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isSelected ? selectedColor : AppTheme.textSecondary(isDark),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: selectedColor, size: 20),
          ],
        ),
      ),
    );
  }
}
