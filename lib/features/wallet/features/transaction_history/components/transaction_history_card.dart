import 'dart:ui'; // Required for ImageFilter (the blur effect)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/wallet/features/transaction_history/model/transaction_history_model.dart';

import '../screens/transaction_receipt_screen.dart';

class TransactionHistoryCard extends StatelessWidget {
  final TransactionHistoryModel transactionHistoryModel;
  const TransactionHistoryCard({super.key, required this.transactionHistoryModel});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isDebit =
        transactionHistoryModel.type == "purchase" ||
            transactionHistoryModel.type == "withdrawal" ||
            transactionHistoryModel.type == "transfer";

    final Color cardBg = isDark
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFFFAF5F0);
    final Color cardBorder = isDark
        ? Colors.white.withOpacity(0.2)
        : const Color(0xFFDDD3C5);
    final Color primaryText = isDark ? Colors.white : const Color(0xFF1A1008);
    final Color subtleText = isDark
        ? Colors.grey.withOpacity(0.8)
        : const Color(0xFF6B5A4A);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionReceiptScreen(transactionHistoryModel: transactionHistoryModel,),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              height: 185,
              width: 140,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1.5, color: cardBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Image.asset(
                              "images/card_icon.png",
                              color: isDark ? Colors.white : const Color(0xFF1A1008),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        transactionHistoryModel.type[0].toUpperCase() +
                            transactionHistoryModel.type.substring(1),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: primaryText,
                        ),
                      ),
                      Text(
                        transactionHistoryModel.paymentMethod,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: subtleText,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${isDebit ? "-" : "+"}₦${_formatNumber(number: transactionHistoryModel.amount)}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDebit ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatFullDateTime(rawDate: transactionHistoryModel.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: subtleText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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

    return DateFormat("MMM d, yyyy").format(dateTime);
  }
}