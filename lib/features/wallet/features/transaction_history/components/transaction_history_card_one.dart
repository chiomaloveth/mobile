import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/wallet/features/transaction_history/model/transaction_history_model.dart';

import '../screens/transaction_receipt_screen.dart';

class TransactionHistoryCardOne extends StatelessWidget {
  final bool isDark;
  final TransactionHistoryModel transactionHistoryModel;

  const TransactionHistoryCardOne({
    super.key,
    required this.isDark,
    required this.transactionHistoryModel,
  });

  @override
  Widget build(BuildContext context) {
    bool isDebit =
        transactionHistoryModel.type == "purchase" ||
        transactionHistoryModel.type == "withdrawal" ||
        transactionHistoryModel.type == "transfer";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionReceiptScreen(transactionHistoryModel: transactionHistoryModel,),
            ),
          );
        },
        child: Container(
          height: 75,
          width: MediaQuery.of(context).size.width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              children: [
                Container(
                  height: 47,
                  width: 47,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Icon(
                      isDebit ? CupertinoIcons.arrow_down_left : Icons.add,
                      color: isDark ? Colors.white : Colors.black,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      transactionHistoryModel.type[0].toUpperCase() + transactionHistoryModel.type.substring(1),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateTime(rawDate: transactionHistoryModel.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withOpacity(0.4)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Text(
                      "${isDebit ? "-" : "+"}₦${_formatNumber(number: transactionHistoryModel.amount)}",
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : null,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isDark ? Colors.white : Colors.black,
                      size: 15,
                    ),
                  ],
                ),
              ],
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

  String _formatDateTime({required String rawDate}) {
    DateTime dateTime = DateTime.parse(rawDate).toLocal();
    DateTime now = DateTime.now();

    String time = DateFormat("h:mm a").format(dateTime);

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "Today, $time";
    }

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day - 1) {
      return "Yesterday, $time";
    }

    return "${DateFormat("MMM d").format(dateTime)}, $time";
  }
}
