import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/post_detail/comment_item_widget.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/post_detail/comment_input_bar.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

void showCommentBottomSheet(
  BuildContext context, {
  required GetFeedResponseData post,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return CommentBottomSheet(post: post);
    },
  );
}

class CommentBottomSheet extends ConsumerStatefulWidget {
  final GetFeedResponseData post;

  const CommentBottomSheet({super.key, required this.post});

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final SaveValues _saveValues = SaveValues();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadComments();
  }

  Future<void> _loadCurrentUser() async {
    final userId = await _saveValues.getString(AppPreferenceHelper.ID);
    if (mounted) {
      setState(() {
        currentUserId = userId;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadComments() {
    Future.microtask(() {
      ref.read(feedProvider.notifier).loadComments(widget.post.id);
    });
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();

    if (content.isEmpty) return;

    // Clear input immediately for snappy UX (optimistic)
    _commentController.clear();
    FocusScope.of(context).unfocus();

    final commentDto = <String, dynamic>{};
    commentDto['content'] = content;

    // Fire-and-forget: provider handles optimistic insert + rollback
    ref.read(feedProvider.notifier).addComment(widget.post.id, commentDto);
  }

  Future<void> _sendVoiceComment(File audioFile) async {
    final GetComment? result = await ref
        .read(feedProvider.notifier)
        .addCommentWithMedia(
          widget.post.id,
          mediaFile: audioFile,
          type: 'voice',
        );

    if (result != null && mounted) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text('Voice comment posted!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final comments = feedState.comments;
    final isLoading = feedState.isCommentsLoading;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for errors from the feed provider
    ref.listen(feedProvider.select((s) => s.error), (previous, next) {
      if (next != null && next.isNotEmpty) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(next), backgroundColor: Colors.redAccent),
        // );
      }
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBg(isDark),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      '${widget.post.commentCount} comments',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: AppTheme.textPrimary(isDark)),
                ),
              ],
            ),
          ),
          Divider(color: AppTheme.divider(isDark), height: 1),

          // Comments List
          Expanded(
            child: (isLoading && comments.isEmpty)
                ? Center(
                    child: Text(
                      'Loading comments...',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary(isDark),
                        fontSize: 14,
                      ),
                    ),
                  )
                : comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet. Be the first!',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary(isDark),
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return CommentItemWidget(
                        comment: comments[index],
                        currentUserId: currentUserId ?? '',
                      );
                    },
                  ),
          ),

          // Input Bar
          CommentInputBar(
            controller: _commentController,
            isPosting: isLoading,
            onPost: _postComment,
            onSendVoiceNote: _sendVoiceComment,
            replyingToUsername: feedState.replyingToComment?.user.username,
            onCancelReply: () =>
                ref.read(feedProvider.notifier).clearReplyingTo(),
          ),

          // Padding for keyboard
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
