import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/post_detail/comment_audio_player.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/media_utils.dart';

import 'package:qik_talk/features/feed/presentation/screens/widget/post_options_bottom_sheet.dart';

class CommentItemWidget extends ConsumerStatefulWidget {
  final GetComment comment;
  final String currentUserId;

  const CommentItemWidget({
    super.key,
    required this.comment,
    required this.currentUserId,
  });

  @override
  ConsumerState<CommentItemWidget> createState() => _CommentItemWidgetState();
}

class _CommentItemWidgetState extends ConsumerState<CommentItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showReplies = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 2.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(CommentItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comment.isLikedBy(widget.currentUserId) &&
        !oldWidget.comment.isLikedBy(widget.currentUserId)) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final currentUserId = widget.currentUserId;
    final username = comment.user.username;
    final avatarUrl = comment.user.profilePicture;
    final timeAgo = comment.getTimeAgo();
    final isReply = comment.parentComment != null;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = AppTheme.textPrimary(isDark);
    final Color subtleColor = AppTheme.textSecondary(isDark);
    final Color hintColor = AppTheme.textHint(isDark);
    final Color dividerColor = AppTheme.divider(isDark);

    final bool hasReplies = comment.replies.isNotEmpty;
    final bool showToggle = comment.replies.length >= 4;
    final bool shouldRenderReplies = !showToggle || _showReplies;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isReply ? 48 : 16,
            right: 16,
            top: 8,
            bottom: 8,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Reply Line (L-shape)
              if (isReply)
                Positioned(
                  left: -26,
                  top: -20,
                  child: Container(
                    width: 24,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: dividerColor, width: 1.5),
                        bottom: BorderSide(color: dividerColor, width: 1.5),
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: isReply ? 14 : 18,
                    backgroundColor: HexColor("#FB8830"),
                    backgroundImage:
                        (avatarUrl.isNotEmpty && avatarUrl.startsWith('http'))
                        ? NetworkImage(MediaUtils.getThumbnailUrl(avatarUrl))
                        : null,
                    child: (avatarUrl.isEmpty || !avatarUrl.startsWith('http'))
                        ? Text(
                            username.trim().isNotEmpty
                                ? username.trim()[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: isReply ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: currentUserId == comment.user.id
                              ? () => _showDeleteDialog(context, ref)
                              : () => showCommentOptionsBottomSheet(
                                    context,
                                    commentId: comment.id,
                                    username: username,
                                  ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: GoogleFonts.poppins(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.end,
                                children: [
                                  if (comment.content != null &&
                                      comment.content!.isNotEmpty)
                                    Text(
                                      comment.content!,
                                      style: GoogleFonts.poppins(
                                        color: textColor,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    timeAgo,
                                    style: GoogleFonts.poppins(
                                      color: hintColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              if ((comment.type == 'audio' ||
                                      comment.type == 'voice') &&
                                  comment.media != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: CommentAudioPlayer(
                                    audioUrl: comment.media!,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (showToggle) ...[
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showReplies = !_showReplies;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            _showReplies
                                                ? 'Hide replies'
                                                : 'View replies (${comment.replies.length})',
                                            style: GoogleFonts.poppins(
                                              color: subtleColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            _showReplies
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: subtleColor,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                  ],
                                  GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(feedProvider.notifier)
                                          .setReplyingTo(comment);
                                    },
                                    child: Text(
                                      'Reply',
                                      style: GoogleFonts.poppins(
                                        color: subtleColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Like Button (Right Side)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(feedProvider.notifier)
                              .toggleLikeComment(comment.id, currentUserId);
                        },
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Icon(
                            comment.isLikedBy(currentUserId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: comment.isLikedBy(currentUserId)
                                ? HexColor("#FF00A8")
                                : subtleColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${comment.likes.length}',
                        style: GoogleFonts.poppins(
                          color: subtleColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        if (hasReplies && shouldRenderReplies)
          ...comment.replies.map(
            (reply) =>
                CommentItemWidget(comment: reply, currentUserId: currentUserId),
          ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
        backgroundColor: AppTheme.cardBg(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Delete Comment",
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this comment?",
          style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(feedProvider.notifier)
                  .deleteComment(
                    commentId: widget.comment.id,
                    postId: widget.comment.post,
                    parentCommentId: widget.comment.parentComment,
                  );
            },
            child: Text(
              "Delete",
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
      },
    );
  }
}
