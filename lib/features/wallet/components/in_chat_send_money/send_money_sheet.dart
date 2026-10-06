import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/chat/general/model/transaction_model.dart';
import 'package:qik_talk/features/wallet/features/in_chat_transfer/send_or_request_option_bottom_sheet.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Colours ───────────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF2C2B2B);
const Color _kCard = Color(0xFF3A3A3A);
const Color _kOrange = Color(0xFFB85C00);
const Color _kOrangeBtn = Color(0xFF6B3E26);
const Color _kGreen = Color(0xFF1A7F4B);
const Color _kGreenLight = Color(0xFF4DFFA0);
const Color _kWhite = Colors.white;
const Color _kGrey = Color(0xFF9E9E9E);
const Color _kDivider = Color(0xFF4A4A4A);

// ── Step enum ─────────────────────────────────────────────────────────────────
enum _Step {
  sendOrRequest,
  recipient,
  deliveryMethod,
  chooseAirplane,
  confirmation,
  pin,
  takingOff,
  success,
}

// ═════════════════════════════════════════════════════════════════════════════
// SendMoneySheet
// ═════════════════════════════════════════════════════════════════════════════
class SendMoneySheet extends StatefulWidget {
  final String recipientName;
  final String recipientAccountNumber;
  final String recipientBank;
  final String senderName;
  final String chatId;
  final String? profilePicture;
  final void Function(TransactionRecord record)? onShareReceipt;

  const SendMoneySheet({
    super.key,
    required this.recipientName,
    required this.recipientAccountNumber,
    required this.recipientBank,
    required this.senderName,
    required this.chatId,
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
    String? profilePicture,
    void Function(TransactionRecord)? onShareReceipt,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SendOrRequestOptionBottomSheet(
        recipientName: recipientName,
        recipientAccountNumber: recipientAccountNumber,
        recipientBank: recipientBank,
        senderName: senderName,
        chatId: chatId,
        profilePicture: profilePicture,
        onShareReceipt: onShareReceipt,
      ),
    );
  }

  @override
  State<SendMoneySheet> createState() => _SendMoneySheetState();
}

