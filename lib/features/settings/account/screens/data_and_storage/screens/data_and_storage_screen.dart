import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/settings/account/screens/data_and_storage/components/custom_storage_usage_bar.dart';
import 'package:qik_talk/features/settings/account/screens/data_and_storage/provider/data_storage_backend_provider.dart';
import 'package:qik_talk/features/settings/account/screens/data_and_storage/screens/manage_storage_screen.dart';
import 'package:qik_talk/features/settings/account/screens/data_and_storage/screens/network_usage_screen.dart';
import 'package:qik_talk/features/settings/account/screens/data_and_storage/screens/photo_quality_screen.dart';
import 'package:qik_talk/utilities/constants/app_icons.dart';

import '../../../../../../utilities/constants/app_colors.dart';
import '../../../../../../utilities/constants/app_theme.dart';
import '../../../../theme/provider/theme_provider.dart';
import '../provider/data_storage_provider.dart';

class DataAndStorageScreen extends ConsumerStatefulWidget {
  const DataAndStorageScreen({super.key});

  @override
  ConsumerState<DataAndStorageScreen> createState() =>
      _DataAndStorageScreenState();
}

class _DataAndStorageScreenState extends ConsumerState<DataAndStorageScreen> {
  bool _wifiExpanded = false;
  bool _roamingExpanded = false;

