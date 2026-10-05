import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qik_talk/features/wallet/features/e_bills/mobile_data/transaction_status_screen.dart';

class EnterPinBottomSheet extends StatefulWidget {
  final Function onSuccess;
  final Future<bool> Function()? onClick;
  const EnterPinBottomSheet({super.key, required this.onSuccess, this.onClick});

  @override
  State<EnterPinBottomSheet> createState() => _EnterPinBottomSheetState();
}

class _EnterPinBottomSheetState extends State<EnterPinBottomSheet> {

  bool _showNumpad = false;
  bool _isProcessing = false;
  String _pin = "";

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
    try {
      setState(() => _isProcessing = true);

      bool isSuccess = true;

      if (widget.onClick != null) {
        isSuccess = await widget.onClick!();
      }

      if (isSuccess && mounted) {
        Navigator.of(context).pop();
        widget.onSuccess();
      }
    } catch (e) {
      // 3. If you throw an error in onClick, it gets caught right here!
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'), // Shows the custom throw message
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Color(0xFF47433D),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF47433D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: _buildPinView(),
          ),
        ),
      ),
    );
  }

  Widget _buildPinView() {
    return SafeArea(
      child: Padding(
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
                onPressed: _isProcessing ? null : () {
                  if (_showNumpad) {
                    setState(() => _showNumpad = false);
                  } else {
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
              onTap: _isProcessing ? null : () {
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
                  disabledBackgroundColor: const Color(0xFF6C3916).withOpacity(0.5),
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
