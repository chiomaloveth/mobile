import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/wallet/components/transaction_history_card_two.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
class AccountComponent extends StatefulWidget {
  const AccountComponent({super.key});

  @override
  State<AccountComponent> createState() => _AccountComponentState();
}

class _AccountComponentState extends State<AccountComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Stack(
                    children: [
                      Container(
                          height: double.infinity,
                          width: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: Colors.transparent
                          ),
                          child: Image.asset("images/background_card.png", fit: BoxFit.cover,)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Current Balance",
                                  style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "₦87,430.12",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black
                                      ),
                                    ),
                                    const SizedBox(width: 5,),
                                    Text(
                                      "10.2%",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6552FE)
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "🥲 Sapa mode",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 15,),
                                Text(
                                  "Top Up",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black
                                  ),
                                ),
                                const SizedBox(height: 8,),
                                Icon(CupertinoIcons.eye, color: Colors.black, size: 20,),
                                Spacer()
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Text(
                      "Account No_ 234678839",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white
                      ),
                    ),
                    const SizedBox(width: 15,),
                    Icon(Icons.copy, color: Colors.white, size: 20,)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(AppColors.primaryColor),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15))
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "All Transactions",
                          style: GoogleFonts.poppins(
                            color: Colors.white,

                          ),
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Text(
                              "Sort by:",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Color(0xFF4E589F)
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Text(
                              "Recent",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white)
                          ],
                        )
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (int i = 0; i < 6; i++)...[
                              TransactionHistoryCardTwo()
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
