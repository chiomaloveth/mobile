import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:qik_talk/features/chat/general/model/group_model.dart';

class GroupCallScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;
  final String groupImage;
  final List<GroupMember> members;
  final bool isVideo;
  final IO.Socket? socket;
  final String myUserId;

  const GroupCallScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.groupImage,
    required this.members,
    required this.isVideo,
    this.socket,
    required this.myUserId,
  }) : super(key: key);

  @override
  ConsumerState<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends ConsumerState<GroupCallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.groupName,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.groupImage.isNotEmpty)
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(widget.groupImage),
              )
            else
              CircleAvatar(
                radius: 60,
                backgroundColor: HexColor('#FF6B00'),
                child: Text(
                  widget.groupName.isNotEmpty ? widget.groupName[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Group Calling',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Group calling is temporarily disabled under the new WebRTC signaling logic.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor('#FF6B00'),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Go Back',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
