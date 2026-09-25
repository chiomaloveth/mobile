import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/chat/single_chat/screens/message_screen.dart';
import 'package:qik_talk/features/contact/components/contact_sync_provider.dart';
import 'package:qik_talk/features/contact/services/contact_sync_service.dart';
import 'package:qik_talk/utilities/bottom_nav/screen/custom_bottom_nav.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contact_screen extends ConsumerStatefulWidget {
  final List<Contact> contacts;

  const Contact_screen({required this.contacts});

  @override
  ConsumerState<Contact_screen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends ConsumerState<Contact_screen> {
  String message = "";
  bool _isChecking = false;
  String chatId = "";
  SaveValues mySaveValues = SaveValues();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _gridScrollController = ScrollController();

  // One GlobalKey per letter — used to scroll-to reliably
  final Map<String, GlobalKey> _sectionKeys = {};

  static const List<String> _alphabetLetters = [
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

  @override
  void initState() {
    super.initState();
    for (final letter in _alphabetLetters) {
      _sectionKeys[letter] = GlobalKey();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactSyncProvider.notifier).setAllContacts(widget.contacts);
      // ── Step 1: Load cached users instantly (no network) ─────────────────
      _loadCachedRegisteredUsers().then((_) {
        // ── Step 2: Refresh in background silently ──────────────────────────
        _syncContacts();
      });
    });
  }

  /// Load previously synced registered users from SharedPreferences.
  /// Makes contacts screen open instantly without any network call.
  Future<void> _loadCachedRegisteredUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cached_registered_users');
      if (raw == null || raw.isEmpty) return;

      final List<dynamic> parsed = jsonDecode(raw);
      final users = parsed
          .map((u) {
            final map = u as Map<String, dynamic>;
            return RegisteredUser(
              id: map['id'] as String? ?? '',
              username: map['username'] as String? ?? '',
              phone: map['phone'] as String? ?? '',
              profilePicture: map['profilePicture'] as String?,
              about: map['about'] as String?,
              isOnline: map['isOnline'] as bool?,
              lastActive: map['lastActive'] as String?,
            );
          })
          .where((u) => u.id.isNotEmpty)
          .toList();

      if (users.isNotEmpty) {
        ref.read(contactSyncProvider.notifier).injectCachedUsers(users);
        debugPrint('✅ Contacts screen: loaded ${users.length} cached users');
      }
    } catch (e) {
      debugPrint('❌ _loadCachedRegisteredUsers: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  Future<void> _syncContacts() async {
    await ref.read(contactSyncProvider.notifier).syncContacts();
    // ── Save fresh results to cache for next offline visit ─────────────────
    _saveRegisteredUsersToCache();
  }

  Future<void> _saveRegisteredUsersToCache() async {
    try {
      final state = ref.read(contactSyncProvider);
      if (state.registeredUsers.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(
        state.registeredUsers
            .map(
              (u) => {
                'id': u.id,
                'username': u.username,
                'phone': u.phone,
                'profilePicture': u.profilePicture ?? '',
                'about': u.about ?? '',
                'isOnline': u.isOnline ?? false,
                'lastActive': u.lastActive ?? '',
              },
            )
            .toList(),
      );
      await prefs.setString('cached_registered_users', data);
      debugPrint('✅ Saved ${state.registeredUsers.length} users to cache');
    } catch (e) {
      debugPrint('❌ _saveRegisteredUsersToCache: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Scroll to a letter section via its GlobalKey
  // ---------------------------------------------------------------------------
  void _scrollToLetter(String letter) {
    print('🔍 Attempting to scroll to letter: $letter');

    final key = _sectionKeys[letter];
    if (key == null) {
      print('⚠️ No key created for $letter');
      return;
    }

    // Wait for the next frame to ensure the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key.currentContext != null) {
        print('✅ Found section for $letter, scrolling...');
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      } else {
        print('⚠️ No context for $letter - section may not exist in contacts');
      }
    });
  }

  // ---------------------------------------------------------------------------
  String formatFriendlyTime(DateTime dateTime) {
    final now = DateTime.now();
    final localTime = dateTime.toLocal();
    final timeFormatted = DateFormat('hh:mm a').format(localTime);

    if (localTime.year == now.year &&
        localTime.month == now.month &&
        localTime.day == now.day) {
      return "Today at $timeFormatted";
    }

    final yesterday = now.subtract(Duration(days: 1));
    if (localTime.year == yesterday.year &&
        localTime.month == yesterday.month &&
        localTime.day == yesterday.day) {
      return "Yesterday at $timeFormatted";
    }

    return "${DateFormat('dd MMM').format(localTime)} at $timeFormatted";
  }

  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return ApiStrings.baseUriImage + imageUrl;
  }

  // ---------------------------------------------------------------------------
  // Build flat grouped list: [String header, Contact, Contact, ...]
  // ---------------------------------------------------------------------------
  List<Object> _buildGroupedContactList(List<Contact> contacts) {
    final sorted = List<Contact>.from(contacts);
    sorted.sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );

    final List<Object> items = [];
    String currentLetter = '';
    Set<String> sectionsCreated = {};

    for (final contact in sorted) {
      final name = contact.displayName.trim();
      if (name.isEmpty) continue;

      final firstChar = name[0].toUpperCase();
      final sectionLetter = firstChar.contains(RegExp(r'[A-Z]'))
          ? firstChar
          : '#';

      if (sectionLetter != currentLetter) {
        currentLetter = sectionLetter;
        items.add(currentLetter);
        sectionsCreated.add(currentLetter);
      }
      items.add(contact);
    }

    print('📑 Sections created: ${sectionsCreated.join(", ")}');
    return items;
  }

  // ---------------------------------------------------------------------------
  // Chat logic
  // ---------------------------------------------------------------------------
  Future<void> accessNewChatWithRegisteredUser(RegisteredUser user) async {
    String? token = await mySaveValues.getString(
      AppPreferenceHelper.AUTH_TOKEN,
    );
    final String apiUrl = ApiStrings.accessNewChat;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(<String, dynamic>{"phone": user.phone}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final chatIdValue = responseData['_id'];
        if (chatIdValue == null) throw Exception('Chat ID not found');
        chatId = chatIdValue.toString();

        final otherUser = responseData['otherUser'];

        String otherUserId = '';
        if (otherUser != null && otherUser['_id'] != null) {
          otherUserId = otherUser['_id'].toString();
        }

        String username = user.username;
        if (otherUser != null && otherUser['username'] != null) {
          username = otherUser['username'].toString();
        }
        if (username.isEmpty) username = 'Unknown User';

        String about = user.about ?? 'Hey there! I am using QikTalk.';
        if (otherUser != null && otherUser['about'] != null) {
          about = otherUser['about'].toString();
        }
        if (about.isEmpty) about = 'Hey there! I am using QikTalk.';

        String profilePicture = user.profilePicture ?? '';
        if (otherUser != null && otherUser['profilePicture'] != null) {
          profilePicture = otherUser['profilePicture'].toString();
        }
        profilePicture = _getFullImageUrl(profilePicture);

        String lastActiveStr = DateTime.now().toIso8601String();
        if (otherUser != null && otherUser['lastActive'] != null) {
          lastActiveStr = otherUser['lastActive'].toString();
        } else if (user.lastActive != null) {
          lastActiveStr = user.lastActive!;
        }

        DateTime lastActive;
        try {
          lastActive = DateTime.parse(lastActiveStr);
        } catch (e) {
          lastActive = DateTime.now();
        }

        if (chatId.isEmpty) throw Exception('Invalid chat ID');
        if (otherUserId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Could not get user information')),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MessageScreen(
              chatId: chatId,
              userId: otherUserId,
              username: username,
              about: about,
              profilePicture: profilePicture,
              lastSeenActive: formatFriendlyTime(lastActive),
            ),
          ),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        message = errorData['message'] ?? 'Unknown error occurred';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error occurred. Please try again.")),
      );
    }
  }

  void _showInviteDialog(String phoneNumber, String contactName) {
    showDialog(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppTheme.cardBg(isDark),
          title: Text(
            "Invite to Qiktalk",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18.0),
          ),
          content: Text(
            "$contactName is not on Qiktalk yet. Would you like to invite them?",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14.0),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Invite feature coming soon!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor("#FF6B00"),
              ),
              child: Text(
                "Invite",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final contactState = ref.watch(contactSyncProvider);
    final contactNotifier = ref.read(contactSyncProvider.notifier);

    final int registeredCount = contactState.registeredUsers.length;
    final int totalCount = contactState.filteredContacts.length;

    return PopScope(
      onPopInvoked: (didPop) async {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => CustomBottomNav()));
      },
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        body: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/app_bar_gredient.png"),
                  fit: BoxFit.cover,
                ),
                color: HexColor("#3A1D07"),
              ),
              padding: EdgeInsets.only(
                top: statusBarHeight + 14,
                left: 20,
                right: 20,
                bottom: 18,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CustomBottomNav()),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "New Chat",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$registeredCount/$totalCount",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              // Show main content immediately — cached users populate it instantly.
              // Only show error if we have no data at all.
              child:
                  contactState.errorMessage != null &&
                      contactState.registeredUsers.isEmpty &&
                      !contactState.isSyncing
                  ? _buildErrorState(contactState)
                  : _buildMainContent(contactState, contactNotifier),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildSyncingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: HexColor("#FF6B00")),
          const SizedBox(height: 20),
          Text(
            "Syncing contacts...",
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary(
                Theme.of(context).brightness == Brightness.dark,
              ),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ContactSyncState contactState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          Text(
            "Error syncing contacts",
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary(
                Theme.of(context).brightness == Brightness.dark,
              ),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              contactState.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _syncContacts,
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor("#FF6B00"),
            ),
            child: Text(
              "Retry",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN CONTENT
  // ---------------------------------------------------------------------------
  Widget _buildMainContent(
    ContactSyncState contactState,
    ContactSyncNotifier contactNotifier,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    Map<String, RegisteredUser> registeredUsersMap = {};
    for (var user in contactState.registeredUsers) {
      registeredUsersMap[user.phone] = user;
    }

    print('📊 Registered Users Map:');
    print('   Total registered: ${registeredUsersMap.length}');
    registeredUsersMap.forEach((phone, user) {
      print('   $phone → ${user.username}');
    });

    final displayContacts = contactState.filteredContacts;
    final groupedItems = _buildGroupedContactList(displayContacts);
    final recentChats = contactState.registeredUsers.take(8).toList();

    return Column(
      children: [
        // ── Search Bar ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary(
                Theme.of(context).brightness == Brightness.dark,
              ),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Search names or numbers',
              hintStyle: GoogleFonts.poppins(
                color: AppTheme.textHint(
                  Theme.of(context).brightness == Brightness.dark,
                ),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 20,
              ),
              filled: true,
              fillColor: HexColor("#2A2A2A"),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: HexColor("#FF6B00"), width: 1.5),
              ),
              suffixIcon: contactState.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.grey,
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        contactNotifier.clearSearch();
                        _searchFocusNode.unfocus();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              contactNotifier.updateSearchQuery(value);
            },
          ),
        ),

        // ── Recent Chats ─────────────────────────────────────────────
        if (contactState.searchQuery.isEmpty && recentChats.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recent Chats",
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(
                      Theme.of(context).brightness == Brightness.dark,
                    ),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 82,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentChats.length,
                    itemBuilder: (ctx, i) {
                      final user = recentChats[i];
                      final imgUrl = _getFullImageUrl(user.profilePicture);
                      return Padding(
                        padding: EdgeInsets.only(
                          right: i < recentChats.length - 1 ? 16 : 0,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            print('🎯 Recent chat tapped: ${user.username}');
                            setState(() => _isChecking = true);
                            try {
                              await accessNewChatWithRegisteredUser(user);
                            } catch (e) {
                              print('❌ Error opening recent chat: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            } finally {
                              setState(() => _isChecking = false);
                            }
                          },
                          child: SizedBox(
                            width: 62,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 27,
                                  backgroundColor: HexColor("#FF6B00"),
                                  backgroundImage: imgUrl.isNotEmpty
                                      ? NetworkImage(imgUrl)
                                      : null,
                                  child: imgUrl.isEmpty
                                      ? Text(
                                          user.username.isNotEmpty
                                              ? user.username[0].toUpperCase()
                                              : '?',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  user.username,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textPrimary(
                                      Theme.of(context).brightness ==
                                          Brightness.dark,
                                    ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        // ── Grid + A-Z Sidebar ─────────────────────────────────────────
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Scrollable grid ────────────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _syncContacts,
                  color: HexColor("#FF6B00"),
                  child: ListView.builder(
                    controller: _gridScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: groupedItems.length,
                    itemBuilder: (context, index) {
                      final item = groupedItems[index];

                      // ── Section letter header ────────────────────────
                      if (item is String) {
                        final key = _sectionKeys[item];
                        return Padding(
                          key: key,
                          padding: EdgeInsets.fromLTRB(
                            0,
                            index == 0 ? 18 : 14,
                            0,
                            10,
                          ),
                          child: Center(
                            child: Text(
                              item,
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary(
                                  Theme.of(context).brightness ==
                                      Brightness.dark,
                                ),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }

                      // ── Contact grid row ───────────────────────────
                      int sectionStart = 0;
                      for (int i = index; i >= 0; i--) {
                        if (groupedItems[i] is String) {
                          sectionStart = i + 1;
                          break;
                        }
                      }
                      int posInSection = index - sectionStart;

                      if (posInSection % 4 != 0) {
                        return const SizedBox.shrink();
                      }

                      List<Contact> rowContacts = [];
                      for (
                        int i = index;
                        i < groupedItems.length && rowContacts.length < 4;
                        i++
                      ) {
                        if (groupedItems[i] is String) break;
                        rowContacts.add(groupedItems[i] as Contact);
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                        child: Row(
                          children: List.generate(4, (col) {
                            if (col >= rowContacts.length) {
                              return const Expanded(child: SizedBox());
                            }
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: col < 3 ? 6 : 0,
                                ),
                                child: _buildContactCard(
                                  rowContacts[col],
                                  registeredUsersMap,
                                  isDark,
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── A–Z sidebar ──────────────────────────────────────────
              // LayoutBuilder reads the exact available height from the
              // stretched Row.  Each letter slot = totalH / 26.
              // Children sum to exactly totalH → zero overflow.
              if (contactState.searchQuery.isEmpty)
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    final double totalH = constraints.maxHeight;
                    final double perLetter = totalH / _alphabetLetters.length;
                    final double fontSize = (perLetter * 0.62).clamp(7, 11);

                    return SizedBox(
                      width: 18,
                      height: totalH,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _alphabetLetters.map((letter) {
                          return GestureDetector(
                            onTap: () => _scrollToLetter(letter),
                            child: SizedBox(
                              width: 18,
                              height: perLetter,
                              child: Center(
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    color: HexColor("#4CAF50"),
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Contact card
  // ---------------------------------------------------------------------------
  Widget _buildContactCard(
    Contact contact,
    Map<String, RegisteredUser> registeredUsersMap,
    bool isDark,
  ) {
    String? phoneNumber;
    if (contact.phones.isNotEmpty) {
      phoneNumber = ContactSyncService().standardizePhoneNumber(
        contact.phones.first.number,
      );
    }

    RegisteredUser? registeredUser;
    bool isRegistered = false;
    if (phoneNumber != null) {
      registeredUser = registeredUsersMap[phoneNumber];
      isRegistered = registeredUser != null;
    }

    String profilePicUrl = '';
    if (isRegistered && registeredUser?.profilePicture != null) {
      profilePicUrl = _getFullImageUrl(registeredUser!.profilePicture);
    }
    final hasProfilePicture = profilePicUrl.isNotEmpty;

    final Color ringColor = isRegistered
        ? HexColor("#F5C518")
        : Colors.grey.shade600;

    // Debug logging
    print('📱 Contact: ${contact.displayName}');
    print('   Phone: $phoneNumber');
    print('   Is Registered: $isRegistered');
    if (isRegistered && registeredUser != null) {
      print('   Registered User: ${registeredUser.username}');
      print('   User ID: ${registeredUser.id}');
    }

    return GestureDetector(
      onTap: () async {
        print('🔘 Tapped: ${contact.displayName}');

        if (phoneNumber == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No phone number found for this contact")),
          );
          return;
        }

        print('   Phone: $phoneNumber');
        print('   Is Registered: $isRegistered');

        if (isRegistered && registeredUser != null) {
          print(
            '✅ Opening chat with registered user: ${registeredUser.username}',
          );
          setState(() => _isChecking = true);
          try {
            await accessNewChatWithRegisteredUser(registeredUser);
          } catch (e) {
            print('❌ Error opening chat: $e');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          } finally {
            setState(() => _isChecking = false);
          }
        } else {
          print('⚠️ Showing invite dialog - user not registered');
          _showInviteDialog(phoneNumber, contact.displayName);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 2.5),
              ),
              child: ClipOval(
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: HexColor("#333333"),
                  backgroundImage: hasProfilePicture
                      ? NetworkImage(profilePicUrl)
                      : null,
                  child: !hasProfilePicture
                      ? Text(
                          contact.displayName.isNotEmpty
                              ? contact.displayName[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              contact.displayName,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary(isDark),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
