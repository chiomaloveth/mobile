import 'package:flutter/material.dart';

class ThemeChatWallpaperComponent extends StatelessWidget {
  final String title;
  final String image;
  final String selected;
  final VoidCallback onClick;
  final bool isDark;
  const ThemeChatWallpaperComponent({super.key, required this.title, required this.image, required this.selected, required this.onClick, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.1),
        border: Border.symmetric(horizontal: BorderSide(width: 0.5, color: Colors.white.withOpacity(0.3)))
      ),
      child: MaterialButton(onPressed: onClick, child: Row(children: [
        Container(
          height: 35,
          width: 35,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: image.isEmpty ? Colors.black : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 1, color: isDark ? Colors.white.withOpacity(0.2) : Colors.black)
          ),
          child: image.isEmpty ? const SizedBox.shrink() : Image.network(image, fit: BoxFit.cover, errorBuilder: (context, err ,st) {
            return Center(
              child: Icon(Icons.image, color: Colors.grey, size: 18,),
            );
          },),
        ),
        const SizedBox(width: 10,),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white : null,
          ),
        ),
        Spacer(),
        Icon(Icons.check, color: selected.trim().toLowerCase() == title.trim().toLowerCase() ? Colors.green : Colors.transparent,)
      ],),),
    );
  }
}
