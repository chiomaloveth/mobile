import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum RequestFlowStep { amount, confirm, pin, success }

class RequestMoneyBottomSheet extends StatefulWidget {
  final String recipientName;
  final String recipientAccountNumber;
  final String? profilePicture;

  const RequestMoneyBottomSheet({
    super.key,
    required this.recipientName,
    required this.recipientAccountNumber,
    this.profilePicture,
  });

  static Future<void> show(
    BuildContext context, {
    required String recipientName,
    required String recipientAccountNumber,
    String? profilePicture,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => RequestMoneyBottomSheet(
        recipientName: recipientName,
        recipientAccountNumber: recipientAccountNumber,
        profilePicture: profilePicture,
      ),
    );
  }

  @override
  State<RequestMoneyBottomSheet> createState() =>
      _RequestMoneyBottomSheetState();
}

class _RequestMoneyBottomSheetState extends State<RequestMoneyBottomSheet> {
  static const Color bgColor = Color(0xFF4C4A48);
  static const Color cardBgColor = Color(0xFF3B3937);
  static const Color accentColor = Color(0xFF6C3916);
  static const Color borderColor = Color(0xFF5A5856);
  static const Color textSecondary = Color(0xFFAFAFAF);
  static const Color pinLineColor = Color(0xFFD97706);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color successCardBg = Color(0xFF36443B);
  static const Color successCardBorder = Color(0xFF425648);

  RequestFlowStep _currentStep = RequestFlowStep.amount;
  bool _isProcessing = false;
  String _pin = "";

  int _currentAmount = 10000;
  final int _maxSliderAmount = 500000;
  final List<int> _quickAmountsRow1 = [1000, 5000, 10000, 20000];
  final List<int> _quickAmountsRow2 = [50000, 100000, 200000, 500000];

  String? _selectedPurpose;

