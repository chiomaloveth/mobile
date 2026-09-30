import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qik_talk/features/chat/general/services/community_api_service/community_api_service.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';
import 'community_details_screen.dart';

/// Drop-in replacement for CreateNewCommunityScreen.
/// Wires the form to POST /chat/community and navigates into the new community.
class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _api = CommunityApiService();
  final _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── Image picker ────────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.popupBg(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: AppTheme.iconColor(isDark),
              ),
              title: Text(
                'Camera',
                style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark)),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: AppTheme.iconColor(isDark),
              ),
              title: Text(
                'Gallery',
                style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark)),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;
    ref.read(biometricAuthProvider.notifier).isPickerActive = true;
    final XFile? img = await _picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 800,
    );
    await ref.read(biometricAuthProvider.notifier).onPickerReturned();
    if (img != null && mounted) {
      setState(() => _selectedImage = File(img.path));
    }
  }

  // ── Create ──────────────────────────────────────────────────────────────────

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await _api.createCommunity(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      imageFile: _selectedImage,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success && result.community != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Community created! An announcement group was added automatically.',
          ),
          backgroundColor: HexColor('#1A7F4B'),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CommunityDetailsScreen(
            communityId: result.community!.id,
            initialCommunity: result.community,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message.isNotEmpty
                ? result.message
                : 'Failed to create community',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: Column(
        children: [
          _buildAppBar(isDark),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildImagePicker(isDark),
                    const SizedBox(height: 28),
                    _label('Community Name'),
                    const SizedBox(height: 8),
                    _nameField(isDark),
                    const SizedBox(height: 20),
                    _label('Description'),
                    const SizedBox(height: 8),
                    _descField(isDark),
                    const SizedBox(height: 14),
                    _infoHint(
                      '📢 An announcement group is automatically created inside your community. Only admins can post there.',
                    ),
                    const SizedBox(height: 36),
                    _createButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [HexColor('#3A1D07'), HexColor('#171516')]
            : [const Color(0xFFF5EEE4), const Color(0xFFFAF5F0)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back, 
                  color: isDark ? Colors.white.withOpacity(0.85) : AppTheme.textPrimary(isDark)
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Community',
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white.withOpacity(0.85) : AppTheme.textPrimary(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Organize group communication.',
                      style: GoogleFonts.poppins(
                        color: isDark ? HexColor('#B0B0B0') : AppTheme.textSecondary(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? HexColor('#4A4A4A') : const Color(0xFFD9CFC4),
                image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedImage == null
                  ? Icon(Icons.people, color: AppTheme.textSecondary(isDark), size: 50)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen(isDark),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? HexColor('#1A1A1A') : AppTheme.scaffoldBg(isDark), 
                    width: 3
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: AppTheme.textPrimary(isDark),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _infoHint(String text) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark 
          ? HexColor('#1A7F4B').withOpacity(0.1)
          : AppTheme.successGreen(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark 
            ? HexColor('#1A7F4B').withOpacity(0.3)
            : AppTheme.successGreen(isDark).withOpacity(0.3)
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: isDark ? HexColor('#A0D9B8') : AppTheme.successGreen(isDark),
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _nameField(bool isDark) => Container(
    decoration: BoxDecoration(
      color: AppTheme.inputFill(isDark),
      borderRadius: BorderRadius.circular(12),
      border: isDark ? null : Border.all(color: AppTheme.inputBorder(isDark)),
    ),
    child: TextFormField(
      controller: _nameController,
      style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Enter community name',
        hintStyle: GoogleFonts.poppins(
          color: AppTheme.textHint(isDark),
          fontSize: 14,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Name is required';
        if (v.trim().length < 3) return 'At least 3 characters';
        return null;
      },
    ),
  );

  Widget _descField(bool isDark) => Container(
    decoration: BoxDecoration(
      color: AppTheme.inputFill(isDark),
      borderRadius: BorderRadius.circular(12),
      border: isDark ? null : Border.all(color: AppTheme.inputBorder(isDark)),
    ),
    child: TextFormField(
      controller: _descController,
      maxLines: 6,
      style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark), fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Add a welcoming message or description...',
        hintStyle: GoogleFonts.poppins(
          color: AppTheme.textHint(isDark),
          fontSize: 14,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
      ),
    ),
  );

  Widget _createButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _create,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoading
                ? [HexColor('#1A5A33'), HexColor('#1A5A33')]
                : [HexColor('#201E1F'), HexColor('#201E1F')],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: HexColor('#FF00A8').withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Create Community',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
