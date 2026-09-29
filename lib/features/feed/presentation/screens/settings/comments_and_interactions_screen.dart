import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../../state/provider/feed_provider.dart';
import '../../../data/models/update_privacy_settings_dto.dart';

class CommentsAndInteractionsScreen extends ConsumerStatefulWidget {
  const CommentsAndInteractionsScreen({super.key});

  @override
  ConsumerState<CommentsAndInteractionsScreen> createState() => _CommentsAndInteractionsScreenState();
}

class _CommentsAndInteractionsScreenState extends ConsumerState<CommentsAndInteractionsScreen> {
  // Local optimistic state
  String? _optimisticCommentPermission;

  String _toUi(String? val) {
    if (val == null) return "Everyone";
    switch (val.toLowerCase()) {
      case "everyone":
        return "Everyone";
      case "contacts":
      case "friends":
        return "Friends";
      case "no_one":
      case "nobody":
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
        return "contacts"; // Match backend value
      case "No one":
        return "nobody"; // Match backend value
      default:
        return "everyone";
    }
  }

  void _updateCommentPermission(String uiValue) async {
    setState(() {
      _optimisticCommentPermission = uiValue;
    });

    final success = await ref.read(feedProvider.notifier).updatePrivacySettings(
      UpdatePrivacySettingsDto(
        privacy: PrivacySettingsDto(commentPermissions: _toBackend(uiValue)),
      ),
    );

    if (mounted) {
      setState(() {
        _optimisticCommentPermission = null;
      });
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update comment permission")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final feedState = ref.watch(feedProvider);
    final privacy = feedState.fetchedPrivacySettings?.data.privacy;
    final commentFilters = feedState.fetchedPrivacySettings?.data.settings.commentFilters;
    
    final currentCommentPermission = _optimisticCommentPermission ?? _toUi(privacy?.commentPermissions);

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
          "Comments & Interactions",
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
            // Info Box
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
                      "Control who can comment on your posts and how comments are filtered.",
                      style: GoogleFonts.poppins(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionHeader("Who can comment", isDark),
            _buildSelectionItem("Everyone", currentCommentPermission, isDark),
            _buildSelectionItem("Friends", currentCommentPermission, isDark),
            _buildSelectionItem("No one", currentCommentPermission, isDark),

            const SizedBox(height: 24),
            _buildSectionHeader("COMMENT FILTERS", isDark),
            _buildToggleItem(
              "Filter spam", 
              "Hide likely spam comments", 
              commentFilters?.filterSpam ?? true, 
              (v) {
                ref.read(feedProvider.notifier).updatePrivacySettings(
                  UpdatePrivacySettingsDto(
                    settings: AppSettingsDto(
                      commentFilters: CommentFiltersDto(filterSpam: v),
                    ),
                  ),
                );
              },
              isDark,
            ),
            _buildToggleItem(
              "Filter offensive words", 
              "Hide comments with offensive language", 
              commentFilters?.filterOffensiveWords ?? true, 
              (v) {
                ref.read(feedProvider.notifier).updatePrivacySettings(
                  UpdatePrivacySettingsDto(
                    settings: AppSettingsDto(
                      commentFilters: CommentFiltersDto(filterOffensiveWords: v),
                    ),
                  ),
                );
              },
              isDark,
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppTheme.textPrimary(isDark),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSelectionItem(String title, String currentValue, bool isDark) {
    final isSelected = currentValue == title;
    final selectedColor = HexColor("#EA4359");
    
    return GestureDetector(
      onTap: () => _updateCommentPermission(title),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.2) : AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: selectedColor, width: 1.43) : null,
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
  
  Widget _buildToggleItem(String title, String subtitle, bool value, ValueChanged<bool> onChanged, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: HexColor("#EA4359"),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}
