import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart'; // ✅ ADD THIS

class ProfilePictureViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String username;

  const ProfilePictureViewer({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
    required this.username,
  }) : super(key: key);

  @override
  State<ProfilePictureViewer> createState() => _ProfilePictureViewerState();
}

class _ProfilePictureViewerState extends State<ProfilePictureViewer> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ✅ UPDATED: Use OfflineCachedImage for profile pictures
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: OfflineCachedImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.contain,
                    placeholder: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Top bar with username and close button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Username
                  Expanded(
                    child: Text(
                      widget.username,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Page indicator (if multiple images)
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${currentIndex + 1} / ${widget.imageUrls.length}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
