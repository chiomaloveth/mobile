import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qik_talk/features/wallet/features/in_chat_transfer/services/in_chat_transfer_services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../chat/general/model/transaction_model.dart';
import '../../../../../notifications/services/notification_service.dart';

enum FlowStep { chooseCar, transfer, pin, leavingGarage, receipt }

class CarRideFlowBottomSheet extends StatefulWidget {
  final String recipientName;
  final String recipientAccountNumber;
  final String recipientBank;
  final String senderName;
  final String chatId;
  final String? profilePicture;
  final void Function(TransactionRecord record)? onShareReceipt;
  final String amount;

  const CarRideFlowBottomSheet({
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

  static Future<TransactionRecord?> show(
    BuildContext context, {
    required String recipientName,
    required String recipientAccountNumber,
    required String recipientBank,
    required String senderName,
    required String chatId,
    required String amount,
    String? profilePicture,
    void Function(TransactionRecord)? onShareReceipt,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => CarRideFlowBottomSheet(
        recipientName: recipientName,
        recipientAccountNumber: recipientAccountNumber,
        recipientBank: recipientBank,
        senderName: senderName,
        chatId: chatId,
        amount: amount,
        profilePicture: profilePicture,
        onShareReceipt: onShareReceipt,
      ),
    );
  }

  @override
  State<CarRideFlowBottomSheet> createState() => _CarRideFlowBottomSheetState();
}

class _CarRideFlowBottomSheetState extends State<CarRideFlowBottomSheet> {
  FlowStep _currentStep = FlowStep.chooseCar;
  final InChatTransferServices _inChatTransferServices =
      InChatTransferServices();
  final ScreenshotController _screenshotController = ScreenshotController();

  bool _showNumpad = false;
  bool _isProcessing = false;
  String _pin = "";
  TransactionRecord? _completedTx;

  void _goToStep(FlowStep step) {
    if (!mounted) return;
    setState(() {
      _currentStep = step;
    });
  }

  void _onPinKeyTap(String key) {
    if (_isProcessing) return;
    setState(() {
      if (key == 'backspace') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else {
        if (_pin.length < 5) _pin += key;
      }
    });
  }

  Future<void> _confirmPinAndProcess() async {
    setState(() => _isProcessing = true);

    try {
      final statusCode = await _inChatTransferServices.inChatTransfer(
        context: context,
        amount: widget.amount,
        accountNumber: widget.recipientAccountNumber,
      );

      if (statusCode == 200 || statusCode == 201) {
        final record = TransactionRecord(
          id: "28276879672567876",
          chatId: widget.chatId,
          senderName: widget.senderName,
          receiverName: widget.recipientName,
          receiverAccountNumber: widget.recipientAccountNumber,
          receiverBank: widget.recipientBank,
          amount: double.parse(widget.amount.replaceAll(',', '')),
          timestamp: DateTime.now(),
          isMe: true,
        );

        await _saveLocally(record);
        if (!mounted) return;

        setState(() {
          _completedTx = record;
        });

        _goToStep(FlowStep.leavingGarage);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _onFinishedAnimation() {
    final record = _completedTx;

    if (record != null) {
      widget.onShareReceipt?.call(record);
    }

    NotificationService().showTransferSuccessNotification().catchError((e) {
      debugPrint('Notification Error: $e');
    });

    if (!mounted) return;

    _goToStep(FlowStep.receipt);
  }

  Future<void> _saveLocally(TransactionRecord r) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'transactions_${widget.chatId}';
      final list = prefs.getStringList(key) ?? [];
      list.add(jsonEncode(r.toJson()));
      await prefs.setStringList(key, list);
    } catch (e) {
      debugPrint('tx save: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isReceipt = _currentStep == FlowStep.receipt;

    return PopScope(
      canPop:
          !_isProcessing &&
          _currentStep != FlowStep.leavingGarage &&
          _currentStep != FlowStep.receipt,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: isReceipt
              ? const Color(0xFF2C2925)
              : const Color(0xFF47433D),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isReceipt
                ? const Color(0xFF2C2925)
                : const Color(0xFF47433D),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: _buildCurrentView(),
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
      case FlowStep.chooseCar:
        return _buildChooseCarView();
      case FlowStep.transfer:
        return _buildTransferView();
      case FlowStep.pin:
        return _buildPinView();
      case FlowStep.leavingGarage:
        return LeavingGarageAnimatedView(
          key: const ValueKey('leavingGarage'),
          onAnimationFinished: _onFinishedAnimation,
        );
      case FlowStep.receipt:
        return _buildReceiptView();
    }
  }


  Widget _buildPinView() {
    return Padding(
      key: const ValueKey('pin'),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 8),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.white,
              ),
              onPressed: _isProcessing
                  ? null
                  : () {
                      if (_showNumpad) {
                        setState(() => _showNumpad = false);
                      } else {
                        _goToStep(FlowStep.transfer);
                      }
                    },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Enter your security pin',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'We use state-of-the-art security measures\nto protect your information at all times',
            style: TextStyle(fontSize: 15, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _isProcessing
                ? null
                : () {
                    setState(() {
                      _showNumpad = true;
                    });
                  },
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => _buildPinSlot(index)),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (_pin.length == 5 && !_isProcessing)
                  ? () => _confirmPinAndProcess()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C3916),
                disabledBackgroundColor: const Color(
                  0xFF6C3916,
                ).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Confirm PIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          if (_showNumpad) ...[
            const SizedBox(height: 32),
            _buildNumpadRow(['1', '2', '3']),
            const SizedBox(height: 24),
            _buildNumpadRow(['4', '5', '6']),
            const SizedBox(height: 24),
            _buildNumpadRow(['7', '8', '9']),
            const SizedBox(height: 24),
            _buildNumpadRow(['*', '0', 'backspace']),
          ],
        ],
      ),
    );
  }

