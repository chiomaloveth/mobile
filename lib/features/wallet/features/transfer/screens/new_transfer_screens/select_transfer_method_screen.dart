import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/wallet/features/transfer/screens/new_transfer_screens/transfer_confirm_transfer_screen.dart';

class SelectTransferMethodScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String description;
  final String accountNumber;
  final String bankName;
  final String bankCode;

  const SelectTransferMethodScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.description,
    required this.accountNumber,
    required this.bankName,
    required this.bankCode,
  });

  @override
  State<SelectTransferMethodScreen> createState() =>
      _SelectTransferMethodScreenState();
}

class _SelectTransferMethodScreenState
    extends State<SelectTransferMethodScreen> {
  final NumberFormat _formatter = NumberFormat("#,##0.00");

  @override
  Widget build(BuildContext context) {
    final Color labelColor = const Color(0xFFC3A586).withOpacity(0.8);

    final DateTime now = DateTime.now();
    final String currentDate = DateFormat('EEEE, d MMMM yyyy').format(now);
    final String currentTime = DateFormat('HH:mm:ss').format(now);
    final double parsedAmount =
        double.tryParse(widget.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0804),
      body: Container(
        decoration: const BoxDecoration(
          // gradient: RadialGradient(
          //   colors: [Color(0xFF3B2210), Color(0xFF0C0704)],
          //   center: Alignment.centerLeft,
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
                      'Select Method',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailField(
                            'Amount',
                            '₦${_formatter.format(parsedAmount)}',
                            labelColor,
                            isAmount: true,
                          ),
                          _buildFadingDivider(),
                          _buildDetailField(
                            'Method',
                            'Bank Transfer',
                            labelColor,
                          ),
                          _buildFadingDivider(),
                          _buildDetailField(
                            'Name of receiver',
                            widget.receiverName,
                            labelColor,
                          ),
                          _buildFadingDivider(),
                          _buildDetailField(
                            'Description',
                            widget.description,
                            labelColor,
                          ),
                          _buildFadingDivider(),
                          // 4. Apply Dynamic Date here
                          _buildDetailField('Date', currentDate, labelColor),
                          _buildFadingDivider(),
                          // 5. Apply Dynamic Time here
                          _buildDetailField('Time', currentTime, labelColor),
                          const SizedBox(height: 32),

                          // Wallet Details Row
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8B5A2B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: Color(0xFFFFD199),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Transfer from\nHilary Wallet',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₦3,231.90 Available Balance',
                                      style: TextStyle(
                                        color: labelColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white54,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
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
                            builder: (context) => TransferConfirmTransferScreen(
                              name: widget.receiverName,
                              amount: widget.amount,
                              accountNumber: widget.accountNumber,
                              bankName: widget.bankName,
                              bankCode: widget.bankCode,
                              narration: widget.description,
                            ),
                          ),
                        );
                      },
                      child: const Center(
                        child: Text(
                          'Transfer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildDetailField(
    String label,
    String value,
    Color labelColor, {
    bool isAmount = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isAmount ? 28 : 16,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFadingDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }
}
