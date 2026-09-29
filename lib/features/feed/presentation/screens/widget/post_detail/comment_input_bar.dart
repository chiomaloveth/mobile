import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:hexcolor/hexcolor.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:qik_talk/features/chat/single_chat/components/recorder_ui.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/services/audio_recorder_service.dart';

class CommentInputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isPosting;
  final VoidCallback onPost;
  final Function(File audioFile)? onSendVoiceNote;
  final String? replyingToUsername;
  final VoidCallback? onCancelReply;

  const CommentInputBar({
    super.key,
    required this.controller,
    required this.isPosting,
    required this.onPost,
    this.onSendVoiceNote,
    this.replyingToUsername,
    this.onCancelReply,
  });

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  // Audio Recording State
  bool _isRecording = false;
  bool _isPreviewing = false;
  late final AudioRecorderService _audioRecorder;
  String? _recordingPath;
  int _recordingDuration = 0;
  Timer? _recordTimer;

  bool get _showRecorder => _isRecording || _isPreviewing;

  late ValueNotifier<bool> _hasText;

  // Emoji Picker State
  bool _showEmojiPicker = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorderService();
    _hasText = ValueNotifier(widget.controller.text.trim().isNotEmpty);
    widget.controller.addListener(_onTextChanged);

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (_hasText.value != hasText) {
      _hasText.value = hasText;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _audioRecorder.dispose();
    _recordTimer?.cancel();
    _hasText.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        _isRecording = true;
        _isPreviewing = false;
        _recordingDuration = 0;
      });

      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _recordingDuration++);
      });

      await _audioRecorder.startRecording();
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
      if (mounted) {
        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(SnackBar(content: Text('Error recording audio: $e')));
      }
    }
  }

  Future<void> _stopRecordingPreview() async {
    if (!_isRecording) return;

    _recordTimer?.cancel();
    final path = await _audioRecorder.stopRecording();

    if (path == null || _recordingDuration == 0) {
      _resetRecordingState();
      return;
    }

    setState(() {
      _recordingPath = path;
      _isRecording = false;
      _isPreviewing = true;
    });
  }

  void _resetRecordingState() {
    setState(() {
      _isRecording = false;
      _isPreviewing = false;
      _recordingPath = null;
      _recordingDuration = 0;
    });
  }

  void _deleteRecording() async {
    _recordTimer?.cancel();
    await _audioRecorder.stopRecording();
    _resetRecordingState();
  }

  Future<void> _sendRecording() async {
    if (_recordingPath == null && _isRecording) {
      await _stopRecordingPreview();
    }

    if (_recordingPath == null) return;

    final path = _recordingPath!;
    final audioFile = File(path);

    widget.onSendVoiceNote?.call(audioFile);
    _resetRecordingState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = AppTheme.textPrimary(isDark);
    final Color subtleColor = AppTheme.textSecondary(isDark);
    final Color bgColor = AppTheme.cardBg(isDark);
    final Color inputBg = AppTheme.scaffoldBg(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: AppTheme.divider(isDark), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _showRecorder
              ? RecorderUI(
                  onDelete: _deleteRecording,
                  onSend: _sendRecording,
                  recorderController: _audioRecorder.recorderController,
                  recordingDuration: _recordingDuration,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: widget.replyingToUsername != null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBgAlt(isDark),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.divider(isDark), width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.reply, size: 14, color: subtleColor),
                            const SizedBox(width: 8),
                            Text(
                              'Replying to ${widget.replyingToUsername}',
                              style: GoogleFonts.poppins(
                                color: subtleColor,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: widget.onCancelReply,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.iconBg(isDark),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 12,
                                  color: subtleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      secondChild: const SizedBox(width: double.infinity),
                    ),
                    Container(
                      key: const ValueKey('input_bar'),
                      decoration: BoxDecoration(color: inputBg),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              focusNode: _focusNode,
                              controller: widget.controller,
                              style: GoogleFonts.poppins(
                                color: textColor,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Add comment...',
                                hintStyle: GoogleFonts.poppins(
                                  color: AppTheme.textHint(isDark),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              maxLines: null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ValueListenableBuilder<bool>(
                            valueListenable: _hasText,
                            builder: (context, hasText, child) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (hasText) {
                                        if (!widget.isPosting) {
                                          widget.onPost();
                                        }
                                      } else {
                                        _startRecording();
                                      }
                                    },
                                    child: widget.isPosting
                                        ? Icon(Icons.send,
                                            color: textColor.withValues(alpha: 0.5), size: 22)
                                        : hasText
                                        ? Icon(Icons.send,
                                            color: textColor, size: 22)
                                        : SvgPicture.asset(
                                            'assets/svgs/mic.svg',
                                            colorFilter: ColorFilter.mode(
                                              textColor,
                                              BlendMode.srcIn,
                                            ),
                                            width: 22,
                                            height: 22,
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: Mention user feature
                                    },
                                    child: SvgPicture.asset(
                                      'assets/svgs/at.svg',
                                      colorFilter: ColorFilter.mode(
                                        textColor,
                                        BlendMode.srcIn,
                                      ),
                                      width: 22,
                                      height: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      if (_showEmojiPicker) {
                                        _focusNode.requestFocus();
                                      } else {
                                        _focusNode.unfocus();
                                      }
                                      setState(() {
                                        _showEmojiPicker = !_showEmojiPicker;
                                      });
                                    },
                                    child: SvgPicture.asset(
                                      'assets/svgs/emoji.svg',
                                      colorFilter: ColorFilter.mode(
                                        textColor,
                                        BlendMode.srcIn,
                                      ),
                                      width: 22,
                                      height: 22,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_showEmojiPicker)
                      SizedBox(
                        height: 250,
                        child: EmojiPicker(
                          textEditingController: widget.controller,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
