import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../../../theme/provider/theme_provider.dart';

// ── Model ──────────────────────────────────────────────────────────────────
class LiveLocationShare {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime expiresAt;

  const LiveLocationShare({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Returns "Xh Ym" remaining, or "Expired"
  String get timeRemaining {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    if (h > 0) return 'Expires in ${h}h ${m}m';
    return 'Expires in ${m}m';
  }
}

// ── State ──────────────────────────────────────────────────────────────────
class LiveLocationState {
  final List<LiveLocationShare> shares;

  const LiveLocationState({this.shares = const []});

  LiveLocationState copyWith({List<LiveLocationShare>? shares}) =>
      LiveLocationState(shares: shares ?? this.shares);
}

class LiveLocationNotifier extends StateNotifier<LiveLocationState> {
  LiveLocationNotifier() : super(const LiveLocationState());

  void stopSharing(String id) {
    state = state.copyWith(
      shares: state.shares.where((s) => s.id != id).toList(),
    );
  }
}

final liveLocationProvider =
    StateNotifierProvider<LiveLocationNotifier, LiveLocationState>(
  (ref) => LiveLocationNotifier(),
);

// ── Screen ─────────────────────────────────────────────────────────────────
class LiveLocationScreen extends ConsumerStatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  ConsumerState<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends ConsumerState<LiveLocationScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Tick every minute to refresh the countdown
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(liveLocationProvider);
    final notifier = ref.read(liveLocationProvider.notifier);

    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final Color bg = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFAF5F0);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white60 : Colors.black54;
    final Color sectionLabelColor = isDark ? Colors.white54 : Colors.black45;
    final Color cardBg = isDark ? const Color(0xFF141820) : const Color(0xFFF0F0F0);
    final Color dividerColor =
        isDark ? Colors.white.withValues(alpha: 0.07) : Colors.grey.withValues(alpha: 0.2);

    final activeShares =
        liveState.shares.where((s) => !s.isExpired).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(AppColors.gradientColorsTwo),
                  Color(AppColors.gradientColorsOne),
                ],
              ) : null,
              color: isDark ? null : AppTheme.scaffoldBg(isDark),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Live Location',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── CURRENTLY SHARING section ──────────────────────────
              if (activeShares.isNotEmpty) ...[
                _sectionLabel('CURRENTLY SHARING', sectionLabelColor),
                Container(height: 0.5, color: dividerColor),
                ...activeShares.map((share) => _ShareCard(
                      share: share,
                      cardBg: cardBg,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      onStop: () => _confirmStop(context, share, notifier),
                    )),
                const SizedBox(height: 24),
              ],

              // ── ABOUT card ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Live Location',
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share your real-time location with individuals or groups. '
                        'You can choose how long to share for, and you can stop sharing at any time.',
                        style: GoogleFonts.poppins(
                          color: subTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Empty state when nothing is shared ─────────────────
              if (activeShares.isEmpty) ...[
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.location_off_outlined,
                          color: subTextColor, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Not sharing location',
                        style: GoogleFonts.poppins(
                          color: subTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _confirmStop(
    BuildContext context,
    LiveLocationShare share,
    LiveLocationNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Stop Sharing?',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        content: Text(
          'Stop sharing your live location with ${share.name}?',
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              notifier.stopSharing(share.id);
              Navigator.pop(context);
            },
            child: Text('Stop',
                style: GoogleFonts.poppins(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Share card widget ──────────────────────────────────────────────────────
class _ShareCard extends StatelessWidget {
  final LiveLocationShare share;
  final Color cardBg;
  final Color textColor;
  final Color subTextColor;
  final VoidCallback onStop;

  const _ShareCard({
    required this.share,
    required this.cardBg,
    required this.textColor,
    required this.subTextColor,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + name + expiry
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade700,
                  backgroundImage: share.avatarUrl != null
                      ? NetworkImage(share.avatarUrl!)
                      : null,
                  child: share.avatarUrl == null
                      ? Text(
                          share.name[0].toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      share.name,
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 13, color: subTextColor),
                        const SizedBox(width: 4),
                        Text(
                          share.timeRemaining,
                          style: GoogleFonts.poppins(
                            color: subTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Stop Sharing button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onStop,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C1A1A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Stop Sharing',
                        style: GoogleFonts.poppins(
                          color: Colors.red.shade300,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