  Widget _buildPinSlot(int index) {
    bool isFilled = index < _pin.length;
    bool isActive = index == _pin.length && _showNumpad;

    return Container(
      width: 44,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
            child: isFilled
                ? const Center(
                    child: CircleAvatar(
                      radius: 5.5,
                      backgroundColor: Colors.white,
                    ),
                  )
                : isActive
                ? Container(width: 1.5, height: 20, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 12),
          Container(
            height: 2,
            color: isActive
                ? const Color(0xFFC47427)
                : const Color(0xFFC47427).withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key == 'backspace') {
          return InkWell(
            onTap: _isProcessing ? null : () => _onPinKeyTap(key),
            borderRadius: BorderRadius.circular(30),
            child: const SizedBox(
              width: 80,
              height: 40,
              child: Icon(
                Icons.backspace_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        }
        return InkWell(
          onTap: _isProcessing ? null : () => _onPinKeyTap(key),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 80,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  Widget _buildReceiptView() {
    final orange = const Color(0xFFF7931E);

    return Column(
      key: const ValueKey('receipt'),
      children: [
        const SizedBox(height: 12),
        _buildDragHandle(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context, _completedTx),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              const Text(
                "Transaction Receipt",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Screenshot(
          controller: _screenshotController,
          child: Container(
            color: const Color(0xFF2C2925),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildStatusHeader(orange),
                const SizedBox(height: 32),
                _buildReceiptCard(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        _buildActionButton(
          "Download Receipt",
          Icons.file_download_outlined,
          true,
          orange,
          _downloadPdf,
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          "Share Receipt",
          Icons.share_outlined,
          false,
          orange,
          _showShareSheet,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatusHeader(Color orange) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              color: Colors.white.withOpacity(0.05),
              size: 110,
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: orange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: orange, size: 48),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "₦${NumberFormat('#,###').format(double.tryParse(widget.amount.replaceAll(',', '')) ?? 0)}",
          style: TextStyle(
            color: orange,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "Payment Successful",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Feb 27th, 2026  15:44:37",
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildReceiptCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3D3934),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _receiptRow("Transaction ID", "28276879672567876", true),
          const Divider(color: Colors.white10, height: 32),
          _receiptRow(
            "Recipient Details",
            widget.recipientName,
            false,
            sub: "Wallet | Qik@hilary_o",
          ),
          const Divider(color: Colors.white10, height: 32),
          _receiptRow(
            "Sender Details",
            widget.senderName,
            false,
            sub: "QIKTAG | Qik@hilarydan",
          ),
          const Divider(color: Colors.white10, height: 32),
          _receiptRow("Session ID", "9786789786735656778", false),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value, bool copy, {String? sub}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (copy) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.copy,
                      size: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ],
                ],
              ),
              if (sub != null)
                Text(
                  sub,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    bool isOutline,
    Color orange,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isOutline
                ? Colors.transparent
                : const Color(0xFF1A1A1A),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isOutline
                  ? BorderSide(color: orange.withOpacity(0.4))
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Share Receipt As",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _shareTile(
              "Share as PDF",
              "Portable document format",
              Icons.picture_as_pdf_outlined,
              _sharePdf,
            ),
            const SizedBox(height: 12),
            _shareTile(
              "Share as Image",
              "PNG image format",
              Icons.image_outlined,
              _shareImage,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareTile(
    String title,
    String sub,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7931E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFF7931E)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPdf() async {
    final doc = await _generatePdf();
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  Future<void> _sharePdf() async {
    final doc = await _generatePdf();
    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/receipt.pdf");
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Transaction Receipt');
  }

  Future<void> _shareImage() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/receipt.png");
      await file.writeAsBytes(image);
      await Share.shareXFiles([XFile(file.path)], text: 'Transaction Receipt');
    }
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                "Transaction Receipt",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Amount: NGN ${widget.amount}"),
              pw.Text("Recipient: ${widget.recipientName}"),
              pw.Text("Sender: ${widget.senderName}"),
              pw.Text("Status: Successful"),
            ],
          ),
        ),
      ),
    );
    return pdf;
  }


  Widget _buildChooseCarView() {
    return Padding(
      key: const ValueKey('chooseCar'),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 16),
          const Text(
            'Choose Car',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 1,
            crossAxisSpacing: 10,
            childAspectRatio: 0.99,
            children: [
              _buildCarCard(imageUrl: 'car_icon_four.png'),
              _buildCarCard(imageUrl: 'car_icon_one.png'),
              _buildCarCard(imageUrl: 'car_icon_three.png'),
              _buildCarCard(imageUrl: 'car_icon_two.png'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard({required String imageUrl}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _goToStep(FlowStep.transfer),
        child: Image.asset("images/$imageUrl"),
      ),
    );
  }

  Widget _buildTransferView() {
    return Padding(
      key: const ValueKey('transfer'),
      padding: const EdgeInsets.only(left: 44, right: 44, top: 12, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 16),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFF6F0EB),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset("images/in_app_transfer_icon.png"),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Transfer Confirmation',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          _buildDetailRow(
            'From',
            widget.senderName,
            'United Bank of Africa',
            '**** 1121',
          ),
          const SizedBox(height: 32),
          _buildDetailRow(
            'To',
            widget.recipientName,
            widget.recipientBank,
            widget.recipientAccountNumber,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
              Text(
                '₦${widget.amount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _goToStep(FlowStep.pin),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C3916),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Ok,Send Now!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String l1, String v1, String l2, String v2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l1,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              v1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l2,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              v2,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 48,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class LeavingGarageAnimatedView extends StatefulWidget {
  final VoidCallback onAnimationFinished;

  const LeavingGarageAnimatedView({
    super.key,
    required this.onAnimationFinished,
  });

  @override
  State<LeavingGarageAnimatedView> createState() =>
      _LeavingGarageAnimatedViewState();
}

class _LeavingGarageAnimatedViewState extends State<LeavingGarageAnimatedView> {
  Alignment _carAlignment = const Alignment(-3.5, 0.0);

  @override
  void initState() {
    super.initState();
    _playAnimationSequence();
  }

  Future<void> _playAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => _carAlignment = const Alignment(0.0, 0.0));
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    setState(() => _carAlignment = const Alignment(3.5, 0.0));
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    widget.onAnimationFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const Text(
            'Leaving the Garage',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enjoy the ride',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 320,
            child: AnimatedAlign(
              alignment: _carAlignment,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Image.asset(
                'images/car_icon_main.png',
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
