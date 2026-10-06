import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../../features/authentication/login/components/create_login_details_dialog.dart';
import '../../../features/calls/screens/call_screen.dart';
import '../../../features/chat/general/screens/chat_screen.dart';
import '../../../features/feed/presentation/screens/feed_screen.dart';
import '../../../features/settings/theme/provider/theme_provider.dart';
import '../../../features/status/screens/status_screen.dart';
import '../../../features/wallet/screens/main_wallet/screen/wallet_screen.dart';
import '../../../features/wallet/features/wallet_setup/screens/wallet_intro_screen.dart';
import '../../../features/wallet/services/wallet_services.dart';
import '../../../utilities/constants/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/custom_bottom_nav_provider.dart';
import 'package:qik_talk/features/notifications/services/notification_service.dart';
import 'package:qik_talk/features/feed/presentation/screens/feed_profile_screen.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/utilities/components/app_lock_wrapper.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

/// Tri-state: null = not yet checked, true = has wallet, false = no wallet
final walletRegisteredProvider = StateProvider<bool?>((ref) => null);

const int _kChatIndex = 0;
const int _kCallIndex = 1;
const int _kStatusIndex = 2;
const int _kDiscoverIndex = 3;
const int _kWalletIndex = 4;

const double _kFabOverhang = 12.0;
const double _kFabSize = 64.0;
const double _kBarHeight = 64.0;

class CustomBottomNav extends ConsumerStatefulWidget {
  const CustomBottomNav({super.key});