  late TextEditingController _amountController;
  late FocusNode _focusNode;
  bool _isManualInput = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _currentAmount.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(
      () => setState(() => _isManualInput = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateAmount(int newAmount, {bool fromTextField = false}) {
    setState(() => _currentAmount = newAmount);
    if (!fromTextField) {
      _amountController.text = newAmount.toString();
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    }
  }

  void _goToStep(RequestFlowStep step) {
    if (!mounted) return;
    setState(() => _currentStep = step);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !_isProcessing && _currentStep == RequestFlowStep.amount,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              decoration: const BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: Alignment.bottomCenter,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: _buildCurrentView(),
                        ),
                      ),
                    ),
                    if (_currentStep == RequestFlowStep.confirm)
                      _buildGlassConfirmOverlay(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentStep) {
      case RequestFlowStep.amount:
        return _buildAmountView();
      case RequestFlowStep.confirm:
        return _buildAmountView();
      case RequestFlowStep.pin:
        return _buildPinView();
      case RequestFlowStep.success:
        return _buildSuccessView();
    }
  }

  Widget _buildAmountView() {
    return Padding(
      key: const ValueKey('amount'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 24),
          _buildRecipientCard(),
          const SizedBox(height: 24),
          _buildAmountInputCard(),
          _buildQuickAmountSelection(),
          const SizedBox(height: 24),
          _buildPurposeDropdown(),
          const SizedBox(height: 32),
          _buildPrimaryButton(
            'Continue',
            () => _goToStep(RequestFlowStep.confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassConfirmOverlay() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.4),
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Confirm Request",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "You are about to request ₦${_formatCurrency(_currentAmount)} from ${widget.recipientName}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: () => _goToStep(RequestFlowStep.pin),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2B1609), Color(0xFF6C3916)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Proceed",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _goToStep(RequestFlowStep.amount),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinView() {
    return Padding(
      key: const ValueKey('pin'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 24),
          _buildBackButton(() => _goToStep(RequestFlowStep.amount)),
          const SizedBox(height: 24),
          const Text(
            'Enter your security pin',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => _buildPinSlot(i)),
          ),
          const SizedBox(height: 48),
          _buildPrimaryButton(
            'Confirm PIN',
            _pin.length == 5 ? _confirmPinAndProcess : null,
            isLoading: _isProcessing,
          ),
          const SizedBox(height: 32),
          _buildNumpad(),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      key: const ValueKey('success'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
      child: Column(
        children: [
          _buildDragHandle(),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildBackButton(() => Navigator.pop(context)),
          ),
          const SizedBox(height: 40),
          _buildSuccessIcon(),
          const SizedBox(height: 24),
          const Text(
            'Request Successful!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          _buildSuccessCard(),
        ],
      ),
    );
  }


  Widget _buildRecipientCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
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
              backgroundImage: widget.profilePicture != null
                  ? NetworkImage(widget.profilePicture!)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipientName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Qiktag: ${widget.recipientAccountNumber.length >= 10
                        ? widget.recipientAccountNumber.substring(widget.recipientAccountNumber.length - 10)
                        : widget.recipientAccountNumber}',
                    style: const TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconButton(
                Icons.remove,
                () => _updateAmount(
                  (_currentAmount - 1000).clamp(0, _maxSliderAmount),
                ),
              ),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '₦ ',
                    prefixStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent
                  ),
                  onChanged: (val) => _updateAmount(
                    int.tryParse(val) ?? 0,
                    fromTextField: true,
                  ),
                ),
              ),
              _buildIconButton(
                Icons.add,
                () => _updateAmount(
                  (_currentAmount + 1000).clamp(0, _maxSliderAmount),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInteractiveSlider(),
        ],
      ),
    );
  }

  Widget _buildQuickAmountSelection() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: _isManualInput
          ? const SizedBox(height: 20)
          : Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: _quickAmountsRow1
                      .map((amt) => Expanded(child: _buildQuickAmountTile(amt)))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _quickAmountsRow2
                      .map((amt) => Expanded(child: _buildQuickAmountTile(amt)))
                      .toList(),
                ),
              ],
            ),
    );
  }

  Widget _buildQuickAmountTile(int amount) {
    bool isSelected = _currentAmount == amount;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _updateAmount(amount);
      },
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : cardBgColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? accentColor : borderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          '₦${amount >= 1000 ? '${(amount / 1000).toStringAsFixed(0)}k' : amount}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPurposeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPurpose,
          dropdownColor: cardBgColor,
          isExpanded: true,
          hint: const Text(
            'Select purpose',
            style: TextStyle(color: textSecondary),
          ),
          items: ['Personal', 'Business', 'Loan', 'Gift']
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text(v, style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedPurpose = v),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    String text,
    VoidCallback? onTap, {
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  String _formatCurrency(int amount) => amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );

  Future<void> _confirmPinAndProcess() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isProcessing = false);
      _goToStep(RequestFlowStep.success);
    }
  }

  Widget _buildPinSlot(int index) => Container(
    width: 44,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      children: [
        SizedBox(
          height: 24,
          child: index < _pin.length
              ? const CircleAvatar(radius: 6, backgroundColor: Colors.white)
              : null,
        ),
        const SizedBox(height: 12),
        Container(height: 2, color: pinLineColor),
      ],
    ),
  );

  Widget _buildNumpad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', 'backspace'],
    ];
    return Column(
      children: keys
          .map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row
                    .map(
                      (k) => InkWell(
                        onTap: () => _onPinKeyTap(k),
                        child: SizedBox(
                          width: 80,
                          height: 40,
                          child: Center(
                            child: k == 'backspace'
                                ? const Icon(
                                    Icons.backspace_outlined,
                                    color: Colors.white,
                                  )
                                : Text(
                                    k,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
          .toList(),
    );
  }

  void _onPinKeyTap(String key) {
    if (_isProcessing) return;
    setState(() {
      if (key == 'backspace') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (_pin.length < 5) {
        _pin += key;
      }
    });
  }

  Widget _buildSuccessIcon() => Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: successGreen.withOpacity(0.1),
      border: Border.all(color: successGreen, width: 2),
    ),
    child: const Icon(Icons.check, color: successGreen, size: 50),
  );

  Widget _buildSuccessCard() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: successCardBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: successCardBorder),
    ),
    child: Column(
      children: [
        const Text('Amount Requested', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text(
          '₦${_formatCurrency(_currentAmount)}',
          style: const TextStyle(
            color: successGreen,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _buildInteractiveSlider() {
    double percentage = (_currentAmount / _maxSliderAmount).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        double trackWidth = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            FocusScope.of(context).unfocus();
            double newPct = (details.localPosition.dx / trackWidth).clamp(
              0.0,
              1.0,
            );
            _updateAmount(((newPct * _maxSliderAmount) / 1000).round() * 1000);
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
                  width: trackWidth * percentage,
                  color: accentColor,
                ),
                Positioned(
                  left: (trackWidth - 28) * percentage,
                  child: Container(
                    width: 28,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.chevron_left, color: Colors.white, size: 12),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 12,
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

  Widget _buildIconButton(IconData i, VoidCallback o) => InkWell(
    onTap: o,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(i, color: Colors.white, size: 20),
    ),
  );

  Widget _buildBackButton(VoidCallback o) => InkWell(
    onTap: o,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.arrow_back_ios_new,
        size: 18,
        color: Colors.white,
      ),
    ),
  );

  Widget _buildDragHandle() => Center(
    child: Container(
      width: 48,
      height: 4,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}
