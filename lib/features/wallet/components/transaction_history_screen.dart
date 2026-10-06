// lib/features/chat/single_chat/screens/wallet_transaction_history_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/chat/general/model/transaction_model.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String? chatId;

  const TransactionHistoryScreen({super.key, this.chatId});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<TransactionRecord> _all = [];
  List<TransactionRecord> _filtered = [];
  bool _loading = true;

  // Search
  bool _searchOpen = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter
  String?
  _activeFilter; // null | 'today' | 'week' | 'month' | 'sent' | 'received'

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _applyFilters();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<TransactionRecord> all = [];

      if (widget.chatId != null) {
        final key = 'transactions_${widget.chatId}';
        final raw = prefs.getStringList(key) ?? [];
        all = raw
            .map((e) => TransactionRecord.fromJson(jsonDecode(e)))
            .toList();
      } else {
        final keys = prefs
            .getKeys()
            .where((k) => k.startsWith('transactions_'))
            .toList();
        for (final key in keys) {
          final raw = prefs.getStringList(key) ?? [];
          all.addAll(raw.map((e) => TransactionRecord.fromJson(jsonDecode(e))));
        }
        all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }

      if (mounted) {
        setState(() {
          _all = all;
          _filtered = all;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load transactions: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    List<TransactionRecord> result = List.from(_all);

    // Date filter
    if (_activeFilter != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (_activeFilter == 'today') {
        result = result.where((t) {
          final d = DateTime(
            t.timestamp.year,
            t.timestamp.month,
            t.timestamp.day,
          );
          return d == today;
        }).toList();
      } else if (_activeFilter == 'week') {
        final weekAgo = today.subtract(const Duration(days: 7));
        result = result.where((t) => t.timestamp.isAfter(weekAgo)).toList();
      } else if (_activeFilter == 'month') {
        final monthAgo = today.subtract(const Duration(days: 30));
        result = result.where((t) => t.timestamp.isAfter(monthAgo)).toList();
      } else if (_activeFilter == 'sent') {
        result = result.where((t) => t.isMe).toList();
      } else if (_activeFilter == 'received') {
        result = result.where((t) => !t.isMe).toList();
      }
    }

    // Search: match amount or name
    if (_searchQuery.isNotEmpty) {
      result = result.where((t) {
        final amountStr = t.amount.toStringAsFixed(0);
        final name = (t.isMe ? t.receiverName : t.senderName).toLowerCase();
        return amountStr.contains(_searchQuery) ||
            name.contains(_searchQuery) ||
            t.receiverBank.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    _filtered = result;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? HexColor("#1E1E1E") : AppTheme.scaffoldBg(Theme.of(context).brightness == Brightness.dark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Widget filterChip(String label, String value) {
              final active = _activeFilter == value;
              return GestureDetector(
                onTap: () {
                  setSheetState(() {});
                  setState(() {
                    _activeFilter = active ? null : value;
                    _applyFilters();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: active ? HexColor("#1A7F4B") : HexColor("#2A2A2A"),
                    borderRadius: BorderRadius.circular(30),
                    border: active ? null : Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Filter by date',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      filterChip('Today', 'today'),
                      filterChip('This week', 'week'),
                      filterChip('This month', 'month'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Filter by type',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      filterChip('Sent', 'sent'),
                      filterChip('Received', 'received'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_activeFilter != null)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _activeFilter = null;
                            _applyFilters();
                          });
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          'Clear filter',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group filtered by date
    final grouped = <String, List<TransactionRecord>>{};
    for (final t in _filtered) {
      final key = _dateKey(t.timestamp);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(Theme.of(context).brightness == Brightness.dark),
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HexColor("#1E1E1E"),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Transaction history',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Filter button with active indicator
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: _showFilterSheet,
                      ),
                      if (_activeFilter != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: HexColor("#1A7F4B"),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Search toggle
                  IconButton(
                    icon: Icon(
                      _searchOpen ? Icons.close : Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchOpen = !_searchOpen;
                        if (!_searchOpen) {
                          _searchController.clear();
                          _searchQuery = '';
                          _applyFilters();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            // ── Active filter pill ───────────────────────────────────────────
            if (_activeFilter != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: HexColor("#1A7F4B").withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: HexColor("#1A7F4B")),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _filterLabel(_activeFilter!),
                            style: GoogleFonts.poppins(
                              color: HexColor("#1A7F4B"),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setState(() {
                              _activeFilter = null;
                              _applyFilters();
                            }),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: HexColor("#1A7F4B"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // ── Search bar ───────────────────────────────────────────────────
            if (_searchOpen)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(color: AppTheme.textPrimary(Theme.of(context).brightness == Brightness.dark)),
                  decoration: InputDecoration(
                    hintText: 'Search by name or amount...',
                    hintStyle: TextStyle(color: AppTheme.textHint(Theme.of(context).brightness == Brightness.dark)),
                    prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary(Theme.of(context).brightness == Brightness.dark)),
                    filled: true,
                    fillColor: HexColor("#1E1E1E"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

            // ── List ─────────────────────────────────────────────────────────
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (_filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Colors.grey.shade700,
                        size: 56,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty || _activeFilter != null
                            ? 'No results found'
                            : 'No transactions yet',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            entry.key,
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        ...entry.value.map(
                          (t) => _TransactionTile(transaction: t),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _filterLabel(String f) {
    switch (f) {
      case 'today':
        return 'Today';
      case 'week':
        return 'This week';
      case 'month':
        return 'This month';
      case 'sent':
        return 'Sent';
      case 'received':
        return 'Received';
      default:
        return f;
    }
  }

  String _dateKey(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return 'Today, ${DateFormat('MMM d').format(dt)}';
    if (date == yesterday) {
      return 'Yesterday, ${DateFormat('MMM d').format(dt)}';
    }
    return DateFormat('EEE, MMM d').format(dt);
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionRecord transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,##0.00').format(transaction.amount);
    final isSent = transaction.isMe;
    final name = isSent ? transaction.receiverName : transaction.senderName;
    final time = DateFormat('hh:mm a').format(transaction.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HexColor("#1A1A1A"),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: HexColor("#FB8830"),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${isSent ? 'Transferred' : 'Credited'} • $time',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            isSent ? '- ₦$formatted' : '+ ₦$formatted',
            style: GoogleFonts.poppins(
              color: isSent ? HexColor("#FFB347") : HexColor("#4DFFA0"),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
