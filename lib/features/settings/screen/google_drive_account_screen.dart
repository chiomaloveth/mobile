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

class _DriveStatus {
  final bool connected;
  final String email;
  final String storageUsed;
  final String storageTotal;
  final String lastSync;

  const _DriveStatus({
    this.connected = false,
    this.email = '',
    this.storageUsed = '',
    this.storageTotal = '',
    this.lastSync = '',
  });
}

// ── Screen ─────────────────────────────────────────────────────────────────

class GoogleDriveAccountScreen extends ConsumerStatefulWidget {
  const GoogleDriveAccountScreen({super.key});

  @override
  ConsumerState<GoogleDriveAccountScreen> createState() =>
      _GoogleDriveAccountScreenState();
}

class _GoogleDriveAccountScreenState
    extends ConsumerState<GoogleDriveAccountScreen> {
  bool _isConnecting = false;
  bool _isDisconnecting = false;
  _DriveStatus _status = const _DriveStatus();

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _fetchStatus() async {
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
          _status = _DriveStatus(
            connected: data['connected'] == true,
            email: data['email'] as String? ?? '',
            storageUsed: data['storageUsed'] as String? ?? '',
            storageTotal: data['storageTotal'] as String? ?? '',
            lastSync: data['lastSync'] as String? ?? '',
          );
        });
      }
    } catch (e) {
      print('Drive status error: $e');
    }
  }

  Future<void> _connectDrive() async {
    // POST /api/v1/settings/backups/google-drive/connect
    // In a real app this would open a Google OAuth flow.
    // Here we call the connect endpoint with a placeholder and show the result.
    setState(() => _isConnecting = true);
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse(ApiStrings.connectGoogleDrive),
        headers: headers,
        body: jsonEncode({
          'authCode': 'google_oauth_code_placeholder',
          'redirectUri': 'com.company.qik_talk:/oauth2redirect',
        }),
      );
      print('Connect Drive ${response.statusCode}: ${response.body}');
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Drive connected successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchStatus();
      } else {
        String message = 'Failed to connect Google Drive';
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
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _disconnectDrive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _RemoveAccountDialog(
        onRemove: () => Navigator.pop(context, true),
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDisconnecting = true);
    try {
      final headers = await _authHeaders();
      // DELETE /api/v1/settings/backups/google-drive/disconnect
      final response = await http.delete(
        Uri.parse(ApiStrings.disconnectGoogleDrive),
        headers: headers,
      );
      print('Disconnect Drive ${response.statusCode}: ${response.body}');
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Drive disconnected'),
            backgroundColor: Colors.orange,
          ),
        );
        _fetchStatus();
      } else {
        String message = 'Failed to disconnect Google Drive';
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
      if (mounted) setState(() => _isDisconnecting = false);
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
                          'Google Drive Account',
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

                    // ── Info box ────────────────────────────────────────────
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
                              'Your backups are saved to your Google Drive. Connect your account to sync data across devices.',
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

                    const SizedBox(height: 24),

                    // ── Connection Status ───────────────────────────────────
                    Text(
                      'GOOGLE DRIVE',
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _status.connected
                                      ? const Color(0xFF1A3A2A)
                                      : const Color(0xFF2A2A2A),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.storage_outlined,
                                  color: _status.connected
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
                                      'Google Drive',
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.textPrimary(isDark),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      _status.connected
                                          ? _status.email
                                          : 'Not connected',
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.textSecondary(isDark),
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _status.connected
                                      ? const Color(0xFF1A3A2A)
                                      : const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _status.connected ? 'Connected' : 'Disconnected',
                                  style: GoogleFonts.poppins(
                                    color: _status.connected
                                        ? const Color(0xFF34C759)
                                        : Colors.grey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Storage info when connected
                          if (_status.connected &&
                              _status.storageUsed.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Container(
                                height: 0.5,
                                color: AppTheme.dividerSubtle(isDark)),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Storage used',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary(isDark),
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${_status.storageUsed} / ${_status.storageTotal}',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary(isDark),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (_status.lastSync.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Last sync',
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textSecondary(isDark),
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(_status.lastSync),
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textPrimary(isDark),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Connect / Disconnect button ─────────────────────────
                    if (_status.connected)
                      GestureDetector(
                        onTap: _disconnectDrive,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A1A1A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFFF3B30),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                                    'Disconnect Google Drive',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFFF3B30),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _connectDrive,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C3A1A),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Connect Google Drive',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ── About Google Drive Backup ───────────────────────────
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Google Drive Backup',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...[
                            "Backups don't count against your Google Drive storage quota",
                            'Your messages and media are stored securely',
                            'Backups are automatically synced when connected to Wi-Fi',
                          ].map(
                            (point) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('• ',
                                      style: GoogleFonts.poppins(
                                          color:
                                              AppTheme.textSecondary(isDark),
                                          fontSize: 13)),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.textSecondary(isDark),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
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
}

// ── Remove / Disconnect Dialog ─────────────────────────────────────────────

class _RemoveAccountDialog extends StatelessWidget {
  final VoidCallback onRemove;
  const _RemoveAccountDialog({required this.onRemove});

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
            color: const Color(0xFFB84A00).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disconnect Google Drive?',
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This will stop syncing backups to Google Drive. Your existing backups will remain in Google Drive.',
              style: GoogleFonts.poppins(
                  color: textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Disconnect',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: cancelBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
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
