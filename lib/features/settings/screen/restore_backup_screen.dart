import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import '../theme/provider/theme_provider.dart';

// ── Model ──────────────────────────────────────────────────────────────────

class _BackupEntry {
  final String fileId;
  final String name;
  final String size;
  final String createdAt;
  final bool isLatest;

  const _BackupEntry({
    required this.fileId,
    required this.name,
    required this.size,
    required this.createdAt,
    this.isLatest = false,
  });

  factory _BackupEntry.fromJson(Map<String, dynamic> json, bool isLatest) {
    return _BackupEntry(
      fileId: json['fileId'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Backup',
      size: json['size'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      isLatest: isLatest,
    );
  }
}

// ── Screen ─────────────────────────────────────────────────────────────────

class RestoreBackupScreen extends ConsumerStatefulWidget {
  const RestoreBackupScreen({super.key});

  @override
  ConsumerState<RestoreBackupScreen> createState() =>
      _RestoreBackupScreenState();
}

class _RestoreBackupScreenState extends ConsumerState<RestoreBackupScreen> {
  List<_BackupEntry> _backups = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBackups();
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _fetchBackups() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse(ApiStrings.listGoogleDriveFiles),
        headers: headers,
      );
      print('List backups ${response.statusCode}: ${response.body}');
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final List<dynamic> list = body['data'] as List<dynamic>? ?? [];
        setState(() {
          _backups = list.asMap().entries.map((e) {
            return _BackupEntry.fromJson(
                e.value as Map<String, dynamic>, e.key == 0);
          }).toList();
        });
      } else {
        String message = 'Failed to load backups';
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? message;
        } catch (_) {}
        setState(() => _errorMessage = message);
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Network error: $e');
    }
  }

  Future<void> _restoreBackup(_BackupEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _ConfirmRestoreDialog(entry: entry),
    );
    if (confirmed != true || !mounted) return;

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _RestoreProgressDialog(
        entry: entry,
        onRestore: () => _callRestoreApi(entry),
      ),
    );
  }

  Future<bool> _callRestoreApi(_BackupEntry entry) async {
    try {
      final headers = await _authHeaders();
      // POST /api/v1/settings/backups/google-drive/restore
      final response = await http.post(
        Uri.parse(ApiStrings.restoreFromGoogleDrive),
        headers: headers,
        body: jsonEncode({'fileId': entry.fileId}),
      );
      print('Restore backup ${response.statusCode}: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Restore error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);
    final double topPadding = MediaQuery.of(context).padding.top + 10;

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
            backgroundColor:
                isDark ? HexColor("#3A1D07") : AppTheme.scaffoldBg(isDark),
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
                          'Restore Backup',
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

                    // Warning box
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFFFB800), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Restoring a backup will replace your current messages and media',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFFB800),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFFF3B30), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFF3B30),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _fetchBackups,
                              child: Text(
                                'Retry',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF5B8CFF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_backups.isEmpty) ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(Icons.cloud_off_outlined,
                                  color: AppTheme.textSecondary(isDark),
                                  size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'No backups found',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary(isDark),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Connect Google Drive and create a backup first',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary(isDark),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'AVAILABLE BACKUPS',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF8A8A8E),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._backups.map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _BackupCard(
                            entry: b,
                            onRestore: () => _restoreBackup(b),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Confirm Restore Dialog ─────────────────────────────────────────────────

class _ConfirmRestoreDialog extends StatelessWidget {
  final _BackupEntry entry;
  const _ConfirmRestoreDialog({required this.entry});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color dialogBg = AppTheme.cardBg(isDark);
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);
    final Color cancelBg =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8DDD0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFFB84A00).withOpacity(0.5), width: 1.5),
        ),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Restore Backup?',
                style: GoogleFonts.poppins(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(
              'This will replace your current messages and media with the backup from ${entry.name}. This cannot be undone.',
              style: GoogleFonts.poppins(
                  color: textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                    color: const Color(0xFF5C3A1A),
                    borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: Text('Restore',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                    color: cancelBg,
                    borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: Text('Cancel',
                      style: GoogleFonts.poppins(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Backup card ────────────────────────────────────────────────────────────

class _BackupCard extends StatelessWidget {
  final _BackupEntry entry;
  final VoidCallback onRestore;

  const _BackupCard({required this.entry, required this.onRestore});

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: Color(0xFF1A2A4A), shape: BoxShape.circle),
                child: const Icon(Icons.cloud_outlined,
                    color: Color(0xFF5B8CFF), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.name,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (entry.isLatest) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A3A2A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Latest',
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF34C759),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.createdAt.isNotEmpty
                          ? _formatDate(entry.createdAt)
                          : '',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary(isDark),
                        fontSize: 12,
                      ),
                    ),
                    if (entry.size.isNotEmpty)
                      Text(
                        entry.size,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary(isDark),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onRestore,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: entry.isLatest
                    ? const Color(0xFF5C3A1A)
                    : const Color(0xFF1A2A4A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Restore This Backup',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Restore Progress Dialog ────────────────────────────────────────────────

class _RestoreProgressDialog extends StatefulWidget {
  final _BackupEntry entry;
  final Future<bool> Function() onRestore;

  const _RestoreProgressDialog(
      {required this.entry, required this.onRestore});

  @override
  State<_RestoreProgressDialog> createState() =>
      _RestoreProgressDialogState();
}

class _RestoreProgressDialogState extends State<_RestoreProgressDialog> {
  double _progress = 0.0;
  String _statusText = 'Connecting to Google Drive...';
  bool _complete = false;
  bool _failed = false;
  Timer? _timer;

  static const _stages = [
    (0.2, 'Connecting to Google Drive...'),
    (0.45, 'Downloading backup...'),
    (0.7, 'Restoring messages...'),
    (0.9, 'Restoring media...'),
    (1.0, 'Finalizing...'),
  ];
  int _stageIndex = 0;

  @override
  void initState() {
    super.initState();
    _startRestore();
  }

  Future<void> _startRestore() async {
    // Animate progress while API call runs in parallel
    _timer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final target = _stages[_stageIndex].$1;
      if (_progress < target - 0.01) {
        setState(() => _progress += 0.006);
      } else if (_stageIndex < _stages.length - 1) {
        _stageIndex++;
        setState(() => _statusText = _stages[_stageIndex].$2);
      }
    });

    final success = await widget.onRestore();
    _timer?.cancel();

    if (!mounted) return;
    if (success) {
      setState(() {
        _progress = 1.0;
        _complete = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    } else {
      setState(() => _failed = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color dialogBg =
        isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFFB84A00).withOpacity(0.6), width: 1.5),
        ),
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: _failed
            ? _buildFailed(textPrimary, textSecondary)
            : _complete
                ? _buildComplete(textPrimary, textSecondary)
                : _buildProgress(textPrimary, textSecondary, isDark),
      ),
    );
  }

  Widget _buildProgress(
      Color textPrimary, Color textSecondary, bool isDark) {
    final percent = (_progress * 100).toInt();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
              color: Color(0xFF1A2A4A), shape: BoxShape.circle),
          child: const Icon(Icons.cloud_outlined,
              color: Color(0xFF5B8CFF), size: 36),
        ),
        const SizedBox(height: 20),
        Text('Restoring Backup',
            style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(_statusText,
            style: GoogleFonts.poppins(color: textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 8,
            backgroundColor: AppTheme.dividerSubtle(isDark),
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF5B8CFF)),
          ),
        ),
        const SizedBox(height: 10),
        Text('$percent%',
            style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Text('Please keep the app open until restore is complete',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: AppTheme.textHint(isDark), fontSize: 12)),
      ],
    );
  }

  Widget _buildComplete(Color textPrimary, Color textSecondary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
              color: Color(0xFF1A3A2A), shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded,
              color: Color(0xFF34C759), size: 38),
        ),
        const SizedBox(height: 20),
        Text('Restore Complete!',
            style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Your backup has been restored successfully',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _buildFailed(Color textPrimary, Color textSecondary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
              color: Color(0xFF3A1A1A), shape: BoxShape.circle),
          child: const Icon(Icons.error_outline,
              color: Color(0xFFFF3B30), size: 38),
        ),
        const SizedBox(height: 20),
        Text('Restore Failed',
            style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Could not restore backup. Please try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: textSecondary, fontSize: 13)),
      ],
    );
  }
}
