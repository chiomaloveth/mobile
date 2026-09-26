import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../../utilities/components/buttons/custom_back_button.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../../utilities/constants/app_strings/api_strings.dart';
import '../../../../../utilities/constants/app_theme.dart';
import '../../../../../utilities/database/save_values.dart';
import '../../../../../utilities/services/app_pref_helper.dart';
import '../../../theme/provider/theme_provider.dart';

// ── Contact model ──────────────────────────────────────────────────────────

class _Contact {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;

  const _Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });

  factory _Contact.fromJson(Map<String, dynamic> json) => _Contact(
        id: json['_id'] ?? json['id'] ?? '',
        name: json['username'] ?? json['fullName'] ?? json['name'] ?? 'Unknown',
        phone: json['phone'] ?? '',
        avatarUrl: json['profilePicture'],
      );
}

// ── Screen ─────────────────────────────────────────────────────────────────

/// Shows the user's QikTalk contacts for the "Only Share" status privacy
/// option — only the selected contacts will be able to see the user's status.
class OnlyShareScreen extends ConsumerStatefulWidget {
  const OnlyShareScreen({super.key});

  @override
  ConsumerState<OnlyShareScreen> createState() => _OnlyShareScreenState();
}

class _OnlyShareScreenState extends ConsumerState<OnlyShareScreen> {
  final _searchController = TextEditingController();
  final _saveValues = SaveValues();

  List<_Contact> _contacts = [];
  List<_Contact> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      // Primary: broadcast/contacts returns the user's full QikTalk contact list
      final res = await http.get(
        Uri.parse('${ApiStrings.baseUri}chat/broadcast/contacts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data'] as List?;
        if (list != null && list.isNotEmpty) {
          final contacts = list
              .map((u) => _Contact.fromJson(u as Map<String, dynamic>))
              .where((c) => c.id.isNotEmpty)
              .toList();
          if (mounted) {
            setState(() {
              _contacts = contacts;
              _filtered = contacts;
              _isLoading = false;
            });
          }
          return;
        }
      }

      // Fallback: sync-contacts
      final syncRes = await http.post(
        Uri.parse(ApiStrings.syncContacts),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'contacts': []}),
      );

      if (syncRes.statusCode == 200) {
        final body = jsonDecode(syncRes.body);
        final users = body['users'] as List?;
        if (users != null && users.isNotEmpty) {
          final contacts = users
              .map((u) => _Contact.fromJson(u as Map<String, dynamic>))
              .where((c) => c.id.isNotEmpty)
              .toList();
          if (mounted) {
            setState(() {
              _contacts = contacts;
              _filtered = contacts;
              _isLoading = false;
            });
          }
          return;
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  void _onSearch(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? _contacts
          : _contacts
              .where((c) =>
                  c.name.toLowerCase().contains(q) ||
                  c.phone.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppColors.lightNavBar,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppColors.lightNavBar,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(AppColors.gradientColorsTwo),
                        Color(AppColors.gradientColorsOne),
                      ],
                    )
                  : null,
              color: isDark ? null : AppTheme.scaffoldBg(isDark),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: CustomBackButton(buildContext: context),
              title: Text(
                'Only Share With',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Select contacts who can see your status updates',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search,
                        color: isDark ? Colors.white38 : Colors.black38,
                        size: 20),
                    hintText: 'Search contacts',
                    hintStyle: GoogleFonts.poppins(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            // Contact list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No contacts found',
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: isDark
                                ? Colors.white.withOpacity(0.07)
                                : Colors.black.withOpacity(0.07),
                            indent: 68,
                          ),
                          itemBuilder: (context, i) {
                            final contact = _filtered[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.grey.shade700,
                                    backgroundImage: contact.avatarUrl != null &&
                                            contact.avatarUrl!.isNotEmpty
                                        ? NetworkImage(contact.avatarUrl!)
                                        : null,
                                    child: contact.avatarUrl == null ||
                                            contact.avatarUrl!.isEmpty
                                        ? Text(
                                            contact.name.isNotEmpty
                                                ? contact.name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contact.name,
                                          style: GoogleFonts.poppins(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (contact.phone.isNotEmpty)
                                          Text(
                                            contact.phone,
                                            style: GoogleFonts.poppins(
                                              color: isDark
                                                  ? Colors.white54
                                                  : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
