import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AnimationPlayer extends StatefulWidget {
  final String assetPath; // ✅ ส่ง path ของไฟล์เข้ามา
  final bool autoPlay;
  final bool loop;

  const AnimationPlayer({
    super.key,
    required this.assetPath,
    this.autoPlay = true,
    this.loop = true,
  });

  @override
  State<AnimationPlayer> createState() => _AnimationPlayerState();
}

class _AnimationPlayerState extends State<AnimationPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath);

    _controller.addListener(() {
      if (_controller.value.hasError) {
        print("Video Error: ${_controller.value.errorDescription}");
      }
    });

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.setLooping(widget.loop);
      _controller.setVolume(0.0);
      if (widget.autoPlay) _controller.play();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
