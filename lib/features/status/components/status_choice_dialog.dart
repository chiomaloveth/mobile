import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class StatusChoiceDialog extends StatelessWidget {

  VoidCallback onCameraButtonPressed;
  VoidCallback onGalleryButtonPressed;
  VoidCallback onVideoButtonPressed;

  StatusChoiceDialog({
    required this.onCameraButtonPressed,
    required this.onGalleryButtonPressed,
    required this.onVideoButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 260.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [


          Container(
            height: 5.0,
            width: 40.0,
            margin: EdgeInsets.only(top: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(2.5)),
              color: Colors.grey,
            ),
          ),



          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [

                Expanded(child: SizedBox()),

                Column(
                  children: [
                    GestureDetector(
                      onTap: onCameraButtonPressed,
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        margin: EdgeInsets.only(top: 20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          border: Border(top: BorderSide(width: 0.5, color: Colors.grey),
                            left: BorderSide(width: 0.5, color: Colors.grey),
                            right: BorderSide(width: 0.5, color: Colors.grey),
                            bottom: BorderSide(width: 0.5, color: Colors.grey),),
                        ),
                        child: Icon(Icons.camera_alt_outlined, size: 25.0, color: Colors.black,),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text("Camera", style: TextStyle(color: Colors.grey, fontSize: 16.0, fontWeight: FontWeight.normal),),
                    ),

                  ],
                ),

                Expanded(child: SizedBox()),

                Column(
                  children: [
                    GestureDetector(
                      onTap: onGalleryButtonPressed,
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        margin: EdgeInsets.only(top: 20.0, left: 0.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          border: Border(top: BorderSide(width: 0.5, color: Colors.grey),
                            left: BorderSide(width: 0.5, color: Colors.grey),
                            right: BorderSide(width: 0.5, color: Colors.grey),
                            bottom: BorderSide(width: 0.5, color: Colors.grey),),
                        ),
                        child: Icon(Icons.image, size: 25.0, color: Colors.black,),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 0.0),
                      child: Text("Gallery", style: TextStyle(color: Colors.grey, fontSize: 16.0, fontWeight: FontWeight.normal),),
                    ),
                  ],
                ),

                // Expanded(child: SizedBox()),
                //
                //
                // Column(
                //   children: [
                //     GestureDetector(
                //       onTap: onVideoButtonPressed,
                //       child: Container(
                //         height: 60.0,
                //         width: 60.0,
                //         margin: EdgeInsets.only(top: 20.0, left: 0.0),
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.all(Radius.circular(30.0)),
                //           border: Border(top: BorderSide(width: 0.5, color: Colors.grey),
                //             left: BorderSide(width: 0.5, color: Colors.grey),
                //             right: BorderSide(width: 0.5, color: Colors.grey),
                //             bottom: BorderSide(width: 0.5, color: Colors.grey),),
                //         ),
                //         child: Icon(Icons.videocam, size: 25.0, color: Colors.black,),
                //       ),
                //     ),
                //
                //     Padding(
                //       padding: const EdgeInsets.only(top: 10.0, left: 0.0),
                //       child: Text("Video", style: TextStyle(color: Colors.grey, fontSize: 16.0, fontWeight: FontWeight.normal),),
                //     ),
                //   ],
                // ),

                Expanded(child: SizedBox()),
              ],
            ),
          ),

        ],
      ),
    );
  }
}