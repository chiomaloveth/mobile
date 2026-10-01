import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/feed/presentation/screens/settings/notification/tone_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

/// Thin wrapper around [ToneSelectionScreen] that persists the chosen
/// notification tone per chat/group using SharedPreferences.
///
/// Key format:  "chat_tone_uri_<chatId>"   → content URI / asset path
///              "chat_tone_name_<chatId>"  → human-readable label
class ChatToneSelectionScreen extends StatefulWidget {
  final String chatId;
  final String chatName;

  const ChatToneSelectionScreen({
    super.key,
    required this.chatId,
    required this.chatName,
  });

  @override
  State<ChatToneSelectionScreen> createState() =>
      _ChatToneSelectionScreenState();
}

class _ChatToneSelectionScreenState extends State<ChatToneSelectionScreen> {
  String _currentToneUri = 'Default';
  String _currentToneName = 'Default';
  bool _loaded = false;

  String get _uriKey => 'chat_tone_uri_${widget.chatId}';
  String get _nameKey => 'chat_tone_name_${widget.chatId}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentToneUri = prefs.getString(_uriKey) ?? 'Default';
        _currentToneName = prefs.getString(_nameKey) ?? 'Default';
        _loaded = true;
      });
    }
  }

  Future<void> _save(String name, String uri) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uriKey, uri);
    await prefs.setString(_nameKey, name);
    if (mounted) {
      setState(() {
        _currentToneUri = uri;
        _currentToneName = name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notification tone set to "$name"',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1A7F4B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg(
          Theme.of(context).brightness == Brightness.dark,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ToneSelectionScreen(
      title: widget.chatName,
      note:
          'This tone will play for new messages from this chat only. '
          'Your default notification tone plays for all other chats.',
      currentTone: _currentToneUri,
      soundType: 'notification',
      onToneSelected: _save,
    );
  }
}