  @override
  ConsumerState<CustomBottomNav> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<CustomBottomNav> {
  late final PageController _pageController;

  // Pages declared as late final so they're created once and kept alive
  late final List<Widget> pages;

  // Guard to prevent stacking multiple email-verification dialogs
  bool _isEmailVerificationDialogOpen = false;

  @override
  void initState() {
    super.initState();
    pages = [
      const ChatFragment(),
      const CallScreen(),
      const StatusFragment(),
      const FeedFragment(),
      const WalletScreen(),
    ];
    final pageIndex = ref.read(customBottomNavProvider).pageIndex;
    _pageController = PageController(initialPage: pageIndex);
    _setupNotificationHandler();

    // Trigger the email-verification overlay from the ROOT navigator
    // so it renders above the PageView and bottom nav bar.
    // A 400 ms delay ensures the route transition from AddProfileInfoScreen
    // is fully settled before we call showDialog.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _checkAndPromptEmailVerification();
      });
    });
  }

  /// Shows [CreateLoginDetailsDialog] using the ROOT navigator so the overlay
  /// covers the entire screen (including the bottom nav bar).
  /// Re-shows automatically if the user somehow closes it without verifying.
  Future<void> _checkAndPromptEmailVerification() async {
    if (!mounted || _isEmailVerificationDialogOpen) return;

    final bool hasPassword =
        await SaveValues().getBool(AppPreferenceHelper.HAS_PASSWORD) ?? false;
    debugPrint('🔐 [CustomBottomNav] hasPassword=$hasPassword');

    if (!hasPassword && mounted) {
      _isEmailVerificationDialogOpen = true;
      try {
        await showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: true, // ← KEY: uses root overlay, not PageView child
          builder: (ctx) => PopScope(
            canPop: false, // Block hardware back button (Flutter 3.x+)
            child: CreateLoginDetailsDialog(),
          ),
        );
      } finally {
        if (mounted) _isEmailVerificationDialogOpen = false;
      }

      // After the full dialog chain closes, re-check.
      // If still unverified (user somehow dismissed), reopen immediately.
      if (mounted) {
        final bool nowHasPassword =
            await SaveValues().getBool(AppPreferenceHelper.HAS_PASSWORD) ?? false;
        if (!nowHasPassword) _checkAndPromptEmailVerification();
      }
    }
  }

  void _setupNotificationHandler() {
    NotificationService().onNotificationTap = (Map<String, dynamic> data) {
      final type = data['type'] as String? ?? '';
      switch (type) {
        case 'CHAT_MESSAGE':
          animateToPage(_kChatIndex);
          break;
        case 'POST_LIKED':
        case 'POST_COMMENTED':
          animateToPage(_kDiscoverIndex);
          break;
        case 'USER_FOLLOWED':
          animateToPage(_kDiscoverIndex);
          final followerId = data['followerId'] as String? ?? '';
          if (followerId.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 400), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    user: FeedUser(id: followerId, username: 'Loading...'),
                    isCurrentUser: false,
                  ),
                ),
              );
            });
          }
          break;
        case 'STATUS_RESHARED':
          animateToPage(_kStatusIndex);
          break;
        default:
          debugPrint('⚠️ Unhandled notification type: $type');
      }
    };
  }

  void onPageChanged(int index) =>
      ref.read(customBottomNavProvider.notifier).setPageIndex(index);

  void animateToPage(int index) {
    SaveValues().getBool(AppPreferenceHelper.HAS_PASSWORD).then((hasPassword) {
      if (index != _kChatIndex && !(hasPassword ?? false)) {
        // Intercept navigation if email verification is not complete yet
        return;
      }
      _pageController.jumpToPage(index);
      ref.read(customBottomNavProvider.notifier).setPageIndex(index);

      // Pre-fetch profile info when Discover tab is clicked
      if (index == _kDiscoverIndex) {
        ref.read(feedProvider.notifier).loadUserInfo(silent: true);
      }
    });
  }

  /// Called when the wallet FAB is tapped.
  /// Checks whether the user already has a wallet before allowing access.
  Future<void> _onWalletFabTapped() async {
    final bool hasPassword =
        await SaveValues().getBool(AppPreferenceHelper.HAS_PASSWORD) ?? false;
    if (!hasPassword) {
      // Intercept navigation if email verification is not complete yet
      return;
    }

    // If we already confirmed the user has a wallet, go straight there.
    final cached = ref.read(walletRegisteredProvider);
    if (cached == true) {
      animateToPage(_kWalletIndex);
      return;
    }

    // Show a brief loading indicator while we check.
    if (!mounted) return;
    final overlay = OverlayEntry(
      builder: (_) => const _WalletCheckOverlay(),
    );
    Overlay.of(context).insert(overlay);

    bool hasWallet = false;
    try {
      await WalletServices().getAccountDetails(context: context);
      hasWallet = true;
    } catch (_) {
      hasWallet = false;
    }

    overlay.remove();

    if (!mounted) return;

    if (hasWallet) {
      // Cache the result so we don't check again this session.
      ref.read(walletRegisteredProvider.notifier).state = true;
      animateToPage(_kWalletIndex);
    } else {
      // Stay on the current page (chat) and push the intro as a route.
      // Back button will return here automatically.
      final registered = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const WalletIntroScreen(),
        ),
      );
      // If the intro flow completed successfully, mark wallet as registered
      // and navigate to the wallet page.
      if (registered == true && mounted) {
        ref.read(walletRegisteredProvider.notifier).state = true;
        animateToPage(_kWalletIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = ref.watch(customBottomNavProvider).pageIndex;
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return AppLockWrapper(
      child: WillPopScope(
        onWillPop: () async {
          if (pageIndex != _kChatIndex) {
            animateToPage(_kChatIndex);
            return false;
          }
          return true;
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: AppTheme.scaffoldBg(isDark),
            // extendBody lets the page content show BEHIND the floating bar
            extendBody: true,
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: onPageChanged,
              children: pages,
            ),
            // Use bottomNavigationBar so Flutter handles safe-area automatically
            bottomNavigationBar: _NavBarWrapper(
              pageIndex: pageIndex,
              isDark: isDark,
              onTap: animateToPage,
              onWalletTap: _onWalletFabTapped,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wrapper that adds the safe-area bottom padding and positions the FAB overhang
// ─────────────────────────────────────────────────────────────────────────────
class _NavBarWrapper extends StatelessWidget {
  const _NavBarWrapper({
    required this.pageIndex,
    required this.onTap,
    required this.onWalletTap,
    required this.isDark,
  });

  final int pageIndex;
  final void Function(int) onTap;
  final VoidCallback onWalletTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Total height = bar + overhang above bar + safe area below
    final totalHeight = _kBarHeight + _kFabOverhang + bottomInset;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Glass bar — sits at the bottom of the wrapper ──────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomInset + 8,
            height: _kBarHeight,
            child: _GlassBar(
              pageIndex: pageIndex,
              onTap: onTap,
              isDark: isDark,
            ),
          ),

          // ── Wallet FAB — centred, top pokes _kFabOverhang above bar ───
          Positioned(
            // centre horizontally
            left: 0,
            right: 0,
            // bottom of FAB aligns with bottom of bar minus a little padding
            bottom: bottomInset + 5 + 10,
            child: Center(
              child: _WalletFab(
                isActive: pageIndex == _kWalletIndex,
                onTap: onWalletTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glassmorphism rounded-rectangle bar
// ─────────────────────────────────────────────────────────────────────────────
class _GlassBar extends StatelessWidget {
  const _GlassBar({
    required this.pageIndex,
    required this.onTap,
    required this.isDark,
  });

  final int pageIndex;
  final void Function(int) onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Rounded rectangle — matches Figma shape exactly
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0x12FFFFFF) : const Color(0x18000000),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.10),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0x66000000)
                    : const Color(0x22000000),
                blurRadius: 50,
                spreadRadius: -12,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NavItem(
                icon: 'images/chat.png',
                activeIcon: 'images/chat_active.png',
                label: 'Chats',
                index: _kChatIndex,
                currentIndex: pageIndex,
                onTap: onTap,
                isDark: isDark,
              ),
              _NavItem(
                icon: 'images/call.png',
                activeIcon: 'images/call_active.png',
                label: 'Call',
                index: _kCallIndex,
                currentIndex: pageIndex,
                onTap: onTap,
                isDark: isDark,
              ),

              // Spacer for the wallet FAB hole in the centre
              const SizedBox(width: _kFabSize),

              _NavItem(
                icon: 'images/feeds.png',
                activeIcon: 'images/feeds_active.png',
                label: 'Discover',
                index: _kDiscoverIndex,
                currentIndex: pageIndex,
                onTap: onTap,
                isDark: isDark,
              ),
              _NavItem(
                icon: 'images/status.png',
                activeIcon: 'images/status_active.png',
                label: 'Status',
                index: _kStatusIndex,
                currentIndex: pageIndex,
                onTap: onTap,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Orange Wallet FAB — larger, top pokes above the bar
// ─────────────────────────────────────────────────────────────────────────────
class _WalletFab extends StatelessWidget {
  const _WalletFab({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _kFabSize,
        height: _kFabSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [const Color(0xFFFF6000), const Color(0xFFFF9500)]
                : [const Color(0xFFFF8C00), const Color(0xFFFF5500)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFFF6B00,
              ).withOpacity(isActive ? 0.35 : 0.20),
              blurRadius: isActive ? 12 : 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            isActive ? 'images/wallet_active.png' : 'images/wallet.png',
            width: 26,
            height: 26,
            color: Colors.white,
            colorBlendMode: BlendMode.srcIn,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual nav item
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  final String icon;
  final String activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentIndex;
    final Color labelColor = isDark ? Colors.white : const Color(0xFF1A1008);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 62,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Image.asset(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                width: isActive ? 26 : 22,
                height: isActive ? 26 : 22,
                color: !isActive && !isDark ? const Color(0xFF4A4A4A) : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? (isDark ? Colors.white : const Color(0xFFC65800))
                    : labelColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Translucent overlay shown while checking wallet status
// ─────────────────────────────────────────────────────────────────────────────
class _WalletCheckOverlay extends StatelessWidget {
  const _WalletCheckOverlay();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: ColoredBox(
        color: Colors.black26,
        child: Center(
          child: SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
            ),
          ),
        ),
      ),
    );
  }
}
