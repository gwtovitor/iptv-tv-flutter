import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(const VideoPlayerScreen(parametro: 'meu parametro'));
  });
}

class VideoPlayerScreen extends StatefulWidget {
  final String parametro;

  const VideoPlayerScreen({Key? key, required this.parametro})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.parametro)
      ..initialize().then((_) {
        setState(() {});
      });
    _videoPlayerController.play();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  bool _showProgressIndicator = false;

  @override
  Widget build(BuildContext context) {
    if (!_videoPlayerController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_videoPlayerController),
          AnimatedOpacity(
            opacity: _showProgressIndicator ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                _videoPlayerController.value.isPlaying
                    ? Icons.play_arrow
                    : Icons.pause,
                color: Colors.white,
                size: 10.w,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_videoPlayerController.value.isPlaying) {
                _videoPlayerController.pause();
                setState(() {
                  _showProgressIndicator = true;
                });
              } else {
                _videoPlayerController.play();

                Timer(const Duration(seconds: 3), () {
                  setState(() {
                    _showProgressIndicator = false;
                  });
                });
              }
              setState(() {});
            },
          ),
          AnimatedOpacity(
            opacity: _showProgressIndicator ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: VideoProgressIndicator(
                _videoPlayerController,
                allowScrubbing: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
