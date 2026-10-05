import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

import '../../../verification/screens/tier_one/screens/basic_information_screen.dart';


class TransferMidRefScreen extends ConsumerWidget {
  const TransferMidRefScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    final Color cardBg = isDark ? const Color(0xFF1E1714) : AppTheme.cardBg(isDark);
    final Color borderColor = isDark ? Colors.white.withOpacity(0.15) : AppTheme.border(isDark);
    final Color textMuted = isDark ? const Color(0xFFB58E6D) : AppTheme.textSecondary(isDark);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0502) : AppTheme.scaffoldBg(isDark),
      body: Container(
        decoration: isDark ? const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2A160B), Color(0xFF0A0502)],
            center: Alignment.topCenter,
            radius: 1.2,
          ),
        ) : null,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 32),

              Column(
                children: [
                  Text(
                    '₦0.00',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your account value',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.info_outline_rounded, color: textMuted, size: 18),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Unlock all features card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: isDark ? const LinearGradient(
                    colors: [Color(0xFF381F0D), Color(0xFF160D07)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ) : null,
                  color: isDark ? null : AppTheme.cardBg(isDark),
                  border: isDark ? null : Border.all(color: AppTheme.border(isDark)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock all features',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please confirm your ID and unlock all\napp features.',
                      style: TextStyle(
                        color: isDark ? Colors.white.withOpacity(0.7) : AppTheme.textSecondary(isDark),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => BasicInformationScreen(),
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.3) : AppTheme.border(isDark),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: isDark ? Colors.white : AppTheme.textPrimary(isDark), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Add documents',
                              style: TextStyle(
                                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Link your bank account card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Link your bank account',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Transfer your cash to investments to\nmeet your goals',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFB58E6D).withOpacity(0.8) : AppTheme.textSecondary(isDark),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF903B1E),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Add card',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Invite friends card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite friends',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2E2723) : AppTheme.cardBgAlt(isDark),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.border(isDark)),
                          ),
                          child: Text(
                            'LP867J',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C3020),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text(
                            'Earn \$200',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}