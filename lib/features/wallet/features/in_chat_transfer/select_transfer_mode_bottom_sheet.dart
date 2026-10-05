import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../chat/general/model/transaction_model.dart';
import 'package:qik_talk/features/wallet/features/in_chat_transfer/ship_mode/sheet/ship_transfer_bottom_sheet.dart';
import 'airplane_mode/sheet/airplane_transfer_bottom_sheet.dart';
import 'car_mode/sheet/car_transfer_bottom_sheet.dart';

class DeliveryMethodSheet extends StatefulWidget {
  final String recipientName;
  final String recipientAccountNumber;
  final String recipientBank;
  final String senderName;
  final String chatId;
  final String amount;
  final String? profilePicture;
  final void Function(TransactionRecord record)? onShareReceipt;

  const DeliveryMethodSheet({
    super.key,
    required this.recipientName,
    required this.recipientAccountNumber,
    required this.recipientBank,
    required this.senderName,
    required this.chatId,
    required this.amount,
    this.profilePicture,
    this.onShareReceipt,
  });

  @override
  State<DeliveryMethodSheet> createState() => _DeliveryMethodSheetState();
}

class _DeliveryMethodSheetState extends State<DeliveryMethodSheet> {

  void _startCarFlow(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CarRideFlowBottomSheet(
        recipientName: widget.recipientName,
        recipientAccountNumber: widget.recipientAccountNumber,
        recipientBank: widget.recipientBank,
        senderName: widget.senderName,
        chatId: widget.chatId,
        amount: widget.amount,
        profilePicture: widget.profilePicture,
        onShareReceipt: widget.onShareReceipt,
      ),
    );
  }

  void _startShipFlow(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShipRideFlowBottomSheet(
        recipientName: widget.recipientName,
        recipientAccountNumber: widget.recipientAccountNumber,
        recipientBank: widget.recipientBank,
        senderName: widget.senderName,
        chatId: widget.chatId,
        amount: widget.amount,
        profilePicture: widget.profilePicture,
        onShareReceipt: widget.onShareReceipt,
      ),
    );
  }

  void _startPlaneFlow(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AirplaneRideFlowBottomSheet(
        recipientName: widget.recipientName,
        recipientAccountNumber: widget.recipientAccountNumber,
        recipientBank: widget.recipientBank,
        senderName: widget.senderName,
        chatId: widget.chatId,
        amount: widget.amount,
        profilePicture: widget.profilePicture,
        onShareReceipt: widget.onShareReceipt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Color(0xFF4C4A48),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        height: MediaQuery.of(context).size.height * 0.45,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Color(0xFF4C4A48),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 32),
                width: 100,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3828),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              "Which delivery method do you want?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 35),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DeliveryOption(
                  label: "Airplane Mode",
                  boxColor: const Color(0xFF8D6E4F),
                  icon: "images/Air Shipping.png",
                  onClick: () => _startPlaneFlow(context),
                ),
                DeliveryOption(
                  label: "Car Mode",
                  boxColor: const Color(0xFF6E6178),
                  icon: "images/Car_icon.png",
                  onClick: () => _startCarFlow(context),
                ),
                DeliveryOption(
                  label: "Ship Mode",
                  boxColor: const Color(0xFF5D5755),
                  icon: "images/Ship_icon.png",
                  onClick: () => _startShipFlow(context),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class DeliveryOption extends StatelessWidget {
  final String label;
  final Color boxColor;
  final String icon;
  final VoidCallback onClick;

  const DeliveryOption({
    super.key,
    required this.label,
    required this.boxColor,
    required this.icon,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    double itemWidth = (MediaQuery.of(context).size.width - 72) / 3;

    return Column(
      children: [
        GestureDetector(
          onTap: onClick,
          child: Container(
            width: itemWidth,
            height: itemWidth * 1.1,
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(icon),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}