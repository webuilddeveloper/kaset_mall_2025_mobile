import 'package:flutter/material.dart';
import 'package:mobile_mart_v3/widget/videoForm.dart';
import 'package:video_player/video_player.dart';


class MyVideoWidget extends StatefulWidget {
  final String videoUrl;
  final String title; // รับค่าชื่อวิดีโอจาก `_futureListVideo`
  final dynamic model; // รับค่าชื่อวิดีโอจาก `_futureListVideo`

  const MyVideoWidget({
    Key? key,
    required this.videoUrl,
    required this.title, // เพิ่มพารามิเตอร์ title
    required this.model, // เพิ่มพารามิเตอร์ title
  }) : super(key: key);

  @override
  _MyVideoWidgetState createState() => _MyVideoWidgetState();
}

class _MyVideoWidgetState extends State<MyVideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {}); // รีเฟรช UI หลังจากโหลดเสร็จ
        }
      });
    _controller.setLooping(true);
    _controller.setVolume(0.0);
  }

  @override
  void dispose() {
    _controller.dispose(); // ปิด Controller เมื่อ Widget ถูกทำลาย
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoApp(model: widget.model),
            // MyApp()
          ),
        );
        // if (_controller.value.isPlaying) {
        //   _controller.pause();
        // } else {
        //   _controller.play();
        // }
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _controller.value.isInitialized
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: AspectRatio(
                    aspectRatio: 6 / 9, // กำหนดอัตราส่วนให้วิดีโอกว้างขึ้น
                    child: VideoPlayer(_controller),
                  ),
                )
              : Container(
                  width: 160,
                  height: 260,
                  color: Colors.black,
                  child: Center(child: CircularProgressIndicator()),
                ),
          Positioned(
            bottom: 0,
            left: 0, // จัดชิดซ้าย
            right: 0, // จัดชิดขวา
            child: Container(
              padding: EdgeInsets.all(4),
              // color: Colors.black
              //     .withOpacity(0.5), // เพิ่มพื้นหลังให้ข้อความอ่านง่ายขึ้น
              child: Text(
                widget.title, // แสดงชื่อวิดีโอจาก `_futureListVideo`
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4.0, // ความเบลอของเงา
                      color: Colors.black, // สีของเงา
                      offset: Offset(2, 2), // ทิศทางเงา (x, y)
                    ),
                  ],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
