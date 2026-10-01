/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/single_chat/screens/chat_actions_service.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';

class BlockedContact {
  final String userId;
  final String username;
  final String profilePicture;
  final String about;

  const BlockedContact({
    required this.userId,
    required this.username,
    required this.profilePicture,
    required this.about,
  });

  factory BlockedContact.fromJson(Map<String, dynamic> json) {
    return BlockedContact(
      userId: json['_id']?.toString() ?? json['userId']?.toString() ?? '',
      username:
          json['username']?.toString() ?? json['name']?.toString() ?? 'Unknown',
      profilePicture:
          json['profilePicture']?.toString() ??
          json['avatar']?.toString() ??
          '',
      about: json['about']?.toString() ?? '',
    );
  }
}

class BlockedContactsScreen extends StatefulWidget {
  const BlockedContactsScreen({Key? key}) : super(key: key);

  @override
  State<BlockedContactsScreen> createState() => _BlockedContactsScreenState();
}

class _BlockedContactsScreenState extends State<BlockedContactsScreen> {
  List<BlockedContact> _blockedContacts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBlockedContacts();
  }

  Future<void> _loadBlockedContacts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      debugPrint('🚫 [BLOCKED] Fetching blocked contacts...');

      final response = await http
          .get(
            Uri.parse(
              ('${AppConfig.apiUrl}users/blocked'),
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('🚫 [BLOCKED] Status: ${response.statusCode}');
      debugPrint('🚫 [BLOCKED] Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Handle both array and { data: [...] } shapes
        final List rawList = decoded is List
            ? decoded
            : (decoded['data'] ??
                  decoded['blockedUsers'] ??
                  decoded['users'] ??
                  []);

        final contacts = rawList
            .map((e) => BlockedContact.fromJson(Map<String, dynamic>.from(e)))
            .where((c) => c.userId.isNotEmpty)
            .toList();

        debugPrint('🚫 [BLOCKED] Found ${contacts.length} blocked contacts');

        if (mounted) {
          setState(() {
            _blockedContacts = contacts;
            _isLoading = false;
          });
        }
      } else {
        debugPrint(
          '🚫 [BLOCKED] Error: ${response.statusCode} - ${response.body}',
        );
        if (mounted) {
          setState(() {
            _error = 'Failed to load blocked contacts (${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('🚫 [BLOCKED] Exception: $e');
      if (mounted) {
        setState(() {
          _error = 'Could not load blocked contacts. Check your connection.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _unblockContact(BlockedContact contact) async {
    // Optimistic UI — remove immediately
    setState(() {
      _blockedContacts.removeWhere((c) => c.userId == contact.userId);
    });

    debugPrint('🔓 [UNBLOCK] Unblocking userId: ${contact.userId}');
    final result = await ChatActionsService().unblockUser(contact.userId);
    debugPrint(
      '🔓 [UNBLOCK] Result: success=${result.success}, message=${result.message}',
    );

    if (!result.success) {
      // Revert on failure
      if (mounted) {
        setState(() => _blockedContacts.add(contact));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to unblock ${contact.username}: ${result.message}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Restore chat visibility in Hive by un-flagging blocked state
    try {
      final chatBox = await Hive.openBox<ChatListItemHive>('chats');
      // Find chat by userId
      final entry = chatBox.values
          .where((c) => c.userId == contact.userId)
          .firstOrNull;
      if (entry != null) {
        await chatBox.put(entry.id, entry.copyWith(isBlocked: false));
        debugPrint('🔓 [UNBLOCK] Hive updated for chat ${entry.id}');
      }
    } catch (e) {
      debugPrint('🔓 [UNBLOCK] Hive update error: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${contact.username} unblocked',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: HexColor('#1A7F4B'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showUnblockDialog(BlockedContact contact) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBgAlt(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Unblock ${contact.username}',
          style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 17),
        ),
        content: Text(
          '${contact.username} will be able to call you and send you messages again.',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _unblockContact(contact);
            },
            child: Text(
              'Unblock',
              style: GoogleFonts.poppins(
                color: HexColor('#1A7F4B'),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: Column(
        children: [
          // AppBar
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/app_bar_gredient.png'),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.only(
              top: topPadding + 10,
              left: 8,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Blocked Contacts',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: _loadBlockedContacts,
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: HexColor('#1A7F4B'),
                    ),
                  )
                : _error != null
                ? _buildErrorState()
                : _blockedContacts.isEmpty
                ? _buildEmptyState()
                : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _blockedContacts.length,
      separatorBuilder: (_, __) =>
          Divider(color: AppTheme.dividerSubtle(isDark), height: 1, indent: 72),
      itemBuilder: (context, index) {
        final contact = _blockedContacts[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: CachedProfileAvatar(
            imageUrl: contact.profilePicture.isNotEmpty
                ? contact.profilePicture
                : null,
            displayName: contact.username,
            radius: 26,
            backgroundColor: HexColor('#FB8830'),
          ),
          title: Text(
            contact.username,
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary(isDark),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: contact.about.isNotEmpty
              ? Text(
                  contact.about,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: GestureDetector(
            onTap: () => _showUnblockDialog(contact),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(color: HexColor('#1A7F4B'), width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Unblock',
                style: GoogleFonts.poppins(
                  color: HexColor('#1A7F4B'),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, size: 64, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 16),
          Text(
            'No blocked contacts',
            style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'People you block will appear here',
            style: GoogleFonts.poppins(color: AppTheme.textHint(isDark), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark), fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadBlockedContacts,
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#1A7F4B'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text(
              'Retry',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/
