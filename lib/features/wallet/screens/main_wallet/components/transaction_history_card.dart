import 'dart:ui'; // Required for ImageFilter (the blur effect)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionHistoryCard extends StatelessWidget {
  const TransactionHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            height: 185,
            width: 140,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1.5, color: Colors.white.withOpacity(0.2))
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children:[
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Image.asset("images/card_icon.png", color: Colors.white,),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Text(
                    "Enora David",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "3109606124",
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.withOpacity(0.8)
                    ),
                  ),
                  const SizedBox(height: 5,),
                  const Text(
                    "-₦129.99",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.red
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Text(
                    "Mar 14, 2026",
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.withOpacity(0.8)
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}