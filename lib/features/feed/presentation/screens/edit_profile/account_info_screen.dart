import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/feed/data/models/update_profile_dto.dart';
import 'package:qik_talk/features/feed/presentation/state/feed_state.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/media_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';
import 'dart:io';
import 'links_screen.dart';

class AccountInfoScreen extends ConsumerStatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  ConsumerState<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends ConsumerState<AccountInfoScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  List<Map<String, String>> _links = [];
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(feedProvider).userInfo?.data;
      if (user == null) {
        ref.read(feedProvider.notifier).loadUserInfo();
      } else {
        _populateFields(user);
      }
    });
  }

  void _populateFields(dynamic user) {
    _usernameController.text = user.username ?? '';
    _fullNameController.text = user.fullName ?? '';
    _emailController.text = user.email ?? '';
    _phoneController.text = user.phone ?? '';
    _aboutController.text = user.about ?? '';

    final List<Map<String, String>> loadedLinks = [];
    if (user.instagram != null && user.instagram!.isNotEmpty) {
      loadedLinks.add({'title': 'Instagram', 'url': user.instagram!});
    }
    if (user.youtube != null && user.youtube!.isNotEmpty) {
      loadedLinks.add({'title': 'YouTube', 'url': user.youtube!});
    }
    if (user.link != null && user.link!.isNotEmpty) {
      loadedLinks.add({'title': 'Website', 'url': user.link!});
    }
    setState(() {
      _links = loadedLinks;
    });
  }

  Future<void> _updateProfile() async {
    String instagram = "";
    String youtube = "";
    String genericLink = "";

    for (final link in _links) {
      final title = link['title'];
      final url = link['url'] ?? '';
      if (title == 'Instagram') {
        instagram = url;
      } else if (title == 'YouTube') {
        youtube = url;
      } else if (title == 'Website') {
        genericLink = url;
      }
    }

    final dto = UpdateProfileDto(
      fullName: _fullNameController.text,
      username: _usernameController.text,
      about: _aboutController.text,
      phone: int.tryParse(_phoneController.text.replaceAll(RegExp(r'\D'), '')),
      instagram: instagram,
      youtube: youtube,
      link: genericLink,
    );

    if (_pickedImage != null) {
      await ref
          .read(feedProvider.notifier)
          .updateProfileWithImage(data: dto, imageFile: _pickedImage!);
    } else {
      await ref.read(feedProvider.notifier).updateProfile(dto);
    }

    if (mounted) {
      final error = ref.read(feedProvider).error;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(error ?? 'Profile updated successfully'),
      //     backgroundColor: error != null ? Colors.red : Colors.green,
      //   ),
      // );
      if (error == null) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    ref.read(biometricAuthProvider.notifier).isPickerActive = true;
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    await ref.read(biometricAuthProvider.notifier).onPickerReturned();

    if (image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Photo',
            toolbarColor: const Color(0xFF0F0F0F),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Profile Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _pickedImage = File(croppedFile.path);
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    final feedState = ref.watch(feedProvider);
    final user = feedState.userInfo?.data;

    ref.listen<FeedState>(feedProvider, (previous, next) {
      if (previous?.userInfo == null && next.userInfo != null) {
        _populateFields(next.userInfo!.data);
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: Stack(
        children: [
          // Background gradient at the top
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark 
                  ? [const Color(0xFF3A1D07), const Color(0xFF0F0F0F)]
                  : [const Color(0xFFE8DDD0), AppTheme.scaffoldBg(isDark)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Profile',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Profile Photo Section
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? Colors.white24 : AppTheme.border(isDark),
                                      width: 2,
                                    ),
                                  ),
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: ClipOval(
                                      child: _pickedImage != null
                                          ? Image.file(
                                              _pickedImage!,
                                              fit: BoxFit.cover,
                                            )
                                          : user?.profilePicture != null &&
                                                user!
                                                    .profilePicture
                                                    .isNotEmpty &&
                                                user.profilePicture.startsWith(
                                                  'http',
                                                )
                                          ? Image.network(
                                              MediaUtils.getThumbnailUrl(
                                                user.profilePicture,
                                              ),
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) =>
                                                      _buildInitialsPlaceholder(
                                                        user,
                                                      ),
                                            )
                                          : _buildInitialsPlaceholder(user),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Change Picture',
                                  style: GoogleFonts.poppins(
                                    color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Form Fields
                          _buildInputField(
                            label: 'Username',
                            controller: _usernameController,
                            hintText: 'Enter username',
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            label: 'Full Name',
                            controller: _fullNameController,
                            hintText: 'Enter full name',
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            label: 'Email',
                            controller: _emailController,
                            hintText: 'Enter email',
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            label: 'Phone Number',
                            controller: _phoneController,
                            hintText: 'Enter phone number',
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            label: 'About',
                            controller: _aboutController,
                            hintText: 'Add a bio to your profile',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 20),
                          // Links section
                          _buildNavigationField(
                            label: 'Links',
                            value: _links.isEmpty
                                ? 'Add links'
                                : '${_links.length} links',
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LinksScreen(initialLinks: _links),
                                ),
                              );
                              if (result != null &&
                                  result is List<Map<String, String>>) {
                                setState(() {
                                  _links = result;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 50),
                          // Update Button
                          _buildUpdateButton(feedState),
                          const SizedBox(height: 40),
                        ],
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : AppTheme.inputFill(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white : AppTheme.inputBorder(isDark)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.poppins(color: isDark ? Colors.white70 : AppTheme.textPrimary(isDark)),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(color: isDark ? Colors.white24 : AppTheme.textHint(isDark)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : AppTheme.inputFill(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white : AppTheme.inputBorder(isDark)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: value == 'Add links'
                        ? (isDark ? Colors.white24 : AppTheme.textHint(isDark))
                        : (isDark ? Colors.white70 : AppTheme.textPrimary(isDark)),
                    fontSize: 14,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? Colors.white24 : AppTheme.iconColorSubtle(isDark),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(FeedState feedState) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Glow Effect (only in dark mode)
        if (isDark)
          Container(
            height: 10,
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF3D00).withValues(alpha: 0.4),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        // Button
        GestureDetector(
          onTap: feedState.isUserInfoLoading ? null : _updateProfile,
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : AppTheme.accent(isDark),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? HexColor('#FF00A8') : AppTheme.accent(isDark), 
                width: 0.92
              ),
              boxShadow: isDark ? [
                BoxShadow(
                  color: Colors.yellow.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ] : [],
            ),
            child: Center(
              child: feedState.isUserInfoLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Update',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsPlaceholder(dynamic user) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    final String? rawUsername = user?.username;
    final String username = (rawUsername == null || rawUsername.trim().isEmpty)
        ? 'User'
        : rawUsername;
    final initials = username.isNotEmpty ? username[0].toUpperCase() : 'U';
    return Container(
      color: isDark ? Colors.white10 : const Color(0xFFD9CFC4),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
