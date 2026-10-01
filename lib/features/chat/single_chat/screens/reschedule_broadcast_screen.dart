// reschedule_broadcast_screen.dart
// Drop into: lib/features/chat/single_chat/screens/reschedule_broadcast_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/chat/general/model/broadcast_model.dart';
import 'package:qik_talk/features/chat/general/services/broadcast_service.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';

// ─────────────────────────────────────────────────────────────
// RescheduleBroadcastScreen
// Allows the user to pick a new date + time for a broadcast.
// Calls PUT /api/v1/chat/broadcast/:id with the new scheduledAt.
// ─────────────────────────────────────────────────────────────
class RescheduleBroadcastScreen extends StatefulWidget {
  final BroadcastList broadcast;

  const RescheduleBroadcastScreen({super.key, required this.broadcast});

  @override
  State<RescheduleBroadcastScreen> createState() =>
      _RescheduleBroadcastScreenState();
}

class _RescheduleBroadcastScreenState extends State<RescheduleBroadcastScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;
  final BroadcastService _service = BroadcastService();

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing scheduled time if available
    if (widget.broadcast.scheduledAt != null) {
      _selectedDate = widget.broadcast.scheduledAt;
      _selectedTime = TimeOfDay.fromDateTime(widget.broadcast.scheduledAt!);
    }
  }

  ThemeData get _pickerTheme => ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: HexColor("#FB8830"),
      surface: const Color(0xFF1C1C1E),
      onSurface: Colors.white,
    ),
    dialogBackgroundColor: const Color(0xFF1C1C1E),
  );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(data: _pickerTheme, child: child!),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(data: _pickerTheme, child: child!),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  DateTime? get _combined {
    if (_selectedDate == null || _selectedTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  bool get _canSave => _combined != null && _combined!.isAfter(DateTime.now());

  Future<void> _save() async {
    if (!_canSave) {
      _showSnack('Please select a future date and time', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = await _service.updateBroadcast(
        widget.broadcast.id,
        broadcastStatus: 'scheduled',
        scheduledAt: _combined!.toIso8601String(),
      );

      if (mounted) {
        // Notify broadcast list + detail screen in real-time
        try {
          GlobalSocketService().broadcastUpdatedController.add({
            ...updated.toJson(),
            '_socketEvent': 'updated',
          });
          debugPrint('📢 RescheduleBroadcast: notified stream');
        } catch (e) {
          debugPrint('⚠️ Could not notify broadcast stream: $e');
        }
        _showSnack('Broadcast rescheduled!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('❌ reschedule error: $e');
      if (mounted) _showSnack('Failed to reschedule: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
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

  String _formatDate(DateTime dt) => DateFormat('EEEE, d MMMM yyyy').format(dt);

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  // ── BUILD ────────────────────────────────────────────────────
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
              'Reschedule Broadcast',
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
            // ── Broadcast info card ──────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: HexColor("#FB8830").withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.campaign_outlined,
                      color: HexColor("#FB8830"),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.broadcast.name,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.broadcast.members.length} recipients',
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
            ),

            const SizedBox(height: 32),

            Text(
              'Select New Date & Time',
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // ── Date picker tile ─────────────────────────────
            _pickerTile(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: _selectedDate != null
                  ? _formatDate(_selectedDate!)
                  : 'Select date',
              hasValue: _selectedDate != null,
              onTap: _pickDate,
              isDark: isDark,
            ),

            const SizedBox(height: 12),

            // ── Time picker tile ─────────────────────────────
            _pickerTile(
              icon: Icons.access_time_outlined,
              label: 'Time',
              value: _selectedTime != null
                  ? _formatTime(_selectedTime!)
                  : 'Select time',
              hasValue: _selectedTime != null,
              onTap: _pickTime,
              isDark: isDark,
            ),

            // ── Preview of selected datetime ─────────────────
            if (_combined != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: HexColor("#FB8830").withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: HexColor("#FB8830").withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: HexColor("#FB8830"), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scheduled for',
                            style: GoogleFonts.poppins(
                              color: HexColor("#FB8830"),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            DateFormat(
                              'd MMM yyyy, hh:mm a',
                            ).format(_combined!),
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_combined!.isAfter(DateTime.now()))
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                  ],
                ),
              ),
              if (!_combined!.isAfter(DateTime.now())) ...[
                const SizedBox(height: 8),
                Text(
                  'Please select a future date and time.',
                  style: GoogleFonts.poppins(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ],

            const Spacer(),

            // ── Save button ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (_isSaving || !_canSave) ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#FB8830"),
                  disabledBackgroundColor: HexColor("#FB8830").withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Confirm Reschedule',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
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

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required String value,
    required bool hasValue,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? HexColor("#FB8830").withOpacity(0.4)
                : AppTheme.textHint(isDark).withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: hasValue
                    ? HexColor("#FB8830").withOpacity(0.15)
                    : AppTheme.textHint(isDark).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: hasValue
                    ? HexColor("#FB8830")
                    : AppTheme.textHint(isDark),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textHint(isDark),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: hasValue
                          ? AppTheme.textPrimary(isDark)
                          : AppTheme.textHint(isDark),
                      fontSize: 14,
                      fontWeight: hasValue
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textHint(isDark),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
