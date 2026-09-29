import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'follow_friends_screen.dart';

class ChooseInterestsScreen extends ConsumerStatefulWidget {
  const ChooseInterestsScreen({super.key});

  @override
  ConsumerState<ChooseInterestsScreen> createState() =>
      _ChooseInterestsScreenState();
}

class _ChooseInterestsScreenState extends ConsumerState<ChooseInterestsScreen> {
  final SaveValues _saveValues = SaveValues();
  final Set<String> _selectedTopics = {};

  void _toggleTopic(String topic) {
    setState(() {
      if (_selectedTopics.contains(topic)) {
        _selectedTopics.remove(topic);
      } else {
        _selectedTopics.add(topic);
      }
    });
  }

  /// Maps a topic string to its category key by looking in the current
  /// preference data available in state.
  String _categoryKeyForTopic(
    String topic,
    Map<String, List<String>> categories,
  ) {
    for (final entry in categories.entries) {
      if (entry.value.contains(topic)) return entry.key;
    }
    return 'entertainment'; // fallback
  }

  Future<void> _completeSelection({
    required bool isNext,
    required Map<String, List<String>> categories,
  }) async {
    if (isNext && _selectedTopics.isNotEmpty) {
      // Group selected topics by their backend category key
      final List<String> entertainment = [];
      final List<String> homeFamily = [];
      final List<String> fashionBeauty = [];

      for (final topic in _selectedTopics) {
        final cat = _categoryKeyForTopic(topic, categories);
        if (cat == 'Entertainment & Culture') {
          entertainment.add(topic);
        } else if (cat == 'Home & Family') {
          homeFamily.add(topic);
        } else if (cat == 'Fashion & Beauty') {
          fashionBeauty.add(topic);
        } else {
          entertainment.add(topic);
        }
      }

      final success = await ref
          .read(preferenceListProvider.notifier)
          .createPreferenceList(
            entertainment: entertainment,
            homeFamily: homeFamily,
            fashionBeauty: fashionBeauty,
          );

      if (!mounted) return;

      if (success) {
        // Refresh user info to sync backend status of isPreferenceSet
        ref.read(feedProvider.notifier).loadUserInfo(silent: true);
      }
    }

    await _saveValues.saveBool(AppPreferenceHelper.HAS_SEEN_INTERESTS, true);
    if (!mounted) return;

    Navigator.of(context).pop();

    if (isNext) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const FollowFriendsScreen(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canProceed = _selectedTopics.length >= 3;
    final screenHeight = MediaQuery.of(context).size.height;

    // Watch the preference list state
    final preferenceState = ref.watch(preferenceListProvider);
    final isSaving = preferenceState.isSaving;

    // Build categories map once, used by both buttons and body
    final data = preferenceState.data?.data;
    final Map<String, List<String>> categories = {
      'Entertainment & Culture': data?.entertainment ?? [],
      'Home & Family': data?.homeFamily ?? [],
      'Fashion & Beauty': data?.fashionBeauty ?? [],
    };

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  bottom: 8.0,
                  left: 24.0,
                  right: 24.0,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: isSaving
                              ? null
                              : () => _completeSelection(
                                  isNext: false,
                                  categories: categories,
                                ),
                          child: Text(
                            "Skip",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade400,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (canProceed)
                          GestureDetector(
                            onTap: isSaving
                                ? null
                                : () => _completeSelection(
                                    isNext: true,
                                    categories: categories,
                                  ),
                            child: isSaving
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: HexColor("#EE1D52"),
                                    ),
                                  )
                                : Text(
                                    "Next",
                                    style: GoogleFonts.poppins(
                                      color: HexColor("#EE1D52"),
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          )
                        else
                          const SizedBox(width: 30),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(child: _buildBody(preferenceState, categories)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    PreferenceListState preferenceState,
    Map<String, List<String>> categories,
  ) {
    if (preferenceState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFEE1D52)),
      );
    }

    if (preferenceState.error != null && preferenceState.data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                "Couldn't load interests",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please check your connection and try again.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref
                    .read(preferenceListProvider.notifier)
                    .loadPreferenceList(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#EE1D52"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Retry",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Text(
            "Choose your interests",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 32.0,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            "Personalize your experience by picking 3 or more topics",
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32.0),

          ...categories.entries.map((entry) {
            return _buildCategorySection(entry.key, entry.value);
          }),

          const SizedBox(height: 40.0), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<String> topics) {
    SvgPicture getIconForCategory(String category) {
      switch (category) {
        case "Entertainment & Culture":
          return SvgPicture.asset(
            "assets/svgs/feed_entertainment.svg",
            height: 20,
            width: 20,
          );
        case "Home & Family":
          return SvgPicture.asset(
            "assets/svgs/feed_home.svg",
            height: 20,
            width: 20,
          );
        case "Fashion & Beauty":
          return SvgPicture.asset(
            "assets/svgs/fashion.svg",
            height: 20,
            width: 20,
          );
        default:
          return SvgPicture.asset(
            "assets/svgs/entertainment_culture.svg",
            height: 20,
            width: 20,
          );
      }
    }

    if (topics.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              getIconForCategory(title),
              const SizedBox(width: 8.0),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 12.0,
            runSpacing: 16.0,
            children: topics.map((topic) {
              final isSelected = _selectedTopics.contains(topic);
              return GestureDetector(
                onTap: () => _toggleTopic(topic),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? HexColor("#EE1D52") : Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: isSelected
                          ? HexColor("#EE1D52")
                          : Colors.grey.shade300,
                      width: 1.0,
                    ),
                    boxShadow: !isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4.0,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    topic,
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 14.0,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
