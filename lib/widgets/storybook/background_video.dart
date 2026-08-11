import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BackgroundVideo extends StatefulWidget {
  final Function isInitialized;

  const BackgroundVideo({super.key, required this.isInitialized});

  @override
  State<BackgroundVideo> createState() => _BackgroundVideoState();
}

class _BackgroundVideoState extends State<BackgroundVideo> {
  late final VideoPlayerController videoController;

  @override
  void initState() {
    super.initState();

    videoController =
        VideoPlayerController.asset(
            'assets/vids/once-upon-a-time-castles-contrast.mp4',
          )
          ..initialize().then((_) {
            setState(() {
              videoController.setVolume(0);
              videoController.setLooping(true);
              videoController.play();
            });
            widget.isInitialized();
          });
  }

  @override
  void dispose() {
    videoController.pause();
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          height: videoController.value.size.height,
          width: videoController.value.size.width,
          child: videoController.value.isInitialized
              ? VideoPlayer(videoController)
              : const SizedBox(),
        ),
      ),
    );
  }
}
