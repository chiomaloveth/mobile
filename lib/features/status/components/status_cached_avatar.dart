import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qik_talk/features/status/services/status_cache_service.dart';

class StatusCachedAvatar extends StatelessWidget {
  final String imageUrl;
  final String fallbackText;
  final double radius;
  final Color backgroundColor;

  const StatusCachedAvatar({
    super.key,
    required this.imageUrl,
    required this.fallbackText,
    required this.radius,
    this.backgroundColor = const Color(0x33FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: StatusCacheService.localMediaPath(imageUrl),
      builder: (context, snapshot) {
        ImageProvider? provider;
        final localPath = snapshot.data;
        if (localPath != null && localPath.isNotEmpty) {
          provider = FileImage(File(localPath));
        } else if (imageUrl.isNotEmpty) {
          provider = NetworkImage(imageUrl);
        }

        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          backgroundImage: provider,
          child: provider == null
              ? Text(
                  fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: radius * 0.75,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        );
      },
    );
  }
}
