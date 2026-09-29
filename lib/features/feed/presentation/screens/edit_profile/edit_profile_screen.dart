import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/utilities/components/switchs/custom_switch_one.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/media_utils.dart';
import 'account_info_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  bool _hidePhoneNumber = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(feedProvider).userInfo?.data;
      if (user == null) {
        ref.read(feedProvider.notifier).loadUserInfo();
      } else {
        setState(() {
          _hidePhoneNumber = user.hidePhone ?? false;
        });
      }
    });
  }

  Future<void> _navigateToAccountInfo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountInfoScreen()),
    );
    if (result == true) {
      if (mounted) Navigator.pop(context);
    }
  }


  Future<void> _pickImage() async {
    _navigateToAccountInfo();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    final feedState = ref.watch(feedProvider);
    final user = feedState.userInfo?.data;
    final String? rawUsername = user?.username;
    final String username = (rawUsername == null || rawUsername.trim().isEmpty)
        ? 'User'
        : rawUsername;
    final initials = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(isDark), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Edit profile',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(color: Colors.transparent, height: 40),
            const SizedBox(height: 30),
            // Profile Photo Section
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.white24 : AppTheme.border(isDark), 
                              width: 2
                            ),
                          ),
                          child: ClipOval(
                            child: ClipOval(
                              child:
                                  user?.profilePicture != null &&
                                      user!.profilePicture.isNotEmpty
                                  ? Image.network(
                                      MediaUtils.getThumbnailUrl(
                                        user.profilePicture,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
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
                                    ),
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark 
                              ? Colors.black.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.7),
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Change photo',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Profile Info List
            _buildInfoItem(
              label: 'Name',
              value: '',
              onTap: () => _navigateToAccountInfo(),
            ),
            _buildInfoItem(
              label: 'Username',
              value: username,
              onTap: () => _navigateToAccountInfo(),
            ),
            _buildInfoItem(
              label: '',
              value:
                  'qiktalk.com/@${username.toLowerCase().replaceAll(' ', '_')}',
              trailing: Icon(Icons.copy, color: AppTheme.iconColor(isDark), size: 18),
              onTap: () {
                Clipboard.setData(
                  ClipboardData(
                    text:
                        'qiktalk.com/@${username.toLowerCase().replaceAll(' ', '_')}',
                  ),
                );
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Link copied to clipboard')),
                // );
              },
            ),
            _buildInfoItem(
              label: 'Bio',
              value: user?.about != null && user!.about.isNotEmpty
                  ? user.about
                  : 'Add a bio to your profile',
              onTap: () => _navigateToAccountInfo(),
            ),
            Divider(color: isDark ? Colors.white12 : AppTheme.divider(isDark), height: 40),
            _buildInfoItem(
              label: 'Phone',
              value: 'Add Phone number to your profile',
              onTap: () => _navigateToAccountInfo(),
            ),
            // Hide phone number switch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Hide phone number when chatting?',
                        style: GoogleFonts.poppins(
                          color: isDark ? HexColor('#ED9F22') : const Color(0xFFB8860B),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  CustomSwitchOne(
                    value: _hidePhoneNumber,
                    onChange: (value) {
                      setState(() {
                        _hidePhoneNumber = value;
                      });
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoItem(
              label: 'Instagram',
              value: 'Add Instagram to your profile',
              onTap: () => _navigateToAccountInfo(),
            ),
            _buildInfoItem(
              label: 'YouTube',
              value: 'Add YouTube to your profile',
              onTap: () => _navigateToAccountInfo(),
            ),
            const SizedBox(height: 50),
            // Update Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Glow Effect
                  Container(
                    height: 15,
                    width: MediaQuery.of(context).size.width * 0.55,
                    decoration: BoxDecoration(
                      boxShadow: isDark ? [
                        BoxShadow(
                          color: const Color(0xFFFF3D00).withValues(alpha: 0.4),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ] : [],
                    ),
                  ),
                  // Button
                  GestureDetector(
                    onTap: _navigateToAccountInfo,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : AppTheme.accent(isDark),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? HexColor('#FF00A8') : AppTheme.accent(isDark),
                          width: 0.92,
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
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Update Profile',
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
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            if (label.isNotEmpty)
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  color: label.isEmpty 
                    ? (isDark ? Colors.white54 : AppTheme.textSecondary(isDark))
                    : (isDark ? Colors.white70 : AppTheme.textSecondary(isDark)),
                  fontSize: 14,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? Colors.white38 : AppTheme.iconColorSubtle(isDark),
                  size: 14,
                ),
          ],
        ),
      ),
    );
  }
}
