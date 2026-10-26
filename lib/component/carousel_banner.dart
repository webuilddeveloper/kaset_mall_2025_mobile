import 'package:carousel_slider/carousel_slider.dart';
import 'dart:ui';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:kasetmall/banner_detail_page.dart';
import 'package:kasetmall/component/carousel_form.dart';
import 'package:kasetmall/component/link_url_in.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/component/material/loading_tween.dart';
import 'package:kasetmall/exercise_main.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/shared/login_guard.dart';

class CarouselBanner extends StatefulWidget {
  CarouselBanner({Key? key, this.model, this.url, this.height = 70})
      : super(key: key);

  final dynamic model;
  final String? url;
  final double height;

  @override
  _CarouselBanner createState() => _CarouselBanner();
}

class _CarouselBanner extends State<CarouselBanner>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<CarouselBanner> {
  final storage = new FlutterSecureStorage();
  final txtDescription = TextEditingController();
  int _current = 0;
  String profileCode = "";
  String userProfileCode = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  final List<String> imgList = [];

  @override
  void initState() {
    _getprofileCode();
    _getUserData();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  _getprofileCode() async {
    profileCode = (await storage.read(key: 'profileCode10')) ?? '';
  }

  _getUserData() async {
    var _token = await storage.read(key: 'token');

    setState(() {
      userProfileCode = _token ?? '';
    });
  }

  Future<List<String>> _readGallery(dynamic code) async {
    try {
      final result = await postObjectData(bannerGalleryApi, {'code': code});
      if (result['status'] != 'S') return [];
      return (result['objectData'] as List)
          .map((e) => (e['imageUrl'] ?? '').toString())
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _onTapBanner(Map<String, dynamic> item) async {
    if (item['isChkLogin'] == true) {
      final allowed = await requireLogin(
        context,
        title: 'เข้าสู่ระบบ',
        description: 'ต้องเข้าสู่ระบบก่อนเพื่อดูเนื้อหานี้',
      );
      if (!allowed || !mounted) return;
      await _getprofileCode();
      await _getUserData();
    }

    final action = item['action'];
    final linkUrl = (item['linkUrl'] ?? '').toString();

    if (action == 'out' && linkUrl.isNotEmpty) {
      final linkSplit = linkUrl.split('/');
      if (linkSplit[0] == '') {
        if (linkSplit.length > 1 && linkSplit[1] == 'exercise') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseMain(coverImg: item['imageUrl']),
            ),
          );
        }
      } else if (item['isPostHeader'] == true) {
        if (profileCode != '') {
          var path = linkUrl;
          if (!path.endsWith('/')) path = path + '/';
          final codeReplace = 'B' +
              profileCode.replaceAll('-', '') +
              item['code'].toString().replaceAll('-', '');
          launchInWebViewWithJavaScript('$path$codeReplace');
        }
      } else {
        launchInWebViewWithJavaScript(linkUrl);
      }
    } else if (action == 'in') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CarouselForm(
            code: item['code'],
            model: item,
            url: 'm/Banner/' + (widget.url ?? ''),
            urlGallery: 'm/Banner/' + (widget.url ?? ''),
          ),
        ),
      );
    } else {
      final gallery = await _readGallery(item['code']);
      if (!mounted) return;
      final hasDescription =
          (item['description'] ?? '').toString().trim().isNotEmpty;
      if (hasDescription || gallery.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BannerDetailPage(model: item, gallery: gallery),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<dynamic>(
      future: widget.model,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Carousel ส่วนรูป
                InkWell(
                  onTap: () => _onTapBanner(snapshot.data[_current]),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: widget.height,
                      aspectRatio: 16 / 9,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      autoPlay: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                    items: snapshot.data.map<Widget>((document) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            loadingImageNetwork(
                              document['imageUrl'],
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                            ),
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                              child: Container(
                                color: Colors.white.withValues(alpha: 0.28),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                child: loadingImageNetwork(
                                  document['imageUrl'],
                                  fit: BoxFit.contain,
                                  height: double.infinity,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10), // เว้นระยะห่างเล็กน้อย

                // 🔹 แถบ AnimatedContainer ที่อยู่ข้างล่างสุด
                Container(
                  width: 100,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Colors.grey.shade300),
                  ),
                  child: AnimatedContainer(
                    margin: EdgeInsets.only(
                      left: ((100 / snapshot.data.length) * (_current))
                          .toDouble(),
                    ),
                    duration: Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                    child: Container(
                      width: (100 / snapshot.data.length) -
                          ((snapshot.data.length / 3)),
                      height: 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xFF09665a),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Container(height: 150);
          }
        } else {
          return LoadingTween(height: 150);
        }
      },
    );
  }
}

class Carousel2 extends StatefulWidget {
  Carousel2({Key? key, this.model, this.url}) : super(key: key);

  final Future<dynamic>? model;
  final String? url;

  @override
  _Carousel2 createState() => _Carousel2();
}

class _Carousel2 extends State<Carousel2> {
  final txtDescription = TextEditingController();
  int _current = 0;
  final storage = new FlutterSecureStorage();
  String profileCode = "";

  @override
  void dispose() {
    txtDescription.dispose();
    super.dispose();
  }

  final List<String> imgList = [];

  @override
  void initState() {
    _getprofileCode();
    super.initState();
  }

  _getprofileCode() async {
    profileCode = (await storage.read(key: 'profileCode10'))!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                InkWell(
                  onTap: () {
                    if (snapshot.data[_current]['action'] == 'out') {
                      if (snapshot.data[_current]['isPostHeader']) {
                        if (profileCode != '') {
                          var path = snapshot.data[_current]['linkUrl'];
                          var code = snapshot.data[_current]['code'];
                          var splitCheck = path.split('').reversed.join();
                          if (splitCheck[0] != "/") {
                            path = path + "/";
                          }
                          var codeReplae = "B" +
                              profileCode.replaceAll('-', '') +
                              code.replaceAll('-', '');
                          launchInWebViewWithJavaScript('$path$codeReplae');
                        }
                      } else
                        launchInWebViewWithJavaScript(
                            snapshot.data[_current]['linkUrl']);
                    } else if (snapshot.data[_current]['action'] == 'in') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarouselForm(
                            code: snapshot.data[_current]['code'],
                            model: snapshot.data[_current],
                            url: widget.url,
                            urlGallery: widget.url,
                          ),
                        ),
                      );
                    }
                  },
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 120,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      autoPlay: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                    items: snapshot.data.map<Widget>(
                      (document) {
                        return new Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: loadingImageNetwork(
                                  document['imageUrl'],
                                  fit: BoxFit.fill,
                                  height: 150,
                                  width: double.infinity,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: snapshot.data.map<Widget>((url) {
                    int index = snapshot.data.indexOf(url);
                    return Container(
                      width: _current == index ? 7.5 : 7.5,
                      height: 7.5,
                      margin: _current == index
                          ? EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 1.0,
                            )
                          : EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 2.0,
                            ),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Color(0xFFE84C12)),
                        borderRadius: BorderRadius.circular(5),
                        color: _current == index
                            ? Color(0xFFE84C12)
                            : Colors.transparent,
                      ),
                    );
                  }).toList(),
                )
              ],
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }
}
