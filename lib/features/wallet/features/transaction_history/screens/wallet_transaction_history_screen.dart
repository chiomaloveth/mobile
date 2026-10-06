import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import '../../../../../utilities/components/buttons/gradient_flow_button.dart';
import '../../../../settings/theme/provider/theme_provider.dart';
import '../components/transaction_history_card_one.dart';
import '../model/transaction_history_model.dart';
import '../services/transaction_history_services.dart';

class WalletTransactionHistoryScreen extends ConsumerStatefulWidget {
  const WalletTransactionHistoryScreen({super.key});

  @override
  ConsumerState<WalletTransactionHistoryScreen> createState() =>
      _WalletTransactionHistoryScreenState();
}

class _WalletTransactionHistoryScreenState
    extends ConsumerState<WalletTransactionHistoryScreen> {
  final TransactionHistoryServices _transactionHistoryServices =
      TransactionHistoryServices();
  late Future<List<TransactionHistoryModel>> _futureTransactions;

  bool _isSearching = false;
  String _searchQuery = "";
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterCategory;
  String? _filterStatus;
  String? _filterPaymentMethod;

  final List<String> _categories = [
    "purchase",
    "refund",
    "withdrawal",
    "deposit",
    "transfer",
  ];
  final List<String> _statuses = ["pending", "completed", "failed", "refunded"];
  final List<String> _paymentMethods = [
    "wallet",
    "card",
    "transfer",
    "korapay",
  ];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _fetchTransactions() {
    _futureTransactions = _transactionHistoryServices.getUserTransactions(
      context: context,
    );
  }

  String _formatDateHeader(String isoDateString) {
    if (isoDateString.isEmpty) return "Unknown Date";

    try {
      DateTime date = DateTime.parse(isoDateString).toLocal();
      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(const Duration(days: 1));

      const List<String> shortMonths = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      const List<String> fullMonths = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      String monthShort = shortMonths[date.month - 1];
      String monthFull = fullMonths[date.month - 1];
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return "Today, $monthShort ${date.day}";
      }
      if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        return "Yesterday, $monthShort ${date.day}";
      }
      return "$monthFull ${date.day}, ${date.year}";
    } catch (e) {
      return "Unknown Date";
    }
  }

  List<TransactionHistoryModel> _applyFilters(
    List<TransactionHistoryModel> transactions,
  ) {
    return transactions.where((tx) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final searchString =
            "${tx.type} ${tx.status} ${tx.paymentMethod} ${tx.amount} ${tx.reference}"
                .toLowerCase();
        if (!searchString.contains(query)) return false;
      }

      if (_filterStartDate != null && _filterEndDate != null) {
        try {
          DateTime txDate = DateTime.parse(tx.createdAt).toLocal();
          DateTime start = DateTime(
            _filterStartDate!.year,
            _filterStartDate!.month,
            _filterStartDate!.day,
          );
          DateTime end = DateTime(
            _filterEndDate!.year,
            _filterEndDate!.month,
            _filterEndDate!.day,
            23,
            59,
            59,
          );
          if (txDate.isBefore(start) || txDate.isAfter(end)) return false;
        } catch (e) {
          return false;
        }
      }

      if (_filterCategory != null) {
        if (tx.type?.toLowerCase() != _filterCategory?.toLowerCase())
          return false;
      }

      if (_filterStatus != null) {
        if (tx.status?.toLowerCase() != _filterStatus?.toLowerCase())
          return false;
      }

      if (_filterPaymentMethod != null) {
        if (tx.paymentMethod?.toLowerCase() !=
            _filterPaymentMethod?.toLowerCase())
          return false;
      }

      return true;
    }).toList();
  }

  Map<String, List<TransactionHistoryModel>> _groupTransactionsByDate(
    List<TransactionHistoryModel> transactions,
  ) {
    Map<String, List<TransactionHistoryModel>> grouped = {};
    transactions.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a.createdAt) ?? DateTime(1970);
      DateTime dateB = DateTime.tryParse(b.createdAt) ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });

    for (var tx in transactions) {
      String dateHeader = _formatDateHeader(tx.createdAt);
      if (!grouped.containsKey(dateHeader)) {
        grouped[dateHeader] = [];
      }
      grouped[dateHeader]!.add(tx);
    }

    return grouped;
  }

  void _showFilterBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? Color(AppColors.primaryBackgroundColor)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Filter Transactions",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _filterStartDate = null;
                                _filterEndDate = null;
                                _filterCategory = null;
                                _filterStatus = null;
                                _filterPaymentMethod = null;
                              });
                            },
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                      const Divider(),

                      Text(
                        "Date Range",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: isDark
                                      ? const ColorScheme.dark(
                                          primary: Colors.blue,
                                        )
                                      : const ColorScheme.light(
                                          primary: Colors.blue,
                                        ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setModalState(() {
                              _filterStartDate = picked.start;
                              _filterEndDate = picked.end;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _filterStartDate == null
                                    ? "Select Date Range"
                                    : "${_filterStartDate!.toLocal().toString().split(' ')[0]} - ${_filterEndDate!.toLocal().toString().split(' ')[0]}",
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              const Icon(
                                IconlyLight.calendar,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildFilterChips(
                        "Category",
                        _categories,
                        _filterCategory,
                        (val) {
                          setModalState(() => _filterCategory = val);
                        },
                        isDark,
                      ),
                      const SizedBox(height: 15),

                      _buildFilterChips("Status", _statuses, _filterStatus, (
                        val,
                      ) {
                        setModalState(() => _filterStatus = val);
                      }, isDark),
                      const SizedBox(height: 15),

                      _buildFilterChips(
                        "Payment Method",
                        _paymentMethods,
                        _filterPaymentMethod,
                        (val) {
                          setModalState(() => _filterPaymentMethod = val);
                        },
                        isDark,
                      ),
                      const SizedBox(height: 25),

                      GradientGlowButton(text: 'Apply Filter', onClick: () {
                        setState(() {});
                        Navigator.pop(context);
                      },),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChips(
    String title,
    List<String> options,
    String? selectedValue,
    ValueChanged<String?> onSelected,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selectedValue == opt;
            return ChoiceChip(
              label: Text(opt[0].toUpperCase() + opt.substring(1)),
              selected: isSelected,
              onSelected: (selected) => onSelected(selected ? opt : null),
              selectedColor: Colors.blue.withOpacity(0.2),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.blue
                    : (isDark ? Colors.white : Colors.black),
              ),
              showCheckmark: false,
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark
              ? Color(AppColors.primaryBackgroundColor)
              : Colors.white,
          surfaceTintColor: isDark
              ? Color(AppColors.primaryBackgroundColor)
              : Colors.white,
          leading: CustomBackButton(buildContext: context),
          title: _isSearching
              ? TextField(
                  autofocus: true,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search transactions...",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      color: isDark ? Colors.grey : Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
              : Text(
                  "Transactions",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : null,
                  ),
                ),
          actions: [
            if (!_isSearching)
              IconButton(
                onPressed: () => _showFilterBottomSheet(context, isDark),
                icon: const Icon(Icons.filter_list_rounded),
                color:
                    (_filterStartDate != null ||
                        _filterCategory != null ||
                        _filterStatus != null ||
                        _filterPaymentMethod != null)
                    ? Colors.blue
                    : (isDark ? Colors.white : Colors.black),
              ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchQuery = "";
                  } else {
                    _isSearching = true;
                  }
                });
              },
              icon: Icon(_isSearching ? Icons.close : IconlyLight.search),
              color: isDark ? Colors.white : Colors.black,
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _fetchTransactions();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: FutureBuilder<List<TransactionHistoryModel>>(
                  future: _futureTransactions,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          for (int i = 0; i < 18; i++) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Container(
                                height: 75,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Text(
                            "Error loading transactions",
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Text(
                            "No transactions found.",
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.grey : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }

                    final filteredTransactions = _applyFilters(snapshot.data!);

                    if (filteredTransactions.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Text(
                            "No matches found.",
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.grey : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }

                    final groupedTransactions = _groupTransactionsByDate(
                      filteredTransactions,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groupedTransactions.entries.map((entry) {
                        String dateHeader = entry.key;
                        List<TransactionHistoryModel> dayTransactions =
                            entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                dateHeader,
                                style: GoogleFonts.poppins(
                                  color: isDark ? Colors.grey : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            for (var tx in dayTransactions) ...[
                              TransactionHistoryCardOne(
                                isDark: isDark,
                                transactionHistoryModel: tx,
                              ),
                            ],
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
