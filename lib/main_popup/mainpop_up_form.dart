import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class MainPopup extends StatefulWidget {
  MainPopup({Key? key, this.model, this.nav}) : super(key: key);

  final Future<dynamic>? model;
  final Function(String, String, dynamic, String, String)? nav;

  @override
  _MainPopup createState() => _MainPopup();
}

class _MainPopup extends State<MainPopup> {
  final txtDescription = TextEditingController();
  int _current = 0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  final List<String> imgList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>
        // double sideLength = 50;
        // final double height = MediaQuery.of(context).size.height;
        if (snapshot.hasData) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  widget.nav!(
                    snapshot.data[_current]['linkUrl'],
                    snapshot.data[_current]['action'],
                    snapshot.data[_current],
                    snapshot.data[_current]['code'],
                    '',
                  );
                },
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: height * 0.4,
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
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              '${document['imageUrl']}',
                              fit: BoxFit.contain,
                              height: 480,
                              width: 360,
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: snapshot.data.map<Widget>((url) {
              //     int index = snapshot.data.indexOf(url);
              //     return Container(
              //         width: _current == index ? 20.0 : 5.0,
              //         height: 5.0,
              //         margin: _current == index
              //             ? EdgeInsets.symmetric(vertical: 5.0, horizontal: 1.0)
              //             : EdgeInsets.symmetric(
              //             vertical: 5.0, horizontal: 2.0),
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(5),
              //           // shape: BoxShape.circle,
              //           color: _current == index
              //               ? Color(0xFF09665a)
              //               : Color.fromRGBO(0, 0, 0, 0.4),
              //         ));
              //   }).toList(),
              // ),
            ],
          );
        } else {
          return Container(height: (height * 22.5) / 100);
        }
      },
    );
  }
}
