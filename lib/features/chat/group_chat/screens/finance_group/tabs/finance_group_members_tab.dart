import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/chat/group_chat/screens/finance_group/finance_group_member_profile_screen.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class _FinanceMember {
  final String name;
  final String status; // 'paid' | 'pending'
  final bool isYou;
  final bool payoutReceived;

  const _FinanceMember({
    required this.name,
    required this.status,
    this.isYou = false,
    this.payoutReceived = false,
  });
}

class FinanceGroupMembersTab extends ConsumerWidget {
  final bool isAdmin;

  const FinanceGroupMembersTab({super.key, required this.isAdmin});

  static const _members = [
    _FinanceMember(
        name: 'You', status: 'paid', isYou: true, payoutReceived: true),
    _FinanceMember(name: 'Adetola Johnson', status: 'paid'),
    _FinanceMember(name: 'Chioma Okeke', status: 'paid'),
    _FinanceMember(name: 'Ibrahim Musa', status: 'pending'),
    _FinanceMember(name: 'Funke Adeyemi', status: 'paid'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 24 + MediaQuery.of(context).padding.bottom),
      itemCount: _members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final m = _members[i];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FinanceGroupMemberProfileScreen(
                  name: m.name,
                  isYou: m.isYou,
                  isAdmin: isAdmin,
                  status: m.status,
                  payoutReceived: m.payoutReceived,
                ),
              ),
            );
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg(isDark),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.scaffoldBg(isDark),
                  child: Text(
                    m.name[0],
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.name,
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusBadge(status: m.status),
                          if (m.payoutReceived) ...[
                            const SizedBox(width: 6),
                            _StatusBadge(status: 'payout'),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: isDark ? Colors.white38 : AppTheme.textSecondary(isDark),
                    size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case 'paid':
        bg = AppColors.infoGreenBg;
        text = AppColors.primaryGreen;
        label = 'paid';
        break;
      case 'pending':
        bg = AppColors.warningBg;
        text = AppColors.warningText;
        label = 'pending';
        break;
      case 'payout':
        bg = AppColors.iconBgBlue.withOpacity(0.3);
        text = AppColors.lightBlueText;
        label = 'Payout received';
        break;
      default:
        bg = Colors.transparent;
        text = Colors.white38;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
