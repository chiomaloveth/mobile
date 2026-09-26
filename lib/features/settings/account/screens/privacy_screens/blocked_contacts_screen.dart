import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/single_chat/screens/chat_actions_service.dart';
import 'package:qik_talk/features/settings/account/screens/privacy_screens/block_contact_picker_screen.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_config.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Model ──────────────────────────────────────────────────────────────────

class BlockedContact {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;

  const BlockedContact({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });

  factory BlockedContact.fromJson(Map<String, dynamic> json) {
    return BlockedContact(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['username'] ?? json['fullName'] ?? json['name'] ?? 'Unknown',
      phone: json['phone'] ?? '',
      avatarUrl: json['profilePicture'],
    );
  }
}

// ── State ──────────────────────────────────────────────────────────────────

class BlockedContactsState {
  final List<BlockedContact> contacts;
  final String searchQuery;
  final bool isLoading;

  const BlockedContactsState({
    this.contacts = const [],
    this.searchQuery = '',
    this.isLoading = false,
  });

  List<BlockedContact> get filtered {
    if (searchQuery.trim().isEmpty) return contacts;
    final q = searchQuery.toLowerCase();
    return contacts
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.phone.toLowerCase().contains(q),
        )
        .toList();
  }

  BlockedContactsState copyWith({
    List<BlockedContact>? contacts,
    String? searchQuery,
    bool? isLoading,
  }) {
    return BlockedContactsState(
      contacts: contacts ?? this.contacts,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BlockedContactsNotifier extends StateNotifier<BlockedContactsState> {
  BlockedContactsNotifier() : super(const BlockedContactsState()) {
    loadBlockedContacts();
  }

  final SaveValues _saveValues = SaveValues();

  Future<void> loadBlockedContacts() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.get(
        Uri.parse(ApiStrings.getUserInfo),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      List<BlockedContact> apiContacts = [];
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map) {
          final blockedUsers = body['data']['blockedUsers'] as List<dynamic>?;
          if (blockedUsers != null) {
            apiContacts = blockedUsers
                .map((u) => BlockedContact.fromJson(u as Map<String, dynamic>))
                .toList();
          }
        }
      }

      // Merge with locally blocked users from Hive (isBlocked flag)
      final chatBox = Hive.box<ChatListItemHive>('chats');
      final locallyBlockedHive = chatBox.values
          .where((c) => c.isBlocked == true && c.userId.isNotEmpty)
          .toList();

      // Also merge from SharedPreferences blocked_user_ids
      final prefs = await SharedPreferences.getInstance();
      final prefBlockedIds = prefs.getStringList('blocked_user_ids') ?? [];

      final apiIds = apiContacts.map((c) => c.id).toSet();

      // Add contacts from Hive isBlocked flag
      for (final hiveChat in locallyBlockedHive) {
        if (!apiIds.contains(hiveChat.userId)) {
          apiIds.add(hiveChat.userId);
          apiContacts.add(
            BlockedContact(
              id: hiveChat.userId,
              name: hiveChat.title,
              phone: '',
              avatarUrl: hiveChat.profilePicture.isNotEmpty
                  ? hiveChat.profilePicture
                  : null,
            ),
          );
        }
      }

      // Add contacts from SharedPreferences that aren't already in the list
      for (final blockedId in prefBlockedIds) {
        if (!apiIds.contains(blockedId)) {
          // Try to find their name from Hive
          final hiveChat = chatBox.values
              .where((c) => c.userId == blockedId)
              .firstOrNull;
          apiContacts.add(
            BlockedContact(
              id: blockedId,
              name: hiveChat?.title ?? 'Blocked User',
              phone: '',
              avatarUrl: hiveChat?.profilePicture.isNotEmpty == true
                  ? hiveChat!.profilePicture
                  : null,
            ),
          );
        }
      }

      state = state.copyWith(contacts: apiContacts, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> unblock(String userId) async {
    // Optimistic update
    state = state.copyWith(
      contacts: state.contacts.where((c) => c.id != userId).toList(),
    );
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      // Try both endpoint variants — backend may use either
      http.Response? res;
      // Hit ALL unblock endpoints in parallel — backend may use any of them
      // depending on whether the block was done from chat vs settings.
      final unblockUrls = [
        '${AppConfig.apiUrl}user/unblock',
        '${AppConfig.apiUrl}chat/unblock',
        '${AppConfig.apiUrl}users/$userId/unblock',
      ];

      for (final url in unblockUrls) {
        try {
          res = await http
              .post(
                Uri.parse(url),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'userId': userId,
                  'targetUserId': userId,
                  'blockedUserId': userId,
                }),
              )
              .timeout(const Duration(seconds: 8));
          debugPrint('🔓 UNBLOCK $url → ${res.statusCode} ${res.body}');
          // Don't break — hit ALL endpoints to ensure full unblock across both systems
        } catch (e) {
          debugPrint('🔓 UNBLOCK $url failed: $e');
        }
      }

      // Wait for backend to propagate before allowing messages
      await Future.delayed(const Duration(milliseconds: 800));
      // Clear ALL local block state BEFORE reloading so the UI never
      // sends a message while the block flag is still set locally.
      // Also call ChatActionsService.unblockUser() — this hits /chat/unblock
      // which mirrors the path used when blocking from the chat screen.
      try {
        final chatActionResult = await ChatActionsService().unblockUser(userId);
        debugPrint(
          '🔓 ChatActionsService unblock → ${chatActionResult.message}',
        );
      } catch (e) {
        debugPrint('🔓 ChatActionsService unblock error: $e');
      }

      // Remove from local prefs so chat list restores the contact
      final prefs = await SharedPreferences.getInstance();
      final blocked = prefs.getStringList('blocked_user_ids') ?? [];
      blocked.remove(userId);
      await prefs.setStringList('blocked_user_ids', blocked);

      // Clear isBlocked in Hive for every chat belonging to this user
      final chatBox = Hive.box<ChatListItemHive>('chats');
      for (final chat in chatBox.values.where((c) => c.userId == userId)) {
        await chatBox.put(chat.id, chat.copyWith(isBlocked: false));
      }

      // Give the backend a moment to propagate the unblock before we
      // allow any messages through (race condition guard).
      await Future.delayed(const Duration(milliseconds: 600));

      // Reload from server to confirm sync
      await loadBlockedContacts();
    } catch (_) {
      // Reload on failure
      await loadBlockedContacts();
    }
  }

  Future<void> block(String userId) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.post(
        Uri.parse('${ApiStrings.baseUri}user/block'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': userId}),
      );
      debugPrint('🚫 BLOCK → ${response.statusCode} ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save to prefs immediately
        final prefs = await SharedPreferences.getInstance();
        final blocked = prefs.getStringList('blocked_user_ids') ?? [];
        if (!blocked.contains(userId)) {
          blocked.add(userId);
          await prefs.setStringList('blocked_user_ids', blocked);
        }
        // Mark Hive immediately
        final chatBox = Hive.box<ChatListItemHive>('chats');
        for (final chat in chatBox.values.where((c) => c.userId == userId)) {
          await chatBox.put(chat.id, chat.copyWith(isBlocked: true));
        }
        await loadBlockedContacts();
      }
    } catch (_) {}
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final blockedContactsProvider =
    StateNotifierProvider<BlockedContactsNotifier, BlockedContactsState>(
      (ref) => BlockedContactsNotifier(),
    );