class _SendMoneySheetState extends State<SendMoneySheet>
    with TickerProviderStateMixin {
  _Step _step = _Step.sendOrRequest;

  double _amount = 100;
  final _amountCtrl = TextEditingController(text: '100');
  final List<double> _quickAmounts = [5, 10, 15, 20, 50, 100, 200, 500];

  int _selectedPlane = 0;
  int _pinLength = 0;
  bool _isProcessing = false;
  bool _takingOffStarted = false;
  bool _incomingTriggered = false;
  TransactionRecord? _completedTx;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _planeCtrl;

  final List<Map<String, String>> _planes = const [
    {'name': 'Boeing 747-8F', 'image': 'images/airplane1.png'},
    {'name': 'Boeing 777F', 'image': 'images/airplane2.png'},
    {'name': 'Boeing 747-8F', 'image': 'images/airplane1.png'},
    {'name': 'Antonov An-124', 'image': 'images/airplane3.png'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    _planeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _fadeCtrl.dispose();
    _planeCtrl.dispose();
    super.dispose();
  }

  void _goTo(_Step s) {
    _fadeCtrl.forward(from: 0);
    setState(() => _step = s);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCREEN 0  –  Send / Request
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSendOrRequest() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 95),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 135,
            height: 50.75,
            child: ElevatedButton(
              onPressed: () => _goTo(_Step.recipient),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF29190E) : _kOrange,
                foregroundColor: _kWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Send',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kWhite,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 135,
            height: 50.75,
            child: OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.45)
                      : AppTheme.border(false),
                  width: 1.5,
                ),
                disabledForegroundColor: isDark
                    ? Colors.white.withOpacity(0.45)
                    : AppTheme.textHint(false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Request',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withOpacity(0.45)
                      : AppTheme.textHint(false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCREEN 1  –  Recipient + Amount
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRecipientStep() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary = isDark ? _kWhite : AppTheme.textPrimary(false);
    final Color textSecondary = isDark ? _kGrey : AppTheme.textSecondary(false);
    final Color cardColor = isDark ? _kCard : AppTheme.cardBg(false);
    final Color dividerColor = isDark ? const Color(0xFF4A4A4A) : AppTheme.divider(false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recipient card
        Center(
          child: Container(
            width: 269,
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF333333) : AppTheme.cardBg(false),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF4D4D4D) : AppTheme.divider(false),
                width: 3,
              ),
            ),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.recipientName,
                        style: GoogleFonts.poppins(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Qiktag: ${widget.recipientAccountNumber}',
                        style: GoogleFonts.poppins(color: textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3A3A3A) : AppTheme.iconBg(false),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF555555) : AppTheme.divider(false),
                    ),
                  ),
                  child: Icon(Icons.check, color: textPrimary, size: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Amount card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount',
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _amountBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if (_amount > 1) {
                        setState(() {
                          _amount = (_amount - 1).clamp(1, 500000);
                          _amountCtrl.text = _amount.toInt().toString();
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₦',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              color: textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                            cursorColor: _kOrange,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (v) => setState(
                              () => _amount = double.tryParse(v) ?? _amount,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _amountBtn(
                    icon: Icons.add,
                    onTap: () {
                      setState(() {
                        _amount = (_amount + 1).clamp(1, 500000);
                        _amountCtrl.text = _amount.toInt().toString();
                      });
                    },
                  ),
                ],
              ),
              _buildSlider(),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Quick amounts
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.6,
          physics: const NeverScrollableScrollPhysics(),
          children: _quickAmounts.map((qa) {
            final sel = _amount == qa;
            return GestureDetector(
              onTap: () => setState(() {
                _amount = qa;
                _amountCtrl.text = qa.toInt().toString();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: sel
                      ? (isDark ? const Color(0xFF2E1A0B) : _kOrange)
                      : cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel
                        ? (isDark ? const Color(0xFF2E1A0B) : _kOrange)
                        : dividerColor,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '₦${qa.toInt()}',
                    style: GoogleFonts.poppins(
                      color: sel ? _kWhite : textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        Center(
          child: GestureDetector(
            onTap: _amount >= 1 ? () => _goTo(_Step.deliveryMethod) : null,
            child: Container(
              width: 344,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [HexColor("#6A3710"), HexColor("#6A3710")],
                ),
              ),
              child: Center(
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final hasImage =
        widget.profilePicture != null && widget.profilePicture!.isNotEmpty;
    final initials = widget.recipientName.isNotEmpty
        ? widget.recipientName[0].toUpperCase()
        : 'U';
    if (!hasImage) return _initialsAvatar(initials);
    return ClipOval(
      child: SizedBox(
        width: 56,
        height: 56,
        child: Image.network(
          widget.profilePicture!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, prog) =>
              prog == null ? child : _initialsAvatar(initials),
          errorBuilder: (_, __, ___) => _initialsAvatar(initials),
        ),
      ),
    );
  }

  Widget _initialsAvatar(String initials) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF555555) : _kOrange,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            color: _kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCREEN 2  –  Delivery Method
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDeliveryMethodStep() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final methods = [
      {
        'label': 'Airplane Mode',
        'image': 'images/send_plane.png',
        'icon': Icons.flight,
        'color': const Color(0xFF8B6914),
        'disabled': false,
      },
      {
        'label': 'Car Mode',
        'image': 'images/send_car.png',
        'icon': Icons.directions_car,
        'color': const Color(0xFF6B5B95),
        'disabled': true,
      },
      {
        'label': 'Ship Mode',
        'image': 'images/send_ship.png',
        'icon': Icons.directions_boat,
        'color': const Color(0xFF4A4A6A),
        'disabled': true,
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Which delivery method\ndo you want?',
          style: GoogleFonts.poppins(
            color: isDark ? _kWhite : AppTheme.textPrimary(false),
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: methods.map((m) {
            final disabled = m['disabled'] as bool;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: disabled ? null : () => _goTo(_Step.chooseAirplane),
                  child: Opacity(
                    opacity: disabled ? 0.45 : 1.0,
                    child: Column(
                      children: [
                        Container(
                          height: 110,
                          decoration: BoxDecoration(
                            color: m['color'] as Color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Image.asset(
                              m['image'] as String,
                              width: 90,
                              height: 90,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                m['icon'] as IconData,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          m['label'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: isDark ? _kWhite : AppTheme.textPrimary(false),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _deliveryIcon(String imagePath, IconData fallback, Color bgColor) {
    return Image.asset(
      imagePath,
      width: 68,
      height: 68,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Center(child: Icon(fallback, size: 36, color: bgColor)),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCREEN 3  –  Choose Airplane
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildChooseAirplaneStep() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Choose Airplane',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: isDark ? _kWhite : AppTheme.textPrimary(false),
            fontWeight: FontWeight.w800,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: _planes.length,
          itemBuilder: (_, i) {
            final selected = _selectedPlane == i;
            final bgColors = [
              const Color(0xFF1A2A4A),
              const Color(0xFF2A1A3A),
              const Color(0xFF1A3A2A),
              const Color(0xFF3A2A1A),
            ];
            return GestureDetector(
              onTap: () => setState(() => _selectedPlane = i),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      _planes[i]['image']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: bgColors[i % bgColors.length],
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.flight,
                                size: 40,
                                color: Colors.white70,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _planes[i]['name']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _planes[i]['name']!,
                        style: GoogleFonts.poppins(
                          color: _kWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (selected) ...[
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF22C55E),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () => _goTo(_Step.confirmation),
            child: Container(
              width: 344,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [HexColor("#2E1A0B"), HexColor("#6A3710")],
                ),
              ),
              child: Center(
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCREEN 4  –  Transfer Confirmation  (full-screen overlay)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildConfirmationOverlay() {
    final last4 = widget.recipientAccountNumber.length >= 4
        ? widget.recipientAccountNumber.substring(
            widget.recipientAccountNumber.length - 4,
          )
        : widget.recipientAccountNumber;

    return Material(
      color: Colors.black.withOpacity(0.60),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon circle floating above card
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'images/credit_card.png',
                      width: 44,
                      height: 44,
                      errorBuilder: (_, __, ___) =>
                          const Text('💳', style: TextStyle(fontSize: 36)),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: _kBg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Transfer Confirmation',
                        style: GoogleFonts.poppins(
                          color: _kWhite,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _confirmRow(
                              'From',
                              widget.senderName,
                              'United Bank of Africa',
                              '**** 1121',
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Divider(height: 1, color: _kDivider),
                            ),
                            _confirmRow(
                              'To',
                              widget.recipientName,
                              '${widget.recipientBank} Online',
                              '**** $last4',
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: GoogleFonts.poppins(
                                    color: _kGrey,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '₦${_amount.toInt()}',
                                  style: GoogleFonts.poppins(
                                    color: _kWhite,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => _goTo(_Step.pin),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kOrangeBtn,
                              foregroundColor: _kWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Ok,Send Now!',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _confirmRow(String dir, String name, String bank, String acct) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dir, style: GoogleFonts.poppins(color: _kGrey, fontSize: 12)),
            const SizedBox(height: 3),
            Text(
              name,
              style: GoogleFonts.poppins(
                color: _kWhite,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(bank, style: GoogleFonts.poppins(color: _kGrey, fontSize: 12)),
            const SizedBox(height: 3),
            Text(
              acct,
              style: GoogleFonts.poppins(
                color: _kWhite,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCREEN 5  –  Enter PIN
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPinStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _goTo(_Step.confirmation),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kDivider),
            ),
            child: const Icon(Icons.chevron_left, color: _kWhite, size: 26),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Enter your security pin',
          style: GoogleFonts.poppins(
            color: _kWhite,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We use state-of-the-art security measures\nto protect your information at all times',
          style: GoogleFonts.poppins(color: _kGrey, fontSize: 13),
        ),
        const SizedBox(height: 32),

        // PIN dots + orange underlines
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final filled = i < _pinLength;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (filled)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: _kWhite,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  Container(width: 16, height: 16),
                const SizedBox(height: 8),
                Container(width: 52, height: 2.5, color: _kOrange),
              ],
            );
          }),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _pinLength == 5 && !_isProcessing
                ? _processPayment
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kOrangeBtn,
              disabledBackgroundColor: const Color(0xFF3A2A1A),
              foregroundColor: _kWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kWhite,
                    ),
                  )
                : Text(
                    'Confirm PIN',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        _buildNumpad(),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildNumpad() {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', 'del'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((k) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (k == 'del') {
                      if (_pinLength > 0) setState(() => _pinLength--);
                    } else if (k != '*') {
                      if (_pinLength < 5) setState(() => _pinLength++);
                    }
                  },
                  borderRadius: BorderRadius.circular(40),
                  splashColor: Colors.white12,
                  child: SizedBox(
                    width: 80,
                    height: 52,
                    child: Center(
                      child: k == 'del'
                          ? Container(
                              width: 36,
                              height: 26,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white38,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.backspace_outlined,
                                color: _kWhite,
                                size: 15,
                              ),
                            )
                          : Text(
                              k,
                              style: GoogleFonts.poppins(
                                color: _kWhite,
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  // ── Fake 2 s payment delay → success ──────────────────────────────────────
  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    if (!mounted) return;

    // Simulate a real network call with 2-second delay
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final record = TransactionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chatId,
      senderName: widget.senderName,
      receiverName: widget.recipientName,
      receiverAccountNumber: widget.recipientAccountNumber,
      receiverBank: widget.recipientBank,
      amount: _amount,
      timestamp: DateTime.now(),
      isMe: true,
    );

    await _saveLocally(record);
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _completedTx = record;
    });
    _goTo(_Step.takingOff);
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

  // ═══════════════════════════════════════════════════════════════════════════
  // SCREEN 6  –  Taking Off  (plane flies across & lifts off)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTakingOffStep() {
    if (!_takingOffStarted) {
      _takingOffStarted = true;
      _planeCtrl.forward();
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) _goTo(_Step.success);
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        Text(
          'Taking off',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: _kWhite,
            fontWeight: FontWeight.w800,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enjoy the ride',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: _kGrey,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: Image.asset(
            'assets/svgs/send_money.gif',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.flight_takeoff, size: 80, color: _kWhite),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCREEN 7  –  Success
  //
  //  • Receipt card style (From/To/Bank/Account/Date/Ref + green badge)
  //  • Auto-triggers IncomingFlightSheet after 3 s (demo)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSuccessStep() {
    final record = _completedTx!;
    final formatted = NumberFormat('#,##0').format(record.amount);
    final last4 = record.receiverAccountNumber.length >= 4
        ? record.receiverAccountNumber.substring(
            record.receiverAccountNumber.length - 4,
          )
        : record.receiverAccountNumber;
    final time = DateFormat('dd MMM yyyy, hh:mm a').format(record.timestamp);

    // ── IncomingFlightSheet disabled for now ──────────────────────────────
    // if (!_incomingTriggered) {
    //   _incomingTriggered = true;
    //   Future.delayed(const Duration(seconds: 3), () {
    //     if (!mounted) return;
    //     IncomingFlightSheet.show(
    //       context,
    //       senderName: record.senderName,
    //       recipientName: record.receiverName,
    //       amount: record.amount,
    //     );
    //   });
    // }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Illustration from assets
        Image.asset(
          'images/transfer.png',
          height: 100,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF22C55E),
            size: 70,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Transfer Successful',
          style: GoogleFonts.poppins(
            color: _kWhite,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Transfers are reviewed which may result in delays',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: _kGrey, fontSize: 11),
        ),
        const SizedBox(height: 16),

        // Receipt card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kDivider),
          ),
          child: Column(
            children: [
              Text(
                '₦$formatted',
                style: GoogleFonts.poppins(
                  color: _kWhite,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: _kDivider),
              const SizedBox(height: 10),
              _receiptRow('From', record.senderName),
              const SizedBox(height: 6),
              _receiptRow('To', record.receiverName),
              const SizedBox(height: 6),
              _receiptRow('Bank', record.receiverBank),
              const SizedBox(height: 6),
              _receiptRow('Account', '**** $last4'),
              const SizedBox(height: 6),
              _receiptRow('Date', time),
              const SizedBox(height: 6),
              _receiptRow(
                'Ref',
                '#${record.id.substring(record.id.length > 8 ? record.id.length - 8 : 0)}',
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: _kDivider),
              const SizedBox(height: 10),
              // Green "Successful" pill badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _kGreen.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _kGreenLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Successful',
                      style: GoogleFonts.poppins(
                        color: _kGreenLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Share Receipt — green filled
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              widget.onShareReceipt?.call(record);
              Navigator.of(context).pop(record);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGreen,
              foregroundColor: _kWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send_rounded, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Share Receipt',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Done — white outline
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(record),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.25)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Done',
              style: GoogleFonts.poppins(
                color: _kWhite,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _receiptRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: GoogleFonts.poppins(color: _kGrey, fontSize: 12)),
      Text(
        value,
        style: GoogleFonts.poppins(
          color: _kWhite,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    ],
  );

  Widget _buildSlider() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const double sliderHeight = 48;
    const double hPad = 20;

    return LayoutBuilder(
      builder: (_, constraints) {
        final trackWidth = constraints.maxWidth - hPad * 2;
        final fraction = (_amount.clamp(1, 500000) - 1) / 499999;
        final thumbCentreX = hPad + fraction * trackWidth;

        return SizedBox(
          height: sliderHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbColor: Colors.transparent,
                    activeTrackColor: _kOrange,
                    inactiveTrackColor: isDark ? _kDivider : AppTheme.divider(false),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 0,
                    ),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: _amount.clamp(1, 500000),
                    min: 1,
                    max: 500000,
                    onChanged: (v) => setState(() {
                      _amount = v.roundToDouble();
                      _amountCtrl.text = v.toInt().toString();
                    }),
                  ),
                ),
              ),
              Positioned(
                left: thumbCentreX - 21,
                top: sliderHeight / 2 - 17,
                child: IgnorePointer(
                  child: Container(
                    width: 42,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : AppTheme.cardBg(false),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _kOrange, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '<>',
                        style: GoogleFonts.poppins(
                          color: isDark ? _kWhite : AppTheme.textPrimary(false),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _amountBtn({required IconData icon, required VoidCallback onTap}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3F3F3F) : AppTheme.iconBg(false),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isDark ? _kWhite : AppTheme.iconColor(false), size: 20),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD ROOT
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_step == _Step.confirmation) return _buildConfirmationOverlay();

    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double sheetHeight = () {
      switch (_step) {
        case _Step.sendOrRequest:
          return screenHeight * 0.38;
        case _Step.recipient:
          return screenHeight * 0.75;
        case _Step.deliveryMethod:
          return screenHeight * 0.55;
        case _Step.chooseAirplane:
          return screenHeight * 0.75;
        case _Step.pin:
          return screenHeight * 0.80;
        case _Step.takingOff:
          return screenHeight * 0.60;
        case _Step.success:
          return screenHeight * 0.85;
        default:
          return screenHeight * 0.60;
      }
    }();

    final bool showBack =
        _step == _Step.recipient ||
        _step == _Step.deliveryMethod ||
        _step == _Step.chooseAirplane;

    Widget content;
    switch (_step) {
      case _Step.sendOrRequest:
        content = _buildSendOrRequest();
        break;
      case _Step.recipient:
        content = _buildRecipientStep();
        break;
      case _Step.deliveryMethod:
        content = _buildDeliveryMethodStep();
        break;
      case _Step.chooseAirplane:
        content = _buildChooseAirplaneStep();
        break;
      case _Step.pin:
        content = _buildPinStep();
        break;
      case _Step.takingOff:
        content = _buildTakingOffStep();
        break;
      case _Step.success:
        content = _buildSuccessStep();
        break;
      default:
        content = const SizedBox.shrink();
    }

    return Container(
      height: sheetHeight + bottomInset,
      decoration: BoxDecoration(
        color: _step == _Step.takingOff
            ? HexColor("#423B36")
            : Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF424242).withOpacity(0.85)
                : AppTheme.scaffoldBg(false),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.25)
                      : AppTheme.divider(false),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            if (showBack)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      switch (_step) {
                        case _Step.recipient:
                          _goTo(_Step.sendOrRequest);
                          break;
                        case _Step.deliveryMethod:
                          _goTo(_Step.recipient);
                          break;
                        case _Step.chooseAirplane:
                          _goTo(_Step.deliveryMethod);
                          break;
                        default:
                          break;
                      }
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? _kCard
                            : AppTheme.cardBg(false),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? _kDivider
                              : AppTheme.divider(false),
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? _kWhite
                            : AppTheme.textPrimary(false),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 4, 20, bottomInset + 20),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// IncomingFlightSheet
//
// Receiver's sheet — plane glides in from top-right, lands on runway,
// shows amount + sender info, then auto-dismisses.
//
// Demo: auto-triggered 3 s after sender's success screen.
// Production: call IncomingFlightSheet.show() from your socket listener
//   socket!.on('transaction received', (data) { ... });
// ═════════════════════════════════════════════════════════════════════════════
class IncomingFlightSheet extends StatefulWidget {
  final String senderName;
  final String recipientName;
  final double amount;
  final String? senderProfilePicture;

  const IncomingFlightSheet({
    super.key,
    required this.senderName,
    required this.recipientName,
    required this.amount,
    this.senderProfilePicture,
  });

  static Future<void> show(
    BuildContext context, {
    required String senderName,
    required double amount,
    required String recipientName,
    String? senderProfilePicture,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      // auto-dismisses via animation
      enableDrag: false,
      builder: (_) => IncomingFlightSheet(
        senderName: senderName,
        recipientName: recipientName,
        amount: amount,
        senderProfilePicture: senderProfilePicture,
      ),
    );
  }

  @override
  State<IncomingFlightSheet> createState() => _IncomingFlightSheetState();
}

class _IncomingFlightSheetState extends State<IncomingFlightSheet>
    with TickerProviderStateMixin {
  // Landing animation — 3.5 s
  late AnimationController _landCtrl;
  late Animation<double> _planeXFrac; // fraction of screen width
  late Animation<double> _planeYFrac; // fraction of sheet height
  late Animation<double> _tiltAngle; // nose-down radians

  // Sheet fade-out before pop
  late AnimationController _sheetFadeCtrl;
  late Animation<double> _sheetFadeAnim;

  // Info card fade-in (after landing)
  late AnimationController _cardFadeCtrl;
  late Animation<double> _cardFadeAnim;

  @override
  void initState() {
    super.initState();

    // ── Landing animation ────────────────────────────────────────────────
    _landCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Plane sweeps from off-screen right → settles ~40 % from left
    _planeXFrac = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.35,
          end: 0.38,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.38,
          end: 0.08,
        ).chain(CurveTween(curve: Curves.decelerate)),
        weight: 35,
      ),
    ]).animate(_landCtrl);

    // Starts above sheet → settles on runway (~56 % down)
    _planeYFrac = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: -0.18,
          end: 0.54,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 65,
      ),
      TweenSequenceItem(tween: Tween(begin: 0.54, end: 0.54), weight: 35),
    ]).animate(_landCtrl);

    // Nose-down approach → level touchdown
    _tiltAngle = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.18,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 65,
      ),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 35),
    ]).animate(_landCtrl);

    // ── Sheet fade-out ───────────────────────────────────────────────────
    _sheetFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _sheetFadeAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _sheetFadeCtrl, curve: Curves.easeOut));

    // ── Card fade-in ─────────────────────────────────────────────────────
    _cardFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardFadeAnim = CurvedAnimation(
      parent: _cardFadeCtrl,
      curve: Curves.easeIn,
    );

    // Sequence: land → hold 1.8 s showing info → fade sheet out → pop
    _landCtrl.forward().then((_) {
      _cardFadeCtrl.forward();
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        _sheetFadeCtrl.forward().then((_) {
          if (mounted) Navigator.of(context).pop();
        });
      });
    });
  }

  @override
  void dispose() {
    _landCtrl.dispose();
    _sheetFadeCtrl.dispose();
    _cardFadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fmtAmt = NumberFormat('#,##0').format(widget.amount);
    final sheetH = size.height * 0.52;

    return FadeTransition(
      opacity: _sheetFadeAnim,
      child: Container(
        height: sheetH,
        decoration: const BoxDecoration(
          color: Color(0xFF0E0E0E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Stack(
            children: [
              // Night-sky gradient
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF06101F),
                        Color(0xFF102038),
                        Color(0xFF0E0E0E),
                      ],
                      stops: [0.0, 0.52, 1.0],
                    ),
                  ),
                ),
              ),

              // Stars
              ..._buildStars(size, sheetH),

              // Runway ground
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Centre-line dashes
                    Row(
                      children: List.generate(
                        20,
                        (i) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 3,
                            color: (i % 2 == 0)
                                ? const Color(0xFFFFF9C4).withOpacity(0.55)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    Container(height: 44, color: const Color(0xFF0A0A0A)),
                    // Edge lights
                    _runwayLights(),
                  ],
                ),
              ),

              // Animated plane
              AnimatedBuilder(
                animation: _landCtrl,
                builder: (_, __) {
                  final px = _planeXFrac.value * size.width - 70;
                  final py = _planeYFrac.value * sheetH;
                  return Positioned(
                    left: px,
                    top: py,
                    child: Transform.rotate(
                      angle: _tiltAngle.value,
                      alignment: Alignment.center,
                      child: CustomPaint(
                        size: const Size(140, 50),
                        painter: _AirplaneBodyPainter(),
                      ),
                    ),
                  );
                },
              ),

              // Info content (fades in after landing)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FadeTransition(
                  opacity: _cardFadeAnim,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0E0E0E).withOpacity(0.96),
                          const Color(0xFF0E0E0E),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Incoming Flight',
                          style: GoogleFonts.poppins(
                            color: _kWhite,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Your container has landed',
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₦$fmtAmt',
                          style: GoogleFonts.poppins(
                            color: _kOrange,
                            fontWeight: FontWeight.w800,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'From: ',
                              style: GoogleFonts.poppins(
                                color: _kWhite,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              widget.senderName,
                              style: GoogleFonts.poppins(
                                color: _kWhite,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Drag handle
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStars(Size size, double sheetH) {
    final positions = [
      [0.08, 0.05],
      [0.25, 0.03],
      [0.48, 0.07],
      [0.70, 0.02],
      [0.90, 0.09],
      [0.15, 0.18],
      [0.40, 0.13],
      [0.63, 0.16],
      [0.82, 0.10],
      [0.95, 0.21],
      [0.06, 0.30],
      [0.33, 0.26],
      [0.57, 0.33],
      [0.77, 0.23],
      [0.92, 0.28],
    ];
    return positions
        .map(
          (p) => Positioned(
            left: p[0] * size.width,
            top: p[1] * sheetH,
            child: Container(
              width: 2,
              height: 2,
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _runwayLights() => Row(
    children: List.generate(
      24,
      (i) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 5,
          decoration: BoxDecoration(
            color: (i % 3 == 0)
                ? const Color(0xFFFF9800).withOpacity(0.85)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared airplane CustomPainter
// Used by both TakingOff (sender) and IncomingFlight (receiver)
// ═════════════════════════════════════════════════════════════════════════════
class _AirplaneBodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.fill;
    final windowPaint = Paint()
      ..color = const Color(0xFFB0D4F1)
      ..style = PaintingStyle.fill;
    final accentPaint = Paint()
      ..color = const Color(0xFF1A4A8A)
      ..style = PaintingStyle.fill;
    final enginePaint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..style = PaintingStyle.fill;

    // Fuselage
    final bodyPath = Path()
      ..moveTo(w * 0.97, h * 0.44)
      ..cubicTo(w * 0.84, h * 0.18, w * 0.38, h * 0.17, w * 0.04, h * 0.37)
      ..lineTo(w * 0.02, h * 0.52)
      ..cubicTo(w * 0.38, h * 0.64, w * 0.84, h * 0.62, w * 0.97, h * 0.44)
      ..close();
    canvas.save();
    canvas.translate(2, 3);
    canvas.drawPath(bodyPath, shadowPaint);
    canvas.restore();
    canvas.drawPath(bodyPath, bodyPaint);

    // Airline stripe
    final stripePath = Path()
      ..moveTo(w * 0.88, h * 0.36)
      ..cubicTo(w * 0.62, h * 0.23, w * 0.28, h * 0.23, w * 0.06, h * 0.40)
      ..lineTo(w * 0.06, h * 0.45)
      ..cubicTo(w * 0.28, h * 0.29, w * 0.62, h * 0.29, w * 0.88, h * 0.42)
      ..close();
    canvas.drawPath(stripePath, accentPaint);

    // Main wing
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.54, h * 0.41)
        ..lineTo(w * 0.20, h * 0.94)
        ..lineTo(w * 0.30, h * 0.96)
        ..lineTo(w * 0.62, h * 0.56)
        ..close(),
      Paint()
        ..color = const Color(0xFFCCCCCC)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.52, h * 0.40)
        ..lineTo(w * 0.20, h * 0.94)
        ..lineTo(w * 0.22, h * 0.94)
        ..lineTo(w * 0.54, h * 0.41)
        ..close(),
      bodyPaint,
    );

    // Engine
    final eng = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.39, h * 0.83),
        width: w * 0.19,
        height: h * 0.14,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(eng, shadowPaint);
    canvas.drawRRect(eng, enginePaint);
    canvas.drawCircle(
      Offset(w * 0.48, h * 0.83),
      h * 0.060,
      Paint()..color = const Color(0xFF888888),
    );
    canvas.drawCircle(
      Offset(w * 0.48, h * 0.83),
      h * 0.036,
      Paint()..color = const Color(0xFF333333),
    );

    // Tail fin
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.08, h * 0.37)
        ..lineTo(w * 0.03, h * 0.03)
        ..lineTo(w * 0.17, h * 0.35)
        ..close(),
      bodyPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.08, h * 0.37)
        ..lineTo(w * 0.04, h * 0.10)
        ..lineTo(w * 0.15, h * 0.35)
        ..close(),
      accentPaint,
    );

    // Horizontal stabiliser
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.19, h * 0.46)
        ..lineTo(w * 0.05, h * 0.70)
        ..lineTo(w * 0.11, h * 0.72)
        ..lineTo(w * 0.25, h * 0.53)
        ..close(),
      bodyPaint,
    );

    // Cabin windows
    for (int i = 0; i < 7; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(w * (0.76 - i * 0.085), h * 0.35),
            width: w * 0.028,
            height: h * 0.10,
          ),
          const Radius.circular(2),
        ),
        windowPaint,
      );
    }

    // Cockpit glass
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.90, h * 0.39)
        ..cubicTo(w * 0.87, h * 0.28, w * 0.79, h * 0.26, w * 0.76, h * 0.33)
        ..lineTo(w * 0.76, h * 0.42)
        ..cubicTo(w * 0.81, h * 0.47, w * 0.89, h * 0.46, w * 0.90, h * 0.39)
        ..close(),
      windowPaint,
    );
  }

  @override
  bool shouldRepaint(_AirplaneBodyPainter old) => false;
}
