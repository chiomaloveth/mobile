// lib/features/chat/single_chat/components/transaction_bubble.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/chat/general/model/transaction_model.dart';

class TransactionBubble extends StatefulWidget {
  final TransactionRecord transaction;

  const TransactionBubble({super.key, required this.transaction});

  @override
  State<TransactionBubble> createState() => _TransactionBubbleState();
}

class _TransactionBubbleState extends State<TransactionBubble> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final formattedAmt = NumberFormat('#,##0.00', 'en_NG').format(tx.amount);
    final time = DateFormat('h:mm a').format(tx.timestamp);
    final date = DateFormat('dd MMM yyyy').format(tx.timestamp);
    final last4 = tx.receiverAccountNumber.length >= 4
        ? '**** ${tx.receiverAccountNumber.substring(tx.receiverAccountNumber.length - 4)}'
        : tx.receiverAccountNumber;
    final ref = '#${tx.id.substring(tx.id.length > 8 ? tx.id.length - 8 : 0)}';

    return Align(
      alignment: tx.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        width: 270,
        decoration: BoxDecoration(
          gradient: tx.isMe
              ? LinearGradient(
                  colors: [HexColor('#1A7F4B'), HexColor('#0F5C35')],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [HexColor('#2A2A2A'), HexColor('#1E1E1E')],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: tx.isMe
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: tx.isMe
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          border: Border.all(
            color: tx.isMe
                ? Colors.white.withOpacity(0.15)
                : HexColor('#3A3A3A'),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ─────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tx.isMe
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: tx.isMe ? Colors.white : HexColor('#4DFFA0'),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tx.isMe ? 'Sent' : 'Received',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Amount ─────────────────────────────────────────────────
              Text(
                '₦$formattedAmt',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),
              Container(height: 1, color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 10),

              // ── Collapsed summary (always visible) ────────────────────
              if (tx.isMe) ...[
                _infoRow('To', tx.receiverName),
                const SizedBox(height: 4),
                _infoRow(tx.receiverBank, last4),
              ] else ...[
                _infoRow('From', tx.senderName),
                const SizedBox(height: 4),
                _infoRow('Via', tx.receiverBank),
              ],

              // ── Expanded receipt details ───────────────────────────────
              if (_expanded) ...[
                const SizedBox(height: 8),
                Container(height: 1, color: Colors.white.withOpacity(0.08)),
                const SizedBox(height: 8),

                if (tx.isMe) ...[
                  _infoRow('From', tx.senderName),
                  const SizedBox(height: 4),
                ] else ...[
                  _infoRow('To', tx.receiverName),
                  const SizedBox(height: 4),
                  _infoRow('Account', last4),
                  const SizedBox(height: 4),
                ],
                _infoRow('Date', date),
                const SizedBox(height: 4),
                _infoRow('Ref', ref),
                const SizedBox(height: 8),
                Container(height: 1, color: Colors.white.withOpacity(0.08)),
              ],

              const SizedBox(height: 10),

              // ── Footer: status pill + read more/less ──────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: HexColor('#4DFFA0').withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: HexColor('#4DFFA0'),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Successful',
                          style: GoogleFonts.poppins(
                            color: HexColor('#4DFFA0'),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Read more / Read less toggle
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? 'Read less' : 'Read more',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
