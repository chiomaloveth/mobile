import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _rippleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    // Auto-trigger authentication after a short delay
    Future.delayed(const Duration(milliseconds: 800), _authenticate);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    
    setState(() {
      _isAuthenticating = true;
    });

    try {
      final success = await ref
          .read(biometricAuthProvider.notifier)
          .authenticate(reason: 'Unlock to use QikTalk');

      if (success) {
        // Authentication successful - the AppLockWrapper will automatically hide this screen
        if (mounted) {
          setState(() {
            _isAuthenticating = false;
          });
        }
      } else {
        _handleAuthFailure();
      }
    } catch (e) {
      _handleAuthFailure();
    }
  }

  void _handleAuthFailure() {
    setState(() {
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: size.height * 0.04,
            ),
            child: Column(
              children: [
                // Top spacing
                SizedBox(height: size.height * 0.15),
                
                // System Shield Notification Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2A2A2A),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shield icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.security,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'System Shield',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Just now',
                                  style: GoogleFonts.inter(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Unlock to use QikTalk',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Spacer to center fingerprint section
                const Spacer(),
                
                // Fingerprint Authentication Section
                Column(
                  children: [
                    // Animated fingerprint with ripple effect
                    GestureDetector(
                      onTap: _isAuthenticating ? null : _authenticate,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer ripple circles
                            AnimatedBuilder(
                              animation: _rippleAnimation,
                              builder: (context, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outermost circle
                                    Container(
                                      width: 200 * _rippleAnimation.value,
                                      height: 200 * _rippleAnimation.value,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(
                                            (1 - _rippleAnimation.value) * 0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    // Middle circle
                                    Container(
                                      width: 160 * _rippleAnimation.value,
                                      height: 160 * _rippleAnimation.value,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(
                                            (1 - _rippleAnimation.value) * 0.4,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    // Inner circle
                                    Container(
                                      width: 120 * _rippleAnimation.value,
                                      height: 120 * _rippleAnimation.value,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(
                                            (1 - _rippleAnimation.value) * 0.5,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            
                            // Main fingerprint circle
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF1A1A1A),
                                      border: Border.all(
                                        color: const Color(0xFF333333),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.fingerprint,
                                      size: 40,
                                      color: _isAuthenticating 
                                          ? Colors.orange
                                          : Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.04),
                    
                    // Hold to authenticate text
                    Text(
                      'TOUCH TO AUTHENTICATE',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                
                // Bottom spacer
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}