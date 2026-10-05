import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

import '../screens/send_to_recipient_screen.dart';

class SearchRecipientItemCard extends StatelessWidget {
  const SearchRecipientItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SendToRecipientScreen()));
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle
                  ),
                  child: Center(
                    child: Icon(IconlyBold.profile, size: 20, color: Colors.grey,),
                  ),
                ),
                const SizedBox(width: 5,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Odogwu Hilary",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 2,),
                    Text(
                      "Qik@hilary_o",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.5)
                      ),
                    ),
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
