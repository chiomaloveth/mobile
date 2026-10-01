// add_more_recipients_screen.dart
// Drop into: lib/features/chat/single_chat/screens/add_more_recipients_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/services/broadcast_service.dart';
import 'package:qik_talk/features/contact/services/contact_sync_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';

// ─────────────────────────────────────────────────────────────
// AddMoreRecipientsScreen
// Matches Figma: Image 8
// Shows all QikTalk-registered contacts, excluding those already
// in the broadcast. Allows multi-select and adds them via API.
// ─────────────────────────────────────────────────────────────
class AddMoreRecipientsScreen extends StatefulWidget {
  final String broadcastId;
  final List<String> existingMemberIds;

  const AddMoreRecipientsScreen({
    super.key,
    required this.broadcastId,
    required this.existingMemberIds,
  });

  @override
  State<AddMoreRecipientsScreen> createState() =>
      _AddMoreRecipientsScreenState();
}

class _AddMoreRecipientsScreenState extends State<AddMoreRecipientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ContactSyncService _syncService = ContactSyncService();
  final BroadcastService _broadcastService = BroadcastService();

  List<RegisteredUser> _allUsers = [];
  List<RegisteredUser> _filteredUsers = [];
  final Set<String> _selectedIds = {};

  bool _isLoadingContacts = true;
  bool _isAdding = false;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(() {
      final q = _searchController.text.toLowerCase();
      setState(() {
        _searchQuery = q;
        _filteredUsers = q.isEmpty
            ? _allUsers
            : _allUsers
                  .where(
                    (u) =>
                        u.username.toLowerCase().contains(q) ||
                        u.phone.contains(q),
                  )
                  .toList();
      });
    });
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoadingContacts = true;
      _errorMessage = null;
    });
    try {
      final ContactSyncResponse response = await _syncService
          .performFullContactSync();
      if (!mounted) return;

      // Exclude contacts already in the broadcast
      final newUsers = response.registeredUsers
          .where((u) => !widget.existingMemberIds.contains(u.id))
          .toList();

      setState(() {
        _allUsers = newUsers;
        _filteredUsers = newUsers;
        _isLoadingContacts = false;
      });
    } catch (e) {
      debugPrint('❌ AddMoreRecipients _loadContacts: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingContacts = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _keyFor(RegisteredUser u) => u.id.isNotEmpty ? u.id : u.phone;

  void _toggle(RegisteredUser user) {
    final key = _keyFor(user);
    if (key.isEmpty) return;
    setState(() {
      if (_selectedIds.contains(key)) {
        _selectedIds.remove(key);
      } else {
        _selectedIds.add(key);
      }
    });
  }

  bool _isSelected(RegisteredUser u) => _selectedIds.contains(_keyFor(u));

  Future<void> _addRecipients() async {
    if (_selectedIds.isEmpty) return;

    final userIds = _allUsers
        .where((u) => _isSelected(u) && u.id.isNotEmpty)
        .map((u) => u.id)
        .toSet() // Ensure uniqueness
        .toList();

    if (userIds.isEmpty) {
      _showSnack('No valid users selected', isError: true);
      return;
    }

    setState(() => _isAdding = true);

    try {
      await _broadcastService.addMembers(widget.broadcastId, userIds);
      if (mounted) {
        // Notify BroadcastDetailScreen via stream so member list refreshes
        try {
          GlobalSocketService().broadcastMemberJoinedController.add({
            'broadcastId': widget.broadcastId,
            'userIds': userIds,
          });
          debugPrint('📢 AddMoreRecipients: notified memberJoined stream');
        } catch (e) {
          debugPrint('⚠️ Could not notify memberJoined stream: $e');
        }
        _showSnack('${userIds.length} recipient(s) added!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('❌ addMembers error: $e');
      if (mounted) _showSnack('Failed to add recipients: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isError ? Colors.red : HexColor("#1A7F4B"),
      ),
    );
  }

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

  // ── BUILD ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/app_bar_gredient.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add More Recipient',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_selectedIds.length} selected',
                  style: GoogleFonts.poppins(
                    color: HexColor("#FB8830"),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              if (_selectedIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton(
                    onPressed: _isAdding ? null : _addRecipients,
                    child: _isAdding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Add',
                            style: GoogleFonts.poppins(
                              color: HexColor("#FB8830"),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.textHint(isDark).withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search contact',
                  hintStyle: GoogleFonts.poppins(
                    color: AppTheme.textHint(isDark),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.textHint(isDark),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // ── Contact list / states ──────────────────────────
          Expanded(child: _buildBody(isDark)),

          // ── Bottom Add button ──────────────────────────────
          if (_selectedIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isAdding ? null : _addRecipients,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor("#1A7F4B"),
                    disabledBackgroundColor: HexColor(
                      "#1A7F4B",
                    ).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isAdding
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Add ${_selectedIds.length} Recipient${_selectedIds.length == 1 ? '' : 's'}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    // Loading
    if (_isLoadingContacts) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: HexColor("#FB8830")),
            const SizedBox(height: 16),
            Text(
              'Syncing contacts...',
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary(isDark),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // Error
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, color: AppTheme.textHint(isDark), size: 52),
              const SizedBox(height: 12),
              Text(
                'Could not load contacts',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary(isDark),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadContacts,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  'Retry',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#FB8830"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? 'No new contacts to add'
              : 'No results for "$_searchQuery"',
          style: GoogleFonts.poppins(
            color: AppTheme.textHint(isDark),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Contact list — matches Image 8 exactly
    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (_, index) {
        final user = _filteredUsers[index];
        final isSelected = _isSelected(user);
        final imgUrl = _getFullImageUrl(user.profilePicture);

        return InkWell(
          onTap: () => _toggle(user),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 26,
                  backgroundColor: HexColor("#FB8830"),
                  backgroundImage: imgUrl.isNotEmpty
                      ? NetworkImage(imgUrl)
                      : null,
                  child: imgUrl.isEmpty
                      ? Text(
                          user.username.isNotEmpty
                              ? user.username[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                // Name + phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (user.phone.isNotEmpty)
                        Text(
                          user.phone,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary(isDark),
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                // Checkbox — matches the circular outline style in Image 8
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? HexColor("#1A7F4B")
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? HexColor("#1A7F4B")
                          : AppTheme.textHint(isDark),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
