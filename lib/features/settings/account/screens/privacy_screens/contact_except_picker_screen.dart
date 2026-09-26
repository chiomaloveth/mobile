import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

// ── Contact model ──────────────────────────────────────────────────────────
// Defined locally so avatarUrl correctly maps 'profilePicture' from the API
// (mirrors Document 1's _Contact.fromJson field mapping exactly).

class _ExceptContact {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;

  const _ExceptContact({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });

  factory _ExceptContact.fromJson(Map<String, dynamic> json) => _ExceptContact(
        id: json['_id'] ?? json['id'] ?? '',
        name: json['username'] ?? json['fullName'] ?? json['name'] ?? 'Unknown',
        phone: json['phone'] ?? '',
        // 'profilePicture' is the real API key — same as Document 1
        avatarUrl: json['profilePicture'] ??
            json['avatar'] ??
            json['profileImage'] ??
            json['image'],
      );
}

// ── State ──────────────────────────────────────────────────────────────────

class ContactExceptState {
  final List<_ExceptContact> contacts;
  final String searchQuery;
  final bool isLoading;
  final Set<String> selectedIds;

  const ContactExceptState({
    this.contacts = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.selectedIds = const {},
  });

  List<_ExceptContact> get filtered {
    if (searchQuery.trim().isEmpty) return contacts;
    final q = searchQuery.toLowerCase();
    return contacts
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q))
        .toList();
  }

  ContactExceptState copyWith({
    List<_ExceptContact>? contacts,
    String? searchQuery,
    bool? isLoading,
    Set<String>? selectedIds,
  }) {
    return ContactExceptState(
      contacts: contacts ?? this.contacts,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────

class ContactExceptNotifier extends StateNotifier<ContactExceptState> {
  ContactExceptNotifier(Set<String> preselected)
      : super(ContactExceptState(selectedIds: Set.from(preselected))) {
    _loadContacts();
  }

  final SaveValues _saveValues = SaveValues();

  /// Mirrors Document 1's loading strategy exactly:
  /// 1. Try chat/broadcast/contacts  ← the endpoint that actually returns contacts
  /// 2. Fall back to syncContacts
  Future<void> _loadContacts() async {
    state = state.copyWith(isLoading: true);
    try {
      final token =
          await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      // ── Primary: broadcast/contacts (Document 1's working endpoint) ───
      final broadcastRes = await http.get(
        Uri.parse('${ApiStrings.baseUri}chat/broadcast/contacts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (broadcastRes.statusCode == 200) {
        final body = jsonDecode(broadcastRes.body);
        final list = body['data'] as List?;
        if (list != null && list.isNotEmpty) {
          final contacts = list
              .map((u) => _ExceptContact.fromJson(u as Map<String, dynamic>))
              .where((c) => c.id.isNotEmpty)
              .toList();
          state = state.copyWith(contacts: contacts, isLoading: false);
          return;
        }
      }

      // ── Fallback: syncContacts (Document 1's fallback) ────────────────
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
              .map((u) => _ExceptContact.fromJson(u as Map<String, dynamic>))
              .where((c) => c.id.isNotEmpty)
              .toList();
          state = state.copyWith(contacts: contacts, isLoading: false);
          return;
        }
      }
    } catch (_) {}

    state = state.copyWith(isLoading: false);
  }

  /// Filters the already-loaded list locally — instant, no extra API call.
  void setSearch(String query) => state = state.copyWith(searchQuery: query);

  void toggleContact(String id) {
    final updated = Set<String>.from(state.selectedIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(selectedIds: updated);
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final contactExceptProvider = StateNotifierProvider.family<
    ContactExceptNotifier, ContactExceptState, Set<String>>(
  (ref, preselected) => ContactExceptNotifier(preselected),
);

// ── Screen ─────────────────────────────────────────────────────────────────

/// Push this screen and await the result.
/// Returns `Set<String>` of excluded user IDs, or null if cancelled.
///
/// Usage:
/// ```dart
/// final excluded = await Navigator.push<Set<String>>(
///   context,
///   MaterialPageRoute(
///     builder: (_) => ContactExceptPickerScreen(
///       title: 'My Contacts Except...',
///       preselectedIds: currentExcludedIds,
///     ),
///   ),
/// );
/// if (excluded != null) { /* save excluded */ }
/// ```
class ContactExceptPickerScreen extends ConsumerStatefulWidget {
  final String title;
  final Set<String> preselectedIds;

  const ContactExceptPickerScreen({
    super.key,
    required this.title,
    this.preselectedIds = const {},
  });

  @override
  ConsumerState<ContactExceptPickerScreen> createState() =>
      _ContactExceptPickerScreenState();
}

class _ContactExceptPickerScreenState
    extends ConsumerState<ContactExceptPickerScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _letterKeys = {};

  late final Set<String> _providerKey;

  @override
  void initState() {
    super.initState();
    _providerKey = widget.preselectedIds;
    for (final letter in _alphabet) {
      _letterKeys[letter] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  static const List<String> _alphabet = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  ];

  Map<String, List<_ExceptContact>> get _grouped {
    final s = ref.watch(contactExceptProvider(_providerKey));
    final map = <String, List<_ExceptContact>>{};
    for (final c in s.filtered) {
      final letter = c.name.isNotEmpty ? c.name[0].toUpperCase() : '#';
      map.putIfAbsent(letter, () => []).add(c);
    }
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  void _scrollToLetter(String letter) {
    final key = _letterKeys[letter];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onDone() {
    final selected =
        ref.read(contactExceptProvider(_providerKey)).selectedIds;
    Navigator.pop(context, Set<String>.from(selected));
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final state = ref.watch(contactExceptProvider(_providerKey));
    final grouped = _grouped;
    final selectedCount = state.selectedIds.length;

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
              color: isDark ? null : AppColors.lightNavBar,
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: CustomBackButton(buildContext: context),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      color: isDark
                          ? Colors.white
                          : AppTheme.textPrimary(isDark),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (selectedCount > 0)
                    Text(
                      '$selectedCount selected',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1A7F4B),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _onDone,
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1A7F4B),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  // ── Selected chips strip ─────────────────────────────
                  if (selectedCount > 0)
                    _SelectedChipsStrip(
                      contacts: state.contacts
                          .where((c) => state.selectedIds.contains(c.id))
                          .toList(),
                      isDark: isDark,
                      onRemove: (id) => ref
                          .read(contactExceptProvider(_providerKey).notifier)
                          .toggleContact(id),
                    ),

                  // ── Search bar ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
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
                        onChanged: (v) => ref
                            .read(contactExceptProvider(_providerKey).notifier)
                            .setSearch(v),
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? Colors.white38 : Colors.black38,
                            size: 20,
                          ),
                          hintText: 'Search contacts',
                          hintStyle: GoogleFonts.poppins(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 14,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),

                  // ── Loading / List ───────────────────────────────────
                  Expanded(
                    child: state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1A7F4B),
                              strokeWidth: 2,
                            ),
                          )
                        : grouped.isEmpty
                            ? Center(
                                child: Text(
                                  'No contacts found',
                                  style: GoogleFonts.poppins(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 8, 24),
                                itemCount: grouped.length,
                                itemBuilder: (context, sectionIndex) {
                                  final letter =
                                      grouped.keys.elementAt(sectionIndex);
                                  final contacts = grouped[letter]!;
                                  return Column(
                                    key: _letterKeys[letter],
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ── Section letter header ──────
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 12, 0, 6),
                                        child: Text(
                                          letter,
                                          style: GoogleFonts.poppins(
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      // ── Flat rows with dividers (Doc 1 style) ──
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: contacts.length,
                                        separatorBuilder: (_, __) => Divider(
                                          height: 1,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.07)
                                              : Colors.black.withOpacity(0.07),
                                          indent: 68,
                                        ),
                                        itemBuilder: (context, i) {
                                          final c = contacts[i];
                                          final isSelected = state.selectedIds
                                              .contains(c.id);
                                          return _ExceptPickerTile(
                                            contact: c,
                                            isDark: isDark,
                                            isSelected: isSelected,
                                            onTap: () => ref
                                                .read(contactExceptProvider(
                                                        _providerKey)
                                                    .notifier)
                                                .toggleContact(c.id),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),

            // ── Alphabet sidebar ─────────────────────────────────────
            _AlphabetSidebar(
              alphabet: _alphabet,
              grouped: grouped,
              onLetterTap: _scrollToLetter,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Selected chips strip ───────────────────────────────────────────────────

class _SelectedChipsStrip extends StatelessWidget {
  final List<_ExceptContact> contacts;
  final bool isDark;
  final void Function(String id) onRemove;

  const _SelectedChipsStrip({
    required this.contacts,
    required this.isDark,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: contacts.length,
        itemBuilder: (context, i) {
          final c = contacts[i];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A7F4B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF1A7F4B).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  c.name,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1A7F4B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => onRemove(c.id),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Color(0xFF1A7F4B),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Picker tile ───────────────────────────────────────────────────────────
// Doc 1 style: transparent row background, avatar + name/phone + checkbox

class _ExceptPickerTile extends StatelessWidget {
  final _ExceptContact contact;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExceptPickerTile({
    required this.contact,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // ── Avatar (Doc 1: NetworkImage via backgroundImage) ───────
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade700,
              backgroundImage: contact.avatarUrl != null &&
                      contact.avatarUrl!.isNotEmpty
                  ? NetworkImage(contact.avatarUrl!)
                  : null,
              child: contact.avatarUrl == null || contact.avatarUrl!.isEmpty
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

            // ── Name + phone (Doc 1 two-line layout) ──────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (contact.phone.isNotEmpty)
                    Text(
                      contact.phone,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            // ── Animated circle checkbox (Doc 2) ──────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF1A7F4B)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1A7F4B)
                      : (isDark ? Colors.white38 : Colors.black26),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Alphabet sidebar ───────────────────────────────────────────────────────

class _AlphabetSidebar extends StatelessWidget {
  final List<String> alphabet;
  final Map<String, List<_ExceptContact>> grouped;
  final void Function(String) onLetterTap;

  const _AlphabetSidebar({
    required this.alphabet,
    required this.grouped,
    required this.onLetterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: alphabet.map((letter) {
          final hasContacts = grouped.containsKey(letter);
          return GestureDetector(
            onTap: hasContacts ? () => onLetterTap(letter) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: Text(
                letter,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: hasContacts
                      ? const Color(0xFF4CAF50)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}