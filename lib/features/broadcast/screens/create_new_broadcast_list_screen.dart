import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/chat/general/model/broadcast_model.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';

// ─────────────────────────────────────────────────────────────
// CreateBroadcastScreen
// Matches Figma: Images 2, 3, 4
// ─────────────────────────────────────────────────────────────
class CreateBroadcastScreen extends StatefulWidget {
  /// Pass an existing broadcast to edit it instead of creating a new one.
  final BroadcastList? existing;

  /// Pre-selected users passed from CreateBroadcastListScreen
  final List<dynamic> preSelectedUsers;

  /// Optional list name from CreateBroadcastListScreen
  final String listName;

  const CreateBroadcastScreen({
    super.key,
    this.existing,
    this.preSelectedUsers = const [],
    this.listName = '',
  });

  @override
  State<CreateBroadcastScreen> createState() => _CreateBroadcastScreenState();
}

class _CreateBroadcastScreenState extends State<CreateBroadcastScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  BroadcastAudience _selectedAudience = BroadcastAudience.allUsers;
  bool _scheduleForLater = false;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  bool _isSending = false;
  bool _isSavingDraft = false;

  // Dynamic: populated from pre-selected users
  late Map<BroadcastAudience, int> _audienceCounts;
  // Holds the pre-selected users passed from list screen
  late List<dynamic> _selectedUsers;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    // Init selected users and dynamic audience counts
    _selectedUsers = List.from(widget.preSelectedUsers);
    final int total = _selectedUsers.length;
    _audienceCounts = {
      BroadcastAudience.allUsers: total,
      BroadcastAudience.premiumMembers: total,
      BroadcastAudience.communityMembers: total,
    };

    if (_isEditing) {
      _titleController.text = (widget.existing?.name ?? '').trim();
      _messageController.text = (widget.existing?.latestMessage ?? '').trim();
      _selectedAudience =
          widget.existing?.audience ?? BroadcastAudience.allUsers;
      final scheduledAt = widget.existing?.scheduledAt;
      if (scheduledAt != null) {
        _scheduleForLater = true;
        _scheduledDate = scheduledAt;
        _scheduledTime = TimeOfDay.fromDateTime(scheduledAt);
      }
    } else if (widget.listName.isNotEmpty) {
      _titleController.text = widget.listName;
    }
    _titleController.addListener(() => setState(() {}));
    _messageController.addListener(() => setState(() {}));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _scheduledDate ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: HexColor("#FB8830"),
            surface: const Color(0xFF1C1C1E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: HexColor("#FB8830"),
            surface: const Color(0xFF1C1C1E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _scheduledTime = picked);
  }

  DateTime? get _combinedScheduledAt {
    if (_scheduledDate == null || _scheduledTime == null) return null;
    return DateTime(
      _scheduledDate!.year,
      _scheduledDate!.month,
      _scheduledDate!.day,
      _scheduledTime!.hour,
      _scheduledTime!.minute,
    );
  }

  bool get _canSend {
    if (_titleController.text.trim().isEmpty) return false;
    if (_messageController.text.trim().isEmpty) return false;
    if (_scheduleForLater && _combinedScheduledAt == null) return false;
    return true;
  }

  Future<void> _sendBroadcast({bool asDraft = false}) async {
    if (!asDraft && !_canSend) {
      _showSnack('Please fill in title and message', isError: true);
      return;
    }

    setState(() {
      if (asDraft) {
        _isSavingDraft = true;
      } else {
        _isSending = true;
      }
    });

    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );

      String audienceStr;
      switch (_selectedAudience) {
        case BroadcastAudience.allUsers:
          audienceStr = 'all';
          break;
        case BroadcastAudience.premiumMembers:
          audienceStr = 'premium';
          break;
        case BroadcastAudience.communityMembers:
          audienceStr = 'community';
          break;
      }

      // Extract unique valid MongoDB ObjectIds only
      final userIds = <String>{};
      for (final u in _selectedUsers) {
        final id = u.id?.toString() ?? '';
        if (id.isNotEmpty &&
            RegExp(r'^[a-f\d]{24}$', caseSensitive: false).hasMatch(id)) {
          userIds.add(id);
        }
      }
      final uniqueUserIds = userIds.toList();

      final titleText = _titleController.text.trim();
      final messageText = _messageController.text.trim();

      // Build broadcast creation/update body
      // The backend fan-out happens automatically when we POST to /api/v1/message
      // with the broadcast chatId — we only need userIds here for CREATING the broadcast group
      final body = <String, dynamic>{
        'chatName': titleText.isNotEmpty ? titleText : 'Broadcast',
        'name': titleText.isNotEmpty ? titleText : 'Broadcast',
        'content': messageText,
        'audience': audienceStr,
        'broadcastStatus': asDraft
            ? 'draft'
            : (_scheduleForLater ? 'scheduled' : 'sent'),
        if (uniqueUserIds.isNotEmpty) 'userIds': uniqueUserIds,
      };

      if (_scheduleForLater && _combinedScheduledAt != null) {
        body['scheduledAt'] = _combinedScheduledAt!.toIso8601String();
      }

      http.Response response;

      if (_isEditing) {
        // PUT /api/v1/chat/broadcast/:id
        response = await http.put(
          Uri.parse(
            '${ApiStrings.baseUri}chat/broadcast/${widget.existing!.id}',
          ),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(body),
        );
      } else {
        // POST /api/v1/chat/broadcast
        response = await http.post(
          Uri.parse('${ApiStrings.baseUri}chat/broadcast'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(body),
        );
      }

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final respData = json.decode(response.body);

        // Extract the broadcast chat ID from the response
        final Map<String, dynamic>? payload =
            (respData is Map && respData.containsKey('data'))
            ? Map<String, dynamic>.from(respData['data'] as Map)
            : (respData is Map<String, dynamic> ? respData : null);

        final broadcastChatId = (payload?['_id'] ?? payload?['id'] ?? '')
            .toString();

        // ── If not a draft and we have a message, fan-out via message endpoint ──
        // The backend automatically delivers to each member's private DM
        if (!asDraft &&
            !_scheduleForLater &&
            messageText.isNotEmpty &&
            broadcastChatId.isNotEmpty) {
          try {
            final token = await SaveValues().getString(
              AppPreferenceHelper.AUTH_TOKEN,
            );
            final msgResponse = await http.post(
              Uri.parse('${ApiStrings.baseUri}message'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'chatId': broadcastChatId,
                'content': messageText,
              }),
            );
            debugPrint('📢 Fan-out message: ${msgResponse.statusCode}');
            debugPrint(
              '📢 Fan-out body: ${msgResponse.body.substring(0, msgResponse.body.length.clamp(0, 200))}',
            );
          } catch (e) {
            debugPrint('⚠️ Fan-out message failed: $e');
          }
        }

        final msg = asDraft
            ? 'Saved as draft'
            : (_scheduleForLater ? 'Broadcast scheduled!' : 'Broadcast sent!');
        _showSnack(msg);

        // ── Notify broadcast list stream ──────────────────────────────────────
        try {
          if (payload != null) {
            GlobalSocketService().broadcastUpdatedController.add({
              ...payload,
              '_socketEvent': _isEditing ? 'updated' : 'created',
            });
            debugPrint(
              '📢 Broadcast ${_isEditing ? 'updated' : 'created'} — notified stream',
            );
          }
        } catch (e) {
          debugPrint('⚠️ Could not notify broadcast stream: $e');
        }

        Navigator.pop(context, true);
      } else {
        String errMsg = 'Something went wrong';
        try {
          final respBody = json.decode(response.body);
          errMsg = respBody['message']?.toString() ?? errMsg;
        } catch (_) {
          errMsg = 'Server error (${response.statusCode}). Check API endpoint.';
        }
        _showSnack(errMsg, isError: true);
      }
    } catch (e) {
      debugPrint('❌ _sendBroadcast error: $e');
      if (mounted)
        _showSnack('Network error. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _isSavingDraft = false;
        });
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isError ? Colors.red : HexColor("#1A7F4B"),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
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
              _isEditing ? 'Edit Broadcast' : 'Create Broadcast',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Broadcast Title ─────────────────────────────
            _sectionLabel('Broadcast Title', isDark),
            const SizedBox(height: 8),
            _inputField(
              controller: _titleController,
              hint: 'Enter broadcast title.......',
              maxLength: 100,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // ── Message ─────────────────────────────────────
            _sectionLabel('Message', isDark),
            const SizedBox(height: 8),
            _inputField(
              controller: _messageController,
              hint: 'write your message here.......',
              maxLength: 500,
              minLines: 6,
              maxLines: 10,
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // ── Select Audience ─────────────────────────────
            _sectionLabel('Select Audience', isDark),
            const SizedBox(height: 12),
            _audienceTile(
              BroadcastAudience.allUsers,
              'All Users',
              'Send to all registered users',
              isDark,
            ),
            const SizedBox(height: 10),
            _audienceTile(
              BroadcastAudience.premiumMembers,
              'Premium Members',
              'Send only to premium subscribers',
              isDark,
            ),
            const SizedBox(height: 10),
            _audienceTile(
              BroadcastAudience.communityMembers,
              'Community Members',
              'Send to specific community members',
              isDark,
            ),

            const SizedBox(height: 24),

            // ── When to Send ────────────────────────────────
            _sectionLabel('When to Send', isDark),
            const SizedBox(height: 12),
            _sendTimeTile(
              icon: Icons.send,
              title: 'Send Now',
              subtitle: 'Send broadcast immediately to selected audience',
              selected: !_scheduleForLater,
              onTap: () => setState(() => _scheduleForLater = false),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _sendTimeTile(
              icon: Icons.access_time,
              title: 'Schedule for Later',
              subtitle: 'Choose a specific date and time to send',
              selected: _scheduleForLater,
              onTap: () => setState(() => _scheduleForLater = true),
              isDark: isDark,
            ),

            // ── Date/Time pickers ───────────────────────────
            if (_scheduleForLater) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary(isDark),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _pickerField(
                          label: _scheduledDate != null
                              ? '${_scheduledDate!.month.toString().padLeft(2, '0')}/${_scheduledDate!.day.toString().padLeft(2, '0')}/${_scheduledDate!.year}'
                              : 'mm/dd/yyyy',
                          icon: Icons.calendar_today,
                          onTap: _pickDate,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary(isDark),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _pickerField(
                          label: _scheduledTime != null
                              ? _scheduledTime!.format(context)
                              : '--:--',
                          icon: Icons.access_time,
                          onTap: _pickTime,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // ── Broadcast Summary ───────────────────────────
            _buildSummary(isDark),

            const SizedBox(height: 24),

            // ── Send Button ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_isSending || _isSavingDraft)
                    ? null
                    : () => _sendBroadcast(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#201E1F"),
                  disabledBackgroundColor: HexColor("#201E1F").withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(color: HexColor("#FF00A8"), width: 2),
                  ),
                  elevation: 0,
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Send Broadcast',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Save as Draft ────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_isSending || _isSavingDraft)
                    ? null
                    : () => _sendBroadcast(asDraft: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#201E1F"),
                  disabledBackgroundColor: HexColor("#201E1F").withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(color: HexColor("#FF00A8"), width: 2),
                  ),
                  elevation: 0,
                ),
                child: _isSavingDraft
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Save as Draft',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: AppTheme.textPrimary(isDark),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    required bool isDark,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg(isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.textHint(isDark).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary(isDark),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: AppTheme.textHint(isDark),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 12,
          child: Text(
            '${controller.text.length}/$maxLength',
            style: GoogleFonts.poppins(
              color: AppTheme.textHint(isDark),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _audienceTile(
    BroadcastAudience audience,
    String title,
    String subtitle,
    bool isDark,
  ) {
    final bool selected = _selectedAudience == audience;
    final count = _audienceCounts[audience] ?? 0;

    return GestureDetector(
      onTap: () => setState(() => _selectedAudience = audience),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radio
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? HexColor("#FB8830")
                    : AppTheme.textHint(isDark),
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HexColor("#FB8830"),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sendTimeTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? HexColor("#FB8830")
                    : AppTheme.textHint(isDark),
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HexColor("#FB8830"),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: AppTheme.textPrimary(isDark)),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickerField({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.textHint(isDark).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: label.contains('/')
                      ? AppTheme.textPrimary(isDark)
                      : AppTheme.textHint(isDark),
                  fontSize: 13,
                ),
              ),
            ),
            Icon(icon, color: AppTheme.textHint(isDark), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(bool isDark) {
    final int count =
        _audienceCounts[_selectedAudience] ?? _selectedUsers.length;

    String audienceLabel;
    switch (_selectedAudience) {
      case BroadcastAudience.allUsers:
        audienceLabel = 'All Users';
        break;
      case BroadcastAudience.premiumMembers:
        audienceLabel = 'Premium Members';
        break;
      case BroadcastAudience.communityMembers:
        audienceLabel = 'Community Members';
        break;
    }

    String sendTime;
    if (!_scheduleForLater) {
      sendTime = 'Immediately';
    } else if (_combinedScheduledAt != null) {
      final dt = _combinedScheduledAt!;
      sendTime =
          '${dt.day}/${dt.month}/${dt.year} ${_scheduledTime?.format(context) ?? ''}';
    } else {
      sendTime = 'Not set';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              'Broadcast Summary',
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _summaryRow('Recipients:', '$count $audienceLabel', isDark),
        const SizedBox(height: 4),
        _summaryRow('Send Time:', sendTime, isDark),
      ],
    );
  }

  Widget _summaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary(isDark),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
