import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../utilities/constants/app_colors.dart';
import '../../../../../../settings/theme/provider/theme_provider.dart';
import '../../../model/bank_list_model.dart';

class BankListBottomSheet extends StatefulWidget {
  final Future<List<BankListModel>> futureBanks;
  final BankListModel? selected;
  final Function(BankListModel? newValue) onSelected;

  const BankListBottomSheet({
    super.key,
    required this.futureBanks,
    required this.onSelected,
    required this.selected,
  });

  @override
  State<BankListBottomSheet> createState() => _BankListBottomSheetState();
}

class _BankListBottomSheetState extends State<BankListBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Bank",
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              FocusScope.of(context).unfocus();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return Padding(
                    // Adjust padding to support Keyboard pushing the sheet up
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: BankListMainBottomSheet(
                        widget.futureBanks, widget.selected, widget.onSelected),
                  );
                },
              );
            },
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 1, color: Colors.grey.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.selected != null ? widget.selected!.name : "Choose a bank",
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: widget.selected != null ? null : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Colors.grey.withOpacity(0.8),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BankListMainBottomSheet extends ConsumerStatefulWidget {
  final Future<List<BankListModel>> futureBanks;
  final BankListModel? selected;
  final Function(BankListModel? newValue) onSelected;

  const BankListMainBottomSheet(this.futureBanks, this.selected, this.onSelected,
      {super.key});

  @override
  ConsumerState<BankListMainBottomSheet> createState() =>
      _BankListMainBottomSheetState();
}

class _BankListMainBottomSheetState extends ConsumerState<BankListMainBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final textColor = isDark ? Colors.white : Colors.black;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? const Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75, // Scaled for better fit
        decoration: BoxDecoration(
          color: isDark
              ? const Color(AppColors.primaryBackgroundColor)
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),

              // Custom Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}), // triggers local rebuild filtering
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search for a bank",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.withOpacity(0.5)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Dynamic Future builder handles Banks / Loading / Searching
              Expanded(
                child: FutureBuilder<List<BankListModel>>(
                  future: widget.futureBanks,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Failed to load banks. Try reopening.",
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    else if (snapshot.hasData) {
                      final banks = snapshot.data!;
                      final query = _searchController.text.toLowerCase();
                      final filteredBanks = banks.where((b) {
                        return b.name.toLowerCase().contains(query);
                      }).toList();

                      if (filteredBanks.isEmpty) {
                        return Center(
                          child: Text(
                            "No banks found",
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredBanks.length,
                        itemBuilder: (context, index) {
                          return BankOptionCard(
                            bank: filteredBanks[index],
                            selectedBank: widget.selected,
                            textColor: textColor,
                            onClick: () {
                              widget.onSelected(filteredBanks[index]);
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BankOptionCard extends StatelessWidget {
  final BankListModel bank;
  final BankListModel? selectedBank;
  final VoidCallback onClick;
  final Color textColor;

  const BankOptionCard({
    super.key,
    required this.bank,
    required this.onClick,
    this.selectedBank,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: bank.name == selectedBank?.name
              ? Colors.grey.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: MaterialButton(
          onPressed: onClick,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  bank.name,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: bank.name == selectedBank?.name ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}