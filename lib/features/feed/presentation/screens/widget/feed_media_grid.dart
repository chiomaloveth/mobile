import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/media_utils.dart';
import 'video_duration_widget.dart';

class FeedMediaGrid extends StatelessWidget {
  final List<String> media;
  final Function(int)? onMediaTap;
  final bool isFillMode;

  const FeedMediaGrid({
    super.key,
    required this.media,
    this.onMediaTap,
    this.isFillMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (media.length == 1) {
      final isVideo = MediaUtils.isVideo(media[0]);
      return GestureDetector(
        onTap: () => onMediaTap?.call(0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isFillMode ? 0 : 12),
          child: Stack(
            fit: isFillMode ? StackFit.expand : StackFit.loose,
            children: [
              Image.network(
                MediaUtils.getThumbnailUrl(media[0]),
                width: double.infinity,
                height: isFillMode ? double.infinity : 300,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: isFillMode ? double.infinity : 500,
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.white24,
                  ),
                ),
              ),
              if (isVideo) ...[
                const Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: VideoDurationWidget(url: media[0]),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (isFillMode) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: _buildFlexibleGrid(),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 0.7, // Taller items
        ),
        itemCount: media.length > 4 ? 4 : media.length,
        itemBuilder: (context, index) => _buildGridItem(index),
      );
    }
  }

  Widget _buildFlexibleGrid() {
    if (media.length == 2) {
      return Row(
        children: [
          Expanded(child: _buildGridItem(0)),
          const SizedBox(width: 2),
          Expanded(child: _buildGridItem(1)),
        ],
      );
    } else if (media.length == 3) {
      return Row(
        children: [
          Expanded(child: _buildGridItem(0)),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildGridItem(1)),
                const SizedBox(height: 2),
                Expanded(child: _buildGridItem(2)),
              ],
            ),
          ),
        ],
      );
    } else {
      // 4 or more
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildGridItem(0)),
                const SizedBox(width: 2),
                Expanded(child: _buildGridItem(1)),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildGridItem(2)),
                const SizedBox(width: 2),
                Expanded(child: _buildGridItem(3)),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildGridItem(int index) {
    if (index >= media.length) return const SizedBox.shrink();

    final thumbnailUrl = MediaUtils.getThumbnailUrl(media[index]);
    final isVideo = MediaUtils.isVideo(media[index]);

    return GestureDetector(
      onTap: () => onMediaTap?.call(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(thumbnailUrl, fit: BoxFit.cover),
          if (index == 3 && media.length > 4)
            Container(
              color: Colors.black54,
              child: Center(
                child: Text(
                  '+${media.length - 3}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else if (isVideo) ...[
            const Positioned.fill(
              child: Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              left: 4,
              child: VideoDurationWidget(url: media[index]),
            ),
          ],
        ],
      ),
    );
  }
}
