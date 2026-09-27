import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/broadcast/screens/create_new_broadcast_list_screen.dart';
import 'package:qik_talk/features/contact/services/contact_sync_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class CreateBroadcastListScreen extends StatefulWidget {
  const CreateBroadcastListScreen({super.key});

  @override
  State<CreateBroadcastListScreen> createState() =>
      _CreateBroadcastListScreenState();
}

class _CreateBroadcastListScreenState extends State<CreateBroadcastListScreen> {
  final TextEditingController _listNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ContactSyncService _syncService = ContactSyncService();

  List<RegisteredUser> _allUsers = [];
  List<RegisteredUser> _filteredUsers = [];
  final List<RegisteredUser> _selectedUsers = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(() {
      final q = _searchController.text.toLowerCase();
      setState(() {
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
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _syncService.performFullContactSync();
      if (!mounted) return;
      setState(() {
        _allUsers = response.registeredUsers;
        _filteredUsers = response.registeredUsers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _toggle(RegisteredUser user) {
    setState(() {
      final exists = _selectedUsers.any((u) => u.id == user.id);
      if (exists) {
        _selectedUsers.removeWhere((u) => u.id == user.id);
      } else {
        // Check if user is already selected by ID to prevent duplicates
        if (!_selectedUsers.any((u) => u.id == user.id)) {
          _selectedUsers.add(user);
        }
      }
    });
  }

  bool _isSelected(RegisteredUser user) =>
      _selectedUsers.any((u) => u.id == user.id);

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

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
            title: Text(
              'Create New Broadcast List',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // List Name field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Text(
              'List Name (Optional)',
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary(isDark),
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.textHint(isDark).withOpacity(0.2),
                ),
              ),
              child: TextField(
                controller: _listNameController,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter list name',
                  hintStyle: GoogleFonts.poppins(
                    color: AppTheme.textHint(isDark),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Selected users horizontal scroll
          if (_selectedUsers.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selectedUsers.length,
                itemBuilder: (_, i) {
                  final user = _selectedUsers[i];
                  final imgUrl = _getFullImageUrl(user.profilePicture);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _toggle(user),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 56,
                          child: Text(
                            user.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {}, // already on this screen
                child: Text(
                  'Edit list...',
                  style: GoogleFonts.poppins(
                    color: HexColor("#1A7F4B"),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.textHint(isDark).withOpacity(0.15),
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

          // Contact list
          Expanded(child: _buildBody(isDark)),

          // Bottom button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _selectedUsers.isEmpty
                    ? null
                    : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateBroadcastScreen(
                              preSelectedUsers: _selectedUsers,
                              listName: _listNameController.text.trim(),
                            ),
                          ),
                        );
                        if (result == true && mounted) {
                          // Pop back to BroadcastComponent list
                          Navigator.pop(context, true);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#201E1F"),
                  disabledBackgroundColor: HexColor("#201E1F").withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(color: HexColor("#FF00A8"), width: 1.5),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _selectedUsers.isEmpty
                      ? 'Create List'
                      : 'Create List (${_selectedUsers.length})',
                  style: GoogleFonts.poppins(
                    color: _selectedUsers.isEmpty
                        ? AppTheme.textHint(isDark)
                        : AppTheme.textPrimary(isDark),
                    fontSize: 16,
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
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: HexColor("#FB8830")),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, color: AppTheme.textHint(isDark), size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary(isDark),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadContacts,
              child: Text(
                'Retry',
                style: TextStyle(color: HexColor("#FB8830")),
              ),
            ),
          ],
        ),
      );
    }
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Text(
          'No contacts found',
          style: GoogleFonts.poppins(
            color: AppTheme.textHint(isDark),
            fontSize: 14,
          ),
        ),
      );
    }

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
    _listNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
