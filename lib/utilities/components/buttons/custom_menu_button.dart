import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class CustomMenuButton extends StatelessWidget {
  final Function(String value) onSelected;

  const CustomMenuButton({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            MediaQuery.of(context).size.width - 160,
            75,
            10,
            20,
          ),
          color: HexColor("1F2937"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          items: [
            _menuItem("view_admin", Icons.security, "View Admin"),
            _menuItem("view_tailors", null, "View Tailors",
                image: "images/measurement_active.png"),
            _menuItem("edit_profile", Icons.person, "Edit Profile"),
            _menuItem("change_password", Icons.lock_outline, "Change Password"),
            _menuItem("sub_admin", Icons.person, "Add Sub-Admin"),
            _menuItem("logout", Icons.logout, "Logout"),
          ],
        );

        if (selected != null) {
          onSelected(selected);
        }
      },
      child: SizedBox(
        height: 50,
        width: 35,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 13.0, right: 10.0),
              child: Image.asset("images/menu.png", width: 5, height: 15),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
      String value,
      IconData? icon,
      String title, {
        String? image,
      }) {
    return PopupMenuItem<String>(
      value: value,
      child: SizedBox(
        width: 150,
        child: Row(
          children: [
            image != null
                ? Image.asset(image, width: 17, height: 17)
                : Icon(icon, color: HexColor("#FFD700")),
            SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}