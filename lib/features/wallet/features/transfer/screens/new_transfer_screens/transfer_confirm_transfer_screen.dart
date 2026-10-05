import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/wallet/features/transfer/screens/new_transfer_screens/transfer_enter_pin_screen.dart';

class TransferConfirmTransferScreen extends StatefulWidget {
  final String name;
  final String amount;
  final String accountNumber;
  final String bankName;
  final String bankCode;
  final String narration;

  const TransferConfirmTransferScreen({
    super.key,
    required this.name,
    required this.amount,
    required this.accountNumber,
    required this.bankName,
    required this.bankCode,
    required this.narration,
  });

  @override
  State<TransferConfirmTransferScreen> createState() =>
      _TransferConfirmTransferScreenState();
}

class _TransferConfirmTransferScreenState
    extends State<TransferConfirmTransferScreen> {
  final NumberFormat _formatter = NumberFormat("#,##0.00");

  @override
  Widget build(BuildContext context) {
    final Color labelColor = const Color(0xFF9E928A);
    final Color highlightColor = const Color(0xFFC3A586);
    final Color warningColor = const Color(0xFFD9883E);
    final double parsedAmount =
        double.tryParse(widget.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0804),
      body: Container(
        decoration: const BoxDecoration(
          // gradient: RadialGradient(
          //   colors: [Color(0xFF3B2210), Color(0xFF0C0704), Colors.black],
          //   center: Alignment.topCenter,
          //   radius: 1.5,
          // ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Confirm Transfer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "You're sending",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '₦',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    _formatter.format(parsedAmount),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Recipient',
                                widget.name,
                                labelColor,
                              ),
                              _buildFadingDivider(),
                              _buildDetailRow(
                                'Bank',
                                widget.bankName,
                                labelColor,
                              ),
                              _buildFadingDivider(),
                              _buildDetailRow(
                                'Account Number',
                                widget.accountNumber,
                                labelColor,
                              ),
                              _buildFadingDivider(),
                              _buildDetailRow(
                                'Transaction Fee',
                                '₦10.00',
                                labelColor,
                              ),
                              _buildFadingDivider(),
                              _buildDetailRow(
                                'Total Amount',
                                '₦${_formatter.format(parsedAmount + 10)}',
                                highlightColor,
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: warningColor.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: warningColor,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Please verify all details carefully.\nThis transaction cannot be\nreversed once confirmed.',
                                  style: TextStyle(
                                    color: highlightColor,
                                    fontSize: 13,
                                    height: 1.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Center(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6B3A18),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TransferEnterPINScreen(
                                                amount: widget.amount,
                                                name: widget.name,
                                                accountNumber:
                                                    widget.accountNumber,
                                                bankCode: widget.bankCode,
                                                narration: widget.narration,
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Center(
                                      child: Text(
                                        'Confirm',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color labelColor, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTotal ? 16 : 15,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFadingDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
