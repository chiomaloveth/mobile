import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:iconly/iconly.dart';
import 'package:qik_talk/features/wallet/features/transaction_history/screens/transaction_receipt_screen.dart';

import '../screens/send_to_recipient_screen.dart';

class RecentTransferItemCard extends StatelessWidget {
  const RecentTransferItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: GestureDetector(
        onTap: (){
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsWalletTransactionReceiptScreen()));
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Center(
                    child: Icon(CupertinoIcons.arrow_up_left,
                      color: Color(0xFF10B981), size: 20,),
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Transfer to Sarah Johnson",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Today, 2:30 PM",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.5)
                            ),
                          ),
                          const SizedBox(width: 6,),
                          Container(
                            height: 20,
                            width: 20,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(width: 1, color: Colors.white.withOpacity(0.5))
                            ),
                            child: Center(
                              child: Icon(IconlyBold.profile, color: Colors.grey, size: 10,),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "+₦250.00",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF10B981)
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Icon(Icons.arrow_forward_ios_rounded, size: 18,)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
