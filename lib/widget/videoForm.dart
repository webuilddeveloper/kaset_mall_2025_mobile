import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_mart_v3/cart.dart';
import 'package:mobile_mart_v3/product_from.dart';
import 'package:mobile_mart_v3/widget/search_result.dart';
import 'package:toast/toast.dart';
import 'package:video_player/video_player.dart';

import '../shared/api_provider.dart';

/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  const VideoApp({Key? key, this.model});

  final dynamic model;

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  String videoStatus = '0';

  @override
  void initState() {
    super.initState();
    // _controller = VideoPlayerController.network('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
    _controller = VideoPlayerController.network(widget.model['videoUrl'])
      ..initialize().then((con) {
        setState(() {
          // _controller.value.isInitialized ? _controller.play() : null;
          if (_controller.value.isInitialized) {
            _controller.play();
            videoStatus = '1';
            _buildAddView();
          }
          // _controller.
        });
      });

    _controller.addListener(() {
      setState(() {
        if (_controller.value.position == _controller.value.duration) {
          videoStatus = '0';
          print("Video has finished playing!");
        }
      });
    });

    // setState(() {
    //     _controller.play();
    //     // _controller.
    // });
    // print('----------- ${_controller.value}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _buildAddView() {
    postDio(server_we_build + 'videoShort/addView', {
      'code': widget.model['code'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Demo',
      home: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          // backgroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          toolbarHeight: AdaptiveTextSize().getadaptiveTextSize(context, 50),
          flexibleSpace: Container(
            color: Colors.transparent,
            child: Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 20),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(
                      () {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                          videoStatus = '0';
                        } else {
                          _controller.play();
                          videoStatus = '1';
                        }
                      },
                    );
                  },
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    setState(
                      () {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                          videoStatus = '0';
                        } else {
                          _controller.play();
                          videoStatus = '1';
                        }
                      },
                    );
                  },
                  child: videoStatus == '1'
                      ? null
                      : Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade500.withOpacity(0.3),
                              shape: BoxShape.circle),
                          child: Icon(
                            Icons.play_arrow,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            Positioned.fill(
              // bottom: 200,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  // color: Colors.amber,
                  padding: EdgeInsets.only(left: 10, right: 16),
                  height: MediaQuery.of(context).padding.bottom + 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => _getData(widget.model['productId']),
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_mall,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '|',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.0,
                                        fontFamily: 'Kanit',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        widget.model['title'] ?? '',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.0,
                                          fontFamily: 'Kanit',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Wrap(
                              spacing: 3,
                              children: [
                                for (var i = 0;
                                    i < widget.model['hashTag'].length;
                                    i++)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SearchResultPage(
                                            search: widget.model['hashTag'][i],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '#${widget.model['hashTag'][i]}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.0,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.bold),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 26,
                      ),
                      // Column(
                      //   children: [
                      //     buttonActionVideo(icon: Icons.favorite, title: '0'),
                      //     SizedBox(
                      //       height: 30,
                      //     ),
                      //     buttonActionVideo(icon: Icons.chat, title: '0'),
                      //     SizedBox(
                      //       height: 30,
                      //     ),
                      //     buttonActionVideo(icon: Icons.share, title: 'แชร์'),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonActionVideo({
    String? title,
    IconData? icon,
    Color? colorIcon,
    ControllerCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: 30,
            color: Colors.white,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            title!,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.0,
              fontFamily: 'Kanit',
            ),
          ),
        ],
      ),
    );
  }

  _buildLike() {}

  _getData(productId) async {
    setState(
      () {
        getData(server + 'products/$productId').then(
          (value) async => {
             setState(
              () {
                if (value != null) {
                  _controller.pause();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductFormCentralPage(
                        model: value,
                      ),
                    ),
                  ).then((value) => {_controller.play()});
                } else {
                  Toast.show('ขออภัย ไม่พบสินค้า',
                      backgroundColor: Colors.black.withOpacity(0.3),
                      duration: 3,
                      gravity: Toast.center,
                      textStyle: TextStyle(color: Colors.white));
                }
              },
            ),
          },
        );
      },
    );
  }
}
