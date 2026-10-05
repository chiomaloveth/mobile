import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/wallet/features/transfer/screens/new_transfer_screens/transfer_success_screen.dart';
import 'package:qik_talk/features/wallet/features/transfer/services/transfer_services.dart';

class TransferEnterPINScreen extends StatefulWidget {
  final String amount;
  final String name;
  final String accountNumber;
  final String bankCode;
  final String narration;

  const TransferEnterPINScreen({
    super.key,
    required this.amount,
    required this.name,
    required this.accountNumber,
    required this.bankCode,
    required this.narration,
  });

  @override
  State<TransferEnterPINScreen> createState() => _TransferEnterPINScreenState();
}

class _TransferEnterPINScreenState extends State<TransferEnterPINScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TransferServices _transferServices = TransferServices();
  final NumberFormat _formatter = NumberFormat("#,##0.00");
  final FocusNode _focusNode = FocusNode();
  String _pin = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _pinController.addListener(_onPinChanged);
  }

  Future<void> _transferFunds() async {
    if (_isLoading) return; // Prevent multiple clicks

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _transferServices.transferToLocalBank(
        context: context,
        accountNumber: widget.accountNumber,
        bankCode: widget.bankCode,
        amount: widget.amount,
        narration: widget.narration,
      );

      final statusCode = response?['statusCode'] ?? -1;

      if (statusCode == 200 || statusCode == 201) {
        final responseData = response?['data'] ?? {};

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => TransferSuccessfulScreen(
                localAccountNumberResponseModel: responseData,
              ),
            ),
          );
        }
      } else {
        _handleError("Transfer Failed. Please check your PIN or balance.");
      }
    } catch (e) {
      _handleError("An unexpected error occurred.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      // Clear PIN to let them try again
      _pinController.clear();
      _focusNode.requestFocus();
    }
  }

  void _onPinChanged() {
    setState(() {
      _pin = _pinController.text;
    });

    if (_pin.length == 4) {
      _focusNode.unfocus();

      _transferFunds();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color orangeAccent = Color(0xFFE5801A);
    final Color textMuted = const Color(0xFFC3A586).withOpacity(0.8);
    final Color cardBackground = Colors.grey.withOpacity(0.1);
    final double parsedAmount =
        double.tryParse(widget.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0.0;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF0F0804),
          resizeToAvoidBottomInset: true,
          body: Container(
            decoration: const BoxDecoration(
              // gradient: RadialGradient(
              //   colors:[
              //     Color(0xFF3B2210),
              //     Color(0xFF0C0704),
              //     Colors.black,
              //   ],
              //   center: Alignment.center,
              //   radius: 1.2,
              // ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 16.0,
                              ),
                              child: Row(
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
                                    'Enter PIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(flex: 1),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: orangeAccent.withOpacity(0.05),
                                      border: Border.all(
                                        color: orangeAccent.withOpacity(0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.lock_outline_rounded,
                                        color: orangeAccent,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  const Text(
                                    'Enter Your PIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Please enter your 4-digit\nsecurity PIN to confirm this\ntransfer',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: textMuted,
                                      fontSize: 15,
                                      height: 1.4,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  GestureDetector(
                                    onTap: () => _focusNode.requestFocus(),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned.fill(
                                          child: TextField(
                                            controller: _pinController,
                                            focusNode: _focusNode,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            maxLength: 4,
                                            autofocus: true,
                                            showCursor: false,
                                            enableSuggestions: false,
                                            autocorrect: false,
                                            decoration: const InputDecoration(
                                              counterText: '',
                                              border: InputBorder.none,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.transparent,
                                              fontSize: 1,
                                            ),
                                            cursorColor: Colors.transparent,
                                          ),
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(4, (index) {
                                            bool isFilled = index < _pin.length;
                                            bool isFocused = index == _pin.length;

                                            return Expanded(
                                              child: Container(
                                                width: 60,
                                                height: 64,
                                                margin: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF160D08),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: isFocused
                                                        ? orangeAccent.withOpacity(
                                                            0.8,
                                                          )
                                                        : isFilled
                                                        ? orangeAccent.withOpacity(
                                                            0.3,
                                                          )
                                                        : Colors.white.withOpacity(
                                                            0.15,
                                                          ),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: isFilled
                                                      ? Container(
                                                          width: 14,
                                                          height: 14,
                                                          decoration:
                                                              const BoxDecoration(
                                                                color: Colors.white,
                                                                shape:
                                                                    BoxShape.circle,
                                                              ),
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cardBackground,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Transferring',
                                          style: TextStyle(
                                            color: textMuted,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '₦',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              _formatter.format(parsedAmount),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'to ${widget.name}',
                                          style: TextStyle(
                                            color: textMuted,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(flex: 2),

                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 32.0,
                                top: 16.0,
                              ),
                              child: GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  'Forgot PIN?',
                                  style: TextStyle(
                                    color: orangeAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3)
            ),
            child: Center(
              child: SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  color: Colors.deepOrange,
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
          )
      ],
    );
  }
}
