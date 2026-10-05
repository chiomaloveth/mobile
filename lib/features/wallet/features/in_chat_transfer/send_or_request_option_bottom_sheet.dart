import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../chat/general/model/transaction_model.dart';
import 'in_chat_request_money/request_money_bottom_sheet.dart';
import 'input_amount_bottom_sheet.dart';

class SendOrRequestOptionBottomSheet extends StatelessWidget {
  final String recipientName;
  final String recipientAccountNumber;
  final String recipientBank;
  final String senderName;
  final String chatId;
  final String? profilePicture;
  final void Function(TransactionRecord record)? onShareReceipt;

  const SendOrRequestOptionBottomSheet({
    super.key,
    required this.recipientName,
    required this.recipientAccountNumber,
    required this.recipientBank,
    required this.senderName,
    required this.chatId,
    this.profilePicture,
    this.onShareReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color sheetBg = isDark ? const Color(0xFF4C4A48) : const Color(0xFFFAF5F0);
    final Color dragHandleColor = isDark ? Colors.white12 : Colors.black12;
    final Color sendBtnBg = isDark ? const Color(0xFF3D271B) : const Color(0xFF3A1D07);
    final Color requestBorderColor = isDark ? Colors.white : const Color(0xFF3A1D07);
    final Color requestTextColor = isDark ? Colors.white : const Color(0xFF3A1D07);
    final Brightness navBarIconBrightness = isDark ? Brightness.dark : Brightness.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: sheetBg,
        systemNavigationBarIconBrightness: navBarIconBrightness,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                color: dragHandleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Spacer(),

            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => InputAmountBottomSheet(
                      recipientName: recipientName,
                      recipientAccountNumber: recipientAccountNumber,
                      recipientBank: recipientBank,
                      senderName: senderName,
                      chatId: chatId,
                      profilePicture: profilePicture,
                      onShareReceipt: onShareReceipt,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sendBtnBg,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Send',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: 150,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => RequestMoneyBottomSheet(
                      recipientName: recipientName,
                      recipientAccountNumber: recipientAccountNumber,
                      profilePicture: profilePicture,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: requestBorderColor, width: 2),
                  foregroundColor: requestTextColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Request',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            const Spacer(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}