import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Added
import 'package:share_plus/share_plus.dart'; // Added
import 'package:pdf/pdf.dart'; // Added
import 'package:pdf/widgets.dart' as pw; // Added

import 'package:qik_talk/utilities/components/buttons/custom_back_button.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../../../../settings/theme/provider/theme_provider.dart';
import '../model/transaction_history_model.dart';

class TransactionReceiptScreen extends ConsumerStatefulWidget {
  final TransactionHistoryModel transactionHistoryModel;
  const TransactionReceiptScreen({super.key, required this.transactionHistoryModel});

  @override
  ConsumerState<TransactionReceiptScreen> createState() => _SettingsWalletTransactionReceiptScreenState();
}

class _SettingsWalletTransactionReceiptScreenState extends ConsumerState<TransactionReceiptScreen> {
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system && systemBrightness == Brightness.dark);

    final backgroundColor = isDark ? const Color(AppColors.primaryBackgroundColor) : AppTheme.scaffoldBg(isDark);
    final cardColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05);
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white.withOpacity(0.5) : Colors.grey;

    bool isDebit =
        widget.transactionHistoryModel.type == "purchase" ||
            widget.transactionHistoryModel.type == "withdrawal" ||
            widget.transactionHistoryModel.type == "transfer";

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          elevation: 0,
          leading: CustomBackButton(buildContext: context),
          title: Text(
            "Transaction Details",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(IconlyBold.tick_square, color: Colors.green, size: 28),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Transfer Successful",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _formatFullDateTime(rawDate: widget.transactionHistoryModel.createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          "${isDebit ? "-" : "+"}₦${_formatNumber(number: widget.transactionHistoryModel.amount)}",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 25),

                        Divider(color: secondaryTextColor.withOpacity(0.2), thickness: 1),
                        const SizedBox(height: 25),

                        _ReceiptRow(
                          label: "Transaction Type",
                          value: "${widget.transactionHistoryModel.type[0].toUpperCase()}${widget.transactionHistoryModel.type.substring(1)}",
                          isDark: isDark,
                        ),
                        _ReceiptRow(
                          label: "Status",
                          value: widget.transactionHistoryModel.status,
                          isDark: isDark,
                        ),
                        _ReceiptRow(
                          label: "Payment Method",
                          value: widget.transactionHistoryModel.paymentMethod,
                          isDark: isDark,
                        ),
                        _ReceiptRow(
                          label: "Reference ID",
                          value: widget.transactionHistoryModel.reference,
                          isCopyable: true,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: IconlyLight.upload,
                          label: _isSharing ? "Generating..." : "Share Receipt",
                          isDark: isDark,
                          onTap: _isSharing ? () {} : _generateAndShareReceipt, // Trigger Share
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _ActionButton(
                          icon: IconlyLight.document,
                          label: "Report Issue",
                          isDark: isDark,
                          onTap: () {},
                          isPrimary: false,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateAndShareReceipt() async {
    setState(() => _isSharing = true);

    try {
      final pdf = pw.Document();
      bool isDebit = widget.transactionHistoryModel.type == "purchase" ||
          widget.transactionHistoryModel.type == "withdrawal" ||
          widget.transactionHistoryModel.type == "transfer";

      final amountStr = "${isDebit ? "-" : "+"}NGN ${_formatNumber(number: widget.transactionHistoryModel.amount)}";
      final dateStr = _formatFullDateTime(rawDate: widget.transactionHistoryModel.createdAt);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(40),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 2),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                ),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      "Qik Talk Receipt",
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      "Transfer Successful",
                      style: pw.TextStyle(fontSize: 18, color: PdfColors.green),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(dateStr, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                    pw.SizedBox(height: 30),
                    pw.Text(
                      amountStr,
                      style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 30),
                    pw.Divider(color: PdfColors.grey300),
                    pw.SizedBox(height: 20),
                    _buildPdfRow("Transaction Type", widget.transactionHistoryModel.type.toUpperCase()),
                    _buildPdfRow("Status", widget.transactionHistoryModel.status),
                    _buildPdfRow("Payment Method", widget.transactionHistoryModel.paymentMethod),
                    _buildPdfRow("Reference ID", widget.transactionHistoryModel.reference),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Save PDF to temp directory
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/receipt_${widget.transactionHistoryModel.reference}.pdf");
      await file.writeAsBytes(await pdf.save());

      // Share via native dialog
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Here is my transaction receipt from Qik Talk.',
      );

    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to generate receipt: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // Helper widget for PDF Rows
  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatNumber({required dynamic number}) {
    if (number == null) return "0";

    num parsedNumber;

    if (number is int || number is double) {
      parsedNumber = number;
    } else if (number is String) {
      parsedNumber = num.tryParse(number.replaceAll(',', '')) ?? 0;
    } else {
      return "0";
    }

    String numStr = parsedNumber.toString();

    if (numStr.contains('.')) {
      List<String> parts = numStr.split('.');
      String wholePart = parts[0].replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (match) => ',',
      );

      return "$wholePart.${parts[1]}";
    } else {
      return numStr.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (match) => ',',
      );
    }
  }

  String _formatFullDateTime({required String rawDate}) {
    DateTime dateTime = DateTime.parse(rawDate).toLocal();
    return DateFormat("MMM d, yyyy • h:mm a").format(dateTime);
  }
}

// ---- Supporting Widgets (Untouched, just for completeness) ----

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isCopyable;

  const _ReceiptRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isCopyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: isPrimary
              ? (isDark ? Colors.white : Colors.black)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: isPrimary
              ? null
              : Border.all(
              color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3)
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isPrimary
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}