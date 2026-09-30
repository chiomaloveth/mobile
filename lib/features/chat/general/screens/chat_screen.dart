import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/ai/screens/ai_chat_screen.dart';
import 'package:qik_talk/features/ai/screens/ai_onboarding_screen.dart';
import 'package:qik_talk/features/authentication/login/components/create_login_details_dialog.dart';
import 'package:qik_talk/features/broadcast/components/broadcast_component.dart';
import 'package:qik_talk/features/broadcast/screens/create_broadcast_list_screen.dart';
import 'package:qik_talk/features/chat/general/model/chat_count_model.dart';
import 'package:qik_talk/features/chat/general/model/get_chat_model.dart';
import 'package:qik_talk/features/chat/general/screens/archived_chats_screen.dart';
import 'package:qik_talk/features/chat/general/screens/global_search_screen.dart';
// Finance/family group type selection is temporarily disabled.
// import 'package:qik_talk/features/chat/group_chat/screens/group_type_selection_screen.dart';
import 'package:qik_talk/features/settings/account/screens/add_profile_info/screens/edit_profile_screen.dart';
import 'package:qik_talk/features/chat/general/screens/starred_messages_screen.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/features/chat/general/services/rest_api_services/chat_count_api_services.dart';
import 'package:qik_talk/features/chat/group_chat/components/group_component.dart';
import 'package:qik_talk/features/chat/group_chat/screens/create_new_group_screen.dart';
import 'package:qik_talk/features/chat/single_chat/components/chat_component.dart';
import 'package:qik_talk/features/chat/single_chat/screens/friend_requests_screen.dart';
import 'package:qik_talk/features/community/components/communities_component.dart';
import 'package:qik_talk/features/community/screens/create_new_community_screen.dart';
import 'package:qik_talk/features/contact/screens/contact_screen.dart';
import 'package:qik_talk/features/settings/screen/settings_screen.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_config.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/features/calls/widgets/ongoing_call_banner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────
// Enum that drives the Chats ▾ dropdown
// ─────────────────────────────────────────────────────────────
enum _ChatView { chats, requests }

class ChatFragment extends ConsumerStatefulWidget {
  const ChatFragment({super.key});

  @override
  ConsumerState<ChatFragment> createState() => _ChatFragmentState();
}