// ── Screen ─────────────────────────────────────────────────────────────────

class BlockedContactsScreen extends ConsumerStatefulWidget {
  const BlockedContactsScreen({super.key});

  @override
  ConsumerState<BlockedContactsScreen> createState() =>
      _BlockedContactsScreenState();
}

class _BlockedContactsScreenState extends ConsumerState<BlockedContactsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Always reload fresh when screen opens — catches blocks done from chat screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blockedContactsProvider.notifier).loadBlockedContacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmUnblock(BlockedContact contact) {
    showDialog(
      context: context,
      builder: (ctx) {
        final bool isDarkDialog =
            Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppTheme.cardBg(isDarkDialog),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'Unblock ${contact.name}?',
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary(isDarkDialog),
              fontSize: 16,
            ),
          ),
          content: Text(
            '${contact.name} will be able to call you and send you messages.',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary(isDarkDialog),
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary(isDarkDialog),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(blockedContactsProvider.notifier).unblock(contact.id);
              },
              child: Text(
                'Unblock',
                style: GoogleFonts.poppins(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final state = ref.watch(blockedContactsProvider);
    final filtered = state.filtered;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppColors.lightNavBar,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
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
                'Blocked Contacts',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    // Search bar
                    Container(
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
                            .read(blockedContactsProvider.notifier)
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
                          hintText: 'Search blocked contacts',
                          hintStyle: GoogleFonts.poppins(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Contacts list
                    if (filtered.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C1C1E)
                              : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: isDark
                                ? Colors.white.withOpacity(0.07)
                                : Colors.black.withOpacity(0.07),
                            indent: 72,
                          ),
                          itemBuilder: (context, index) {
                            final contact = filtered[index];
                            return _ContactTile(
                              contact: contact,
                              isDark: isDark,
                              onUnblock: () => _confirmUnblock(contact),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Block New Contact button
                    GestureDetector(
                      onTap: () async {
                        final userId = await Navigator.of(context).push<String>(
                          MaterialPageRoute(
                            builder: (_) => const BlockContactPickerScreen(),
                          ),
                        );
                        if (userId != null && mounted) {
                          await ref
                              .read(blockedContactsProvider.notifier)
                              .block(userId);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C1C1E)
                              : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add,
                              color: Color(0xFFD4A017),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Block New Contact',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFD4A017),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Footer note
                    Text(
                      'Blocked contacts cannot call you or send you messages.',
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── Contact tile ───────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  final BlockedContact contact;
  final bool isDark;
  final VoidCallback onUnblock;

  const _ContactTile({
    required this.contact,
    required this.isDark,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade700,
            backgroundImage:
                contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
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
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
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
          GestureDetector(
            onTap: onUnblock,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFB71C1C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Unblock',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
