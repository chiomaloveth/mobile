import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDefaultButtonOne extends StatelessWidget {
  final String title;
  final VoidCallback onClick;

  const CustomDefaultButtonOne({
    super.key,
    required this.title,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: MaterialButton(
        onPressed: onClick,
        padding: EdgeInsets.zero,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(color: Colors.transparent),
                child: Image.asset(
                  "images/custom_default_button_one.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
