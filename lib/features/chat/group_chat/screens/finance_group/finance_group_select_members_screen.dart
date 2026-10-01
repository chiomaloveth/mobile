import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/group_chat/screens/finance_group/finance_group_payout_order_screen.dart';
import 'package:qik_talk/utilities/components/buttons/custom_button_two.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';

// Temporary mock contact model
class _Contact {
  final String name;
  final String avatarUrl;
  _Contact({required this.name, required this.avatarUrl});
}

class FinanceGroupSelectMembersScreen extends StatefulWidget {
  final int maxMembers;

  const FinanceGroupSelectMembersScreen({
    super.key,
    required this.maxMembers,
  });

  @override
  State<FinanceGroupSelectMembersScreen> createState() =>
      _FinanceGroupSelectMembersScreenState();
}

class _FinanceGroupSelectMembersScreenState
    extends State<FinanceGroupSelectMembersScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selected = {};
  String _query = '';

  // Mock contacts — replace with real data from your contact service
  final List<_Contact> _allContacts = [
    _Contact(name: 'Abigail', avatarUrl: ''),
    _Contact(name: 'Adedayo', avatarUrl: ''),
    _Contact(name: 'Adejare', avatarUrl: ''),
    _Contact(name: 'Ajayi', avatarUrl: ''),
    _Contact(name: 'Anothonia', avatarUrl: ''),
    _Contact(name: 'Anothony', avatarUrl: ''),
    _Contact(name: 'Bayo', avatarUrl: ''),
    _Contact(name: 'Barakat', avatarUrl: ''),
    _Contact(name: 'Brandie', avatarUrl: ''),
    _Contact(name: 'Cooper', avatarUrl: ''),
    _Contact(name: 'Daniel', avatarUrl: ''),
    _Contact(name: 'Jumoke', avatarUrl: ''),
    _Contact(name: 'Michael', avatarUrl: ''),
  ];

  final List<_Contact> _frequentContacts = [];

  List<_Contact> get _filtered => _allContacts
      .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  Map<String, List<_Contact>> get _grouped {
    final map = <String, List<_Contact>>{};
    for (final c in _filtered) {
      final letter = c.name[0].toUpperCase();
      map.putIfAbsent(letter, () => []).add(c);
    }
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  @override
  void initState() {
    super.initState();
    _frequentContacts.addAll(_allContacts.take(5));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleContact(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
      } else if (_selected.length < widget.maxMembers - 1) {
        _selected.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final letters = grouped.keys.toList();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(Theme.of(context).brightness == Brightness.dark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HexColor('#3A1D07'), HexColor('#171516')],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Members',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Step 2 of 4',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
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
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // Members selected bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.warningBorder, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Members selected',
                                style: GoogleFonts.poppins(
                                  color: AppColors.warningText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${_selected.length} / ${widget.maxMembers - 1}',
                                style: GoogleFonts.poppins(
                                  color: AppColors.warningText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Search bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(AppColors.primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _query = v),
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search names or numbers',
                              hintStyle: GoogleFonts.poppins(
                                  color: Colors.white38, fontSize: 14),
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.white38, size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Frequently contacted
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Text(
                          'Frequently contacted',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _frequentContacts.length,
                          itemBuilder: (_, i) {
                            final c = _frequentContacts[i];
                            final isSelected = _selected.contains(c.name);
                            return GestureDetector(
                              onTap: () => _toggleContact(c.name),
                              child: Container(
                                width: 68,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor:
                                              const Color(AppColors.primaryColor),
                                          child: Text(
                                            c.name[0],
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              width: 18,
                                              height: 18,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primaryGreen,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 11,
                                              ),
                                            ),
                                          )
                                        else
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white38,
                                                    width: 1.5),
                                                color: Colors.transparent,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      c.name,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Grouped contact list
                    for (final letter in letters) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            letter,
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          margin:
                              const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.primaryColor),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: grouped[letter]!.map((c) {
                              final isSelected = _selected.contains(c.name);
                              final isLast =
                                  grouped[letter]!.last == c;
                              return GestureDetector(
                                onTap: () => _toggleContact(c.name),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: isLast
                                        ? null
                                        : Border(
                                            bottom: BorderSide(
                                              color: Colors.white
                                                  .withOpacity(0.05),
                                            ),
                                          ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: const Color(
                                            AppColors.primaryBackgroundColor),
                                        child: Text(
                                          c.name[0],
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          c.name,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? AppColors.primaryGreen
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryGreen
                                                : Colors.white38,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(Icons.check,
                                                color: Colors.white,
                                                size: 13)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],

                    // Bottom spacing for button
                    const SliverToBoxAdapter(
                        child: SizedBox(height: 100)),
                  ],
                ),

                // A-Z index
                Positioned(
                  right: 4,
                  top: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: letters
                        .map(
                          (l) => GestureDetector(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 1.5),
                              child: Text(
                                l,
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // Bottom button
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, 24 + MediaQuery.of(context).padding.bottom),
            child: Opacity(
              opacity: _selected.isNotEmpty ? 1.0 : 0.4,
              child: CustomButtonTwo(
                title: 'Continue to Contribution Order',
                isLoading: false,
                hasMargin: false,
                onClick: _selected.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FinanceGroupPayoutOrderScreen(
                              members: _selected.toList(),
                            ),
                          ),
                        );
                      }
                    : () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}