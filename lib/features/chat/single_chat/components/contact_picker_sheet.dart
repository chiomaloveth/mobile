import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class ContactPickerSheet extends StatefulWidget {
  final void Function(String name, String phone, String? profilePicture)
  onContactSelected;

  const ContactPickerSheet({super.key, required this.onContactSelected});

  @override
  State<ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<ContactPickerSheet> {
  List<Map<String, String?>> _contacts = [];
  List<Map<String, String?>> _filtered = [];
  bool _loading = true;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _search.addListener(() {
      final q = _search.text.toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? _contacts
            : _contacts
                  .where(
                    (c) =>
                        (c['name'] ?? '').toLowerCase().contains(q) ||
                        (c['phone'] ?? '').contains(q),
                  )
                  .toList();
      });
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final List<Map<String, String?>> result = [];

      // ── 1. Load cached QikTalk registered users first ────────────────────
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cached_registered_users');
      final Set<String> addedPhones = {};

      if (raw != null && raw.isNotEmpty) {
        final parsed = jsonDecode(raw) as List;
        for (final u in parsed) {
          final map = u as Map<String, dynamic>;
          final name = (map['username'] as String? ?? '').trim();
          final phone = (map['phone'] as String? ?? '').trim();
          final pic = map['profilePicture'] as String?;
          if (name.isEmpty || phone.isEmpty) continue;
          result.add({
            'name': name,
            'phone': phone,
            'profilePicture': pic,
            'isOnApp': 'true',
          });
          addedPhones.add(_normalise(phone));
        }
      }

      // ── 2. Load device contacts ───────────────────────────────────────────
      final hasPermission = await FlutterContacts.requestPermission(
        readonly: true,
      );
      if (hasPermission) {
        final deviceContacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        for (final c in deviceContacts) {
          if (c.phones.isEmpty) continue;
          final name = c.displayName.trim();
          if (name.isEmpty) continue;
          final phone = c.phones.first.number.trim();
          if (phone.isEmpty) continue;
          final normPhone = _normalise(phone);
          // Skip if already in list from registered users
          if (addedPhones.contains(normPhone)) continue;
          addedPhones.add(normPhone);
          result.add({
            'name': name,
            'phone': phone,
            'profilePicture': null,
            'isOnApp': 'false',
          });
        }
      }

      // ── 3. Sort: on-app users first, then alphabetically ─────────────────
      result.sort((a, b) {
        final aOn = a['isOnApp'] == 'true' ? 0 : 1;
        final bOn = b['isOnApp'] == 'true' ? 0 : 1;
        if (aOn != bOn) return aOn - bOn;
        return (a['name'] ?? '').compareTo(b['name'] ?? '');
      });

      if (mounted) {
        setState(() {
          _contacts = result;
          _filtered = result;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ ContactPickerSheet load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Strip non-digit characters for dedup comparison.
  String _normalise(String phone) =>
      phone.replaceAll(RegExp(r'[^\d]'), '').replaceAll(RegExp(r'^0'), '');

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double sheetHeight = MediaQuery.of(context).size.height * 0.78;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade500,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Title ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Share Contact',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.iconColor(isDark),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ── Search ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              controller: _search,
              style: TextStyle(color: AppTheme.textPrimary(isDark)),
              decoration: InputDecoration(
                hintText: 'Search by name or number...',
                hintStyle: TextStyle(color: AppTheme.textHint(isDark)),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20,
                ),
                filled: true,
                fillColor: AppTheme.inputFill(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // ── Section label ────────────────────────────────────────────────
          if (!_loading && _filtered.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filtered.length} contact${_filtered.length == 1 ? '' : 's'}',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: HexColor('#1A7F4B'),
                    ),
                  )
                : _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No contacts found',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary(isDark),
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final c = _filtered[i];
                      final name = c['name'] ?? '';
                      final phone = c['phone'] ?? '';
                      final pic = c['profilePicture'];
                      final isOnApp = c['isOnApp'] == 'true';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: HexColor('#FB8830'),
                              backgroundImage:
                                  (pic != null &&
                                      pic.isNotEmpty &&
                                      pic.startsWith('http'))
                                  ? NetworkImage(pic)
                                  : null,
                              child:
                                  (pic == null ||
                                      pic.isEmpty ||
                                      !pic.startsWith('http'))
                                  ? Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )
                                  : null,
                            ),
                            // Green dot badge if on QikTalk
                            if (isOnApp)
                              Positioned(
                                bottom: 0,
                                right: -2,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: HexColor('#1A7F4B'),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.cardBg(isDark),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          name,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary(isDark),
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          isOnApp ? '$phone · On QikTalk' : phone,
                          style: GoogleFonts.poppins(
                            color: isOnApp
                                ? HexColor('#1A7F4B')
                                : AppTheme.textSecondary(isDark),
                            fontSize: 12,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: HexColor('#1A7F4B').withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: HexColor('#1A7F4B').withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            'Send',
                            style: GoogleFonts.poppins(
                              color: HexColor('#1A7F4B'),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        onTap: () => widget.onContactSelected(name, phone, pic),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
