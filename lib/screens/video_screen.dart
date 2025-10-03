import 'package:flutter/material.dart';
import 'package:nasa_app/models/lesson_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoScreen extends StatefulWidget {
  final LessonData lessonData;
  const VideoScreen({super.key, required this.lessonData});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late YoutubePlayerController _controller;
  String? videoId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadVideoId();
  }

  Future<void> _loadVideoId() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('videos')
          .doc(
            widget.lessonData.lessonId.toString(),
          ) // افترض إن عندك id في LessonData
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          videoId = doc.data()!['videoId'] ?? "DEFAULT_ID";
          _controller = YoutubePlayerController(
            initialVideoId: videoId!,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              hideControls: false,
              mute: false,
              disableDragSeek: true,
              enableCaption: false,
            ),
          );
          loading = false;
        });
      } else {
        setState(() {
          videoId = "DEFAULT_ID";
          _controller = YoutubePlayerController(
            initialVideoId: videoId!,
            flags: const YoutubePlayerFlags(autoPlay: true),
          );
          loading = false;
        });
      }
    } catch (e) {
      print("Error fetching videoId: $e");
      setState(() {
        videoId = "DEFAULT_ID";
        _controller = YoutubePlayerController(
          initialVideoId: videoId!,
          flags: const YoutubePlayerFlags(autoPlay: true),
        );
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.lessonData.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: const ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
