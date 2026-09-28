import 'package:flutter/material.dart';
import 'package:qik_talk/features/status/services/status_upload_manager.dart';

/// Floating upload progress banner.
///
/// Usage in status_screen.dart Stack:
///
///   Positioned(
///     top: MediaQuery.of(context).padding.top + 66,
///     left: 16,
///     right: 16,
///     child: const StatusUploadBanner(),
///   ),
///
/// The widget shows itself only when StatusUploadManager.progress != null.
/// It returns SizedBox.shrink() when there is no active upload so it takes
/// zero space and never interferes with layout.
class StatusUploadBanner extends StatelessWidget {
  const StatusUploadBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final mgr = StatusUploadManager();

    return ValueListenableBuilder<String?>(
      valueListenable: mgr.error,
      builder: (context, error, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: mgr.done,
          builder: (context, done, _) {
            return ValueListenableBuilder<double?>(
              valueListenable: mgr.progress,
              builder: (context, progress, _) {
                final isError = error != null;
                final isDone = done && !isError;
                final isUploading = progress != null && !done && !isError;

                // Fully idle — show nothing
                if (!isUploading && !isDone && !isError) {
                  return const SizedBox.shrink();
                }

                return Material(
                  color: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isError
                          ? const Color(0xFF7F1A1A)
                          : isDone
                          ? const Color(0xFF1A3A2A)
                          : const Color(0xFF1B1B1B),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isError
                                  ? Icons.error_outline
                                  : isDone
                                  ? Icons.check_circle_outline
                                  : Icons.cloud_upload_outlined,
                              color: isError
                                  ? Colors.red.shade300
                                  : isDone
                                  ? const Color(0xFF00C853)
                                  : Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isError
                                    ? 'Upload failed — $error'
                                    : isDone
                                    ? 'Status posted! 🎉'
                                    : 'Posting your status…',
                                style: TextStyle(
                                  color: isError
                                      ? Colors.red.shade300
                                      : Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'DM Sans',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUploading)
                              Text(
                                '${((progress ?? 0) * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 12,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                          ],
                        ),
                        if (isUploading) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (progress ?? 0).clamp(0.0, 1.0),
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF1A7F4B),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
