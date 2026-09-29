import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/feed/data/models/update_privacy_settings_dto.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/notifications/services/notification_service.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'tone_selection_screen.dart';
import 'package:qik_talk/utilities/database/save_values.dart' as qik_save;

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  String _callTone = 'Default';

  @override
  void initState() {
    super.initState();
    _loadCallTone();
    // Ensure privacy settings are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feedState = ref.read(feedProvider);
      if (feedState.fetchedPrivacySettings == null &&
          !feedState.isPrivacySettingsLoading) {
        ref.read(feedProvider.notifier).getPrivacySettings();
      }
    });
  }

  Future<void> _loadCallTone() async {
    final saveValues = qik_save.SaveValues();
    final tone = await saveValues.getString('call_ringtone');
    if (tone != null && tone.isNotEmpty) {
      setState(() {
        _callTone = tone;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final notifications =
        feedState.fetchedPrivacySettings?.data.settings.notifications;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Colours ──────────────────────────────────────────────────────────────
    final scaffoldColor = AppTheme.scaffoldBg(isDark);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5EEE4);
    final sectionLabelColor =
        isDark ? Colors.white38 : const Color(0xFF9E8E7E);
    final primaryTextColor = AppTheme.textPrimary(isDark);
    final secondaryTextColor = AppTheme.textSecondary(isDark);
    final iconColor =
        isDark ? Colors.white60 : const Color(0xFF6B5A4A);
    final dividerColor =
        isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFD9CFC4);
    final chevronColor =
        isDark ? Colors.white24 : const Color(0xFFCFC4B5);
    final switchInactive = isDark ? Colors.white10 : Colors.black12;
    const activeGreen = Color(0xFF1A7F4B);
    const resetRed = Color(0xFFEA4359);

    // ── AppBar gradient ───────────────────────────────────────────────────────
    final appBarGradient = isDark
        ? [const Color(0xFF171516), const Color(0xFF3A1D07)]
        : [const Color(0xFFFAF5F0), const Color(0xFFF0E8DE)];
    final appBarTextColor = isDark ? Colors.white : const Color(0xFF1A1008);
    final appBarIconColor = isDark ? Colors.white : const Color(0xFF1A1008);

    // ── Loading / error states ────────────────────────────────────────────────
    if (feedState.isPrivacySettingsLoading && notifications == null) {
      return Scaffold(
        backgroundColor: scaffoldColor,
        appBar: _buildAppBar(
          appBarGradient: appBarGradient,
          textColor: appBarTextColor,
          iconColor: appBarIconColor,
          isDark: isDark,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.accent(isDark),
          ),
        ),
      );
    }

    if (notifications == null) {
      return Scaffold(
        backgroundColor: scaffoldColor,
        appBar: _buildAppBar(
          appBarGradient: appBarGradient,
          textColor: appBarTextColor,
          iconColor: appBarIconColor,
          isDark: isDark,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_off_outlined,
                  size: 48, color: secondaryTextColor),
              const SizedBox(height: 16),
              Text(
                'Failed to load notification settings',
                style: GoogleFonts.poppins(
                    color: secondaryTextColor, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(feedProvider.notifier).getPrivacySettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent(isDark),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Retry',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    final notifier = ref.read(feedProvider.notifier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: scaffoldColor,
        appBar: _buildAppBar(
          appBarGradient: appBarGradient,
          textColor: appBarTextColor,
          iconColor: appBarIconColor,
          isDark: isDark,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── GENERAL section ─────────────────────────────────────────
              _SectionLabel(label: 'GENERAL', color: sectionLabelColor),
              const SizedBox(height: 6),

              _SettingsCard(
                cardColor: cardColor,
                children: [
                  _SwitchRow(
                    icon: Icons.notifications_none_outlined,
                    title: 'Show Notifications',
                    value: notifications.messages,
                    iconColor: iconColor,
                    textColor: primaryTextColor,
                    activeColor: activeGreen,
                    inactiveTrackColor: switchInactive,
                    onChanged: (val) => notifier.updatePrivacySettings(
                      UpdatePrivacySettingsDto(
                        settings: AppSettingsDto(
                          notifications:
                              NotificationSettingsDto(messages: val),
                        ),
                      ),
                    ),
                  ),
                  _Divider(color: dividerColor),
                  _SwitchRow(
                    icon: Icons.vibration_outlined,
                    title: 'Vibration',
                    value: notifications.vibrate,
                    iconColor: iconColor,
                    textColor: primaryTextColor,
                    activeColor: activeGreen,
                    inactiveTrackColor: switchInactive,
                    onChanged: (val) => notifier.updatePrivacySettings(
                      UpdatePrivacySettingsDto(
                        settings: AppSettingsDto(
                          notifications:
                              NotificationSettingsDto(vibrate: val),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── SOUNDS section ──────────────────────────────────────────
              _SectionLabel(label: 'SOUNDS', color: sectionLabelColor),
              const SizedBox(height: 6),

              // Notification Tone card
              _SettingsCard(
                cardColor: cardColor,
                children: [
                  _ToneRow(
                    icon: Icons.volume_up_outlined,
                    title: 'Notification Tone',
                    toneName: notifications.messageTone,
                    iconColor: iconColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    chevronColor: chevronColor,
                    onTap: () => _navigateToToneSelection(
                      context,
                      'Notification Tone',
                      'This tone will play for new message notifications.',
                      notifications.messageTone,
                      'notification',
                      (title, uri) async {
                        final saveValues = qik_save.SaveValues();
                        await saveValues.saveString('message_tone_title', title);
                        await saveValues.saveString('tone_uri_$title', uri);
                        await NotificationService.registerToneChannel(
                          channelKey: 'msg',
                          toneTitle: title,
                          toneUri: uri,
                        );
                        notifier.updatePrivacySettings(
                          UpdatePrivacySettingsDto(
                            settings: AppSettingsDto(
                              notifications: NotificationSettingsDto(
                                  messageTone: title),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _Divider(color: dividerColor),
                  _EnableSoundRow(
                    value: notifications.sound,
                    textColor: secondaryTextColor,
                    activeColor: activeGreen,
                    inactiveTrackColor: switchInactive,
                    onChanged: (val) => notifier.updatePrivacySettings(
                      UpdatePrivacySettingsDto(
                        settings: AppSettingsDto(
                          notifications: NotificationSettingsDto(sound: val),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Group Tone card
              _SettingsCard(
                cardColor: cardColor,
                children: [
                  _ToneRow(
                    icon: Icons.group_outlined,
                    title: 'Group Notifications',
                    toneName: notifications.groupTone,
                    iconColor: iconColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    chevronColor: chevronColor,
                    onTap: () => _navigateToToneSelection(
                      context,
                      'Group Tone',
                      'This tone will play for new group notifications.',
                      notifications.groupTone,
                      'notification',
                      (title, uri) async {
                        final saveValues = qik_save.SaveValues();
                        await saveValues.saveString('group_tone_title', title);
                        await saveValues.saveString('tone_uri_$title', uri);
                        await NotificationService.registerToneChannel(
                          channelKey: 'group',
                          toneTitle: title,
                          toneUri: uri,
                        );
                        notifier.updatePrivacySettings(
                          UpdatePrivacySettingsDto(
                            settings: AppSettingsDto(
                              notifications:
                                  NotificationSettingsDto(groupTone: title),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _Divider(color: dividerColor),
                  _EnableSoundRow(
                    value: notifications.groups,
                    textColor: secondaryTextColor,
                    activeColor: activeGreen,
                    inactiveTrackColor: switchInactive,
                    onChanged: (val) => notifier.updatePrivacySettings(
                      UpdatePrivacySettingsDto(
                        settings: AppSettingsDto(
                          notifications: NotificationSettingsDto(groups: val),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Ringtone card (calls)
              _SettingsCard(
                cardColor: cardColor,
                children: [
                  _ToneRow(
                    icon: Icons.ring_volume_outlined,
                    title: 'Ringtone',
                    toneName: _callTone,
                    iconColor: iconColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    chevronColor: chevronColor,
                    onTap: () => _navigateToToneSelection(
                      context,
                      'Ringtone',
                      'This tone will play for incoming calls.',
                      _callTone,
                      'ringtone',
                      (title, uri) async {
                        setState(() {
                          _callTone = title;
                        });
                        final saveValues = qik_save.SaveValues();
                        await saveValues.saveString('call_ringtone', title);
                        await saveValues.saveString('tone_uri_$title', uri);
                        // Also register the channel for consistency (optional but recommended)
                        await NotificationService.registerToneChannel(
                          channelKey: 'call',
                          toneTitle: title,
                          toneUri: uri,
                        );
                      },
                    ),
                  ),
                  _Divider(color: dividerColor),
                  _EnableSoundRow(
                    value: notifications.calls,
                    textColor: secondaryTextColor,
                    activeColor: activeGreen,
                    inactiveTrackColor: switchInactive,
                    onChanged: (val) => notifier.updatePrivacySettings(
                      UpdatePrivacySettingsDto(
                        settings: AppSettingsDto(
                          notifications: NotificationSettingsDto(calls: val),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Reset button ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: feedState.isPrivacySettingsUpdating
                        ? null
                        : () => _showResetConfirmation(context, notifier),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: resetRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: resetRed.withOpacity(0.5),
                    ),
                    child: feedState.isPrivacySettingsUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Reset Notification Settings',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar builder ──────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar({
    required List<Color> appBarGradient,
    required Color textColor,
    required Color iconColor,
    required bool isDark,
  }) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: appBarGradient,
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Notifications',
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _navigateToToneSelection(
    BuildContext context,
    String title,
    String note,
    String currentTone,
    String soundType,
    Function(String, String) onSelected,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ToneSelectionScreen(
          title: title,
          note: note,
          currentTone: currentTone,
          soundType: soundType,
          onToneSelected: onSelected,
        ),
      ),
    );
  }

  // ── Reset confirmation dialog ───────────────────────────────────────────────

  void _showResetConfirmation(BuildContext context, FeedNotifier notifier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Settings',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to reset all notification settings to their default values?',
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary(isDark),
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await notifier.updatePrivacySettings(
                const UpdatePrivacySettingsDto(
                  settings: AppSettingsDto(
                    notifications: NotificationSettingsDto(
                      messages: true,
                      calls: true,
                      groups: true,
                      sound: true,
                      vibrate: true,
                      messageTone: 'Incoming Message',
                      groupTone: 'Incoming Message',
                      notificationVolume: 1.0,
                    ),
                  ),
                ),
                showLoading: true,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Settings reset successfully'
                          : 'Failed to reset settings',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: Text(
              'Reset',
              style: GoogleFonts.poppins(
                color: const Color(0xFFEA4359),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Color cardColor;
  final List<Widget> children;

  const _SettingsCard({required this.cardColor, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;

  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color,
      height: 1,
      indent: 52,
      endIndent: 16,
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final Color iconColor;
  final Color textColor;
  final Color activeColor;
  final Color inactiveTrackColor;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    required this.textColor,
    required this.activeColor,
    required this.inactiveTrackColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: activeColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: inactiveTrackColor,
          ),
        ],
      ),
    );
  }
}

class _ToneRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String toneName;
  final Color iconColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color chevronColor;
  final VoidCallback onTap;

  const _ToneRow({
    required this.icon,
    required this.title,
    required this.toneName,
    required this.iconColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.chevronColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    toneName,
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: chevronColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _EnableSoundRow extends StatelessWidget {
  final bool value;
  final Color textColor;
  final Color activeColor;
  final Color inactiveTrackColor;
  final ValueChanged<bool> onChanged;

  const _EnableSoundRow({
    required this.value,
    required this.textColor,
    required this.activeColor,
    required this.inactiveTrackColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 52, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Enable Sound',
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 13,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: activeColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: inactiveTrackColor,
          ),
        ],
      ),
    );
  }
}
