import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/services/chat_settings_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EditChatNameDialog
//
// Usage:
//   final newName = await showDialog<String>(
//     context: context,
//     builder: (_) => EditChatNameDialog(
//       chatId: chatId,
//       currentName: currentName,
//       label: 'Community Name',   // or 'Group Name'
//       isCommunity: true,         // ← REQUIRED for communities
//     ),
//   );
//   if (newName != null) setState(() => _name = newName);
// ─────────────────────────────────────────────────────────────────────────────

class EditChatNameDialog extends StatefulWidget {
  final String chatId;
  final String currentName;
  final String label;

  /// Set to true when renaming a community so the correct endpoint is used:
  ///   community → PUT /chat/community/:id   body: { chatName, name }
  ///   group     → PUT /chat/group/rename    body: { chatId, chatName }
  final bool isCommunity;

  const EditChatNameDialog({
    super.key,
    required this.chatId,
    required this.currentName,
    this.label = 'Name',
    this.isCommunity = false, // ← defaults to group behaviour (safe)
  });

  @override
  State<EditChatNameDialog> createState() => _EditChatNameDialogState();
}

class _EditChatNameDialogState extends State<EditChatNameDialog> {
  final ChatSettingsService _service = ChatSettingsService();
  late TextEditingController _ctrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '${widget.label} cannot be empty');
      return;
    }
    if (name == widget.currentName) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    // ✅ FIX: pass isCommunity so the correct endpoint is called
    final result = await _service.renameChatOrCommunity(
      chatId: widget.chatId,
      newName: name,
      isCommunity: widget.isCommunity,
    );

    if (result.success) {
      if (mounted) Navigator.pop(context, name);
    } else {
      setState(() {
        _saving = false;
        _error = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HexColor('#1B1B1B'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Edit ${widget.label}',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLength: 50,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              counterStyle: GoogleFonts.poppins(
                color: HexColor('#787880'),
                fontSize: 11,
              ),
              hintText: 'Enter ${widget.label.toLowerCase()}',
              hintStyle: GoogleFonts.poppins(
                color: HexColor('#787880'),
                fontSize: 14,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: HexColor('#3A3A3A')),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: HexColor('#FB8830')),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: HexColor('#787880')),
          ),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: HexColor('#FB8830'),
                  ),
                )
              : Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    color: HexColor('#FB8830'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EditDescriptionDialog  (same pattern, for description field)
// ─────────────────────────────────────────────────────────────────────────────

class EditDescriptionDialog extends StatefulWidget {
  final String chatId;
  final String currentDescription;
  final String label;

  /// Set to true when editing a community description so the correct
  /// endpoint is used:
  ///   community → PATCH /chat/:id           body: { description }
  ///   group     → PUT   /chat/group/:id/description
  final bool isCommunity;

  const EditDescriptionDialog({
    super.key,
    required this.chatId,
    required this.currentDescription,
    this.label = 'Description',
    this.isCommunity = false,
  });

  @override
  State<EditDescriptionDialog> createState() => _EditDescriptionDialogState();
}

class _EditDescriptionDialogState extends State<EditDescriptionDialog> {
  final ChatSettingsService _service = ChatSettingsService();
  late TextEditingController _ctrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentDescription);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    // ✅ FIX: pass isCommunity so the correct endpoint is called
    final result = await _service.updateDescription(
      chatId: widget.chatId,
      description: _ctrl.text.trim(),
      isCommunity: widget.isCommunity,
    );

    if (result.success) {
      if (mounted) Navigator.pop(context, _ctrl.text.trim());
    } else {
      setState(() {
        _saving = false;
        _error = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HexColor('#1B1B1B'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Edit ${widget.label}',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLength: 200,
            maxLines: 4,
            minLines: 2,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              counterStyle: GoogleFonts.poppins(
                color: HexColor('#787880'),
                fontSize: 11,
              ),
              hintText: 'Add a description...',
              hintStyle: GoogleFonts.poppins(
                color: HexColor('#787880'),
                fontSize: 14,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: HexColor('#3A3A3A')),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: HexColor('#FB8830')),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: HexColor('#787880')),
          ),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: HexColor('#FB8830'),
                  ),
                )
              : Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    color: HexColor('#FB8830'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GroupSettingsSheet  —  disappearing messages + only-admins toggles
// ─────────────────────────────────────────────────────────────────────────────

class GroupSettingsSheet extends StatefulWidget {
  final String chatId;
  final bool isAdmin;
  final bool initialOnlyAdminsMessage;
  final bool initialOnlyAdminsEditInfo;
  final bool initialDisappearing;
  final int initialDisappearDuration;
  final VoidCallback? onChanged;

  const GroupSettingsSheet({
    super.key,
    required this.chatId,
    required this.isAdmin,
    this.initialOnlyAdminsMessage = false,
    this.initialOnlyAdminsEditInfo = false,
    this.initialDisappearing = false,
    this.initialDisappearDuration = 0,
    this.onChanged,
  });

  @override
  State<GroupSettingsSheet> createState() => _GroupSettingsSheetState();
}

class _GroupSettingsSheetState extends State<GroupSettingsSheet> {
  final ChatSettingsService _service = ChatSettingsService();

  late bool _onlyAdminsMsg;
  late bool _onlyAdminsEdit;
  late bool _disappearing;
  late int _disappearDuration;

  bool _savingMsg = false;
  bool _savingEdit = false;
  bool _savingDisappear = false;

  static const List<Map<String, dynamic>> _durations = [
    {'label': 'Off', 'value': 0},
    {'label': '24 hours', 'value': 86400},
    {'label': '7 days', 'value': 604800},
    {'label': '30 days', 'value': 2592000},
  ];

  @override
  void initState() {
    super.initState();
    _onlyAdminsMsg = widget.initialOnlyAdminsMessage;
    _onlyAdminsEdit = widget.initialOnlyAdminsEditInfo;
    _disappearing = widget.initialDisappearing;
    _disappearDuration = widget.initialDisappearDuration;
  }

  Future<void> _toggleAdminsMsg(bool val) async {
    setState(() {
      _savingMsg = true;
      _onlyAdminsMsg = val;
    });
    await _service.setOnlyAdminsCanMessage(chatId: widget.chatId, value: val);
    setState(() => _savingMsg = false);
    widget.onChanged?.call();
  }

  Future<void> _toggleAdminsEdit(bool val) async {
    setState(() {
      _savingEdit = true;
      _onlyAdminsEdit = val;
    });
    await _service.setOnlyAdminsCanEditInfo(chatId: widget.chatId, value: val);
    setState(() => _savingEdit = false);
    widget.onChanged?.call();
  }

  Future<void> _setDisappearing(int duration) async {
    setState(() {
      _savingDisappear = true;
      _disappearDuration = duration;
      _disappearing = duration > 0;
    });
    await _service.setDisappearingMessages(
      chatId: widget.chatId,
      enabled: duration > 0,
      durationSeconds: duration,
    );
    setState(() => _savingDisappear = false);
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor('#1B1B1B'),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: HexColor('#3A3A3A'),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Group Settings',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildToggle(
            icon: Icons.message_outlined,
            title: 'Only admins can send messages',
            subtitle: 'Other members can only read',
            value: _onlyAdminsMsg,
            loading: _savingMsg,
            enabled: widget.isAdmin,
            onChanged: _toggleAdminsMsg,
          ),
          const SizedBox(height: 4),
          Divider(color: HexColor('#2A2A2A')),
          const SizedBox(height: 4),
          _buildToggle(
            icon: Icons.edit_outlined,
            title: 'Only admins can edit group info',
            subtitle: 'Name, description and image',
            value: _onlyAdminsEdit,
            loading: _savingEdit,
            enabled: widget.isAdmin,
            onChanged: _toggleAdminsEdit,
          ),
          const SizedBox(height: 4),
          Divider(color: HexColor('#2A2A2A')),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: HexColor('#242424'),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: HexColor('#FB8830'),
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disappearing messages',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _disappearing
                          ? _durations.firstWhere(
                              (d) => d['value'] == _disappearDuration,
                              orElse: () => _durations.last,
                            )['label']
                          : 'Off',
                      style: GoogleFonts.poppins(
                        color: HexColor('#787880'),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_savingDisappear)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: HexColor('#FB8830'),
                  ),
                )
              else if (widget.isAdmin)
                DropdownButton<int>(
                  value: _disappearDuration,
                  dropdownColor: HexColor('#1B1B1B'),
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: HexColor('#787880'),
                  ),
                  items: _durations
                      .map(
                        (d) => DropdownMenuItem<int>(
                          value: d['value'] as int,
                          child: Text(
                            d['label'] as String,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) _setDisappearing(val);
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool loading,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: HexColor('#242424'),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: HexColor('#FB8830'), size: 18),
        ),
        const SizedBox(width: 14),
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
                  color: HexColor('#787880'),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (loading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: HexColor('#FB8830'),
            ),
          )
        else
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: HexColor('#FB8830'),
            inactiveTrackColor: HexColor('#3A3A3A'),
          ),
      ],
    );
  }
}
