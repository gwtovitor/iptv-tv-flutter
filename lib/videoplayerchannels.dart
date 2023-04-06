import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);

  runApp(VideoPlayerScreen(parametro: 'meu parametro'));
}

class VideoPlayerScreen extends StatefulWidget {
  final String parametro;

  VideoPlayerScreen({Key? key, required this.parametro}) : super(key: key);

  @override
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

  @override
  Widget build(BuildContext context) {
    if (!_videoPlayerController.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_videoPlayerController),
        ],
      ),
    );
  }
}
