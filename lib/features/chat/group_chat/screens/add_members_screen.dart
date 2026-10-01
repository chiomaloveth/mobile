import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_api_service.dart';
import 'package:qik_talk/features/contact/services/contact_sync_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AddMembersScreen — Figma-exact UI
// Opens device contacts, shows QikTalk users, lets admin select & add to group
// ─────────────────────────────────────────────────────────────────────────────

class AddMembersScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const AddMembersScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final SaveValues _saveValues = SaveValues();
  final ContactSyncService _syncService = ContactSyncService();
  final GroupApiService _groupApi = GroupApiService();
  final GlobalSocketService _globalSocket = GlobalSocketService();
  final TextEditingController _searchCtrl = TextEditingController();

  // All device contacts (registered on QikTalk only)
  List<_ContactEntry> _contacts = [];
  // Selected user IDs
  final Set<String> _selectedIds = {};
  // Map id → entry for quick lookup
  final Map<String, _ContactEntry> _selectedEntries = {};

  bool _loading = true;
  bool _adding = false;
  String _searchQuery = '';
  String? _error;
  String? _currentUserId;

  static const int _maxSelect = 580;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Load contacts ──────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _currentUserId = await _saveValues.getString(AppPreferenceHelper.ID);

      final granted = await FlutterContacts.requestPermission(readonly: true);
      if (!granted) {
        setState(() {
          _loading = false;
          _error = 'Contact permission denied.\nPlease enable it in Settings.';
        });
        return;
      }

      final rawContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Collect all phone numbers to sync
      final phones = <String>[];
      for (final c in rawContacts) {
        for (final p in c.phones) {
          phones.add(_syncService.standardizePhoneNumber(p.number));
        }
      }

      final sync = await _syncService.syncContactsWithBackend(phones);

      // Build phone → RegisteredUser map
      final regMap = <String, RegisteredUser>{};
      for (final u in sync.registeredUsers) {
        regMap[u.phone] = u;
      }

      // Build entries — only contacts on QikTalk, sorted alphabetically
      final entries = <_ContactEntry>[];
      final seen = <String>{};
      for (final c in rawContacts) {
        for (final p in c.phones) {
          final std = _syncService.standardizePhoneNumber(p.number);
          final user = regMap[std];
          if (user != null && !seen.contains(user.id)) {
            seen.add(user.id);
            entries.add(
              _ContactEntry(
                id: user.id,
                name: c.displayName.isNotEmpty ? c.displayName : user.username,
                phone: std,
                profilePicture: user.profilePicture,
                isOnline: user.isOnline ?? false,
              ),
            );
          }
        }
      }
      entries.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      if (mounted) {
        setState(() {
          _contacts = entries;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load contacts:\n$e';
        });
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _imgUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

  List<_ContactEntry> get _displayed {
    if (_searchQuery.isEmpty) return _contacts;
    final q = _searchQuery.toLowerCase();
    return _contacts
        .where((c) => c.name.toLowerCase().contains(q) || c.phone.contains(q))
        .toList();
  }

  // Group displayed contacts by first letter for section headers
  List<Object> get _grouped {
    final items = <Object>[];
    String current = '';
    for (final c in _displayed) {
      final first = c.name.isNotEmpty ? c.name[0].toUpperCase() : '#';
      final letter = RegExp(r'[A-Z]').hasMatch(first) ? first : '#';
      if (letter != current) {
        current = letter;
        items.add(letter);
      }
      items.add(c);
    }
    return items;
  }

  void _toggle(_ContactEntry entry) {
    setState(() {
      if (_selectedIds.contains(entry.id)) {
        _selectedIds.remove(entry.id);
        _selectedEntries.remove(entry.id);
      } else {
        if (_selectedIds.length >= _maxSelect) return;
        _selectedIds.add(entry.id);
        _selectedEntries[entry.id] = entry;
      }
    });
  }

  Future<void> _addSelected() async {
    if (_selectedIds.isEmpty || _adding) return;
    setState(() => _adding = true);

    int ok = 0;
    for (final id in _selectedIds) {
      try {
        final res = await _groupApi.addUserToGroup(
          groupId: widget.groupId,
          userId: id,
        );
        if (res?.success == true) {
          ok++;
          _globalSocket.emit('group updated', {
            'groupId': widget.groupId,
            'action': 'member_added',
            'userId': id,
            'addedBy': _currentUserId,
          });
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _adding = false);

    if (ok > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok == 1
                ? '${_selectedEntries.values.first.name} added to ${widget.groupName}'
                : '$ok members added to ${widget.groupName}',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: HexColor('#1A7F4B'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add members. Please try again.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final grouped = _grouped;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(
        Theme.of(context).brightness == Brightness.dark,
      ),
      body: Column(
        children: [
          // ── App Bar (Figma exact) ─────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('images/app_bar_gredient.png'),
                fit: BoxFit.cover,
              ),
              color: const Color(0xFF3A1D07),
            ),
            padding: EdgeInsets.only(
              top: topPad + 14,
              left: 16,
              right: 16,
              bottom: 18,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add People',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_selectedIds.length}/${_contacts.length}',
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Add button — only shown when contacts selected
                if (_selectedIds.isNotEmpty)
                  GestureDetector(
                    onTap: _adding ? null : _addSelected,
                    child: _adding
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Add',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
              ],
            ),
          ),

          // ── Selected chips row ────────────────────────────────────────────
          if (_selectedIds.isNotEmpty)
            Container(
              color: AppTheme.cardBg(
                Theme.of(context).brightness == Brightness.dark,
              ),
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedEntries.length,
                itemBuilder: (_, i) {
                  final entry = _selectedEntries.values.toList()[i];
                  final img = _imgUrl(entry.profilePicture);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: HexColor('#FF6B00'),
                          backgroundImage: img.isNotEmpty
                              ? NetworkImage(img)
                              : null,
                          child: img.isEmpty
                              ? Text(
                                  entry.name.isNotEmpty
                                      ? entry.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: -2,
                          top: -2,
                          child: GestureDetector(
                            onTap: () => _toggle(entry),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF3B30),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search names or numbers',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white38,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.white38,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

          // ── New Contact row ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_outlined,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
                title: Text(
                  'New Contact',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {}, // placeholder
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Frequently contacted label ─────────────────────────────────
          if (_searchQuery.isEmpty && _contacts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Frequently contacted',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Horizontal frequent row (first 6 registered contacts)
            SizedBox(
              height: 82,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: _contacts.take(6).length,
                itemBuilder: (_, i) {
                  final entry = _contacts[i];
                  final img = _imgUrl(entry.profilePicture);
                  final selected = _selectedIds.contains(entry.id);
                  return GestureDetector(
                    onTap: () => _toggle(entry),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 27,
                                backgroundColor: HexColor('#FF6B00'),
                                backgroundImage: img.isNotEmpty
                                    ? NetworkImage(img)
                                    : null,
                                child: img.isEmpty
                                    ? Text(
                                        entry.name.isNotEmpty
                                            ? entry.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      )
                                    : null,
                              ),
                              if (selected)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: HexColor('#1A7F4B'),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF141414),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                )
                              else if (entry.isOnline)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: HexColor('#1A7F4B'),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF141414),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            entry.name.split(' ').first,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ── Contacts list with A-Z sidebar ────────────────────────────────
          Expanded(
            child: _loading && _contacts.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      color: HexColor('#1A7F4B'),
                      strokeWidth: 2,
                    ),
                  )
                : _error != null && _contacts.isEmpty
                ? _buildError()
                : _contacts.isEmpty
                ? Center(
                    child: Text(
                      'No QikTalk contacts found',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 15,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      // Main scrollable list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 8, 20),
                          itemCount: grouped.length,
                          itemBuilder: (_, i) {
                            final item = grouped[i];

                            if (item is String) {
                              // Section letter header
                              return Padding(
                                padding: EdgeInsets.only(
                                  top: i == 0 ? 8 : 16,
                                  bottom: 6,
                                ),
                                child: Text(
                                  item,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }

                            final entry = item as _ContactEntry;
                            final img = _imgUrl(entry.profilePicture);
                            final selected = _selectedIds.contains(entry.id);

                            return GestureDetector(
                              onTap: () => _toggle(entry),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? HexColor('#1A7F4B').withOpacity(0.12)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  children: [
                                    // Avatar with online dot
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundColor: HexColor('#2A2A2A'),
                                          backgroundImage: img.isNotEmpty
                                              ? NetworkImage(img)
                                              : null,
                                          child: img.isEmpty
                                              ? Text(
                                                  entry.name.isNotEmpty
                                                      ? entry.name[0]
                                                            .toUpperCase()
                                                      : '?',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        if (entry.isOnline)
                                          Positioned(
                                            right: 1,
                                            bottom: 1,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: HexColor('#1A7F4B'),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF141414,
                                                  ),
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 14),
                                    // Name
                                    Expanded(
                                      child: Text(
                                        entry.name,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Checkbox circle (Figma style)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selected
                                            ? HexColor('#1A7F4B')
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: selected
                                              ? HexColor('#1A7F4B')
                                              : Colors.white38,
                                          width: 2,
                                        ),
                                      ),
                                      child: selected
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 14,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // A-Z sidebar
                      if (_searchQuery.isEmpty) _buildAlphabetSidebar(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlphabetSidebar() {
    const letters = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
    ];
    return Container(
      width: 18,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final perLetter = constraints.maxHeight / letters.length;
          final fontSize = (perLetter * 0.6).clamp(7.0, 11.0);
          return Column(
            children: letters.map((l) {
              return GestureDetector(
                onTap: () {
                  /* scroll to letter — optional enhancement */
                },
                child: SizedBox(
                  height: perLetter,
                  child: Center(
                    child: Text(
                      l,
                      style: TextStyle(
                        color: HexColor('#1A7F4B'),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 56),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor('#1A7F4B'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _ContactEntry {
  final String id;
  final String name;
  final String phone;
  final String? profilePicture;
  final bool isOnline;

  const _ContactEntry({
    required this.id,
    required this.name,
    required this.phone,
    this.profilePicture,
    this.isOnline = false,
  });
}
