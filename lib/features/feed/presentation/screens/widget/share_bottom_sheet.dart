import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:gal/gal.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
//import 'package:ffmpeg_kit_flutter_new_min_gpl/ffprobe_kit.dart';
import 'package:qik_talk/utilities/metadata_utils.dart';
//import 'package:qik_talk/utilities/media_utils.dart';
import 'package:image/image.dart' as img;


enum _ShareTarget {
  whatsapp,
  whatsappStatus,
  message,
  sms,
  messenger,
  instagram,
}

class ShareBottomSheet extends ConsumerWidget {
  final String postId;
  final List<String> mediaUrls;
  final String? overlayText;

  const ShareBottomSheet({
    super.key,
    required this.postId,
    required this.mediaUrls,
    this.overlayText,
  });




  /// Base URL for shareable post links.
  /// Update this to your actual domain / deep-link domain.
  //static const String _baseShareUrl = 'https://qiktalk.com/post';
  static const String _baseShareUrl = 'https://portfolio-79b32.web.app/post';

  String get _shareLink => '$_baseShareUrl/$postId';
  String get _shareText => 'Check out this post on QikTalk! $_shareLink';

  /// Records the share on the backend, then launches the target app.
  Future<void> _handleShare(
    BuildContext context,
    WidgetRef ref,
    _ShareTarget target,
  ) async {
    // 1. Record the share on your backend
    ref.read(feedProvider.notifier).sharePost(postId);

    // 2. Close the bottom sheet
    if (context.mounted) Navigator.pop(context);

    // 3. Open the target app
    switch (target) {
      case _ShareTarget.whatsapp:
        final url = Uri.parse(
          'whatsapp://send?text=${Uri.encodeComponent(_shareText)}',
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
        break;

      case _ShareTarget.whatsappStatus:
        // WhatsApp status sharing — opens WhatsApp; user can switch to Status
        final url = Uri.parse(
          'whatsapp://send?text=${Uri.encodeComponent(_shareText)}',
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
        break;

      case _ShareTarget.sms:
        final url = Uri.parse('sms:?body=${Uri.encodeComponent(_shareText)}');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
        break;

      case _ShareTarget.messenger:
        final url = Uri.parse(
          'fb-messenger://share?link=${Uri.encodeComponent(_shareLink)}',
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          // Fallback to system share sheet
          await Share.share(_shareText);
        }
        break;

      case _ShareTarget.instagram:
        // Instagram doesn't support pre-filled text via URL scheme.
        // Fallback to the system share sheet which lets user pick Instagram.
        await Share.share(_shareText);
        break;

      case _ShareTarget.message:
        // In-app message / generic share via system share sheet
        await Share.share(_shareText);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'Share to',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),

          // First row of share options (Socials)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShareIcon(
                  label: 'WhatsApp',
                  icon: SvgPicture.asset('assets/svgs/whatsapp.svg'),
                  backgroundColor: HexColor('#25D366'),
                  onTap: () =>
                      _handleShare(context, ref, _ShareTarget.whatsapp),
                ),
                // _buildShareIcon(
                //   label: 'WhatsApp Status',
                //   icon: SvgPicture.asset('assets/svgs/whatsapp.svg'),
                //   backgroundColor: HexColor('#25D366'),
                //   onTap: () =>
                //       _handleShare(context, ref, _ShareTarget.whatsappStatus),
                // ),
                _buildShareIcon(
                  label: 'Message',
                  icon: SvgPicture.asset('assets/svgs/share_qik_flash.svg'),
                  backgroundColor: HexColor('#EA4359'),
                  onTap: () => _handleShare(context, ref, _ShareTarget.message),
                ),
                _buildShareIcon(
                  label: 'SMS',
                  icon: SvgPicture.asset('assets/svgs/sms.svg'),
                  backgroundColor: HexColor('#5FC87D'),
                  onTap: () => _handleShare(context, ref, _ShareTarget.sms),
                ),
                _buildShareIcon(
                  label: 'Messenger',
                  icon: SvgPicture.asset('assets/svgs/messenger.svg'),
                  backgroundColor: HexColor('#0084FF'),
                  onTap: () =>
                      _handleShare(context, ref, _ShareTarget.messenger),
                ),
                _buildShareIcon(
                  label: 'Instagram',
                  icon: SvgPicture.asset('assets/svgs/instagram.svg'),
                  backgroundColor: Colors.transparent,
                  isInstagram: true,
                  onTap: () =>
                      _handleShare(context, ref, _ShareTarget.instagram),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Second row of share options (Actions)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* _buildActionIcon(
                  label: 'Report',
                  svg: SvgPicture.asset('assets/svgs/report.svg'),
                ), */
                _buildActionIcon(
                  label: 'Not\ninterested',
                  svg: SvgPicture.asset('assets/svgs/broken_heart.svg'),
                ),
                _buildActionIcon(
                  label: mediaUrls.any((url) => url.toLowerCase().contains('.mp4'))
                      ? 'Save videos'
                      : 'Save images',
                  svg: SvgPicture.asset('assets/svgs/download.svg'),
                  onTap: () => _saveMedia(context),
                ),


                /* _buildActionIcon(
                  label: 'Duet',
                  svg: SvgPicture.asset('assets/svgs/duet.svg'),
                ),
                _buildActionIcon(
                  label: 'React',
                  svg: SvgPicture.asset('assets/svgs/react.svg'),
                ),
                _buildActionIcon(
                  label: 'Add to\nFavorites',
                  svg: SvgPicture.asset('assets/svgs/share_bookmark.svg'),
                ), */
              ],
            ),
          ),

