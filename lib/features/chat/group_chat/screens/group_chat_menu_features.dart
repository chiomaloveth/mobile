import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:qik_talk/features/chat/general/model/group_model.dart';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_api_service.dart';
import 'package:qik_talk/features/chat/general/services/group_chat_services/group_invite_service.dart';
import 'package:qik_talk/features/chat/group_chat/screens/add_to_groups_screen.dart';
import 'package:qik_talk/features/chat/single_chat/screens/chat_actions_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/features/chat/general/services/chat_settings_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MUTE DIALOG  (Images 4 & 5)
// ─────────────────────────────────────────────────────────────────────────────

class MuteNotificationsDialog extends StatefulWidget {
  final String chatId;
  const MuteNotificationsDialog({super.key, required this.chatId});

  @override
  State<MuteNotificationsDialog> createState() =>
      _MuteNotificationsDialogState();
}

class _MuteNotificationsDialogState extends State<MuteNotificationsDialog> {
  int? _selected; // 0=1h, 1=8h, 2=1wk, 3=always

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mute  message notifications',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Other members will not see that you muted this chat. You will still be notified if you are mentioned',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _muteOption(Icons.access_time_outlined, '1 Hour', 0),
            _muteOption(Icons.access_time_outlined, '8 Hours', 1),
            _muteOption(Icons.calendar_today_outlined, '1 Week', 2),
            _muteOption(Icons.notifications_off_outlined, 'Always', 3),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _dialogButton(
                    'Cancel',
                    onTap: () => Navigator.pop(context),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dialogButton(
                    'OK',
                    onTap: () async {
                      if (_selected == null) {
                        Navigator.pop(context);
                        return;
                      }
                      Navigator.pop(context, _selected);
                      // Call mute API for group chat — same endpoint as single
                      await ChatActionsService().muteChat(widget.chatId);
                    },
                    filled: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _muteOption(IconData icon, String label, int idx) {
    final bool active = _selected == idx;
    return GestureDetector(
      onTap: () => setState(() => _selected = idx),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? HexColor('#FF6B00') : Colors.white24,
              ),
              child: active
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogButton(
    String label, {
    required VoidCallback onTap,
    required bool filled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? Colors.transparent : const Color(0xFF2A2A2A),
          border: filled
              ? Border.all(
                  color: HexColor('#FF6B00').withOpacity(0.8),
                  width: 1.5,
                )
              : null,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXIT GROUP DIALOG  (Images 9 & 10)
// ─────────────────────────────────────────────────────────────────────────────

class ExitGroupDialog extends StatelessWidget {
  final String groupName;
  final bool isAdmin;
  final VoidCallback onExit;

  const ExitGroupDialog({
    super.key,
    required this.groupName,
    required this.isAdmin,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF3D2200),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout, color: HexColor('#FF6B00'), size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'Exit $groupName group',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isAdmin
                  ? "As an admin, you'll need to assign another admin before exiting, or delete the group instead."
                  : "Are you sure you want to leave this group?",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            if (isAdmin) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "You're an admin of this group. Make sure to assign another admin before leaving.",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _button(
                    'Cancel',
                    onTap: () => Navigator.pop(context),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _button(
                    'Exit',
                    onTap: () {
                      Navigator.pop(context);
                      onExit();
                    },
                    filled: true,
                    danger: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(
    String label, {
    required VoidCallback onTap,
    required bool filled,
    bool danger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? Colors.transparent : const Color(0xFF2A2A2A),
          border: filled
              ? Border.all(
                  color: HexColor('#FF6B00').withOpacity(0.8),
                  width: 1.5,
                )
              : null,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELETE GROUP DIALOG  (Image 11)
// ─────────────────────────────────────────────────────────────────────────────

class DeleteGroupDialog extends StatelessWidget {
  final String groupName;
  final VoidCallback onDelete;

  const DeleteGroupDialog({
    super.key,
    required this.groupName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF3D0000),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFFF3B30),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete $groupName group',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'This will permanently delete the group for all members. All messages and media will be lost.',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A0000),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All members will be removed and the group will be permanently deleted.',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: const Color(0xFFFF3B30).withOpacity(0.8),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'Delete',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFF3B30),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GROUP SETTINGS FULL SCREEN  (Image 8)
// ─────────────────────────────────────────────────────────────────────────────

class GroupSettingsFullScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupImage;
  final bool isAdmin;
  final List<GroupMember> members;
  final List<GroupMember> admins;
  final bool initialOnlyAdminsMessage;
  final bool initialOnlyAdminsEditInfo;
  final bool initialRequireApproval;
  final bool initialGroupNotifications;
  final VoidCallback? onChanged;

  const GroupSettingsFullScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupImage,
    required this.isAdmin,
    required this.members,
    required this.admins,
    this.initialOnlyAdminsMessage = false,
    this.initialOnlyAdminsEditInfo = true,
    this.initialRequireApproval = false,
    this.initialGroupNotifications = true,
    this.onChanged,
  });

  @override
  State<GroupSettingsFullScreen> createState() =>
      _GroupSettingsFullScreenState();
}

class _GroupSettingsFullScreenState extends State<GroupSettingsFullScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late bool _allowMembersAdd;
  late bool _requireApproval;
  late bool _groupNotifications;
  bool _saving = false;
  final SaveValues _saveValues = SaveValues();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.groupName);
    _descController = TextEditingController();
    _allowMembersAdd = !widget.initialOnlyAdminsMessage;
    _requireApproval = widget.initialRequireApproval;
    _groupNotifications = widget.initialGroupNotifications;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _saving = true);
    try {
      final newName = _nameController.text.trim();
      if (newName.isNotEmpty && newName != widget.groupName) {
        await GroupApiService().renameGroup(
          groupId: widget.groupId,
          newName: newName,
        );
      }
      widget.onChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Settings saved',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: HexColor('#1A7F4B'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, newName);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteGroup() async {
    showDialog(
      context: context,
      builder: (_) => DeleteGroupDialog(
        groupName: widget.groupName,
        onDelete: () async {
          try {
            final token = await _saveValues.getString(
              AppPreferenceHelper.AUTH_TOKEN,
            );
            await http.delete(
              Uri.parse('${ApiStrings.baseUri}chat/group/${widget.groupId}'),
              headers: {'Authorization': 'Bearer $token'},
            );
          } catch (_) {}
          if (mounted) {
            Navigator.of(context)
              ..pop()
              ..pop()
              ..pop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(Theme.of(context).brightness == Brightness.dark),
      body: Column(
        children: [
          // App bar
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('images/app_bar_gredient.png'),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.only(
              top: topPad + 10,
              left: 4,
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
                  'Group settings',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + name edit
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppTheme.cardBg(Theme.of(context).brightness == Brightness.dark),
                          backgroundImage: widget.groupImage.isNotEmpty
                              ? NetworkImage(widget.groupImage)
                              : null,
                          child: widget.groupImage.isEmpty
                              ? Icon(
                                  Icons.group,
                                  color: AppTheme.textPrimary(Theme.of(context).brightness == Brightness.dark),
                                  size: 40,
                                )
                              : null,
                        ),
                        if (widget.isAdmin)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: HexColor('#1A7F4B'),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.scaffoldBg(Theme.of(context).brightness == Brightness.dark),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Group name row
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.groupName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.isAdmin)
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white54,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      'Group · ${widget.members.length} participants',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Group name field
                  _label('Group Name'),
                  const SizedBox(height: 8),
                  _textField(_nameController, 'Group name'),
                  const SizedBox(height: 16),

                  // Description
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _label('Description'),
                      Text(
                        '${_descController.text.length}/200',
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: 4,
                      maxLength: 200,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Group description...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                        counterText: '',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor('#FF6B00'),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.save_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                      label: Text(
                        'Save Changes',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Members
                  ..._buildMembersSection(),
                  const SizedBox(height: 28),

                  // Permissions
                  _sectionHeader('Permissions'),
                  _permissionToggle(
                    'Allow Members to Add Others',
                    'Members can invite new people to the group',
                    _allowMembersAdd,
                    (v) => setState(() => _allowMembersAdd = v),
                  ),
                  _permissionToggle(
                    'Require Admin Approval',
                    'New members must be approved by admins',
                    _requireApproval,
                    (v) => setState(() => _requireApproval = v),
                  ),
                  const SizedBox(height: 20),

                  // Notifications
                  _sectionHeader('Notifications'),
                  _permissionToggle(
                    'Group Notifications',
                    'Receive notifications for group activity',
                    _groupNotifications,
                    (v) => setState(() => _groupNotifications = v),
                  ),
                  const SizedBox(height: 28),

                  if (widget.isAdmin) ...[
                    // Danger zone
                    _sectionHeader(
                      'Danger Zone',
                      color: const Color(0xFFFF3B30),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Deleting this group will remove all members and data permanently. This action cannot be undone.',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _deleteGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Delete Group',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMembersSection() {
    return [
      ...widget.members.map((m) {
        final isAdmin = widget.admins.any((a) => a.id == m.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: HexColor('#2A2A2A'),
                backgroundImage:
                    m.profilePicture != null && m.profilePicture!.isNotEmpty
                    ? NetworkImage(m.profilePicture!)
                    : null,
                child: m.profilePicture == null || m.profilePicture!.isEmpty
                    ? Text(
                        m.username.isNotEmpty
                            ? m.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.username,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    if (isAdmin)
                      Row(
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: HexColor('#FF6B00'),
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Admin',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Member',
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.isAdmin) ...[
                if (isAdmin)
                  _memberAction('Demote', const Color(0xFFFF9500), () async {
                    await GroupApiService().removeAdmin(
                      groupId: widget.groupId,
                      userId: m.id,
                    );
                    widget.onChanged?.call();
                  })
                else
                  _memberAction('Promote', HexColor('#1A7F4B'), () async {
                    await GroupApiService().makeUserAdmin(
                      groupId: widget.groupId,
                      userId: m.id,
                    );
                    widget.onChanged?.call();
                  }),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    await GroupApiService().removeUserFromGroup(
                      groupId: widget.groupId,
                      userId: m.id,
                    );
                    widget.onChanged?.call();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A0000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person_remove,
                      color: Color(0xFFFF3B30),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    ];
  }

  Widget _memberAction(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      color: Colors.white70,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );

  Widget _textField(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color ?? Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _permissionToggle(
    String title,
    String subtitle,
    bool value,
    void Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: HexColor('#FF6B00'),
            activeTrackColor: HexColor('#FF6B00').withOpacity(0.4),
            inactiveThumbColor: const Color(0xFF787880),
            inactiveTrackColor: const Color(0xFF39393D),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GROUP MENU BOTTOM SHEET  (Image 2 — the full menu)
// ─────────────────────────────────────────────────────────────────────────────

class GroupMenuSheet extends StatelessWidget {
  final String groupName;
  final bool isAdmin;
  final VoidCallback onGroupInfo;
  final VoidCallback onMedia;
  final VoidCallback onSearch;
  final VoidCallback onMute;
  final VoidCallback onAddMembers;
  final VoidCallback onShare;
  final VoidCallback onGroupSettings;
  final VoidCallback onArchive;
  final VoidCallback onExit;
  final VoidCallback onDelete;

  const GroupMenuSheet({
    required this.groupName,
    required this.isAdmin,
    required this.onGroupInfo,
    required this.onMedia,
    required this.onSearch,
    required this.onMute,
    required this.onAddMembers,
    required this.onShare,
    required this.onGroupSettings,
    required this.onArchive,
    required this.onExit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _menuItem(
              icon: Icons.info_outline,
              label: 'Group info',
              onTap: onGroupInfo,
            ),
            _menuItem(
              icon: Icons.photo_library_outlined,
              label: 'Media, links & docs',
              onTap: onMedia,
            ),
            _menuItem(icon: Icons.search, label: 'Search', onTap: onSearch),
            _menuItem(
              icon: Icons.notifications_off_outlined,
              label: 'Mute notifications',
              onTap: onMute,
            ),
            _menuItem(
              icon: Icons.person_add_outlined,
              label: 'Add members',
              onTap: onAddMembers,
            ),
            _menuItem(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: onShare,
            ),
            _menuItem(
              icon: Icons.settings_outlined,
              label: 'Group settings',
              onTap: onGroupSettings,
            ),
            _menuItem(
              icon: Icons.archive_outlined,
              label: 'Archive group',
              onTap: onArchive,
            ),
            _menuItem(
              icon: Icons.logout,
              label: 'Exit group',
              onTap: onExit,
              color: const Color(0xFFFF3B30),
            ),
            if (isAdmin)
              _menuItem(
                icon: Icons.delete_outline,
                label: 'Delete group',
                onTap: onDelete,
                color: const Color(0xFFFF3B30),
              ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.white70, size: 22),
            const SizedBox(width: 18),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color ?? Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