class _ChatFragmentState extends ConsumerState<ChatFragment>
// ROBOT DISABLED: with SingleTickerProviderStateMixin {
{
  bool isMenuOpen = false;
  // ROBOT DISABLED:
  // late AnimationController _robotAnimationController;
  // late Animation<double> _robotAnimation;
  final GlobalSocketService _globalSocket = GlobalSocketService();
  StreamSubscription? _chatUpdateSubscription;
  final GlobalKey _chatComponentKey = GlobalKey();
  SaveValues mySaveValues = SaveValues();
  late Future<List<ChatListItem>> futureChats;
  int totalChats = 0;
  int totalGroup = 0;
  int _communityUnreadCount = 0;
  int _broadcastUnreadCount = 0;

  // Main tab: 0=Chat, 1=Groups, 2=Communities, 3=Broadcast
  int _tabIndex = 0;

  // ── NEW: Controls which view shows inside the Chat tab ──────
  _ChatView _chatView = _ChatView.chats;

  // ROBOT DISABLED: bool _hasCompletedOnboarding = false;
  bool _isEmailVerificationDialogOpen = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final ChatCountApiServices apiService = ChatCountApiServices();

  @override
  void initState() {
    super.initState();
    loadPhone();
    loadGroupChatsCount();
    _fetchSupplementalUnreadCounts();
    // Rebuild tab bar whenever reactive unread notifiers change.
    ChatComponent.totalUnread.addListener(_onUnreadChanged);
    GroupComponent.totalUnread.addListener(_onUnreadChanged);
    // ROBOT DISABLED: _checkOnboardingStatus();
    _connectGlobalSocket();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    // ROBOT DISABLED: Animation controller temporarily disabled
    // _robotAnimationController = AnimationController(
    //   duration: const Duration(milliseconds: 1500),
    //   vsync: this,
    // );

    // _robotAnimation = Tween<double>(begin: 0, end: 15).animate(
    //   CurvedAnimation(
    //     parent: _robotAnimationController,
    //     curve: Curves.easeInOut,
    //   ),
    // );

    // _robotAnimationController.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        loadGroupChatsCount();
        _fetchSupplementalUnreadCounts();
      });
    }
  }

  // ROBOT DISABLED:
  // Future<void> _checkOnboardingStatus() async {
  //   final completed =
  //       await mySaveValues.getBool(
  //         AppPreferenceHelper.AI_ONBOARDING_COMPLETED,
  //       ) ??
  //       false;
  //   if (mounted) setState(() => _hasCompletedOnboarding = completed);
  // }

  /// Checks whether the current user has a password (email verified).
  /// If not, shows [CreateLoginDetailsDialog] and keeps re-showing it
  /// until the user successfully completes email verification.
  Future<void> _checkAndPromptEmailVerification() async {
    if (!mounted || _isEmailVerificationDialogOpen) return;

    final bool hasPassword =
        await mySaveValues.getBool(AppPreferenceHelper.HAS_PASSWORD) ?? false;

    if (!hasPassword && mounted) {
      setState(() {
        _isEmailVerificationDialogOpen = true;
      });

      try {
        await showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: true, // ensure overlay covers PageView + bottom nav
          builder: (ctx) => PopScope(
            canPop: false, // Block hardware back button
            child: CreateLoginDetailsDialog(),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isEmailVerificationDialogOpen = false;
          });
        }
      }

      // After the dialog chain closes, check again. If still unverified, reopen.
      if (mounted) {
        final bool nowHasPassword =
            await mySaveValues.getBool(AppPreferenceHelper.HAS_PASSWORD) ??
            false;
        if (!nowHasPassword) {
          _checkAndPromptEmailVerification();
        }
      }
    }
  }

  Future<void> _connectGlobalSocket() async {
    await _globalSocket.connect();
    _chatUpdateSubscription = _globalSocket.chatListUpdates.listen((_) {
      if (!mounted) return;
      setState(() {});
      loadGroupChatsCount();
      _fetchSupplementalUnreadCounts();
    });
  }

  Future<void> loadChatsCount() async {
    try {
      final chats = await fetchChats();
      final singleChats = chats.where((c) => !c.isGroupChat).toList();
      if (!mounted) return;
      setState(() => totalChats = singleChats.length);
    } catch (e) {
      debugPrint("Error loading chats count: $e");
    }
  }

  Future<void> _fetchSupplementalUnreadCounts() async {
    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http.get(
        Uri.parse(ApiStrings.getUnreadChatCountPerChat),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List data = decoded['data'] ?? [];
        int communityTotal = 0;
        int broadcastTotal = 0; // ✅ Always 0 — broadcasts never show badges
        final Map<String, int> directAndGroupUnread = {};

        for (final item in data) {
          final chatId = (item['_id'] ?? '').toString();
          final count = (item['unreadCount'] ?? 0) as int;
          final isCommunity = item['isCommunity'] == true;
          final isBroadcast = item['isBroadcast'] == true;

          if (isCommunity) {
            communityTotal += count;
          } else if (isBroadcast) {
            // ✅ IGNORE broadcast unread counts — never show badges
            // Recipients don't need to mark broadcasts as read
          } else if (chatId.isNotEmpty) {
            directAndGroupUnread[chatId] = count;
          }
        }

        if (mounted) {
          setState(() {
            _communityUnreadCount = communityTotal;
            _broadcastUnreadCount = broadcastTotal;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching supplemental unread counts: $e');
    }
  }

  Future<void> loadGroupChatsCount() async {
    try {
      final chats = await fetchChats();
      final groupChats = chats.where((c) => c.isGroupChat).toList();
      if (!mounted) return;
      setState(() => totalGroup = groupChats.length);
    } catch (e) {
      debugPrint("Error loading group chats count: $e");
    }
  }

  void loadPhone() async {
    await mySaveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
    if (mounted) setState(() {});
  }

  Future<List<ChatListItem>> fetchChats() async {
    final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
    final response = await http.get(
      Uri.parse(ApiStrings.getAllChat),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      return decoded.map((e) => ChatListItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load chats');
    }
  }

  Future<List<Contact>> getContacts() async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) return [];
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    return contacts.where((c) => c.displayName.isNotEmpty).toList();
  }

  Future<void> _markAllChatsAsRead() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: HexColor("#1A7F4B")),
        ),
      );
      final token = await mySaveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http.put(
        Uri.parse('${AppConfig.apiUrl}chat/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (mounted) Navigator.pop(context);
      if (response.statusCode == 200) {
        ChatComponent.totalUnread.value = 0;
        await loadGroupChatsCount();
        await _fetchSupplementalUnreadCounts();
        if (mounted) setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('All chats marked as read'),
              backgroundColor: HexColor("#1A7F4B"),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error marking all as read: $e');
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to mark all as read'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ── NEW: Show the Chats / Requests dropdown ──────────────────
  void _showChatViewDropdown(BuildContext anchorContext) {
    final RenderBox box = anchorContext.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);

    showMenu<_ChatView>(
      context: context,
      color: HexColor("#1E1E1E"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + box.size.height + 4,
        MediaQuery.of(context).size.width - offset.dx - box.size.width,
        0,
      ),
      items: [
        _dropdownItem(
          value: _ChatView.chats,
          label: 'Chats',
          isSelected: _chatView == _ChatView.chats,
        ),
        _dropdownItem(
          value: _ChatView.requests,
          label: 'Requests',
          isSelected: _chatView == _ChatView.requests,
        ),
      ],
    ).then((selected) {
      if (selected != null && mounted) {
        setState(() => _chatView = selected);
      }
    });
  }

  PopupMenuItem<_ChatView> _dropdownItem({
    required _ChatView value,
    required String label,
    required bool isSelected,
  }) {
    return PopupMenuItem<_ChatView>(
      value: value,
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? HexColor("#FB8830") : Colors.white,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
          if (isSelected)
            Icon(Icons.check, color: HexColor("#FB8830"), size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 10;
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return WillPopScope(
      onWillPop: () async {
        // If showing Requests, go back to Chats first
        if (_tabIndex == 0 && _chatView == _ChatView.requests) {
          setState(() => _chatView = _ChatView.chats);
          return false;
        }
        if (_tabIndex != 0) {
          setState(() => _tabIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            // Always use the dark brown header — same in both light and dark mode
            backgroundColor: HexColor("#3A1D07"),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF3A1D07),
                image: DecorationImage(
                  image: AssetImage("images/app_bar_gredient.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (_isSearching)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSearching = false;
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: topPadding,
                              left: 16.0,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24.0,
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.only(top: topPadding, left: 16.0),
                          child: Text(
                            "QikTalk",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      if (_isSearching)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: topPadding,
                              left: 16.0,
                              right: 16.0,
                            ),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                              decoration: InputDecoration(
                                hintText: "Search chats...",
                                hintStyle: GoogleFonts.poppins(
                                  color: isDark
                                      ? HexColor("#C0B3B3")
                                      : AppColors.lightTextHint,
                                  fontSize: 14.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                      if (!_isSearching)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GlobalSearchScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: topPadding,
                              right: 10.0,
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 25.0,
                            ),
                          ),
                        ),
                      if (!_isSearching)
                        InkWell(
                          onTap: () async {
                            final selected = await showMenu<String>(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                MediaQuery.of(context).size.width - 160,
                                75,
                                10,
                                20,
                              ),
                              color: AppTheme.scaffoldBg(isDark),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                              items: [
                                _menuItem('Profile'),
                                _menuItem('Starred'),
                                _menuItem('Read all'),
                                _menuItem('Archived'),
                                _menuItem('Payments'),
                                _menuItem('Settings'),
                              ],
                            );
                            if (selected == 'Profile') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                            } else if (selected == 'Starred') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StarredMessagesScreen(),
                                ),
                              );
                            } else if (selected == 'Archived') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArchivedChatsScreen(),
                                ),
                              );
                            } else if (selected == 'Read all') {
                              await _markAllChatsAsRead();
                            } else if (selected == 'Settings') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SettingsScreen(),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: topPadding,
                              right: 20.0,
                            ),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 25.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    const OngoingCallBanner(),
                    // ── Main tab bar ───────────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 20.0),
                            _buildTab('Chat', 0, 60, 130),
                            const SizedBox(width: 10.0),
                            _buildTab('Groups', 1, 70, 100),
                            const SizedBox(width: 10.0),
                            _buildTab('Communities', 2, 115, 137),
                            const SizedBox(width: 10.0),
                            _buildTab('Broadcast', 3, 90, 120),
                            const SizedBox(width: 20.0),
                          ],
                        ),
                      ),
                    ),

                    // ── Content area ───────────────────────────────────────
                    Expanded(
                      child: _tabIndex == 0
                          ? _buildChatTabContent()
                          : IndexedStack(
                              // Keep Groups/Communities/Broadcast alive
                              index: _tabIndex - 1,
                              children: const [
                                GroupComponent(),
                                CommunitiesComponent(),
                                BroadcastComponent(),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // ROBOT DISABLED: Robot animation widget temporarily hidden
            // AnimatedBuilder(
            //   animation: _robotAnimation,
            //   builder: (context, child) {
            //     return Positioned(
            //       right: 20,
            //       top:
            //           (isMenuOpen
            //               ? MediaQuery.of(context).size.height * 0.1
            //               : MediaQuery.of(context).size.height * 0.57 - 63) +
            //           _robotAnimation.value,
            //       child: GestureDetector(
            //         onTap: () async {
            //           if (_hasCompletedOnboarding) {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (_) => AIChatScreen(initialMessage: ""),
            //               ),
            //             );
            //           } else {
            //             final result = await Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (_) => const AIOnboardingScreen(),
            //               ),
            //             );
            //             if (result == true || result == null) {
            //               await mySaveValues.saveBool(
            //                 AppPreferenceHelper.AI_ONBOARDING_COMPLETED,
            //                 true,
            //               );
            //               setState(() => _hasCompletedOnboarding = true);
            //             }
            //           }
            //         },
            //         child: ClipOval(
            //           child: Image.asset(
            //             "images/robot.png",
            //             width: 45,
            //             height: 45,
            //             fit: BoxFit.cover,
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            // ),

            // ── FAB ────────────────────────────────────────────────────────
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height * 0.6 - 24,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [HexColor("#FF00A8"), HexColor("#00D1FF")],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: HexColor("#FB8830").withOpacity(0.6),
                      offset: const Offset(4, 4),
                      blurRadius: 13,
                      spreadRadius: -1,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.08),
                      offset: const Offset(-4, -4),
                      blurRadius: 5,
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? HexColor("#1B1B1B") : HexColor("#4D3C2F"),
                    ),
                    child: FloatingActionButton(
                      onPressed: () async {
                        final bool hasPassword =
                            await mySaveValues.getBool(
                              AppPreferenceHelper.HAS_PASSWORD,
                            ) ??
                            false;
                        if (!hasPassword) {
                          // Re-trigger the full email verification flow
                          _checkAndPromptEmailVerification();
                        } else {
                          final pageContext = context;
                          if (isMenuOpen) {
                            Navigator.of(context, rootNavigator: true).pop();
                            setState(() => isMenuOpen = false);
                            return;
                          }
                          setState(() => isMenuOpen = true);
                          showGeneralDialog(
                            context: pageContext,
                            barrierColor: Colors.black.withOpacity(0.7),
                            barrierDismissible: true,
                            barrierLabel: 'Menu',
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                            pageBuilder: (context, a1, a2) =>
                                const SizedBox.shrink(),
                            transitionBuilder: (context, a1, a2, child) {
                              return Stack(
                                children: [
                                  floatingBlurItem(
                                    "Create Community",
                                    "images/community.png",
                                    a1,
                                    70,
                                    () {
                                      Navigator.of(pageContext).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CreateCommunityScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  floatingBlurItem(
                                    "Create Group",
                                    "images/group.png",
                                    a1,
                                    140,
                                    () {
                                      // Finance group creation/type selection is
                                      // temporarily disabled. Default to the
                                      // existing Family & Friends creation flow.
                                      Navigator.of(pageContext).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CreateNewGroupScreen(),
                                        ),
                                      );

                                      /* Finance/family type selector disabled temporarily.
                                      Navigator.of(pageContext).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const GroupTypeSelectionScreen(),
                                        ),
                                      );
                                      */
                                    },
                                  ),
                                  floatingBlurItem(
                                    "Start Broadcast",
                                    "images/broadcast.png",
                                    a1,
                                    210,
                                    () {
                                      Navigator.of(pageContext).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CreateBroadcastListScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  floatingBlurItem(
                                    "Contact",
                                    "images/contact.png",
                                    a1,
                                    280,
                                    () async {
                                      List<Contact> contacts =
                                          await getContacts();
                                      if (contacts.isEmpty) {
                                        ScaffoldMessenger.of(
                                          pageContext,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "No contacts found or permission denied",
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.of(pageContext).push(
                                        MaterialPageRoute(
                                          builder: (_) => Contact_screen(
                                            contacts: contacts,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ).then((_) {
                            if (mounted) setState(() => isMenuOpen = false);
                          });
                        }
                      },
                      heroTag: 'chat_fab',
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      highlightElevation: 0,
                      splashColor: Colors.transparent,
                      child: Icon(
                        isMenuOpen ? Icons.close : Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── NEW: Switch between ChatComponent and FriendRequestsScreen
  Widget _buildChatTabContent() {
    if (_chatView == _ChatView.requests) {
      return FriendRequestsScreen(
        onRequestAccepted: () {
          // Switch back to Chats view after accepting
          if (mounted) setState(() => _chatView = _ChatView.chats);
        },
      );
    }

    // Default: show the normal chat list
    return ChatComponent(key: _chatComponentKey, searchQuery: _searchQuery);
  }

  // ── Unchanged helpers below ────────────────────────────────────

  Widget _buildTab(
    String label,
    int index,
    double inactiveWidth,
    double activeWidth,
  ) {
    final isActive = _tabIndex == index;
    // Chats/Groups use reactive unread notifiers from cache-backed state.
    // Communities/Broadcast still use API totals until they get the same
    // cache-driven unread infrastructure.
    final unread = index == 1
        ? GroupComponent.totalUnread.value
        : (index == 2
              ? _communityUnreadCount
              : (index == 3 ? _broadcastUnreadCount : 0));

    // isDark is available from the build context via Theme
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _tabIndex = index);
          },
          child: Container(
            width: inactiveWidth,
            height: 35.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: HexColor("#E67E2B").withOpacity(0.1),
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                  spreadRadius: -1,
                ),
                BoxShadow(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    0.05,
                  ),
                  offset: const Offset(-2, -2),
                  blurRadius: 5,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: isDark
                      ? const Color(0xFF888888)
                      : const Color(0xFF3D2B1A),
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (!isActive && unread > 0)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: HexColor("#34C759"),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.scaffoldBg(isDark),
                  width: 1.5,
                ),
              ),
            ),
          ),
        if (isActive)
          Container(
            width: activeWidth,
            height: 45.0,
            decoration: BoxDecoration(
              color: isDark ? HexColor("#1B1B1B") : HexColor("#1B1B1B"),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: HexColor("#FB8830").withOpacity(isDark ? 0.6 : 0.3),
                  offset: const Offset(4, 4),
                  blurRadius: 15,
                  spreadRadius: -1,
                ),
                BoxShadow(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    0.08,
                  ),
                  offset: const Offset(-4, -4),
                  blurRadius: 15,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Chat tab: show Chats ▾ dropdown pill ──────────────
                if (index == 0) ...[
                  Builder(
                    builder: (anchorCtx) => GestureDetector(
                      onTap: () => _showChatViewDropdown(anchorCtx),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _chatView == _ChatView.chats ? 'Chats' : 'Requests',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: isDark ? Colors.white : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: HexColor("#FB8830"),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  // Unread badge — listen directly to the notifier so the pill
                  // never gets stuck showing a stale count.
                  ValueListenableBuilder<int>(
                    valueListenable: ChatComponent.totalUnread,
                    builder: (_, count, __) {
                      if (count == 0) return const SizedBox.shrink();
                      return CircleAvatar(
                        radius: 8,
                        backgroundColor: HexColor("#FF6900"),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  // ── Other tabs: plain label + optional unread badge ──
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: isDark ? Colors.white : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (unread > 0) ...[
                    const SizedBox(width: 5),
                    CircleAvatar(
                      radius: 8.5,
                      backgroundColor: HexColor("#FF6900"),
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(String value) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuItem<String>(
      value: value,
      child: SizedBox(
        width: 110,
        child: Row(
          children: [
            const SizedBox(width: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : const Color(0xFF1A1008),
                fontSize: 15.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget floatingBlurItem(
    String label,
    String imagePath,
    Animation<double> animation,
    double offset,
    VoidCallback onTap,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      right: 16,
      top:
          MediaQuery.of(context).size.height * 0.7 -
          24 -
          offset * animation.value,
      child: Opacity(
        opacity: animation.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onTap();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      label,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: isDark
                          ? HexColor("#1B1B1B")
                          : const Color(0xFFDDD3C5),
                      borderRadius: BorderRadius.circular(50.0),
                      boxShadow: [
                        BoxShadow(
                          color: HexColor("#FB8830").withOpacity(0.6),
                          offset: const Offset(4, 4),
                          blurRadius: 13,
                          spreadRadius: -1,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.08),
                          offset: const Offset(-4, -4),
                          blurRadius: 5,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(imagePath, width: 15, height: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onUnreadChanged() {
    // ✅ Rebuild tab bar when Chat or Group unread counts change
    // This ensures badges update in real-time without API polling
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ChatComponent.totalUnread.removeListener(_onUnreadChanged);
    GroupComponent.totalUnread.removeListener(_onUnreadChanged);
    // ROBOT DISABLED: _robotAnimationController.dispose();
    _searchController.dispose();
    _chatUpdateSubscription?.cancel();
    super.dispose();
  }
}
