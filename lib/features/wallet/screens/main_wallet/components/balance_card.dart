import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

import '../../../../authentication/provider/user_provider.dart';
import '../../../components/wallet_animated_balance.dart';
import '../../../model/wallet_balance_model.dart';
import '../../../services/wallet_services.dart';

class BalanceCard extends ConsumerStatefulWidget {
  const BalanceCard({super.key});

  @override
  ConsumerState<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  bool _isBalanceVisible = true;

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  final WalletServices _walletServices = WalletServices();
  late Future<WalletBalanceModel> _futureBalance;

  @override
  void initState() {
    super.initState();
    _futureBalance = _walletServices.getWalletBalance(context: context);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: _toggleCard,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final angle = _animation.value * pi;
            final isFrontSide = _animation.value < 0.5;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(0)
                ..rotateY(angle),
              child: isFrontSide
                  ? _buildFront(userName: user.username)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildBack(),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFront({required String userName}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 205,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF1A1A1A),
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.3 : 0.12),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Available Balance",
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text("NGN", style: GoogleFonts.poppins(fontSize: 12)),
                          const Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  FutureBuilder<WalletBalanceModel>(
                    future: _futureBalance,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return WalletAnimatedBalance(
                          balance: 0.00,
                          isVisible: _isBalanceVisible,
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                        );
                      }
                      if (snapshot.hasError) {
                        return WalletAnimatedBalance(
                          balance: 0.00,
                          isVisible: _isBalanceVisible,
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                        );
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return WalletAnimatedBalance(
                          balance: 0.00,
                          isVisible: _isBalanceVisible,
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                        );
                      }

                      final data = snapshot.data!;
                      return WalletAnimatedBalance(
                        balance: data.balance,
                        isVisible: _isBalanceVisible,
                        fontSize: 35,
                        fontWeight: FontWeight.w700,
                      );
                    },
                  ),
                  Row(
                    children: [
                      Transform.rotate(
                        angle: -1.6,
                        child: const Icon(
                          Icons.arrow_right_alt_rounded,
                          size: 18,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        "+2.3% income this week",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Mood: Odogwu Paranran",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        "Acct Number: 708*****23",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => _copyToClipboard("0000000000"),
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: Image.asset("images/copy_icon.png"),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        height: 16,
                        width: 16,
                        child: Image.asset("images/icons/eye_open.png"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        "Qiktag Address: $userName",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => _copyToClipboard(userName),
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: Image.asset("images/copy_icon.png"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBack() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? Colors.white.withOpacity(0.15) : const Color(0xFF1A1A1A),
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.3 : 0.12),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Receiving Details",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                _buildDetailRow("Bank Name:", "Wema Bank"),
                const SizedBox(height: 10),
                _buildDetailRow("Account Name:", "Safianu Sani"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Account Number: ",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "0000000",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 16,
                      width: 16,
                      child: Image.asset("images/copy_icon.png"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDetailRow("QuickTag:", "hiwhrwi@_g"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label ",
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
