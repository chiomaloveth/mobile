import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/settings/account/screens/privacy_screens/blocked_contacts_screen.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

// ── State ──────────────────────────────────────────────────────────────────

class ContactPickerState {
  final List<BlockedContact> contacts;
  final String searchQuery;
  final bool isLoading;

  const ContactPickerState({
    this.contacts = const [],
    this.searchQuery = '',
    this.isLoading = false,
  });

  List<BlockedContact> get filtered {
    if (searchQuery.trim().isEmpty) return contacts;
    final q = searchQuery.toLowerCase();
    return contacts
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q))
        .toList();
  }

  ContactPickerState copyWith({
    List<BlockedContact>? contacts,
    String? searchQuery,
    bool? isLoading,
  }) {
    return ContactPickerState(
      contacts: contacts ?? this.contacts,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ContactPickerNotifier extends StateNotifier<ContactPickerState> {
  ContactPickerNotifier() : super(const ContactPickerState()) {
    _loadContacts();
  }

  final SaveValues _saveValues = SaveValues();

  Future<void> _loadContacts() async {
    state = state.copyWith(isLoading: true);
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
              .map((u) => BlockedContact.fromJson(u as Map<String, dynamic>))
              .where((c) => c.id.isNotEmpty)
              .toList();
          state = state.copyWith(contacts: contacts, isLoading: false);
          return;
        }
      }

      // Fallback: sync-contacts with empty array
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
              .map((u) => BlockedContact.fromJson(u as Map<String, dynamic>))
              .where((c) => c.id.isNotEmpty)
              .toList();
          state = state.copyWith(contacts: contacts, isLoading: false);
          return;
        }
      }

      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      await _loadContacts();
      return;
    }
    
    state = state.copyWith(isLoading: true);
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.post(
        Uri.parse('${ApiStrings.baseUri}user/search'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'query': query}),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['_id'] != null) {
          // Single user response
          final contact = BlockedContact.fromJson(body as Map<String, dynamic>);
          state = state.copyWith(contacts: [contact], isLoading: false);
        } else if (body is List) {
          // Multiple users response
          final contacts = body
              .map((u) => BlockedContact.fromJson(u as Map<String, dynamic>))
              .toList();
          state = state.copyWith(contacts: contacts, isLoading: false);
        } else {
          state = state.copyWith(isLoading: false);
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final contactPickerProvider =
    StateNotifierProvider<ContactPickerNotifier, ContactPickerState>(
        (ref) => ContactPickerNotifier());

// ── Screen ─────────────────────────────────────────────────────────────────

class BlockContactPickerScreen extends ConsumerStatefulWidget {
  const BlockContactPickerScreen({super.key});

  @override
  ConsumerState<BlockContactPickerScreen> createState() =>
      _BlockContactPickerScreenState();
}

class _BlockContactPickerScreenState
    extends ConsumerState<BlockContactPickerScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _letterKeys = {};

  String? _selectedId;

  @override
  void initState() {
    super.initState();
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

  Map<String, List<BlockedContact>> get _grouped {
    final state = ref.watch(contactPickerProvider);
    final filtered = state.filtered;
    final map = <String, List<BlockedContact>>{};
    for (final c in filtered) {
      final letter =
          c.name.isNotEmpty ? c.name[0].toUpperCase() : '#';
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

  void _onBlock() {
    if (_selectedId == null) return;
    Navigator.pop(context, _selectedId);
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final state = ref.watch(contactPickerProvider);
    final grouped = _grouped;
    final hasSelection = _selectedId != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightNavBar,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor:
            isDark ? Color(AppColors.primaryBackgroundColor) : AppColors.lightNavBar,
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
              color: isDark ? null : AppColors.lightNavBar,
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: CustomBackButton(buildContext: context),
              title: Text(
                'Block Contact',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: hasSelection ? _onBlock : null,
                  child: Text(
                    'Block',
                    style: GoogleFonts.poppins(
                      color: hasSelection
                          ? Colors.white
                          : Colors.white38,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  // Main list
                  Expanded(
                    child: Column(
                      children: [
                        // Search bar
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
                                  .read(contactPickerProvider.notifier)
                                  .setSearch(v),
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                    size: 20),
                                hintText: 'Search names or numbers',
                                hintStyle: GoogleFonts.poppins(
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                  fontSize: 14,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        // Grouped list
                        Expanded(
                          child: grouped.isEmpty
                              ? Center(
                                  child: Text(
                                    'No contacts found',
                                    style: GoogleFonts.poppins(
                                      color: isDark ? Colors.white54 : Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.only(bottom: 20),
                                  itemCount: grouped.length,
                                  itemBuilder: (context, sectionIndex) {
                                    final letter =
                                        grouped.keys.elementAt(sectionIndex);
                                    final contacts = grouped[letter]!;
                                    return Column(
                                      key: _letterKeys[letter],
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 12, 16, 6),
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
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF1C1C1E)
                                                : const Color(0xFFF2F2F7),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: contacts.length,
                                            separatorBuilder: (_, __) => Divider(
                                              height: 1,
                                              color: isDark
                                                  ? Colors.white
                                                      .withOpacity(0.07)
                                                  : Colors.black
                                                      .withOpacity(0.07),
                                              indent: 68,
                                            ),
                                            itemBuilder: (context, i) {
                                              final c = contacts[i];
                                              final isSelected =
                                                  _selectedId == c.id;
                                              return _PickerTile(
                                                contact: c,
                                                isDark: isDark,
                                                isSelected: isSelected,
                                                onTap: () => setState(
                                                    () => _selectedId = c.id),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  // Alphabet sidebar
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

// ── Picker tile ────────────────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  final BlockedContact contact;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickerTile({
    required this.contact,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade700,
              backgroundImage: contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
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
                          fontSize: 16),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                contact.name,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Radio circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD4A017)
                      : (isDark ? Colors.white38 : Colors.black26),
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFFD4A017)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check,
                      color: Colors.white, size: 14)
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
  final Map<String, List<BlockedContact>> grouped;
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
