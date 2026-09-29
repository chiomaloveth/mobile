import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';

enum ReportType { post, user, comment }

class PostOptionsBottomSheet extends ConsumerWidget {
  final String postId;
  final String userId;
  final String username;
  final ReportType reportType;

  const PostOptionsBottomSheet({
    super.key,
    required this.postId,
    required this.userId,
    required this.username,
    this.reportType = ReportType.post,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: HexColor('#1C1C1E'),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Report Option
          _buildOptionTile(
            icon: Icons.error_outline,
            label: reportType == ReportType.comment
                ? 'Report Comment'
                : 'Report Post',
            onTap: () {
              final navigator = Navigator.of(context);
              final feedNotifier = ref.read(feedProvider.notifier);
              navigator.pop();
              _showReportReasons(
                navigator.context,
                feedNotifier: feedNotifier,
                reportedItemId: postId,
                reportType: reportType,
                username: username,
              );
            },
          ),

          // Block User Option (Hidden for comments as per Figma)
          if (reportType != ReportType.comment)
            _buildOptionTile(
              icon: Icons.block,
              label: 'Block User',
              onTap: () {
                final navigator = Navigator.of(context);
                final feedNotifier = ref.read(feedProvider.notifier);
                navigator.pop();

                _showConfirmationSheet(
                  navigator.context,
                  title: 'Block @$username?',
                  description:
                      'They won\'t be able to find your profile, posts, or interact with you.',
                  actionLabel: 'Block User',
                  onAction: () async {
                    final subNavigator = Navigator.of(navigator.context);
                    subNavigator.pop();

                    final error = await feedNotifier.blockUser(userId);

                    if (error == null) {
                      _showSuccessSheet(
                        subNavigator.context,
                        description: '@$username has been blocked.',
                        subDescription: 'Go to your settings to unblock.',
                      );
                    } else {
                      if (navigator.context.mounted) {
                        ScaffoldMessenger.of(navigator.context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.red, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

void _showReportReasons(
  BuildContext context, {
  required FeedNotifier feedNotifier,
  required String reportedItemId,
  required ReportType reportType,
  required String username,
}) {
  final typeName = reportType == ReportType.comment
      ? 'Comment'
      : (reportType == ReportType.user ? 'User' : 'Post');

  showDialog(
    context: context,
    builder: (dialogContext) => Center(
      child: Material(
        color: Colors.transparent,
        child: ReportReasonsAlert(
          username: username,
          title: 'Report $typeName',
          subtitle: 'Why are you reporting @$username\'s $typeName?',
          onReasonSelected: (reason) {
            final navigator = Navigator.of(dialogContext);
            navigator.pop();

            _showConfirmationSheet(
              context,
              title: 'Report @$username?',
              description:
                  'Is this really what you want to do? Reporting help us keep the community safe.',
              actionLabel: 'Report $typeName',
              onAction: () async {
                final subNavigator = Navigator.of(context);
                subNavigator.pop();
                
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                final String itemType;
                if (reportType == ReportType.comment) {
                  itemType = 'Comment';
                } else if (reportType == ReportType.post) {
                  itemType = 'Post';
                } else {
                  itemType = 'User';
                }

                final error = await feedNotifier.submitReport(
                  reportedItemId: reportedItemId,
                  itemType: itemType,
                  reason: reason.toLowerCase().replaceAll(' ', '_'),
                  description: 'Reported for: $reason',
                  severity: 'high',
                );

                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                if (error == null) {
                  _showSuccessSheet(
                    context,
                    description: '@$username has been reported.',
                    subDescription:
                        'We\'ll review this $typeName and take appropriate action.',
                  );
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          },
        ),
      ),
    ),
  );
}

void _showSuccessSheet(
  BuildContext context, {
  required String description,
  required String subDescription,
}) {
  showDialog(
    context: context,
    builder: (context) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: HexColor('#1C1C1E'),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF34C759),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4434C759),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thank You',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showConfirmationSheet(
  BuildContext context, {
  required String title,
  required String description,
  required String actionLabel,
  required VoidCallback onAction,
}) {
  showDialog(
    context: context,
    builder: (context) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: HexColor('#1C1C1E'),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HexColor('#EA4359'),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor('#EA4359'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ReportReasonsAlert extends StatelessWidget {
  final String username;
  final String title;
  final String subtitle;
  final Function(String) onReasonSelected;

  const ReportReasonsAlert({
    super.key,
    required this.username,
    required this.title,
    required this.subtitle,
    required this.onReasonSelected,
  });

  @override
  Widget build(BuildContext context) {
    final reasons = [
      {'label': 'Spam', 'icon': Icons.flag_outlined},
      {'label': 'Harassment or bullying', 'icon': Icons.security_outlined},
      {'label': 'Hate speech', 'icon': Icons.error_outline},
      {
        'label': 'Violence or dangerous content',
        'icon': Icons.security_outlined,
      },
      {'label': 'False information', 'icon': Icons.error_outline},
      {'label': 'Inappropriate content', 'icon': Icons.flag_outlined},
    ];

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: HexColor('#1C1C1E'),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12, height: 1),

          ...reasons.map(
            (reason) => InkWell(
              onTap: () => onReasonSelected(reason['label'] as String),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      reason['icon'] as IconData,
                      color: Colors.orange.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        reason['label'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showPostOptionsBottomSheet(
  BuildContext context, {
  required String postId,
  required String userId,
  required String username,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => PostOptionsBottomSheet(
      postId: postId,
      userId: userId,
      username: username,
    ),
  );
}

void showCommentOptionsBottomSheet(
  BuildContext context, {
  required String commentId,
  required String username,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Consumer(
      builder: (context, ref, _) => Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: HexColor('#1C1C1E'),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),

          // Report Option
          InkWell(
            onTap: () {
              final navigator = Navigator.of(context);
              final feedNotifier = ref.read(feedProvider.notifier);
              navigator.pop();
              _showReportReasons(
                navigator.context,
                feedNotifier: feedNotifier,
                reportedItemId: commentId,
                reportType: ReportType.comment,
                username: username,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cancel Option
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
    ),
  );
}
