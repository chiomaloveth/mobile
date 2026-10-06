import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';

class TransactionHistoryCardTwo extends StatelessWidget {
  const TransactionHistoryCardTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle
              ),
              child: Center(
                child: Icon(Icons.person, color: Colors.grey,),
              ),
            ),
            const SizedBox(width: 8,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Adeboye Usman",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
                const SizedBox(height: 5,),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(50)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 5),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.white, size: 20,),
                        const SizedBox(width: 5,),
                        Text(
                          "Failed",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 12
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Spacer(),
            Text(
              "₦110,000",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red
              ),
            )
          ],
        ),
      ),
    );
  }
}
