import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/settings/screen/backup_frequency_screen.dart';
import 'package:qik_talk/features/settings/screen/google_drive_account_screen.dart';
import 'package:qik_talk/features/settings/screen/restore_backup_screen.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import '../theme/provider/theme_provider.dart';

// ── State ──────────────────────────────────────────────────────────────────

class _BackupState {
  final bool backupOverWifi;
  final bool includeVideos;
  final bool encryptedBackup;

  const _BackupState({
    this.backupOverWifi = true,
    this.includeVideos = true,
    this.encryptedBackup = false,
  });

  _BackupState copyWith({
    bool? backupOverWifi,
    bool? includeVideos,
    bool? encryptedBackup,
  }) =>
      _BackupState(
        backupOverWifi: backupOverWifi ?? this.backupOverWifi,
        includeVideos: includeVideos ?? this.includeVideos,
        encryptedBackup: encryptedBackup ?? this.encryptedBackup,
      );
}

// ── Screen ─────────────────────────────────────────────────────────────────

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  _BackupState _state = const _BackupState();

  // Google Drive status
  bool _driveConnected = false;
  String _driveEmail = '';
  String _driveStorageUsed = '';
  String _driveStorageTotal = '';
  String _lastSync = '';

  // Backup in progress
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    _fetchDriveStatus();
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _fetchDriveStatus() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse(ApiStrings.googleDriveStatus),
        headers: headers,
      );
      print('Drive status ${response.statusCode}: ${response.body}');
      if (mounted && (response.statusCode == 200 || response.statusCode == 201)) {
        final body = jsonDecode(response.body);
        final data = body['data'] as Map<String, dynamic>? ?? {};
        setState(() {
          _driveConnected = data['connected'] == true;
          _driveEmail = data['email'] as String? ?? '';
          _driveStorageUsed = data['storageUsed'] as String? ?? '';
          _driveStorageTotal = data['storageTotal'] as String? ?? '';
          _lastSync = data['lastSync'] as String? ?? '';
        });
      }
    } catch (e) {
      print('Drive status error: $e');
    }
  }

  Future<void> _startBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final headers = await _authHeaders();
      // POST /api/v1/settings/backups — trigger a new backup
      final response = await http.post(
        Uri.parse(ApiStrings.createBackup),
        headers: headers,
        body: jsonEncode({
          'includeVideos': _state.includeVideos,
          'encrypted': _state.encryptedBackup,
          'wifiOnly': _state.backupOverWifi,
        }),
      );
      print('Create backup ${response.statusCode}: ${response.body}');
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup started successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchDriveStatus();
      } else {
        String message = 'Failed to start backup';
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? message;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  void _toggle(String field, bool value) {
    setState(() {
      switch (field) {
        case 'wifi':
          _state = _state.copyWith(backupOverWifi: value);
          break;
        case 'videos':
          _state = _state.copyWith(includeVideos: value);
          break;
        case 'encrypted':
          _state = _state.copyWith(encryptedBackup: value);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);
    final double topPadding = MediaQuery.of(context).padding.top + 10;

    const sectionLabelColor = Color(0xFF8A8A8E);
    final cardColor = AppTheme.cardBg(isDark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? HexColor("#3A1D07") : AppTheme.scaffoldBg(isDark),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: isDark
                    ? const DecorationImage(
                        image: AssetImage("images/app_bar_gredient.png"),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: isDark ? null : AppTheme.scaffoldBg(isDark),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: topPadding, left: 16, right: 40),
                          child: Icon(Icons.arrow_back,
                              size: 22,
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.textPrimary(isDark)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: topPadding, left: 10),
                        child: Text(
                          'Backup',
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.white
                                : AppTheme.textPrimary(isDark),
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              // ── Cloud Backup Status card ──────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _driveConnected
                                ? const Color(0xFF1A3A2A)
                                : const Color(0xFF2A2A2A),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.cloud_outlined,
                            color: _driveConnected
                                ? const Color(0xFF34C759)
                                : Colors.grey,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cloud Backup',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textPrimary(isDark),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                      _driveConnected
                                          ? (_lastSync.isNotEmpty
                                              ? 'Last sync: ${_formatDate(_lastSync)}'
                                              : 'Connected')
                                          : 'Not connected',
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.textSecondary(isDark),
                                        fontSize: 13,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _driveConnected
                                  ? const Color(0xFF1A3A2A)
                                  : const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _driveConnected ? 'Connected' : 'Not Connected',
                              style: GoogleFonts.poppins(
                                color: _driveConnected
                                    ? const Color(0xFF34C759)
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Storage bar (only when connected)
                    if (_driveConnected &&
                        _driveStorageUsed.isNotEmpty &&
                        _driveStorageTotal.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                          height: 0.5,
                          color: AppTheme.dividerSubtle(isDark)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Storage',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary(isDark),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '$_driveStorageUsed / $_driveStorageTotal',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),
                    Container(height: 0.5, color: AppTheme.dividerSubtle(isDark)),
                    const SizedBox(height: 14),

                    // Backup includes grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BACKUP INCLUDES',
                            style: GoogleFonts.poppins(
                              color: sectionLabelColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _IncludeItem(
                                  icon: Icons.message_outlined,
                                  label: 'Messages',
                                  color: const Color(0xFF5B8CFF),
                                ),
                              ),
                              Expanded(
                                child: _IncludeItem(
                                  icon: Icons.photo_outlined,
                                  label: 'Photos',
                                  color: const Color(0xFFFF9F0A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _IncludeItem(
                                  icon: Icons.videocam_outlined,
                                  label: 'Videos',
                                  color: const Color(0xFFFF6B6B),
                                ),
                              ),
                              Expanded(
                                child: _IncludeItem(
                                  icon: Icons.description_outlined,
                                  label: 'Documents',
                                  color: const Color(0xFFFFB800),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Back Up Now button
                    GestureDetector(
                      onTap: _startBackup,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C3A1A),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                                  'Back Up Now',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Backup Account ────────────────────────────────────────────
              Text(
                'BACKUP ACCOUNT',
                style: GoogleFonts.poppins(
                  color: sectionLabelColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                        builder: (_) => const GoogleDriveAccountScreen(),
                      ))
                      .then((_) => _fetchDriveStatus());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C2A3A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.storage_outlined,
                            color: Color(0xFF5B8CFF), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Google Drive',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary(isDark),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _driveConnected && _driveEmail.isNotEmpty
                                  ? _driveEmail
                                  : 'Not connected',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary(isDark),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: AppTheme.iconColorSubtle(isDark), size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Backup Settings ───────────────────────────────────────────
              Text(
                'BACKUP SETTINGS',
                style: GoogleFonts.poppins(
                  color: sectionLabelColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _SettingsRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Auto Backup',
                      subtitle: 'Daily',
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: AppTheme.iconColorSubtle(isDark), size: 16),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const BackupFrequencyScreen(),
                        ));
                      },
                    ),
                    _divider(),
                    _SettingsRow(
                      icon: Icons.wifi,
                      title: 'Backup Over Wi-Fi Only',
                      trailing: _buildSwitch(
                          _state.backupOverWifi, (v) => _toggle('wifi', v)),
                    ),
                    _divider(),
                    _SettingsRow(
                      icon: Icons.videocam_outlined,
                      title: 'Include Videos',
                      subtitle: 'Videos may increase backup size',
                      trailing: _buildSwitch(
                          _state.includeVideos, (v) => _toggle('videos', v)),
                    ),
                    _divider(),
                    _SettingsRow(
                      icon: Icons.lock_outline,
                      title: 'End-to-End Encrypted Backup',
                      subtitle: 'Secure your backup with encryption',
                      trailing: _buildSwitch(_state.encryptedBackup,
                          (v) => _toggle('encrypted', v)),
                    ),
                    _divider(),
                    _SettingsRow(
                      icon: Icons.restore,
                      title: 'Restore Backup',
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: AppTheme.iconColorSubtle(isDark), size: 16),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const RestoreBackupScreen(),
                        ));
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Info box ──────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2A3A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFF5B8CFF), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your messages and media are backed up to Google Drive. Connect your account above to enable cloud backup.',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6AADDB),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Widget _divider() => Container(
        height: 0.5,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: AppTheme.dividerSubtle(
            Theme.of(context).brightness == Brightness.dark),
      );

  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFF34C759),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFF3A3A3C),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}

// ── Include item widget ────────────────────────────────────────────────────

class _IncludeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _IncludeItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary(
                Theme.of(context).brightness == Brightness.dark),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Settings row widget ────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: AppTheme.iconColorSubtle(
                    Theme.of(context).brightness == Brightness.dark),
                size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(
                          Theme.of(context).brightness == Brightness.dark),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary(
                            Theme.of(context).brightness == Brightness.dark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
