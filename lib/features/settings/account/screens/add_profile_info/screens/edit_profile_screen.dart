import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:qik_talk/features/feed/data/models/update_profile_dto.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';
import 'package:qik_talk/utilities/constants/app_config.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/services/presigned_upload_service.dart';
import '../../../../../authentication/provider/user_provider.dart';
import '../../../../theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isSubmitting = false;
  bool _isDirty = false;
  double _uploadProgress = 0.0; // tracks if anything changed

  // Original values to compare against
  String _originalUsername = '';
  String _originalFullName = '';
  String _originalEmail = '';
  String _originalAbout = '';

  void _markDirty() {
    final dirty =
        _userNameController.text.trim() != _originalUsername ||
        _fullNameController.text.trim() != _originalFullName ||
        _emailController.text.trim() != _originalEmail ||
        _aboutController.text.trim() != _originalAbout ||
        _selectedImage != null;
    if (dirty != _isDirty) setState(() => _isDirty = dirty);
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider);
    final feedState = ref.read(feedProvider);
    final liveAbout = feedState.userInfo?.data.about ?? user.about;
    final liveFullName = feedState.userInfo?.data.fullName ?? user.fullName;
    final liveUsername = feedState.userInfo?.data.username ?? user.username;

    _userNameController.text = liveUsername;
    _fullNameController.text = liveFullName;
    _emailController.text = user.email;
    _phoneNumberController.text = user.phoneNumber;
    _aboutController.text = liveAbout;

    _originalUsername = liveUsername;
    _originalFullName = liveFullName;
    _originalEmail = user.email;
    _originalAbout = liveAbout;

    _userNameController.addListener(_markDirty);
    _fullNameController.addListener(_markDirty);
    _emailController.addListener(_markDirty);
    _aboutController.addListener(_markDirty);

    Future.microtask(() async {
      await ref.read(feedProvider.notifier).loadUserInfo(silent: true);
      if (mounted) {
        final info = ref.read(feedProvider).userInfo?.data;
        if (info != null) {
          // Always keep the locally-stored picture URL — never let a
          // potentially-stale backend response overwrite the one we just
          // uploaded.  The local URL (already persisted to SharedPreferences
          // and the provider by _submit) is always the source of truth.
          final preservedPicture = ref.read(userProfileProvider).profilePicture;
          await ref
              .read(userProfileProvider.notifier)
              .updateFromUserInfo(
                username: info.username ?? '',
                about: info.about,
                fullName: info.fullName ?? '',
                profilePicture: preservedPicture.isNotEmpty
                    ? preservedPicture
                    : (info.profilePicture ?? ''),
              );
          // Always refresh from backend — not just when empty
          final freshUsername = info.username ?? '';
          final freshFullName = info.fullName ?? '';
          final freshAbout = info.about;

          if (freshUsername.isNotEmpty) {
            _userNameController.text = freshUsername;
            _originalUsername = freshUsername;
          }
          if (freshFullName.isNotEmpty) {
            _fullNameController.text = freshFullName;
            _originalFullName = freshFullName;
          }
          if (freshAbout.isNotEmpty) {
            _aboutController.text = freshAbout;
            _originalAbout = freshAbout;
          }
          // Reset dirty since we just synced from backend
          setState(() => _isDirty = false);
        }
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      ref.read(biometricAuthProvider.notifier).isPickerActive = true;
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );
      await ref.read(biometricAuthProvider.notifier).onPickerReturned();
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isDirty = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
      }
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.0;
    });

    try {
      final newEmail = _emailController.text.trim();
      final emailChanged = newEmail != _originalEmail && newEmail.isNotEmpty;

      // ── Step 1: Update email if changed ──────────────────────────────
      if (emailChanged) {
        final token = await SaveValues().getString(
          AppPreferenceHelper.AUTH_TOKEN,
        );
        final emailResponse = await http.put(
          Uri.parse('${AppConfig.apiUrl}user/profile/update'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'email': newEmail}),
        );
        if (mounted &&
            emailResponse.statusCode != 200 &&
            emailResponse.statusCode != 201) {
          final body = jsonDecode(emailResponse.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['message'] ?? 'Failed to update email'),
            ),
          );
          setState(() => _isSubmitting = false);
          return;
        }
        await SaveValues().saveString(
          AppPreferenceHelper.EMAIL_ADDRESS,
          newEmail,
        );
        ref.read(userProfileProvider.notifier).updateEmail(newEmail);
      }

      // ── Step 2: Upload image to MinIO if a new one was picked ────────
      String? newProfilePictureUrl;
      if (_selectedImage != null) {
        // Determine mime type from file extension
        final ext = _selectedImage!.path.split('.').last.toLowerCase();
        final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

        newProfilePictureUrl = await PresignedUploadService.uploadFile(
          file: _selectedImage!,
          mimeType: mimeType,
          onProgress: (p) {
            if (mounted) setState(() => _uploadProgress = p);
          },
        );

        if (newProfilePictureUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image upload failed. Please try again.'),
                backgroundColor: Colors.redAccent,
              ),
            );
            setState(() => _isSubmitting = false);
          }
          return;
        }

        // ✅ Immediately persist the new URL to prefs + provider
        // so the settings screen reflects it right away
        await SaveValues().saveString(
          AppPreferenceHelper.PROFILE_IMAGE,
          newProfilePictureUrl,
        );
        ref
            .read(userProfileProvider.notifier)
            .updateProfilePicture(newProfilePictureUrl);
      }

      // ── Step 3: Update profile text fields + new image URL ───────────
      final dto = UpdateProfileDto(
        username: _userNameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        about: _aboutController.text.trim(),
        // Pass the MinIO public URL if we uploaded one
        profilePicture: newProfilePictureUrl,
      );

      await ref.read(feedProvider.notifier).updateProfile(dto);

      if (mounted) {
        final error = ref.read(feedProvider).error;
        if (error == null) {
          // Sync text fields back from backend, but NEVER overwrite the
          // profile picture with whatever the backend returned — we already
          // persisted the freshly-uploaded URL locally and that is the
          // source of truth until the next cold start.
          final info = ref.read(feedProvider).userInfo?.data;
          final preservedPicture = ref.read(userProfileProvider).profilePicture;

          if (info != null) {
            await ref
                .read(userProfileProvider.notifier)
                .updateFromUserInfo(
                  username: info.username ?? _userNameController.text.trim(),
                  about: info.about,
                  fullName: info.fullName ?? _fullNameController.text.trim(),
                  // Always keep the URL we already have locally — never
                  // let a potentially-stale backend response overwrite it.
                  profilePicture: preservedPicture,
                );
          } else {
            await ref.read(userProfileProvider.notifier).loadUser();
          }

          _originalUsername = _userNameController.text.trim();
          _originalFullName = _fullNameController.text.trim();
          _originalEmail = newEmail.isNotEmpty ? newEmail : _originalEmail;
          _originalAbout = _aboutController.text.trim();
          setState(() {
            _selectedImage = null;
            _isDirty = false;
            _uploadProgress = 0.0;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error != null
                  ? 'Update failed: $error'
                  : 'Profile updated successfully',
            ),
            backgroundColor: error != null
                ? Colors.redAccent
                : const Color(0xFF34C759),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);
    final double topPadding = MediaQuery.of(context).padding.top + 10;

    final user = ref.watch(userProfileProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? AppTheme.scaffoldBg(isDark)
            : AppTheme.scaffoldBg(isDark),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? AppTheme.scaffoldBg(isDark)
            : AppTheme.scaffoldBg(isDark),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: isDark
              ? HexColor("#3A1D07")
              : AppTheme.scaffoldBg(isDark),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [HexColor('#3A1D07'), HexColor('#171516')]
                    : [const Color(0xFFF5EEE4), const Color(0xFFFAF5F0)],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: topPadding,
                          left: 16.0,
                          right: 40.0,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          size: 22.0,
                          color: isDark
                              ? Colors.white.withOpacity(0.85)
                              : AppTheme.textPrimary(isDark),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: topPadding, left: 10.0),
                      child: Text(
                        "Profile",
                        style: GoogleFonts.poppins(
                          color: isDark
                              ? Colors.white.withOpacity(0.85)
                              : AppTheme.textPrimary(isDark),
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // Avatar
                    GestureDetector(
                      onTap: _isSubmitting ? null : _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.withOpacity(0.3)
                                  : const Color(0xFFD9CFC4),
                              shape: BoxShape.circle,
                            ),
                            child: _selectedImage != null
                                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                : user.profilePicture.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: user.profilePictureUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.withOpacity(0.3),
                                      child: Icon(
                                        Icons.person,
                                        color: isDark
                                            ? Colors.white70
                                            : AppTheme.textSecondary(isDark),
                                        size: 50,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      color: isDark
                                          ? Colors.white70
                                          : AppTheme.textSecondary(isDark),
                                      size: 50,
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.person,
                                      color: isDark
                                          ? Colors.white70
                                          : AppTheme.textSecondary(isDark),
                                      size: 50,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.orange
                                    : AppTheme.accent(isDark),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _isSubmitting ? null : _pickImage,
                      child: Text(
                        "Change Picture",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white70
                              : AppTheme.textPrimary(isDark),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _customTextField(
                      title: "Username",
                      controller: _userNameController,
                      hintText: "username",
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),

                    _customTextField(
                      title: "Full Name",
                      controller: _fullNameController,
                      hintText: "full name",
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),

                    _customTextField(
                      title: "Email",
                      controller: _emailController,
                      hintText: "email@gmail.com",
                      isDark: isDark,
                      readOnly: false, // now editable
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),

                    _customTextField(
                      title: "Phone Number",
                      controller: _phoneNumberController,
                      hintText: "+234 000 000 0000",
                      isDark: isDark,
                      readOnly: true, // phone not updatable via this endpoint
                    ),
                    const SizedBox(height: 10),

                    _customTextField(
                      title: "About",
                      controller: _aboutController,
                      hintText: "tell us about you",
                      isDark: isDark,
                    ),

                    const SizedBox(height: 30),

                    CustomButtonTwo(
                      title: _isDirty ? "Update" : "Edit Profile",
                      onClick: _submit,
                      isLoading: _isSubmitting,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _customTextField({
    required String title,
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
          ),
        ),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? Colors.white : AppTheme.inputBorder(isDark),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : AppTheme.inputBorder(isDark),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? Colors.white : AppTheme.accent(isDark),
                width: 1.5,
              ),
            ),
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(color: AppTheme.textHint(isDark)),
            filled: true,
            fillColor: readOnly
                ? (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1))
                : (isDark ? Colors.transparent : AppTheme.inputFill(isDark)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _aboutController.dispose();
    super.dispose();
  }
}
