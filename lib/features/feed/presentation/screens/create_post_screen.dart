import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';
import 'package:qik_talk/utilities/services/image_editing_service.dart';
import 'package:qik_talk/features/chat/general/services/rest_api_services/user_profile_service.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/video_thumbnail_widget.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/video_trimmer_screen.dart';
import 'package:qik_talk/utilities/media_utils.dart';
import 'package:qik_talk/features/feed/presentation/screens/new_post_screen.dart';
import 'package:qik_talk/features/feed/data/models/text_overlay_model.dart';
import 'package:qik_talk/features/status/components/emoji_gif_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String? initialPostType;
  const CreatePostScreen({super.key, this.initialPostType});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen>
    with WidgetsBindingObserver {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _captionFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final UserProfileService _profileService = UserProfileService();
  final PageController _pageController = PageController();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isRearCamera = true;
  bool _isRecording = false;
  String _captureMode = 'Photo'; // 'Photo' or 'Video'

  List<File> selectedMedia = [];
  int _currentMediaIndex = 0;
  String? _userProfilePicture;
  String? _userFirstName;
  String _selectedPostType = 'Post';

  // Track overlays per media index
  final Map<int, List<TextOverlay>> _mediaOverlays = {};
  final TextEditingController _overlayTextController = TextEditingController();
  final FocusNode _overlayTextFocusNode = FocusNode();
  bool _isInteractingWithOverlay = false;

  @override
  void initState() {
    super.initState();
    _selectedPostType = widget.initialPostType ?? 'Post';
    WidgetsBinding.instance.addObserver(this);
    _loadUserInfo();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;

      _onNewCameraSelected(
        _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first,
        ),
      );
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.veryHigh,
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Camera controller initialization error: $e');
    }
  }

  void _toggleCamera() {
    if (_cameras == null || _cameras!.isEmpty) return;

    _isRearCamera = !_isRearCamera;
    final direction = _isRearCamera
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == direction,
      orElse: () => _cameras!.first,
    );

    _onNewCameraSelected(newCamera);
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    if (selectedMedia.length >= 4) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        selectedMedia.add(File(image.path));
        _currentMediaIndex = selectedMedia.length - 1;
      });
      // Scroll to the latest captured photo
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentMediaIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    }
  }

  Future<void> _startVideoRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    if (_isRecording) return;

    if (selectedMedia.length >= 4) return;

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      debugPrint('Error starting video recording: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    if (!_isRecording) return;

    try {
      final XFile video = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });

      if (!mounted) return;

      final File? trimmedFile = await Navigator.push<File?>(
        context,
        MaterialPageRoute(
          builder: (_) => VideoTrimmerScreen(file: File(video.path)),
        ),
      );

      if (trimmedFile != null && mounted) {
        setState(() {
          selectedMedia.add(trimmedFile);
          _currentMediaIndex = selectedMedia.length - 1;
        });

        Future.delayed(const Duration(milliseconds: 100), () {
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              _currentMediaIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      debugPrint('Error stopping video recording: $e');
    }
  }

  void _handleCapture() {
    if (_captureMode == 'Photo') {
      _capturePhoto();
    } else {
      if (_isRecording) {
        _stopVideoRecording();
      } else {
        _startVideoRecording();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _contentController.dispose();
    _captionFocusNode.dispose();
    _pageController.dispose();
    _cameraController?.dispose();
    _overlayTextController.dispose();
    _overlayTextFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _onNewCameraSelected(cameraController.description);
    }
  }

  Future<void> _loadUserInfo() async {
    final profile = await _profileService.fetchMyProfile();
    if (!mounted) return;
    setState(() {
      _userProfilePicture = profile?.profilePicture;
      _userFirstName = profile?.username;
    });
  }

  Future<void> _pickImages() async {
    final availableSlots = 4 - selectedMedia.length;
    if (availableSlots <= 0) {
      return;
    }

    ref.read(biometricAuthProvider.notifier).isPickerActive = true;
    final images = await _picker.pickMultiImage(imageQuality: 70);
    await ref.read(biometricAuthProvider.notifier).onPickerReturned();

    if (!mounted || images.isEmpty) return;

    List<XFile> imagesToAdd = images;
    if (images.length > availableSlots) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       'Limited to 4 media files per post. Only adding $availableSlots.',
      //     ),
      //   ),
      // );
      imagesToAdd = images.sublist(0, availableSlots);
    }

    final pickedFiles = imagesToAdd.map((e) => File(e.path)).toList();

    setState(() {
      selectedMedia.addAll(pickedFiles);
    });
  }

  Future<void> _cropCurrentImage() async {
    if (selectedMedia.isEmpty) return;

    // Crop the currently viewed media index
    final index = _currentMediaIndex;

    if (MediaUtils.isVideo(selectedMedia[index].path)) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Cannot crop a video. Use the scissors icon to trim.'),
      //   ),
      // );
      return;
    }

    final edited = await ImageEditingService.cropImage(
      selectedMedia[index],
      context,
    );

    if (!mounted || edited == null) return;
    setState(() {
      selectedMedia[index] = edited;
    });
  }

  Future<void> _pickVideo() async {
    ref.read(biometricAuthProvider.notifier).isPickerActive = true;
    final video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    await ref.read(biometricAuthProvider.notifier).onPickerReturned();

    if (!mounted || video == null) return;

    if (selectedMedia.length >= 4) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('You can select up to 4 media files')),
      // );
      return;
    }

    final File? trimmedFile = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (_) => VideoTrimmerScreen(file: File(video.path)),
      ),
    );

    if (trimmedFile != null && mounted) {
      setState(() {
        selectedMedia.add(trimmedFile);
      });
    }
  }

  void _onNextPressed() {
    if (selectedMedia.isEmpty && _contentController.text.trim().isEmpty) {
      return;
    }

    // NORMALIZE OVERLAYS:
    // This ensures positions are independent of screen size/resolution.
    final Map<int, List<TextOverlay>> normalizedOverlaysMap = {};
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    _mediaOverlays.forEach((index, overlays) {
      normalizedOverlaysMap[index] = overlays.map((o) {
        if (o.isNormalized) return o; // already normalized

        return o.copyWith(
          position: Offset(
            o.position.dx / mediaWidth,
            o.position.dy / mediaHeight,
          ),
          isNormalized: true,
        );
      }).toList();
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewPostScreen(
          selectedMedia: selectedMedia,
          initialCaption: _contentController.text.trim(),
          postType: _selectedPostType,
          overlays: normalizedOverlaysMap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    // If we have selected media, we just show the first one as full background for now
    // as per typical story/camera UI (the design shows a camera preview or the picked media).
    final hasMedia = selectedMedia.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Media (Swipable PageView)
          Positioned.fill(
            child: hasMedia
                ? SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 70, bottom: 140),
                      child: ClipRRect(
                        child: PageView.builder(
                          controller: _pageController,
                          physics: _isInteractingWithOverlay
                              ? const NeverScrollableScrollPhysics()
                              : const AlwaysScrollableScrollPhysics(),
                          itemCount: selectedMedia.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentMediaIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final mediaFile = selectedMedia[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: MediaUtils.isVideo(mediaFile.path)
                                        ? _VideoInPlacePlayerWidget(
                                            videoFile: mediaFile,
                                            isVisible:
                                                index == _currentMediaIndex,
                                          )
                                        : Image.file(
                                            mediaFile,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                  ),
                                  ...(_mediaOverlays[index] ?? [])
                                      .map(
                                        (overlay) => _buildDraggableOverlay(
                                          overlay,
                                          index,
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      (_isCameraInitialized && _cameraController != null)
                          ? CameraPreview(_cameraController!)
                          : Container(color: Colors.black),
                      ...(_mediaOverlays[0] ?? [])
                          .map(
                            (overlay) => _buildDraggableOverlay(
                              overlay,
                              0,
                            ),
                          )
                          .toList(),
                    ],
                  ),
          ),

          // Top Gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Top Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                    size: 24,
                  ),
                ),

                // Settings
                Icon(
                  Icons.settings,
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  size: 28,
                ),
              ],
            ),
          ),

          // Right Toolbar
          Positioned(
            top: MediaQuery.of(context).padding.top + 100,
            right: 16,
            child: Column(
              children: [
                _buildRightToolbarIcon(
                  SvgPicture.asset('assets/svgs/create_image.svg'),
                  _pickImages,
                ),
                _buildRightToolbarIcon(
                  SvgPicture.asset('assets/svgs/create_video.svg'),
                  _pickVideo,
                ),
                _buildRightToolbarIcon(
                  SvgPicture.asset('assets/svgs/Aa.svg'),
                  _showTextEntryOverlay,
                ),
                _buildRightToolbarIcon(
                  const Icon(
                    Icons.video_collection_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  _pickVideoOverlay,
                ),
                _buildRightToolbarIcon(
                  SvgPicture.asset('assets/svgs/create_smiley.svg'),
                  _showEmojiOverlay,
                ),
                _buildRightToolbarIcon(
                  SvgPicture.asset('assets/svgs/crop.svg'),
                  _cropCurrentImage,
                ),
                _buildRightToolbarIcon(
                  const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 28,
                  ),
                  _toggleCamera,
                ),
                _buildRightToolbarIcon(
                  SvgPicture.asset('assets/svgs/cut.svg'),
                  () {}, // Scissors
                ),
              ],
            ),
          ),

          // Bottom Gradient Overlay for text readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Caption Input Field
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _contentController,
                  focusNode: _captionFocusNode,
                  autofocus: false,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Add a caption",
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(height: 20),
                // Center - Media picker & Post Type
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Grid icon overlay style from Figma
                          GestureDetector(
                            onTap: () {
                              // Could launch a bottom sheet with story/post/live options
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: HexColor('#1C1C1E'),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.grid_view_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Selected Media Thumbnails
                          ...List.generate(selectedMedia.length, (index) {
                            final media = selectedMedia[index];
                            final isSelected = index == _currentMediaIndex;
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _pageController.animateToPage(
                                        index,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: HexColor('#1C1C1E'),
                                        borderRadius: BorderRadius.circular(8),
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              )
                                            : null,
                                        image: !MediaUtils.isVideo(media.path)
                                            ? DecorationImage(
                                                image: FileImage(media),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: MediaUtils.isVideo(media.path)
                                          ? const Icon(
                                              Icons.videocam,
                                              color: Colors.white,
                                              size: 20,
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedMedia.removeAt(index);
                                          if (_currentMediaIndex >=
                                              selectedMedia.length) {
                                            _currentMediaIndex =
                                                selectedMedia.length - 1;
                                          }
                                          if (_currentMediaIndex < 0)
                                            _currentMediaIndex = 0;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black87,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          // Add more media button (only if < 4)
                          if (selectedMedia.length < 4)
                            GestureDetector(
                              onTap: () {
                                // Prompt user to pick more images or video depending on what they want to add
                                _pickImages();
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: HexColor('#1C1C1E'),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Mode Selector (Photo/Video)
                if (!hasMedia && _isCameraInitialized)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _captureMode = 'Photo';
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'PHOTO',
                                  style: GoogleFonts.poppins(
                                    color: _captureMode == 'Photo'
                                        ? Colors.white
                                        : Colors.white60,
                                    fontSize: 14,
                                    fontWeight: _captureMode == 'Photo'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                if (_captureMode == 'Photo')
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    height: 4,
                                    width: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _captureMode = 'Video';
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'VIDEO',
                                  style: GoogleFonts.poppins(
                                    color: _captureMode == 'Video'
                                        ? Colors.white
                                        : Colors.white60,
                                    fontSize: 14,
                                    fontWeight: _captureMode == 'Video'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                if (_captureMode == 'Video')
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    height: 4,
                                    width: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Capture Button
                if (!hasMedia && _isCameraInitialized)
                  Center(
                    child: GestureDetector(
                      onTap: _handleCapture,
                      child: Container(
                        height: 80,
                        width: 80,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isRecording ? Colors.red : Colors.white,
                            width: 4,
                          ),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red : Colors.white,
                            borderRadius: BorderRadius.circular(
                              _isRecording ? 12 : 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // Bottom Navigation / Action Bar
          Positioned(
            bottom: 30 + MediaQuery.of(context).padding.bottom,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left - Your Story Button
                PopupMenuButton<String>(
                  offset: const Offset(0, -150),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) {
                    setState(() {
                      _selectedPostType = value;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'Story',
                      child: Text(
                        'Story',
                        style: GoogleFonts.poppins(
                          color: HexColor('#FF2D55'),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'Post',
                      child: Text(
                        'Post',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'Live',
                      child: Text(
                        'Live',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              (_userProfilePicture != null &&
                                  _userProfilePicture!.isNotEmpty)
                              ? NetworkImage(
                                  MediaUtils.getThumbnailUrl(
                                    _userProfilePicture!,
                                  ),
                                )
                              : null,
                          child:
                              (_userProfilePicture == null ||
                                  _userProfilePicture!.isEmpty)
                              ? Text(
                                  _userFirstName != null &&
                                          _userFirstName!.isNotEmpty
                                      ? _userFirstName![0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black87,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedPostType == 'Story'
                              ? 'Your Story'
                              : _selectedPostType,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                // Right - Next Button
                GestureDetector(
                  onTap: _onNextPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: HexColor('#FF2D55'),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightToolbarIcon(Widget icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: GestureDetector(onTap: onTap, child: icon),
    );
  }

  void _showEmojiOverlay() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1B1B1B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: EmojiGifPicker(
                  showGif: false,
                  onTabChanged: (showGif) {
                    // Handled internally by EmojiGifPicker usually,
                    // but we can react if needed.
                  },
                  onEmojiSelected: (emoji) {
                    setState(() {
                      final newOverlay = TextOverlay(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        text: emoji,
                        position: Offset(
                          MediaQuery.of(context).size.width / 2 - 40,
                          MediaQuery.of(context).size.height / 2 - 40,
                        ),
                        fontSize: 60, // Reduced from 80
                        isEmoji: true,
                      );
                      _mediaOverlays[_currentMediaIndex] ??= [];
                      _mediaOverlays[_currentMediaIndex]!.add(newOverlay);
                    });
                    Navigator.pop(context);
                  },
                  onGifSelected: (gifUrl) {
                    // For now, treat GIF as a text overlay with the URL
                    // as it's not fully supported as a "sticker" yet.
                    // But usually, stickers are separate.
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableOverlay(TextOverlay overlay, int mediaIndex) {
    return Positioned(
      left: overlay.position.dx,
      top: overlay.position.dy,
      child: GestureDetector(
        onScaleStart: (details) {
          setState(() {
            _isInteractingWithOverlay = true;
            overlay.baseScale = overlay.fontSize;
          });
        },
        onScaleUpdate: (details) {
          setState(() {
            // Translate based on focal point change
            overlay.position += details.focalPointDelta;

            // Scale based on pointer distance
            if (details.scale != 1.0) {
              overlay.fontSize = (overlay.baseScale * details.scale).clamp(
                10.0,
                400.0,
              );
            }

            // Invisible safety boundary check:
            // Prevent overlays from overlapping with the top progress bars (approx 80px)
            const double topSafeBoundary = 80.0;
            if (overlay.position.dy < topSafeBoundary) {
              overlay.position = Offset(overlay.position.dx, topSafeBoundary);
            }
          });
        },
        onScaleEnd: (details) {
          setState(() {
            _isInteractingWithOverlay = false;
          });
        },
        onTap: (overlay.isEmoji || overlay.type == OverlayType.video)
            ? null
            : () {
                _overlayTextController.text = overlay.text;
                _showTextEntryOverlay(existingOverlay: overlay);
              },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Large transparent hit area to capture two-finger gestures easily
            Container(
              padding: const EdgeInsets.all(55.0),
              color: Colors.transparent,
              child: Container(
                padding: overlay.type == OverlayType.video
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: null,
                child: overlay.type == OverlayType.video
                    ? _VideoOverlayPlayer(
                        videoFile: File(overlay.localVideoPath!),
                        videoUrl: overlay.videoUrl,
                        fontSize: overlay.fontSize,
                        aspectRatio: overlay.aspectRatio,
                      )
                    : Text(
                        overlay.text,
                        textAlign: overlay.textAlign,
                        style: GoogleFonts.getFont(
                          overlay.fontFamily,
                          color: Colors.white,
                          fontSize: overlay.fontSize,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            const Shadow(
                              blurRadius: 8.0,
                              color: Colors.black87,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            // Delete icon for emojis and videos
            if (overlay.isEmoji || overlay.type == OverlayType.video)
              Positioned(
                top: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _mediaOverlays[mediaIndex]?.remove(overlay);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideoOverlay() async {
    ref.read(biometricAuthProvider.notifier).isPickerActive = true;
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 30),
    );
    await ref.read(biometricAuthProvider.notifier).onPickerReturned();

    if (video != null) {
      // Get actual aspect ratio (defaulting to portrait 9:16 instead of 1:1 square)
      double aspectRatio = 9 / 16;
      final controller = VideoPlayerController.file(File(video.path));
      try {
        await controller.initialize();
        if (controller.value.aspectRatio > 0 &&
            controller.value.aspectRatio != 1.0) {
          aspectRatio = controller.value.aspectRatio;
        }
        await controller.dispose();
      } catch (e) {
        debugPrint("Error getting video aspect ratio: $e");
      }

      setState(() {
        final newOverlay = TextOverlay(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '',
          position: const Offset(100, 200),
          type: OverlayType.video,
          localVideoPath: video.path,
          fontSize: 150, // This will be the height now
          baseScale: 150,
          aspectRatio: aspectRatio,
        );
        _mediaOverlays[_currentMediaIndex] ??= [];
        _mediaOverlays[_currentMediaIndex]!.add(newOverlay);
      });
    }
  }

  void _showTextEntryOverlay({TextOverlay? existingOverlay}) {
    String selectedFont = existingOverlay?.fontFamily ?? 'Poppins';
    final List<String> availableFonts = [
      'Poppins',
      'Roboto',
      'Lobster',
      'Bangers',
      'Comic Neue',
      'Permanent Marker',
    ];

    showGeneralPage(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Scaffold(
              backgroundColor: Colors.transparent, // Fully transparent
              body: Stack(
                children: [
                  // Very subtle dimming to make text readable but keep media visible
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: null,
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: _overlayTextController,
                            focusNode: _overlayTextFocusNode,
                            autofocus: true,
                            maxLines: null,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont(
                              selectedFont,
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                const Shadow(
                                  blurRadius: 8.0,
                                  color: Colors.black87,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '',
                              hintStyle: TextStyle(color: Colors.black26),
                              filled: false,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: availableFonts.length,
                        itemBuilder: (context, index) {
                          final font = availableFonts[index];
                          final isSelected = font == selectedFont;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedFont = font;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black54,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Aa',
                                  style: GoogleFonts.getFont(
                                    font,
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    right: 16,
                    child: TextButton(
                      onPressed: () {
                        final text = _overlayTextController.text.trim();
                        if (text.isNotEmpty) {
                          setState(() {
                            if (existingOverlay != null) {
                              existingOverlay.text = text;
                              existingOverlay.fontFamily = selectedFont;
                            } else {
                              final newOverlay = TextOverlay(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                text: text,
                                fontFamily: selectedFont,
                                position: Offset(
                                  MediaQuery.of(context).size.width / 2 - 50,
                                  200,
                                ),
                              );
                              _mediaOverlays[_currentMediaIndex] ??= [];
                              _mediaOverlays[_currentMediaIndex]!.add(
                                newOverlay,
                              );
                            }
                          });
                        } else if (existingOverlay != null) {
                          setState(() {
                            _mediaOverlays[_currentMediaIndex]?.remove(
                              existingOverlay,
                            );
                          });
                        }
                        _overlayTextController.clear();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Done',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showGeneralPage({
    required BuildContext context,
    required RoutePageBuilder pageBuilder,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        pageBuilder: pageBuilder,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _VideoInPlacePlayerWidget extends StatefulWidget {
  final File videoFile;
  final bool isVisible;

  const _VideoInPlacePlayerWidget({
    required this.videoFile,
    required this.isVisible,
  });

  @override
  State<_VideoInPlacePlayerWidget> createState() =>
      _VideoInPlacePlayerWidgetState();
}

class _VideoInPlacePlayerWidgetState extends State<_VideoInPlacePlayerWidget> {
  BetterPlayerController? _betterPlayerController;
  bool _isPlayerInitialized = false;

  @override
  void didUpdateWidget(_VideoInPlacePlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the video is no longer visible, dispose the player
    if (!widget.isVisible && oldWidget.isVisible) {
      _disposePlayer();
    }
  }

  void _initializePlayer() {
    if (_betterPlayerController != null) return;

    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
          aspectRatio: 9 / 16,
          fit: BoxFit.contain,
          autoPlay: true,
          looping: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControls: true, // Show controls once playing
            enableRetry: true,
          ),
        );

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      widget.videoFile.path,
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController!.setupDataSource(dataSource);

    setState(() {
      _isPlayerInitialized = true;
    });
  }

  void _disposePlayer() {
    if (_betterPlayerController != null) {
      _betterPlayerController!.dispose();
      _betterPlayerController = null;
      setState(() {
        _isPlayerInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVisible &&
        _isPlayerInitialized &&
        _betterPlayerController != null) {
      return BetterPlayer(controller: _betterPlayerController!);
    }

    // Initial state: Thumbnail with Play Button
    return Stack(
      children: [
        VideoThumbnailWidget(
          videoFile: widget.videoFile,
          width: double.infinity,
          height: double.infinity,
        ),
        Center(
          child: GestureDetector(
            onTap: _initializePlayer,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoOverlayPlayer extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;
  final double fontSize;
  final double aspectRatio;

  const _VideoOverlayPlayer({
    this.videoFile,
    this.videoUrl,
    required this.fontSize,
    this.aspectRatio = 9 / 16,
  });

  @override
  State<_VideoOverlayPlayer> createState() => _VideoOverlayPlayerState();
}

class _VideoOverlayPlayerState extends State<_VideoOverlayPlayer> {
  BetterPlayerController? _betterPlayerController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(_VideoOverlayPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoFile?.path != oldWidget.videoFile?.path ||
        widget.videoUrl != oldWidget.videoUrl) {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    _betterPlayerController?.dispose();

    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
          aspectRatio: widget.aspectRatio,
          fit: BoxFit.cover,
          autoPlay: true,
          looping: true,
          placeholder: const SizedBox.shrink(),
          showPlaceholderUntilPlay: false,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            showControls: false,
            loadingWidget: SizedBox.shrink(),
          ),
        );

    BetterPlayerDataSource dataSource = widget.videoFile != null
        ? BetterPlayerDataSource(
            BetterPlayerDataSourceType.file,
            widget.videoFile!.path,
          )
        : BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            widget.videoUrl!,
          );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController!.setupDataSource(dataSource);
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.fontSize,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _betterPlayerController != null
              ? BetterPlayer(controller: _betterPlayerController!)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
