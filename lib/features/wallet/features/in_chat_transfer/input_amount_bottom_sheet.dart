import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/provider/user_provider.dart';
import '../../../chat/general/model/transaction_model.dart';
import 'select_transfer_mode_bottom_sheet.dart';

class InputAmountBottomSheet extends ConsumerStatefulWidget {
  final String recipientName;
  final String recipientAccountNumber;
  final String recipientBank;
  final String senderName;
  final String chatId;
  final String? profilePicture;
  final void Function(TransactionRecord record)? onShareReceipt;

  const InputAmountBottomSheet({
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
  ConsumerState<InputAmountBottomSheet> createState() =>
      _InputAmountBottomSheetState();
}

class _InputAmountBottomSheetState
    extends ConsumerState<InputAmountBottomSheet> {
  static const Color bgColor = Color(0xFF4C4A48);
  static const Color cardBgColor = Color(0xFF3B3937);
  static const Color accentColor = Color(0xFF5E2F13);
  static const Color borderColor = Color(0xFF5A5856);
  static const Color textSecondary = Color(0xFFAFAFAF);

  int _currentAmount = 100;
  final int _maxSliderAmount = 500;

  final List<int> _quickAmountsRow1 = [5, 10, 15, 20];
  final List<int> _quickAmountsRow2 = [50, 100, 200, 500];

  late TextEditingController _amountController;
  late FocusNode _focusNode;
  bool _isManualInput = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _currentAmount.toString());
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isManualInput = _focusNode.hasFocus;

        if (!_isManualInput && _amountController.text.isEmpty) {
          _updateAmount(5);
        }
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateAmount(int newAmount, {bool fromTextField = false}) {
    setState(() {
      _currentAmount = newAmount;
    });
    if (!fromTextField) {
      _amountController.text = newAmount.toString();
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    }
  }

  void _startDeliveryMethodSelection(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeliveryMethodSheet(
        recipientName: widget.recipientName,
        recipientAccountNumber: widget.recipientAccountNumber,
        recipientBank: widget.recipientBank,
        senderName: widget.senderName,
        chatId: widget.chatId,
        amount: "$_currentAmount",
        profilePicture: widget.profilePicture,
        onShareReceipt: widget.onShareReceipt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final user = ref.watch(userProfileProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bgColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            decoration: const BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(2, 2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(
                                widget.profilePicture ?? '',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.recipientName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Qiktag: ${widget.recipientAccountNumber.length >= 10
                                        ? widget.recipientAccountNumber.substring(widget.recipientAccountNumber.length - 10)
                                        : widget.recipientAccountNumber}',
                                    style: const TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Amount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildIconButton(
                                icon: Icons.remove,
                                onTap: () {
                                  if (_currentAmount > 5) {
                                    _updateAmount(_currentAmount - 5);
                                  } else {
                                    _updateAmount(0);
                                  }
                                },
                              ),

                              IntrinsicWidth(
                                child: TextField(
                                  controller: _amountController,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  cursorColor: Colors.white,
                                  cursorWidth: 2,
                                  cursorHeight: 32,
                                  decoration: const InputDecoration(
                                    prefixText: '₦ ',
                                    prefixStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    filled: true,
                                    fillColor: Colors.transparent,
                                  ),
                                  onChanged: (val) {
                                    int parsed = int.tryParse(val) ?? 0;
                                    _updateAmount(parsed, fromTextField: true);
                                  },
                                ),
                              ),

                              _buildIconButton(
                                icon: Icons.add,
                                onTap: () => _updateAmount(_currentAmount + 5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _buildInteractiveSlider(),
                        ],
                      ),
                    ),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: _isManualInput
                          ? const SizedBox(height: 20)
                          : Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: _quickAmountsRow1.map((amount) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right:
                                    amount == _quickAmountsRow1.last
                                        ? 0
                                        : 12,
                                  ),
                                  child: _buildQuickAmountButton(amount),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: _quickAmountsRow2.map((amount) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right:
                                    amount == _quickAmountsRow2.last
                                        ? 0
                                        : 12,
                                  ),
                                  child: _buildQuickAmountButton(amount),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _startDeliveryMethodSelection(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(int amount) {
    final isSelected = _currentAmount == amount;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _updateAmount(amount);
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? accentColor : cardBgColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : borderColor,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '₦$amount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildInteractiveSlider() {
    double percentage = (_currentAmount / _maxSliderAmount).clamp(0.0, 1.0);
    const double thumbWidth = 28.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final maxLeftOffset = trackWidth - thumbWidth;
        final thumbLeftPosition = maxLeftOffset * percentage;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (details) {
            FocusScope.of(context).unfocus();
          },
          onHorizontalDragUpdate: (details) {
            double dragPosition = details.localPosition.dx - (thumbWidth / 2);
            double newPercentage = dragPosition / maxLeftOffset;
            newPercentage = newPercentage.clamp(0.0, 1.0);
            int newAmount = (newPercentage * _maxSliderAmount).round();
            newAmount = (newAmount / 5).round() * 5;
            if (newAmount < 5) newAmount = 5;

            _updateAmount(newAmount);
          },
          child: SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 2,
                  width: double.infinity,
                  color: borderColor,
                ),
                Container(
                  height: 2,
                  width: thumbLeftPosition + (thumbWidth / 2),
                  color: accentColor,
                ),
                Positioned(
                  left: thumbLeftPosition,
                  child: Container(
                    width: thumbWidth,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.chevron_left, color: Colors.white, size: 14),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}