import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/settings_wallet/settings_wallet_transaction_receipt_screen.dart';

class TransactionHistoryCardOne extends StatelessWidget {
  final bool isDark;
  const TransactionHistoryCardOne({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsWalletTransactionReceiptScreen()));
        },
        child: Container(
          height: 75,
          width: MediaQuery.of(context).size.width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(17)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              children: [
                Container(
                  height: 47,
                  width: 47,
                  decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Center(
                    child: Icon(CupertinoIcons.arrow_down_left, color: isDark ? Colors.white : Colors.black, size: 20,),
                  ),
                ),
                const SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Airtime Purchase",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.white : null
                      ),
                    ),
                    const SizedBox(height: 2,),
                    Text(
                      "Today, 11:45 AM",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.white.withOpacity(0.4) : Colors.grey
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Text(
                      "-₦10.00",
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : null
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white : Colors.black, size: 15,)
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
