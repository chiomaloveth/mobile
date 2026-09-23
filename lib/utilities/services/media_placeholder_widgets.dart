import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MediaPlaceholder
//
// Shown while an image/video is loading or being uploaded.
// Displays a grey shimmer with an optional blurred thumbnail overlay.
// ─────────────────────────────────────────────────────────────────────────────
class MediaPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  /// Optional local file path to show as a blurred preview while uploading.
  final String? previewImagePath;

  /// Optional network URL to show as a blurred preview.
  final String? previewImageUrl;

  const MediaPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.previewImagePath,
    this.previewImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1 — shimmer base
            Shimmer.fromColors(
              baseColor: const Color(0xFF2A2A2A),
              highlightColor: const Color(0xFF3A3A3A),
              child: Container(color: const Color(0xFF2A2A2A)),
            ),

            // Layer 2 — blurred preview (local file)
            if (previewImagePath != null)
              _BlurredPreview(path: previewImagePath!),

            // Layer 3 — blurred preview (network)
            if (previewImageUrl != null && previewImagePath == null)
              _BlurredNetworkPreview(url: previewImageUrl!),
          ],
        ),
      ),
    );
  }
}

class _BlurredPreview extends StatelessWidget {
  final String path;
  const _BlurredPreview({required this.path});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
        ),
        const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}

class _BlurredNetworkPreview extends StatelessWidget {
  final String url;
  const _BlurredNetworkPreview({required this.url});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
        ),
        const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UploadProgressOverlay
//
// Shown ON TOP of the media bubble while it is uploading.
// Shows a circular progress ring + percentage text.
// ─────────────────────────────────────────────────────────────────────────────
class UploadProgressOverlay extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const UploadProgressOverlay({
    super.key,
    required this.progress,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);
    final pct = (progress * 100).toStringAsFixed(0);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Semi-transparent dark overlay
            Container(color: Colors.black.withOpacity(0.45)),

            // Progress ring + label
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: progress > 0 ? progress : null,
                      strokeWidth: 3,
                      color: Colors.white,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (progress > 0)
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VideoThumbnailPlaceholder
//
// Shown while a video is initializing its player.
// ─────────────────────────────────────────────────────────────────────────────
class VideoThumbnailPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final String? thumbnailPath;
  final String? thumbnailUrl;
  final BorderRadius? borderRadius;

  const VideoThumbnailPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.thumbnailPath,
    this.thumbnailUrl,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);

    Widget? thumbWidget;
    if (thumbnailPath != null) {
      thumbWidget = Image.file(
        File(thumbnailPath!),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    } else if (thumbnailUrl != null) {
      thumbWidget = Image.network(
        thumbnailUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Shimmer base
            Shimmer.fromColors(
              baseColor: const Color(0xFF1A1A1A),
              highlightColor: const Color(0xFF2A2A2A),
              child: Container(color: const Color(0xFF1A1A1A)),
            ),

            // Thumbnail if available
            if (thumbWidget != null) thumbWidget,

            // Play icon + spinner overlay
            Container(
              color: Colors.black.withOpacity(thumbWidget != null ? 0.4 : 0),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
