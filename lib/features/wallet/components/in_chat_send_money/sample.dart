import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/chat/general/model/transaction_model.dart';
import 'package:qik_talk/features/wallet/components/in_chat_send_money/runway_painter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_thumb_shape.dart';

// ── Precise Color Palette from Screenshots ──────────────────────────────────
const Color _kBg = Color(0xFF231F20); // Darker charcoal background
const Color _kCard = Color(0xFF2C2B2B);
const Color _kOrange = Color(0xFFE68A00);
const Color _kButtonBrown = Color(0xFF5A2D0C); // Dark brown from "Continue"
const Color _kWhite = Colors.white;
const Color _kGrey = Color(0xFF9E9E9E);
const Color _kDivider = Color(0xFF3A3A3A);

// Delivery Mode Colors
const Color _kPlaneColor = Color(0xFF8B6914);
const Color _kCarColor = Color(0xFF6D5D95);
const Color _kShipColor = Color(0xFF7388A1);

enum _Step {
  recipient,
  deliveryMethod,
  chooseAirplane,
  confirmation,
  pin,
  takingOff,
  success,
}

class SendMoneySheetTwo extends StatefulWidget {
  final String recipientName;
  final String recipientAccountNumber;
  final String recipientBank;
  final String senderName;
  final String chatId;
  final String? profilePicture;
  final void Function(TransactionRecord record)? onShareReceipt;

