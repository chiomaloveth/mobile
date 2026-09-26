import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../../../../theme/provider/theme_provider.dart';
import '../provider/data_storage_provider.dart';

class NetworkUsageScreen extends ConsumerWidget {
  const NetworkUsageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkAsync = ref.watch(networkUsageProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system && systemBrightness == Brightness.dark);

    final Color bg = isDark ? const Color(0xFF141414) : const Color(0xFFFAF5F0);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF2F2F2);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white60 : Colors.black54;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(AppColors.gradientColorsTwo),
                  Color(AppColors.gradientColorsOne),
                ],
              ) : null,
              color: isDark ? null : AppTheme.scaffoldBg(isDark),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Network Usage',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        body: networkAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (net) {
            // Mock period breakdowns — in a real app these would come from the backend
            final currentMonthSent = (net.sentBytes * 0.25).toInt();
            final currentMonthRecv = (net.receivedBytes * 0.32).toInt();
            final last30Sent = (net.sentBytes * 0.88).toInt();
            final last30Recv = (net.receivedBytes * 0.81).toInt();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _UsageCard(
                    title: 'Current Month',
                    sentBytes: currentMonthSent,
                    receivedBytes: currentMonthRecv,
                    cardBg: cardBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  const SizedBox(height: 12),
                  _UsageCard(
                    title: 'Last 30 Days',
                    sentBytes: last30Sent,
                    receivedBytes: last30Recv,
                    cardBg: cardBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  const SizedBox(height: 12),
                  _UsageCard(
                    title: 'All Time',
                    sentBytes: net.sentBytes,
                    receivedBytes: net.receivedBytes,
                    cardBg: cardBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  const SizedBox(height: 20),
                  // Reset Statistics button
                  GestureDetector(
                    onTap: () async {
                      await ref.read(networkUsageProvider.notifier).reset();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Statistics reset')),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, color: Color(0xFFE8A020), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Reset Statistics',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFE8A020),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  final String title;
  final int sentBytes;
  final int receivedBytes;
  final Color cardBg;
  final Color textColor;
  final Color subTextColor;

  const _UsageCard({
    required this.title,
    required this.sentBytes,
    required this.receivedBytes,
    required this.cardBg,
    required this.textColor,
    required this.subTextColor,
  });

  static String _fmt(int bytes) {
    if (bytes >= 1073741824) return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    if (bytes >= 1048576) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Sent
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A3A2A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bar_chart, color: Color(0xFF34C759), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sent',
                            style: GoogleFonts.poppins(
                                color: subTextColor, fontSize: 11, fontWeight: FontWeight.w400)),
                        Text(_fmt(sentBytes),
                            style: GoogleFonts.poppins(
                                color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              // Received
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2A3A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.wifi, color: Color(0xFF0A84FF), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Received',
                            style: GoogleFonts.poppins(
                                color: subTextColor, fontSize: 11, fontWeight: FontWeight.w400)),
                        Text(_fmt(receivedBytes),
                            style: GoogleFonts.poppins(
                                color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
