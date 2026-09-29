import 'dart:io';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';

class FileVideoPlayerScreen extends StatefulWidget {
  final File file;

  const FileVideoPlayerScreen({super.key, required this.file});

  @override
  State<FileVideoPlayerScreen> createState() => _FileVideoPlayerScreenState();
}

class _FileVideoPlayerScreenState extends State<FileVideoPlayerScreen> {
  late BetterPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
          aspectRatio: 9 / 16,
          fit: BoxFit.cover,
          autoPlay: true,
          looping: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControls: true,
            enableRetry: true,
          ),
        );

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      widget.file.path,
    );

    _controller = BetterPlayerController(betterPlayerConfiguration);
    _controller.setupDataSource(dataSource);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: BetterPlayer(controller: _controller),
        ),
      ),
    );
  }
}