  const SendMoneySheetTwo({
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
    return showModalBottomSheet<TransactionRecord>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SendMoneySheetTwo(
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
  State<SendMoneySheetTwo> createState() => _SendMoneySheetTwoState();
}

class _SendMoneySheetTwoState extends State<SendMoneySheetTwo>
    with TickerProviderStateMixin {
  _Step _step = _Step.recipient;
  double _amount = 100;
  final _amountCtrl = TextEditingController(text: '100');
  final List<double> _quickAmounts = [5, 10, 15, 20, 50, 100, 200, 500];
  int _selectedPlane = 2; // Matches Boeing 747-8F in screenshot
  int _pinLength = 2; // Initial state for visual matching
  bool _isProcessing = false;
  TransactionRecord? _completedTx;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<Map<String, String>> _planes = const [
    {'name': 'McDonnell Douglas MD-11F', 'image': 'images/plane_md11.png'},
    {'name': 'Boeing 777F', 'image': 'images/plane_777.png'},
    {'name': 'Boeing 747-8F', 'image': 'images/plane_747.png'},
    {'name': 'Antonov An-124', 'image': 'images/plane_an124.png'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _goTo(_Step s) {
    _fadeCtrl.forward(from: 0);
    setState(() => _step = s);
    if (s == _Step.takingOff) {
      Future.delayed(const Duration(seconds: 3), () => _goTo(_Step.success));
    }
  }

  // ── Screen 1: Recipient & Amount (Image 3 & 6) ──────────────────────────
  Widget _buildAmountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recipient Pill
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: widget.profilePicture != null
                    ? NetworkImage(widget.profilePicture!)
                    : null,
                backgroundColor: _kGrey,
                child: widget.profilePicture == null
                    ? const Icon(Icons.person, color: _kWhite)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.recipientName,
                        style: GoogleFonts.poppins(
                            color: _kWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    Text('Qiktag: ${widget.recipientAccountNumber}',
                        style: GoogleFonts.poppins(color: _kGrey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 24),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Amount Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount',
                  style: GoogleFonts.poppins(
                      color: _kWhite, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _circleBtn(Icons.remove, () {
                    if (_amount > 1) setState(() => _amount--);
                    _amountCtrl.text = _amount.toInt().toString();
                  }),
                  const SizedBox(width: 20),
                  Text('₦',
                      style: GoogleFonts.poppins(
                          fontSize: 32,
                          color: _kWhite,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  IntrinsicWidth(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(
                          color: _kWhite,
                          fontSize: 36,
                          fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                          border: InputBorder.none, isDense: true),
                      onChanged: (v) => _amount = double.tryParse(v) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 20),
                  _circleBtn(Icons.add, () {
                    setState(() => _amount++);
                    _amountCtrl.text = _amount.toInt().toString();
                  }),
                ],
              ),
              const SizedBox(height: 10),
              _buildCustomSlider(),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Quick Amount Grid
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          physics: const NeverScrollableScrollPhysics(),
          children: _quickAmounts.map((q) {
            bool selected = _amount == q;
            return GestureDetector(
              onTap: () => setState(() {
                _amount = q;
                _amountCtrl.text = q.toInt().toString();
              }),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? _kButtonBrown : _kCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? _kOrange : _kDivider),
                ),
                child: Center(
                  child: Text('₦${q.toInt()}',
                      style: GoogleFonts.poppins(
                          color: _kWhite, fontWeight: FontWeight.w600)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        _largeActionBtn('Continue', () => _goTo(_Step.deliveryMethod)),
      ],
    );
  }

  // ── Screen 2: Delivery Method (Image 4) ──────────────────────────────────
  Widget _buildDeliveryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Which delivery method\ndo you want?',
            style: GoogleFonts.poppins(
                color: _kWhite, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Row(
          children: [
            _deliveryCard('Airplane Mode', Icons.airplanemode_active, _kPlaneColor, true),
            const SizedBox(width: 12),
            _deliveryCard('Car Mode', Icons.directions_car, _kCarColor, false),
            const SizedBox(width: 12),
            _deliveryCard('Ship Mode', Icons.directions_boat, _kShipColor, false),
          ],
        ),
      ],
    );
  }

  Widget _deliveryCard(String title, IconData icon, Color color, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: active ? () => _goTo(_Step.chooseAirplane) : null,
        child: Opacity(
          opacity: active ? 1.0 : 0.6,
          child: Column(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: _kWhite, shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 28),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(title,
                  style: GoogleFonts.poppins(
                      color: _kWhite, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Screen 3: Choose Airplane (Image 5) ──────────────────────────────────
  Widget _buildAirplaneStep() {
    return Column(
      children: [
        Text('Choose Airplane',
            style: GoogleFonts.poppins(
                color: _kWhite, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _planes.length,
          itemBuilder: (ctx, i) {
            bool selected = _selectedPlane == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedPlane = i),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: selected ? Colors.green : Colors.transparent,
                      width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: Container(color: const Color(0xFF333333))),
                      const Center(
                          child: Icon(Icons.flight, color: Colors.white24, size: 40)),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8)),
                          ),
                          child: Text(_planes[i]['name']!,
                              style: GoogleFonts.poppins(
                                  color: _kWhite,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (selected)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        _largeActionBtn('Continue', () => _goTo(_Step.confirmation)),
      ],
    );
  }

  // ── Screen 4: Confirmation (Image 7) ──────────────────────────────────────
  Widget _buildConfirmation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: _kWhite, shape: BoxShape.circle),
              child: const Text('💳', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: _kBg, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  Text('Transfer Confirmation',
                      style: GoogleFonts.poppins(
                          color: _kWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _confirmRow('From', 'Odogwu', 'United Bank of Africa', '**** 1121'),
                  const Divider(color: _kDivider, height: 32),
                  _confirmRow('To', 'Gloriay', 'Opay Online', '**** 4023'),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: GoogleFonts.poppins(color: _kGrey)),
                      Text('₦${_amount.toInt()}',
                          style: GoogleFonts.poppins(
                              color: _kWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _largeActionBtn('Ok, Send Now!', () => _goTo(_Step.pin)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmRow(String label, String name, String bank, String acct) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(color: _kGrey, fontSize: 12)),
          Text(name,
              style: GoogleFonts.poppins(
                  color: _kWhite, fontWeight: FontWeight.bold)),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(bank, style: GoogleFonts.poppins(color: _kGrey, fontSize: 12)),
          Text(acct,
              style: GoogleFonts.poppins(
                  color: _kWhite, fontWeight: FontWeight.bold)),
        ]),
      ],
    );
  }

  // ── Screen 5: PIN Entry (Image 7/8) ───────────────────────────────────────
  Widget _buildPinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => _goTo(_Step.confirmation),
          icon: const Icon(Icons.arrow_back, color: _kWhite),
          style: IconButton.styleFrom(backgroundColor: _kCard),
        ),
        const SizedBox(height: 20),
        Text('Enter your security pin',
            style: GoogleFonts.poppins(
                color: _kWhite, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('We use state-of-the-art security measures to protect your information at all times',
            style: GoogleFonts.poppins(color: _kGrey, fontSize: 14)),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            bool filled = i < _pinLength;
            return Column(
              children: [
                if (filled)
                  const CircleAvatar(radius: 6, backgroundColor: _kWhite)
                else
                  const SizedBox(height: 12),
                const SizedBox(height: 8),
                Container(width: 45, height: 2, color: _kOrange),
              ],
            );
          }),
        ),
        const SizedBox(height: 40),
        _largeActionBtn('Confirm PIN', () => _goTo(_Step.takingOff)),
        const SizedBox(height: 30),
        _buildNumpad(),
      ],
    );
  }

  // ── Screen 6: Taking Off (Image 8) ─────────────────────────────────────────
  Widget _buildTakingOff() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Text('Taking off',
              style: GoogleFonts.poppins(
                  color: _kWhite, fontSize: 44, fontWeight: FontWeight.bold)),
          Text('Enjoy the ride',
              style: GoogleFonts.poppins(
                  color: _kWhite, fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 100),
          // Simple Runway Graphic
          SizedBox(
            width: 250,
            height: 80,
            child: CustomPaint(painter: RunwayPainter()),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────────
  Widget _buildCustomSlider() {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: _kOrange,
        inactiveTrackColor: _kDivider,
        trackHeight: 2,
        thumbColor: Colors.transparent,
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: CustomThumbShape(),
      ),
      child: Slider(
        value: _amount,
        min: 0,
        max: 1000,
        onChanged: (v) => setState(() {
          _amount = v;
          _amountCtrl.text = v.toInt().toString();
        }),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: const Color(0xFF4A4A4A), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: _kWhite, size: 20),
      ),
    );
  }

  Widget _largeActionBtn(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kButtonBrown,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                color: _kWhite, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildNumpad() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 1.5),
      itemCount: 12,
      itemBuilder: (ctx, i) {
        String val = "";
        if (i < 9) val = (i + 1).toString();
        else if (i == 9) val = "*";
        else if (i == 10) val = "0";
        else if (i == 11) return const Icon(Icons.backspace_outlined, color: _kWhite);

        return Center(
          child: Text(val,
              style: GoogleFonts.poppins(color: _kWhite, fontSize: 24)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isModal = _step == _Step.confirmation || _step == _Step.takingOff;

    return Scaffold(
      backgroundColor: isModal ? Colors.black.withOpacity(0.85) : _kBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                if (!isModal)
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: _kGrey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_step) {
      case _Step.recipient: return _buildAmountStep();
      case _Step.deliveryMethod: return _buildDeliveryStep();
      case _Step.chooseAirplane: return _buildAirplaneStep();
      case _Step.confirmation: return _buildConfirmation();
      case _Step.pin: return _buildPinStep();
      case _Step.takingOff: return _buildTakingOff();
      case _Step.success: return const Center(child: Text("Success!", style: TextStyle(color: Colors.white)));
    }
  }
}


