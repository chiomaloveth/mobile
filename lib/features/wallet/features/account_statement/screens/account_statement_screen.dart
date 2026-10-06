import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

import '../../transaction_history/model/transaction_history_model.dart';
import '../../transaction_history/services/transaction_history_services.dart';

class AccountStatementsScreen extends ConsumerStatefulWidget {
  const AccountStatementsScreen({super.key});

  @override
  ConsumerState<AccountStatementsScreen> createState() =>
      _AccountStatementsScreenState();
}

class _AccountStatementsScreenState
    extends ConsumerState<AccountStatementsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'This Month',
    'Last Month',
    'Last 3 Months',
    'Custom Range',
  ];

  static const Color _bgColor = Color(0xFF0A0A0A);
  static const Color _glassColor = Color(0xFF151515);
  static const Color _brandOrange = Color(0xFFE26B00);
  static const Color _btnBrownish = Color(0xFF5A2A08);
  static const Color _btnDarkGrey = Color(0xFF242424);
  static const Color _textGrey = Color(0xFF8A8A8E);
  static const Color _creditGreen = Color(0xFF32D74B);
  static const Color _debitRed = Color(0xFFFF453A);

  bool _isLoading = true;
  List<TransactionHistoryModel> _allTransactions = [];
  List<TransactionHistoryModel> _filteredTransactions = [];

  double _totalCredit = 0.0;
  double _totalDebit = 0.0;

  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final txs = await TransactionHistoryServices()
          .getUserTransactions(context: context);
      _allTransactions = txs;
      _applyFilter();
    } catch (e) {
      debugPrint("Error fetching statements: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    DateTime now = DateTime.now();
    List<TransactionHistoryModel> temp = _allTransactions;

    if (_filters[_selectedFilterIndex] == 'This Month') {
      temp = temp.where((tx) {
        final d = _parseDate(tx.createdAt);
        return d.year == now.year && d.month == now.month;
      }).toList();
    } else if (_filters[_selectedFilterIndex] == 'Last Month') {
      DateTime lastMonth = DateTime(now.year, now.month - 1);
      temp = temp.where((tx) {
        final d = _parseDate(tx.createdAt);
        return d.year == lastMonth.year && d.month == lastMonth.month;
      }).toList();
    } else if (_filters[_selectedFilterIndex] == 'Last 3 Months') {
      DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
      temp = temp.where((tx) {
        final d = _parseDate(tx.createdAt);
        return d.isAfter(threeMonthsAgo);
      }).toList();
    } else if (_filters[_selectedFilterIndex] == 'Custom Range') {
      if (_customStartDate != null && _customEndDate != null) {
        temp = temp.where((tx) {
          final d = _parseDate(tx.createdAt);
          return d.isAfter(_customStartDate!.subtract(const Duration(days: 1))) &&
              d.isBefore(_customEndDate!.add(const Duration(days: 1)));
        }).toList();
      }
    }

    temp.sort((a, b) => _parseDate(b.createdAt).compareTo(_parseDate(a.createdAt)));

    setState(() {
      _filteredTransactions = temp;
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _totalCredit = 0.0;
    _totalDebit = 0.0;

    for (var tx in _filteredTransactions) {
      double amount = double.tryParse(tx.amount.toString()) ?? 0.0;
      if (_isCredit(tx)) {
        _totalCredit += amount;
      } else {
        _totalDebit += amount;
      }
    }
  }

  bool _isCredit(TransactionHistoryModel tx) {
    final typeStr = tx.type?.toLowerCase() ?? '';
    if (typeStr == 'deposit' || typeStr == 'refund' || typeStr == 'credit') {
      return true;
    }
    return false;
  }

  DateTime _parseDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return DateTime(1970);
    return DateTime.tryParse(isoString)?.toLocal() ?? DateTime(1970);
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  String _formatDateString(String isoString) {
    if (isoString.isEmpty) return "Unknown Date";
    try {
      DateTime d = DateTime.parse(isoString).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
    } catch (e) {
      return "Unknown Date";
    }
  }

  Future<void> _handleExport(String type) async {
    Navigator.pop(context);
    if (_filteredTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No transactions available to export.'),
            backgroundColor: _debitRed),
      );
      return;
    }

    try {
      File? generatedFile;
      if (type == 'PDF') {
        generatedFile = await _generatePDF();
      } else if (type == 'DOCX') {
        generatedFile = await _generateDOCX();
      } else if (type == 'Image') {
        generatedFile = await _generateImage();
      }

      if (generatedFile != null && mounted) {
        await Share.shareXFiles(
          [XFile(generatedFile.path)],
          text: 'Account Statement',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating $type: $e'),
            backgroundColor: _debitRed,
          ),
        );
      }
    }
  }

  Future<File> _generatePDF() async {
    final pdf = pw.Document();

    final headers = ['Date', 'Description', 'Ref', 'Amount', 'Status'];
    final data = _filteredTransactions.map((tx) {
      final isCredit = _isCredit(tx);
      final amountVal = double.tryParse(tx.amount.toString()) ?? 0.0;
      return [
        _formatDateString(tx.createdAt),
        tx.reference?.isNotEmpty == true
            ? tx.reference!
            : (tx.type?.toUpperCase() ?? 'N/A'),
        tx.reference ?? 'N/A',
        '${isCredit ? '+' : '-'}NGN ${_formatCurrency(amountVal)}',
        tx.status?.toUpperCase() ?? 'COMPLETED'
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Account Statement')),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            border: pw.TableBorder.all(color: PdfColors.grey400),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(6),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/Account_Statement.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> _generateDOCX() async {
    StringBuffer html = StringBuffer();
    html.writeln('<html><body>');
    html.writeln('<h2 style="font-family: Arial, sans-serif;">Account Statement</h2>');
    html.writeln('<br/>');
    html.writeln(
        '<table border="1" cellspacing="0" cellpadding="8" style="font-family: Arial, sans-serif; border-collapse: collapse; width: 100%;">');
    html.writeln(
        '<tr style="background-color: #f2f2f2;"><th>Date</th><th>Description</th><th>Ref</th><th>Amount</th><th>Status</th></tr>');

    for (var tx in _filteredTransactions) {
      final isCredit = _isCredit(tx);
      final amountVal = double.tryParse(tx.amount.toString()) ?? 0.0;
      final desc = tx.reference?.isNotEmpty == true
          ? tx.reference!
          : (tx.type?.toUpperCase() ?? 'N/A');
      final amt = '${isCredit ? '+' : '-'}NGN ${_formatCurrency(amountVal)}';

      html.writeln(
          '<tr><td>${_formatDateString(tx.createdAt)}</td><td>$desc</td><td>${tx.reference ?? ''}</td><td>$amt</td><td>${tx.status ?? ''}</td></tr>');
    }

    html.writeln('</table></body></html>');

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/Account_Statement.doc');
    await file.writeAsString(html.toString());
    return file;
  }

  Future<File> _generateImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const double padding = 20.0;
    const double rowHeight = 50.0;
    const double colWidth = 160.0;
    final int rows = _filteredTransactions.length + 1;
    final double width = (colWidth * 5) + (padding * 2);
    final double height = (rowHeight * rows) + 120.0;

    final bgPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    final titlePainter = TextPainter(
      text: const TextSpan(
          text: 'Account Statement',
          style: TextStyle(
              color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, const Offset(padding, padding));

    double startY = padding + 70.0;
    final headers = ['Date', 'Description', 'Ref', 'Amount', 'Status'];

    final headerBgPaint = Paint()..color = Colors.grey.shade200;
    canvas.drawRect(Rect.fromLTWH(padding, startY, width - (padding * 2), rowHeight), headerBgPaint);

    for (int i = 0; i < headers.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
            text: headers[i],
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        textDirection: TextDirection.ltr,
      );
      tp.layout(maxWidth: colWidth - 10);
      tp.paint(canvas, Offset(padding + (i * colWidth) + 10, startY + 15));
    }

    startY += rowHeight;
    final linePaint = Paint()..color = Colors.grey.shade300..strokeWidth = 1.0;

    for (var tx in _filteredTransactions) {
      final isCredit = _isCredit(tx);
      final amountVal = double.tryParse(tx.amount.toString()) ?? 0.0;

      final rowData = [
        _formatDateString(tx.createdAt),
        tx.reference?.isNotEmpty == true
            ? tx.reference!
            : (tx.type?.toUpperCase() ?? 'N/A'),
        tx.reference ?? 'N/A',
        '${isCredit ? '+' : '-'}NGN ${_formatCurrency(amountVal)}',
        tx.status?.toUpperCase() ?? 'COMPLETED'
      ];

      canvas.drawLine(
          Offset(padding, startY), Offset(width - padding, startY), linePaint);

      for (int i = 0; i < rowData.length; i++) {
        final tp = TextPainter(
          text: TextSpan(
              text: rowData[i],
              style: TextStyle(
                  color: (i == 3) ? (isCredit ? Colors.green : Colors.red) : Colors.black87,
                  fontSize: 14)),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '...',
        );
        tp.layout(maxWidth: colWidth - 15);
        tp.paint(canvas, Offset(padding + (i * colWidth) + 10, startY + 15));
      }
      startY += rowHeight;
    }

    canvas.drawLine(
        Offset(padding, startY), Offset(width - padding, startY), linePaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/Account_Statement.png');
    await file.writeAsBytes(buffer);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    final bgColor = isDark ? _bgColor : AppTheme.scaffoldBg(isDark);
    final glassColor = isDark ? _glassColor : AppTheme.cardBg(isDark);
    final textColor = isDark ? Colors.white : AppTheme.textPrimary(isDark);
    final subTextColor = isDark ? _textGrey : AppTheme.textSecondary(isDark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bgColor,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _brandOrange.withOpacity(0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _brandOrange.withOpacity(0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildFilterChips(),
                          const SizedBox(height: 24),
                          _buildGlassSummaryCard(),
                          const SizedBox(height: 32),
                          _buildTransactionsHeader(),
                          const SizedBox(height: 16),
                          _buildTransactionsList(),
                          const SizedBox(height: 50),
                          _buildBottomButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textPrimary(isDark);
    final subTextColor = isDark ? _textGrey : AppTheme.textSecondary(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildCircleIcon(Icons.arrow_back, () => Navigator.pop(context)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statement',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Account transactions',
                  style: TextStyle(color: subTextColor, fontSize: 13),
                ),
              ],
            ),
          ),
          _buildCircleIcon(Icons.filter_alt_outlined, () {
            _showCustomDateRangeDialog();
          }),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, VoidCallback onTap) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.06),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.12)),
        ),
        child: Icon(icon, color: isDark ? Colors.white : AppTheme.textPrimary(isDark), size: 20),
      ),
    );
  }

  Widget _buildFilterChips() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                if (_filters[index] == 'Custom Range') {
                  _showCustomDateRangeDialog();
                } else {
                  setState(() => _selectedFilterIndex = index);
                  _applyFilter();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? _brandOrange
                        : (isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2)),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    color: isSelected
                        ? _brandOrange
                        : (isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, double padding = 16}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: isDark ? _glassColor.withOpacity(0.7) : AppTheme.cardBg(isDark),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassSummaryCard() {
    final netBalance = _totalCredit - _totalDebit;

    return _buildGlassCard(
      padding: 20,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Total Credit', '+₦${_formatCurrency(_totalCredit)}',
                  _creditGreen),
              _buildStat('Total Debit', '-₦${_formatCurrency(_totalDebit)}',
                  _debitRed, true),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                  'Net Balance',
                  '${netBalance >= 0 ? '' : '-'}₦${_formatCurrency(netBalance.abs())}',
                  netBalance >= 0 ? Colors.white : _debitRed),
              _buildStat('Transactions', '${_filteredTransactions.length}',
                  Colors.white, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String val, Color color, [bool end = false]) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment:
      end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? _textGrey : AppTheme.textSecondary(isDark), fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsHeader() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transactions',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        InkWell(
          onTap: _showExportDialog,
          child: const Row(
            children: [
              Icon(Icons.file_download_outlined, color: _brandOrange, size: 20),
              SizedBox(width: 4),
              Text(
                'Export',
                style: TextStyle(
                  color: _brandOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    if (_isLoading) {
      return Column(
        children: [
          for (int i = 0; i < 8; i++)...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Container(
                height: 75,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15)
                ),
              ),
            ),
          ]
        ],
      );
    }

    if (_filteredTransactions.isEmpty) {
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined,
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2), size: 60),
              const SizedBox(height: 16),
              Text(
                'No transactions found',
                style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.5) : AppTheme.textSecondary(isDark), fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredTransactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final tx = _filteredTransactions[i];
        final isCredit = _isCredit(tx);
        final amountVal = double.tryParse(tx.amount.toString()) ?? 0.0;
        final formattedAmount =
            '${isCredit ? '+' : '-'}₦${_formatCurrency(amountVal)}';

        return _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tx.reference?.isNotEmpty == true
                          ? tx.reference!
                          : (tx.type?.toUpperCase() ?? 'Transaction'),
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formattedAmount,
                    style: TextStyle(
                      color: isCredit ? _creditGreen : (isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          color: isDark ? _textGrey : AppTheme.textSecondary(isDark), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateString(tx.createdAt),
                        style: TextStyle(color: isDark ? _textGrey : AppTheme.textSecondary(isDark), fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    'Status: ${tx.status?.toUpperCase() ?? 'COMPLETED'}',
                    style: TextStyle(
                        color: tx.status?.toLowerCase() == 'failed'
                            ? _debitRed
                            : (isDark ? _textGrey : AppTheme.textSecondary(isDark)),
                        fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ref: ${tx.reference ?? 'N/A'}',
                style: TextStyle(
                    color: isDark ? Colors.white24 : AppTheme.textSecondary(isDark).withOpacity(0.5),
                    fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _showExportDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: _btnBrownish,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Download Full Statement',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, a1, a2, child) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildGlassCard(
                  padding: 24,
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDialogHeader('Download Statement'),
                        const SizedBox(height: 24),
                        _buildDialogButton(
                          'Download as PDF',
                          Icons.picture_as_pdf_outlined,
                          _btnBrownish,
                          onTap: () => _handleExport('PDF'),
                        ),
                        const SizedBox(height: 12),
                        _buildDialogButton(
                          'Download as DOCX',
                          Icons.description_outlined,
                          _btnDarkGrey,
                          onTap: () => _handleExport('DOCX'),
                        ),
                        const SizedBox(height: 12),
                        _buildDialogButton(
                          'Download as Image',
                          Icons.image_outlined,
                          _btnDarkGrey,
                          onTap: () => _handleExport('Image'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCustomDateRangeDialog() {
    DateTime? tempStart = _customStartDate;
    DateTime? tempEnd = _customEndDate;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, a1, a2, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildGlassCard(
              padding: 24,
              child: Material(
                color: Colors.transparent,
                child: StatefulBuilder(builder: (context, setDialogState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogHeader('Custom Date Range'),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateInput(
                              label: 'Start Date',
                              selectedDate: tempStart,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: tempStart ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setDialogState(() => tempStart = picked);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateInput(
                              label: 'End Date',
                              selectedDate: tempEnd,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: tempEnd ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setDialogState(() => tempEnd = picked);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildDialogButton(
                        'Apply Date Range',
                        null,
                        _btnBrownish,
                        onTap: () {
                          if (tempStart != null && tempEnd != null) {
                            if (tempStart!.isAfter(tempEnd!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Start date cannot be after end date.')),
                              );
                              return;
                            }
                            setState(() {
                              _customStartDate = tempStart;
                              _customEndDate = tempEnd;
                              _selectedFilterIndex = 3;
                            });
                            _applyFilter();
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please select both start and end dates.')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDialogButton(
                        'Cancel',
                        null,
                        Colors.transparent,
                        isOutline: true,
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader(String title) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
            ),
            child: Icon(Icons.close,
                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    String displayDate = selectedDate == null
        ? 'mm/dd/yyyy'
        : '${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayDate,
                  style: TextStyle(
                      color: selectedDate == null
                          ? (isDark ? _textGrey : AppTheme.textHint(isDark))
                          : (isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                      fontSize: 12),
                ),
                Icon(Icons.calendar_month_outlined,
                    color: isDark ? _textGrey : AppTheme.iconColorSubtle(isDark),
                    size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogButton(
      String text,
      IconData? icon,
      Color color, {
        bool isOutline = false,
        required VoidCallback onTap,
      }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // For Cancel button (transparent bg), use dark text in light mode
    final bool isCancel = color == Colors.transparent;
    final Color textColor = isCancel
        ? (isDark ? Colors.white : AppTheme.textPrimary(isDark))
        : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isOutline
                ? BorderSide(color: isDark ? Colors.white24 : Colors.black12)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}