          SizedBox(height: 30),

          // Cancel Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareIcon({
    required String label,
    required Widget icon,
    required Color backgroundColor,
    bool isInstagram = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isInstagram ? null : backgroundColor,
                shape: BoxShape.circle,
                gradient: isInstagram
                    ? RadialGradient(
                        center: Alignment.bottomLeft,
                        radius: 1,
                        colors: [
                          HexColor('#FFDD55'),
                          HexColor('#FFDD55'),
                          HexColor('#FF543E'),
                          HexColor('#C837AB'),
                        ],
                      )
                    : null,
              ),
              child: Center(child: icon),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 70,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMedia(BuildContext context) async {
    if (mediaUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No media found to save')),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(navigator.context);

    // Close the sheet first
    navigator.pop();

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFFF2D55)),
                SizedBox(height: 16),
                Text('Processing media...'),
                Text('This may take a moment', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );

    try {

      // 1. Check/Request permissions
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Gallery access denied. Please enable in settings.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(minutes: 5),
      ));

      final tempDir = await getTemporaryDirectory();
      int savedCount = 0;

      for (final url in mediaUrls) {
        if (url.isEmpty) continue;
        debugPrint('📥 Downloading: $url');

        final isVideo = url.toLowerCase().contains('/video/') ||
            url.toLowerCase().contains('.mp4') ||
            url.toLowerCase().contains('.mov') ||
            url.toLowerCase().contains('.m4v');
        
        final extension = isVideo ? 'mp4' : 'jpg';
        final String rawPath = '${tempDir.path}/qik_raw_${DateTime.now().millisecondsSinceEpoch}_$savedCount.$extension';
        
        // 2. Download raw media
        await dio.download(url, rawPath);
        debugPrint('✅ Downloaded to: $rawPath');

        String finalPath = rawPath;

        // 3. Attempt a merge (burn-in) based on media type
        if (overlayText != null && overlayText!.isNotEmpty) {
          if (isVideo) {
            finalPath = await _processVideoOverlays(rawPath, overlayText!);
          } else {
            finalPath = await _processImageOverlays(rawPath, overlayText!);
          }
        }

        // 4. Save to gallery
        debugPrint('📸 Saving to gallery: $finalPath');
        try {
          if (isVideo) {
            await Gal.putVideo(finalPath);
          } else {
            await Gal.putImage(finalPath);
          }
          debugPrint('🏁 Gal.put success for: $finalPath');
          savedCount++;
        } catch (galError) {
          debugPrint('❌ Gal.put failed: $galError');
          // Try to save the raw file if the processed one failed
          if (finalPath != rawPath) {
             debugPrint('🔄 Retrying with raw file...');
             if (isVideo) await Gal.putVideo(rawPath); else await Gal.putImage(rawPath);
             savedCount++;
          } else {
            rethrow;
          }
        }

        // 5. Clean up temp files (wait a bit for OS to finish copying)
        await Future.delayed(const Duration(milliseconds: 500));
        if (finalPath != rawPath) {
          try { File(rawPath).deleteSync(); } catch (_) {}
          try { File(finalPath).deleteSync(); } catch (_) {}
        } else {
          try { File(rawPath).deleteSync(); } catch (_) {}
        }
      }


      // Close loading dialog
      if (navigator.canPop()) navigator.pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Saved $savedCount items to gallery!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      if (navigator.canPop()) navigator.pop();
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  /// Uses FFmpeg to burn text and video overlays into the video.
  Future<String> _processVideoOverlays(String inputPath, String metadataJson) async {
    try {
      debugPrint('🎬 Starting video overlay process...');
      final metadata = MetadataUtils.parseOverlayMetadata(metadataJson);
      
      // Separate text and video overlays
      final textOverlays = metadata.where((e) => e['type'] == 'text' || e['type'] == '1').toList();
      final videoOverlays = metadata.where((e) => e['type'] == 'video' || e['type'] == '2').toList();
      
      if (textOverlays.isEmpty && videoOverlays.isEmpty) return inputPath;

      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/qik_merged_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final dio = Dio();
      final List<String> inputs = ["-i \"$inputPath\""];
      final List<String> filterSteps = [];
      final List<File> tempVideoFiles = [];

      // 1. Prepare video overlays (download them first)
      for (int i = 0; i < videoOverlays.length; i++) {
        final overlay = videoOverlays[i];
        final videoUrl = overlay['videoUrl'] as String?;
        if (videoUrl == null || videoUrl.isEmpty) continue;

        final videoPath = '${tempDir.path}/overlay_vid_${i}_${DateTime.now().millisecondsSinceEpoch}.mp4';
        await dio.download(videoUrl, videoPath);
        tempVideoFiles.add(File(videoPath));
        
        inputs.add("-i \"$videoPath\"");
        
        final dx = overlay['dx'] ?? 0.5;
        final dy = overlay['dy'] ?? 0.5;
        final scale = overlay['scale'] ?? 0.3; // Default 30% size

        // Map input index to [1], [2], etc. (0 is the base video)
        final inputIdx = inputs.length - 1;
        
        // Filter: Scale the overlay video, then overlay it at (x, y)
        // [inputIdx:v]scale=w*scale:-1[ovrl_i]; [base][ovrl_i]overlay=W*dx:H*dy[base]
        filterSteps.add(
          "[$inputIdx:v]scale=iw*$scale:-1[v$i]; [0:v][v$i]overlay=W*$dx:H*$dy"
        );
      }

      // 2. Prepare text overlays
      String fontPath = '';
      if (Platform.isIOS) {
        fontPath = '/System/Library/Fonts/Core/Helvetica.ttc';
      } else if (Platform.isAndroid) {
        fontPath = '/system/fonts/Roboto-Regular.ttf';
      }

      for (var overlay in textOverlays) {
        final text = (overlay['text'] ?? '').toString().replaceAll("'", "").replaceAll(":", "");
        if (text.isEmpty) continue;

        final dx = overlay['dx'] ?? 0.5;
        final dy = overlay['dy'] ?? 0.5;
        final fontSize = overlay['fontSize'] ?? 30.0;
        
        String color = (overlay['color'] ?? 'white').toString();
        if (color.startsWith('#')) color = '0x${color.substring(1)}';

        String drawtext = "drawtext=text='$text':x=w*$dx:y=h*$dy:fontsize=$fontSize:fontcolor=$color";
        if (File(fontPath).existsSync()) {
          drawtext += ":fontfile='$fontPath'";
        }
        drawtext += ":box=1:boxcolor=black@0.4:boxborderw=5";
        
        filterSteps.add(drawtext);
      }

      if (filterSteps.isEmpty) return inputPath;

      final filterString = filterSteps.join(',');
      final inputString = inputs.join(' ');
      final command = "-y $inputString -filter_complex \"$filterString\" -c:v libx264 -preset ultrafast -c:a copy \"$outputPath\"";

      debugPrint('🎬 Executing FFmpeg Complex: $command');
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      // Clean up temp overlay videos
      for (var f in tempVideoFiles) { try { f.deleteSync(); } catch (_) {} }

      if (returnCode?.isValueSuccess() ?? false) {
        debugPrint('✅ FFmpeg merge successful: $outputPath');
        return outputPath;
      } else {
        debugPrint('❌ FFmpeg failed. Output: ${await session.getOutput()}');
        return inputPath;
      }
    } catch (e) {
      debugPrint('⚠️ Overlay merge error: $e');
      return inputPath;
    }
  }






  /// Uses the 'image' package to burn text overlays into an image.
  Future<String> _processImageOverlays(String inputPath, String metadataJson) async {
    try {
      debugPrint('🎨 Starting image overlay process...');
      final metadata = MetadataUtils.parseOverlayMetadata(metadataJson);
      final textOverlays = metadata.where((e) => e['type'] == 'text' || e['type'] == '1').toList();
      
      if (textOverlays.isEmpty) return inputPath;

      final bytes = await File(inputPath).readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return inputPath;

      for (var overlay in textOverlays) {
        final text = (overlay['text'] ?? '').toString();
        if (text.isEmpty) continue;

        final dx = overlay['dx'] ?? 0.5;
        final dy = overlay['dy'] ?? 0.5;
        
        // Very basic coordinate mapping
        final x = (image.width * dx).toInt();
        final y = (image.height * dy).toInt();

        // Draw text. Note: img.drawString uses built-in fonts.
        img.drawString(
          image,
          text,
          font: img.arial24,
          x: x,
          y: y,
          color: img.ColorRgb8(255, 255, 255),
        );
      }

      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/qik_img_merged_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(outputPath).writeAsBytes(img.encodeJpg(image));
      
      debugPrint('✅ Image merge successful: $outputPath');
      return outputPath;
    } catch (e) {
      debugPrint('⚠️ Image overlay merge error: $e');
      return inputPath;
    }
  }

  Widget _buildActionIcon({

    required String label,
    required SvgPicture svg,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: HexColor('#E8E8E7'),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Center(child: svg),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 65,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showShareBottomSheet(
  BuildContext context, {
  required String postId,
  required List<String> mediaUrls,
  String? overlayText,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ShareBottomSheet(
      postId: postId,
      mediaUrls: mediaUrls,
      overlayText: overlayText,
    ),
  );
}



