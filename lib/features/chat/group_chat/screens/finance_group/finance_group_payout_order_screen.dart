import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/group_chat/screens/finance_group/finance_group_review_screen.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';

class FinanceGroupPayoutOrderScreen extends StatefulWidget {
  final List<String> members;

  const FinanceGroupPayoutOrderScreen({
    super.key,
    required this.members,
  });

  @override
  State<FinanceGroupPayoutOrderScreen> createState() =>
      _FinanceGroupPayoutOrderScreenState();
}

class _FinanceGroupPayoutOrderScreenState
    extends State<FinanceGroupPayoutOrderScreen> {
  bool _isAutoAssign = true;
  late List<String> _orderedMembers;

  @override
  void initState() {
    super.initState();
    _orderedMembers = ['You (Creator)', ...widget.members];
  }

  void _shuffle() {
    final others = _orderedMembers.sublist(1);
    others.shuffle();
    setState(() {
      _orderedMembers = ['You (Creator)', ...others];
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [HexColor('#3A1D07'), HexColor('#171516')],
                  )
                : null,
            color: isDark ? null : AppTheme.scaffoldBg(isDark),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payout Order',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Step 3 of 4',
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Mode toggle
                  Row(
                    children: ['Auto Assign', 'Manual'].map((mode) {
                      final isActive = _isAutoAssign
                          ? mode == 'Auto Assign'
                          : mode == 'Manual';
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: mode == 'Auto Assign' ? 8 : 0),
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _isAutoAssign = mode == 'Auto Assign'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 44,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.accentOrange
                                    : AppTheme.cardBg(isDark),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  mode,
                                  style: GoogleFonts.poppins(
                                    color: isActive
                                        ? Colors.white
                                        : AppTheme.textPrimary(isDark),
                                    fontSize: 14,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.iconBgBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.iconBgBlue, width: 1),
                    ),
                    child: Text(
                      'Payout order will be randomly assigned.\nYou can shuffle to get a different order.',
                      style: GoogleFonts.poppins(
                        color: AppColors.lightBlueText,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Shuffle button (auto assign only)
                  if (_isAutoAssign) ...[
                    GestureDetector(
                      onTap: _shuffle,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg(isDark),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shuffle,
                                color: isDark ? Colors.white70 : AppTheme.iconColorSubtle(isDark),
                                size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Shuffle Order',
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white70 : AppTheme.textSecondary(isDark),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Member list
                  if (_isAutoAssign)
                    ..._orderedMembers.asMap().entries.map((e) =>
                        _PayoutItem(
                          index: e.key + 1,
                          name: e.value,
                          isCreator: e.key == 0,
                          isDraggable: false,
                          isDark: isDark,
                        ))
                  else
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex == 0 || newIndex == 0) return;
                        if (newIndex > oldIndex) newIndex--;
                        setState(() {
                          final item = _orderedMembers.removeAt(oldIndex);
                          _orderedMembers.insert(newIndex, item);
                        });
                      },
                      children: _orderedMembers.asMap().entries.map((e) {
                        return _PayoutItem(
                          key: ValueKey(e.value),
                          index: e.key + 1,
                          name: e.value,
                          isCreator: e.key == 0,
                          isDraggable: e.key != 0,
                          isDark: isDark,
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 20),

                  // How it works
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg(isDark),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How it works',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...[
                          'Each member contributes at the same time every cycle',
                          'The person in position 1 receives the first payout',
                          'The cycle continues until everyone has received their payout',
                          'This order cannot be changed once the group is created',
                        ].map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: AppTheme.textHint(isDark),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    p,
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textSecondary(isDark),
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom button
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, 24 + MediaQuery.of(context).padding.bottom),
            child: CustomButtonTwo(
              title: 'Continue to summary',
              isLoading: false,
              hasMargin: false,
              onClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FinanceGroupReviewScreen(
                      payoutOrder: _orderedMembers,
                      isAutoAssign: _isAutoAssign,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutItem extends StatelessWidget {
  final int index;
  final String name;
  final bool isCreator;
  final bool isDraggable;
  final bool isDark;

  const _PayoutItem({
    super.key,
    required this.index,
    required this.name,
    required this.isCreator,
    required this.isDraggable,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCreator
                  ? AppColors.accentOrange
                  : AppTheme.cardBgAlt(isDark),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: GoogleFonts.poppins(
                  color: isCreator ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isCreator ? 'First payout recipient' : 'Position $index',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textHint(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isDraggable)
            Icon(Icons.drag_indicator,
                color: AppTheme.iconColorSubtle(isDark), size: 20),
        ],
      ),
    );
  }
}