  // Returns "All media types" if all 4 are on, otherwise lists the ones that are on
  String _mediaSubtitle(bool photos, bool videos, bool audio, bool docs) {
    if (photos && videos && audio && docs) return 'All media types';
    final selected = <String>[];
    if (photos) selected.add('Photos');
    if (videos) selected.add('Videos');
    if (audio) selected.add('Audio');
    if (docs) selected.add('Documents');
    if (selected.isEmpty) return 'None';
    return selected.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final storageAsync = ref.watch(storageUsageProvider);
    final networkAsync = ref.watch(networkUsageProvider);
    final storageController = ref.read(storageUsageProvider.notifier);
    final dataSettings = ref.watch(dataSettingsProvider);
    final dataSettingsCtrl = ref.read(dataSettingsProvider.notifier);

    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final Color bg = isDark ? const Color(0xFF141414) : const Color(0xFFFAF5F0);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white60 : Colors.black54;
    final Color dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.grey.withValues(alpha: 0.2);
    final Color sectionLabelColor = isDark ? Colors.white54 : Colors.black45;

    final wifiSubtitle = _mediaSubtitle(
      dataSettings.wifiPhotos,
      dataSettings.wifiVideos,
      dataSettings.wifiAudio,
      dataSettings.wifiDocs,
    );
    final roamingSubtitle = _mediaSubtitle(
      dataSettings.roamingPhotos,
      dataSettings.roamingVideos,
      dataSettings.roamingAudio,
      dataSettings.roamingDocs,
    );

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
                'Data and Storage',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await storageController.calculateStorage();
            await dataSettingsCtrl.loadSettings();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── STORAGE USAGE ──────────────────────────────────────
                _sectionLabel('STORAGE USAGE', sectionLabelColor),
                _divider(dividerColor),

                storageAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _arrowRow(
                        title: 'Manage Storage',
                        subtitle: '${data.formattedTotal} used',
                        textColor: textColor,
                        subTextColor: subTextColor,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const ManageStorageScreen())),
                      ),
                      _divider(dividerColor),
                      const SizedBox(height: 14),
                      CustomStorageUsageBar(
                        title: 'Messages',
                        value: data.formattedMessages,
                        color: Colors.green,
                        percentage: data.totalBytes > 0
                            ? data.messageBytes / data.totalBytes
                            : 0,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      CustomStorageUsageBar(
                        title: 'Media',
                        value: data.formattedMedia,
                        color: Colors.blue,
                        percentage: data.totalBytes > 0
                            ? data.mediaBytes / data.totalBytes
                            : 0,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      CustomStorageUsageBar(
                        title: 'Documents',
                        value: data.formattedDocs,
                        color: Colors.purple,
                        percentage: data.totalBytes > 0
                            ? data.documentBytes / data.totalBytes
                            : 0,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // ── NETWORK USAGE ──────────────────────────────────────
                _divider(dividerColor),
                _sectionLabel('NETWORK USAGE', sectionLabelColor),
                _divider(dividerColor),

                networkAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (net) => Column(
                    children: [
                      _arrowRow(
                        title: 'Network Usage',
                        subtitle: 'View data usage statistics',
                        textColor: textColor,
                        subTextColor: subTextColor,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const NetworkUsageScreen())),
                      ),
                      _divider(dividerColor),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _netRow('Sent', net.formattedSent, textColor, subTextColor),
                            const SizedBox(height: 6),
                            _netRow('Received', net.formattedReceived, textColor, subTextColor),
                            const SizedBox(height: 14),
                            _divider(dividerColor),
                            const SizedBox(height: 10),
                            _netRow('Total', net.formattedTotal, textColor, subTextColor),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── AUTO-DOWNLOAD MEDIA — mobile data (always visible) ─
                _divider(dividerColor),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUTO-DOWNLOAD MEDIA',
                        style: GoogleFonts.poppins(
                          color: sectionLabelColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'When using mobile data',
                        style: GoogleFonts.poppins(
                            color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _divider(dividerColor),
                _plainSwitchRow(
                  label: 'Photos',
                  value: dataSettings.cellularPhotos,
                  onChanged: (v) => dataSettingsCtrl.toggleCellular('photos', v),
                  textColor: textColor,
                  isDark: isDark,
                  dividerColor: dividerColor,
                ),
                _plainSwitchRow(
                  label: 'Videos',
                  value: dataSettings.cellularVideos,
                  onChanged: (v) => dataSettingsCtrl.toggleCellular('videos', v),
                  textColor: textColor,
                  isDark: isDark,
                  dividerColor: dividerColor,
                ),
                _plainSwitchRow(
                  label: 'Documents',
                  value: dataSettings.cellularDocs,
                  onChanged: (v) => dataSettingsCtrl.toggleCellular('docs', v),
                  textColor: textColor,
                  isDark: isDark,
                  dividerColor: dividerColor,
                  showDivider: false,
                ),

                // ── WHEN CONNECTED ON WI-FI — collapsible inline ───────
                _divider(dividerColor),
                _sectionLabel('WHEN CONNECTED ON WI-FI', sectionLabelColor),
                _divider(dividerColor),

                // Header row — tap to expand/collapse
                InkWell(
                  onTap: () => setState(() => _wifiExpanded = !_wifiExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Media Auto-Download',
                                style: GoogleFonts.poppins(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                wifiSubtitle,
                                style: GoogleFonts.poppins(
                                    color: subTextColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _wifiExpanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.arrow_forward_ios,
                              size: 14, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                ),

                // Collapsible toggle rows for Wi-Fi
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _wifiExpanded
                      ? Column(
                          children: [
                            _divider(dividerColor),
                            _plainSwitchRow(
                              label: 'Photos',
                              value: dataSettings.wifiPhotos,
                              onChanged: (v) =>
                                  dataSettingsCtrl.toggleWifi('photos', v),
                              textColor: textColor,
                              isDark: isDark,
                              dividerColor: dividerColor,
                            ),
                            _plainSwitchRow(
                              label: 'Videos',
                              value: dataSettings.wifiVideos,
                              onChanged: (v) =>
                                  dataSettingsCtrl.toggleWifi('videos', v),
                              textColor: textColor,
                              isDark: isDark,
                              dividerColor: dividerColor,
                            ),
                            _plainSwitchRow(
                              label: 'Audio',
                              value: dataSettings.wifiAudio,
                              onChanged: (v) =>
                                  dataSettingsCtrl.toggleWifi('audio', v),
                              textColor: textColor,
                              isDark: isDark,
                              dividerColor: dividerColor,
                            ),
                            _plainSwitchRow(
                              label: 'Documents',
                              value: dataSettings.wifiDocs,
                              onChanged: (v) =>
                                  dataSettingsCtrl.toggleWifi('docs', v),
                              textColor: textColor,
                              isDark: isDark,
                              dividerColor: dividerColor,
                              showDivider: false,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                // ── WHEN ROAMING — collapsible inline ──────────────────
                _divider(dividerColor),
                _sectionLabel('WHEN ROAMING', sectionLabelColor),
                _divider(dividerColor),

                // Header row
                InkWell(
                  onTap: () =>
                      setState(() => _roamingExpanded = !_roamingExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Media Auto-Download',
                                style: GoogleFonts.poppins(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                roamingSubtitle,
                                style: GoogleFonts.poppins(
                                    color: subTextColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _roamingExpanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.arrow_forward_ios,
                              size: 14, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                ),

                // Collapsible toggle rows for Roaming
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _roamingExpanded
                      ? Column(
                          children: [
                            _divider(dividerColor),
                            _plainSwitchRow(
                              label: 'Photos',
                              value: dataSettings.roamingPhotos,
                              onChanged: (v) =>
                                  dataSettingsCtrl.toggleRoaming('photos', v),
                              textColor: textColor,
                              isDark: isDark,
                              dividerColor: dividerColor,
                            ),
                            _plainSwitchRow(
                              label: 'Videos',
                              value: dataSettings.roamingVideos,
                              onChanged: (v) =>
                                  dataSettingsCtrl.toggleRoaming('videos', v),
                              textColor: textColor,
                              isDark: isDark,
                              dividerColor: dividerColor,
                            ),
                            _plainSwitchRow(
                              label: 'Audio',
                              value: dataSettings.roamingAudio,
                              onChanged: (v) =>
                                  dataSettingsCtrl.toggleRoaming('audio', v),
                              textColor: textColor,
                              isDark: isDark,
                              dividerColor: dividerColor,
                            ),
                            _plainSwitchRow(
                              label: 'Documents',
                              value: dataSettings.roamingDocs,
                              onChanged: (v) =>
                                  dataSettingsCtrl.toggleRoaming('docs', v),
                              textColor: textColor,
                              isDark: isDark,
                              dividerColor: dividerColor,
                              showDivider: false,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                // ── IN-APP NOTIFICATIONS ───────────────────────────────
                _divider(dividerColor),
                _sectionLabel('IN-APP NOTIFICATIONS', sectionLabelColor),
                _divider(dividerColor),
                Builder(builder: (ctx) {
                  final quality = ref.watch(photoQualityProvider);
                  final label = quality == PhotoQuality.auto
                      ? 'Auto (recommended)'
                      : quality == PhotoQuality.best
                          ? 'Best quality'
                          : 'Data saver';
                  return _arrowRow(
                    title: 'Photo Quality',
                    subtitle: label,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () => Navigator.push(ctx,
                        MaterialPageRoute(
                            builder: (_) => const PhotoQualityScreen())),
                  );
                }),
                _divider(dividerColor),

                // ── ACTIONS ────────────────────────────────────────────
                const SizedBox(height: 20),
                _actionButton(
                  label: 'Clear Cache',
                  onTap: () async {
                    await storageController.clearCache();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cache cleared')));
                    }
                  },
                ),
                const SizedBox(height: 4),
                _actionButton(
                  label: 'Clear All Data',
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) {
                        final bool isDarkDialog = Theme.of(context).brightness == Brightness.dark;
                        return AlertDialog(
                        backgroundColor: AppTheme.cardBg(isDarkDialog),
                        title: Text('Clear All Data?',
                            style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDarkDialog))),
                        content: Text(
                            'This will delete all messages, media and documents stored locally.',
                            style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDarkDialog))),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel',
                                style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary(isDarkDialog))),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Clear',
                                style: GoogleFonts.poppins(color: Colors.red)),
                          ),
                        ],
                      );
                      },
                    );
                    if (confirm == true) {
                      await storageController.clearAllData();
                      await ref.read(networkUsageProvider.notifier).reset();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('All local data cleared')));
                      }
                    }
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Plain switch row — no icon, matches the mobile-data style ─────────
  Widget _plainSwitchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required bool isDark,
    required Color dividerColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF34C759),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFF636366),
                  trackOutlineColor:
                      WidgetStateProperty.all(Colors.transparent),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Container(height: 0.5, color: dividerColor),
      ],
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
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

  Widget _divider(Color color) => Container(height: 0.5, color: color);

  Widget _arrowRow({
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          color: subTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: subTextColor),
          ],
        ),
      ),
    );
  }

  Widget _netRow(
      String label, String value, Color textColor, Color subTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w400)),
        Text(value,
            style: GoogleFonts.poppins(
                color: subTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _actionButton(
      {required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppIcons.deleteIcon,
                width: 20, height: 20, color: Colors.red),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
