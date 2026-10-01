import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_api_service.dart';
import 'package:qik_talk/features/chat/group_chat/components/group_component.dart';
import 'package:qik_talk/features/contact/components/contact_sync_provider.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';

// ─── STEP 1: Group Type confirmed → Select Members ───────────────────────────
class CreateGroupStep1Screen extends ConsumerStatefulWidget {
  final String? communityId;
  const CreateGroupStep1Screen({super.key, this.communityId});

  @override
  ConsumerState<CreateGroupStep1Screen> createState() =>
      _CreateGroupStep1ScreenState();
}

class _CreateGroupStep1ScreenState
    extends ConsumerState<CreateGroupStep1Screen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<Map<String, dynamic>> filteredUsers = [];
  List<Map<String, dynamic>> selectedMembers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactSyncProvider.notifier).syncContacts();
    });
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          searchQuery = _searchController.text.toLowerCase();
          _filterContacts();
        });
      }
    });
  }

  void _filterContacts() {
    final contactState = ref.read(contactSyncProvider);
    final users = contactState.registeredUsers;
    if (searchQuery.isEmpty) {
      filteredUsers = users
          .map(
            (u) => {
              'id': u.id,
              'name': u.username,
              'image': u.profilePicture ?? '',
              'phone': u.phone,
            },
          )
          .toList();
    } else {
      filteredUsers = users
          .where(
            (u) =>
                u.username.toLowerCase().contains(searchQuery) ||
                u.phone.toLowerCase().contains(searchQuery),
          )
          .map(
            (u) => {
              'id': u.id,
              'name': u.username,
              'image': u.profilePicture ?? '',
              'phone': u.phone,
            },
          )
          .toList();
    }
  }

  void _toggleMember(Map<String, dynamic> contact) {
    setState(() {
      final idx = selectedMembers.indexWhere((m) => m['id'] == contact['id']);
      if (idx != -1) {
        selectedMembers.removeAt(idx);
      } else {
        selectedMembers.add(contact);
      }
    });
  }

  bool _isSelected(String id) => selectedMembers.any((m) => m['id'] == id);

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

  // Frequently contacted = first 5 registered users
  List<Map<String, dynamic>> get _frequentContacts {
    final contactState = ref.read(contactSyncProvider);
    return contactState.registeredUsers
        .take(5)
        .map(
          (u) => {
            'id': u.id,
            'name': u.username,
            'image': u.profilePicture ?? '',
            'phone': u.phone,
          },
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    final contactState = ref.watch(contactSyncProvider);

    if (filteredUsers.isEmpty && contactState.registeredUsers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _filterContacts());
    }

    final frequent = _frequentContacts;
    final displayList = filteredUsers.isNotEmpty
        ? filteredUsers
        : contactState.registeredUsers
              .map(
                (u) => {
                  'id': u.id,
                  'name': u.username,
                  'image': u.profilePicture ?? '',
                  'phone': u.phone,
                },
              )
              .toList();

    // Group by first letter
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final user in displayList) {
      final letter = (user['name'] as String).isNotEmpty
          ? (user['name'] as String)[0].toUpperCase()
          : '#';
      grouped.putIfAbsent(letter, () => []).add(user);
    }
    final sortedKeys = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('images/app_bar_gredient.png'),
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
              children: [
                Text(
                  'Select Members',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Step 2 of 4',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Members selected counter
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? HexColor('#FB8830').withOpacity(0.3) : AppColors.lightAccent.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Members selected',
                  style: GoogleFonts.poppins(
                    color: isDark ? HexColor('#FB8830') : AppColors.lightAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${selectedMembers.length} / ${displayList.length}',
                  style: GoogleFonts.poppins(
                    color: isDark ? HexColor('#FB8830') : AppColors.lightAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              color: AppTheme.cardBg(isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search names or numbers',
                hintStyle: GoogleFonts.poppins(
                  color: AppTheme.textHint(isDark),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.iconColorSubtle(isDark),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: contactState.isSyncing
                ? Center(
                    child: CircularProgressIndicator(
                      color: isDark ? HexColor('#1A7F4B') : AppColors.lightAccent,
                    ),
                  )
                : ListView(
                    children: [
                      // Frequently contacted
                      if (frequent.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: Text(
                            'Frequently contacted',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary(isDark),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: frequent.length,
                            itemBuilder: (ctx, i) {
                              final u = frequent[i];
                              final selected = _isSelected(u['id']);
                              final imgUrl = _getFullImageUrl(u['image']);
                              return GestureDetector(
                                onTap: () => _toggleMember(u),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 28,
                                            backgroundColor: AppTheme.cardBgAlt(isDark),
                                            backgroundImage: imgUrl.isNotEmpty
                                                ? NetworkImage(imgUrl)
                                                : null,
                                            child: imgUrl.isEmpty
                                                ? Text(
                                                    (u['name'] as String)[0]
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      color: AppTheme.textPrimary(isDark),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          if (selected)
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: isDark ? HexColor('#1A7F4B') : AppColors.lightAccent,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppTheme.scaffoldBg(isDark),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          u['name'],
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Alphabetical list
                      ...sortedKeys.map((letter) {
                        final users = grouped[letter]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                              child: Text(
                                letter,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textHint(isDark),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.cardBg(isDark),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: users.map((u) {
                                  final selected = _isSelected(u['id']);
                                  final imgUrl = _getFullImageUrl(u['image']);
                                  final isLast = u == users.last;
                                  return Column(
                                    children: [
                                      ListTile(
                                        onTap: () => _toggleMember(u),
                                        leading: CircleAvatar(
                                          radius: 22,
                                          backgroundColor: AppTheme.cardBgAlt(isDark),
                                          backgroundImage: imgUrl.isNotEmpty
                                              ? NetworkImage(imgUrl)
                                              : null,
                                          child: imgUrl.isEmpty
                                              ? Text(
                                                  (u['name'] as String)[0]
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color: AppTheme.textPrimary(isDark),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        title: Text(
                                          u['name'],
                                          style: GoogleFonts.poppins(
                                            color: AppTheme.textPrimary(isDark),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        trailing: selected
                                            ? Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: isDark ? HexColor('#1A7F4B') : AppColors.lightAccent,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              )
                                            : Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppTheme.textHint(isDark),
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      if (!isLast)
                                        Divider(
                                          color: AppTheme.dividerSubtle(isDark),
                                          height: 1,
                                          indent: 70,
                                        ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      }),

                      const SizedBox(height: 100),
                    ],
                  ),
          ),

          // Bottom CTA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GestureDetector(
                onTap: selectedMembers.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateGroupStep2Screen(
                              selectedMembers: selectedMembers,
                              communityId: widget.communityId,
                            ),
                          ),
                        );
                      },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: selectedMembers.isNotEmpty
                        ? LinearGradient(
                            colors: isDark 
                                ? [HexColor('#201E1F'), HexColor('#201E1F')]
                                : [AppColors.lightAccent, AppColors.lightAccent],
                          )
                        : null,
                    color: selectedMembers.isEmpty 
                        ? (isDark ? HexColor('#201E1F') : AppColors.lightTextHint) 
                        : null,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: selectedMembers.isNotEmpty
                        ? [
                            BoxShadow(
                              color: (isDark ? HexColor('#FF00A8') : AppColors.lightAccent).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'Continue to Contribution Order',
                      style: GoogleFonts.poppins(
                        color: selectedMembers.isNotEmpty
                            ? Colors.white
                            : (isDark ? Colors.white38 : Colors.white70),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ─── STEP 2: Set group name & image ──────────────────────────────────────────
class CreateGroupStep2Screen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> selectedMembers;
  final String? communityId;

  const CreateGroupStep2Screen({
    super.key,
    required this.selectedMembers,
    this.communityId,
  });

  @override
  ConsumerState<CreateGroupStep2Screen> createState() => _CreateGroupStep2ScreenState();
}

class _CreateGroupStep2ScreenState extends ConsumerState<CreateGroupStep2Screen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _groupImage;

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

  Future<void> _pickImage() async {
    ref.read(biometricAuthProvider.notifier).isPickerActive = true;
    final XFile? img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    await ref.read(biometricAuthProvider.notifier).onPickerReturned();
    if (img != null && mounted) {
      setState(() => _groupImage = File(img.path));
    }
  }

  void _removeMember(int index) {
    setState(() => widget.selectedMembers.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('images/app_bar_gredient.png'),
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
              children: [
                Text(
                  'Create New Group',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Group image picker
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cardBgAlt(isDark),
                      image: _groupImage != null
                          ? DecorationImage(
                              image: FileImage(_groupImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _groupImage == null
                        ? Image.asset(
                            'images/family_group.png',
                            width: 50,
                            height: 50,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDark ? HexColor('#1A7F4B') : AppColors.lightAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.scaffoldBg(isDark),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Group name (Optional)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Group Name (Optional)',
                style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark), fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _nameController,
                style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Enter group name',
                  hintStyle: GoogleFonts.poppins(
                    color: AppTheme.textHint(isDark),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Selected members row
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.selectedMembers.length,
                itemBuilder: (ctx, i) {
                  final m = widget.selectedMembers[i];
                  final imgUrl = _getFullImageUrl(m['image']);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppTheme.cardBgAlt(isDark),
                              backgroundImage: imgUrl.isNotEmpty
                                  ? NetworkImage(imgUrl)
                                  : null,
                              child: imgUrl.isEmpty
                                  ? Text(
                                      (m['name'] as String)[0].toUpperCase(),
                                      style: TextStyle(
                                        color: AppTheme.textPrimary(isDark),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeMember(i),
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppTheme.textHint(isDark),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.scaffoldBg(isDark),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 10,
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
                            m['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary(isDark),
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

            const SizedBox(height: 16),

            // Add more people
            _SettingsRow(
              label: 'Add more people',
              onTap: () => Navigator.pop(context),
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // Group permissions
            _SettingsRow(
              label: 'Group permissions',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GroupPermissionsScreen(),
                  ),
                );
              },
              isDark: isDark,
            ),

            const SizedBox(height: 40),

            // Create Group button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateGroupFinalScreen(
                      selectedMembers: widget.selectedMembers,
                      groupName: _nameController.text.trim(),
                      groupImage: _groupImage,
                      communityId: widget.communityId,
                      groupType: 'family', // ← add this
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [HexColor('#201E1F'), HexColor('#201E1F')]
                        : [AppColors.lightAccent, AppColors.lightAccent],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? HexColor('#FF00A8') : AppColors.lightAccent).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Create Group',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

// ─── FINAL STEP: API call ────────────────────────────────────────────────────
class CreateGroupFinalScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> selectedMembers;
  final String groupName;
  final File? groupImage;
  final String? communityId;
  final String groupType; // 'family' or 'finance'

  const CreateGroupFinalScreen({
    super.key,
    required this.selectedMembers,
    required this.groupName,
    this.groupImage,
    this.communityId,
    this.groupType = 'family',
  });

  @override
  ConsumerState<CreateGroupFinalScreen> createState() => _CreateGroupFinalScreenState();
}

class _CreateGroupFinalScreenState extends ConsumerState<CreateGroupFinalScreen> {
  final GroupApiService _groupApiService = GroupApiService();
  final SaveValues _saveValues = SaveValues();
  final GlobalSocketService _globalSocket = GlobalSocketService();
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _createGroup());
  }

  Future<void> _createGroup() async {
    setState(() => _isCreating = true);
    try {
      final userIds = widget.selectedMembers
          .map((m) => m['id'] as String)
          .toList();
      final name = widget.groupName.isNotEmpty
          ? widget.groupName
          : 'Family & Friends';

      final response = await _groupApiService.createGroup(
        chatName: name,
        userIds: userIds,
        communityId: widget.communityId,
      );

      if (!mounted) return;

      if (response?.success == true && response?.group != null) {
        final group = response!.group!;
        await GroupTypeStore.setType(group.id, widget.groupType);
        _globalSocket.emit('group created', {
          'groupId': group.id,
          'groupName': group.chatName,
          'members': userIds,
          'createdBy': await _saveValues.getString(AppPreferenceHelper.ID),
        });

        // Pop all the way back to the chat fragment
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        final themeMode = ref.read(themeProvider);
        final brightness = MediaQuery.of(context).platformBrightness;
        final bool isDark = themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system && brightness == Brightness.dark);
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Group "${group.chatName}" created!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: AppTheme.successGreen(isDark),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response?.message ?? 'Failed to create group',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.successGreen(isDark)),
            const SizedBox(height: 20),
            Text(
              'Creating group...',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Group Permissions Screen ────────────────────────────────────────────────
class GroupPermissionsScreen extends ConsumerStatefulWidget {
  const GroupPermissionsScreen({super.key});

  @override
  ConsumerState<GroupPermissionsScreen> createState() => _GroupPermissionsScreenState();
}

class _GroupPermissionsScreenState extends ConsumerState<GroupPermissionsScreen> {
  bool _approveNewMembers = false;
  bool _editGroupDetails = false;
  bool _allowSendMessages = false;
  bool _inviteViaQr = false;
  bool _pinMessages = false;
  bool _addOtherMembers = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('images/app_bar_gredient.png'),
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
              'Group Permissions',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Admin Controls
            Text(
              'Admin Controls',
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _PermissionTile(
              label: 'Approve New Members',
              value: _approveNewMembers,
              onChanged: (v) => setState(() => _approveNewMembers = v),
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Members Access
            Text(
              'Members Access',
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _PermissionTileInCard(
                    label: 'Edit Group Details',
                    value: _editGroupDetails,
                    onChanged: (v) => setState(() => _editGroupDetails = v),
                    showDivider: true,
                    isDark: isDark,
                  ),
                  _PermissionTileInCard(
                    label: 'Allow Members to Send Messages',
                    value: _allowSendMessages,
                    onChanged: (v) => setState(() => _allowSendMessages = v),
                    showDivider: true,
                    isDark: isDark,
                  ),
                  _PermissionTileInCard(
                    label: 'Invite via QR Code or Group Link',
                    value: _inviteViaQr,
                    onChanged: (v) => setState(() => _inviteViaQr = v),
                    showDivider: true,
                    isDark: isDark,
                  ),
                  _PermissionTileInCard(
                    label: 'Pin Messages',
                    value: _pinMessages,
                    onChanged: (v) => setState(() => _pinMessages = v),
                    showDivider: true,
                    isDark: isDark,
                  ),
                  _PermissionTileInCard(
                    label: 'Add other members',
                    value: _addOtherMembers,
                    onChanged: (v) => setState(() => _addOtherMembers = v),
                    showDivider: false,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Edit Group Admins
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(isDark),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Group Admins',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary(isDark),
                        fontSize: 15,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppTheme.iconColorSubtle(isDark),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable widgets ────────────────────────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _SettingsRow({required this.label, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 15),
            ),
            Icon(Icons.chevron_right, color: AppTheme.iconColorSubtle(isDark), size: 22),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _PermissionTile({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 14),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.successGreen(isDark),
            inactiveTrackColor: isDark ? HexColor('#3A3A3A') : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

class _PermissionTileInCard extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;
  final bool isDark;

  const _PermissionTileInCard({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.showDivider,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 13.5,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.successGreen(isDark),
                inactiveTrackColor: isDark ? HexColor('#3A3A3A') : Colors.grey.shade300,
              ),
            ],
          ),
        ),
        if (showDivider) Divider(color: AppTheme.dividerSubtle(isDark), height: 1, indent: 16),
      ],
    );
  }
}

// Keep old class name as alias so nothing else breaks
typedef CreateNewGroupScreen = CreateGroupStep1Screen;
