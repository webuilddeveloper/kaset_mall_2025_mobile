import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasetmall/commercial_organization_search.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/widget/scroll_behavior.dart';
import 'package:kasetmall/widget/text_header.dart';
import 'package:url_launcher/url_launcher.dart';
import '../component/link_url_in.dart';
import 'cart.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart'
    as google_maps_marker;

class CommercialOrganizationPage extends StatefulWidget {
  const CommercialOrganizationPage({
    Key? key,
    this.commercialOrganization = '0',
  }) : super(key: key);
  final String commercialOrganization;

  @override
  State<CommercialOrganizationPage> createState() =>
      _CommercialOrganizationPageState();
}

class _CommercialOrganizationPageState
    extends State<CommercialOrganizationPage> {
  Completer<GoogleMapController> _mapController = Completer();
  late Future<dynamic> _futureBranch;
  String nowDayOfWeek = '';
  String lat = '13.7910237';
  String lng = '100.600868';
  late DateTime now;
  dynamic model = [
    {
      'title':
          'กลับมาอีกครั้ง งานสัปดาห์หนังสือแห่งชาติ ปี 2565 วันที่ 26 มี.ค. - 6',
      'imageUrl': 'assets/images/bg-news.jpeg',
    },
    {
      'title':
          'กลับมาอีกครั้ง งานสัปดาห์หนังสือแห่งชาติ ปี 2565 วันที่ 26 มี.ค. - 6',
      'imageUrl': 'assets/images/bg-news.jpeg',
    },
    {
      'title':
          'กลับมาอีกครั้ง งานสัปดาห์หนังสือแห่งชาติ ปี 2565 วันที่ 26 มี.ค. - 6',
      'imageUrl': 'assets/images/bg-news.jpeg',
    }
  ];

  @override
  void initState() {
    _readBranch();
    now = DateTime.now();
    nowDayOfWeek = DateFormat('EEEE').format(now);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _readBranch() async {
    _futureBranch = postDio(server_we_build + 'branch/read',
        {'code': widget.commercialOrganization});
  }

  Widget googleMap(double lat, double lng) {
    print('---123------$lat --------------456------$lng');
    return GoogleMap(
      myLocationEnabled: true,
      compassEnabled: true,
      tiltGesturesEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 16,
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      // onTap: _handleTap,
      markers: <google_maps_marker.Marker>[
        google_maps_marker.Marker(
          markerId: MarkerId('1'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      ].toSet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Color(0x80F7F7F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 10,
      ),
      body: ScrollConfiguration(
        behavior: CsBehavior(),
        child: FutureBuilder<dynamic>(
          future: _futureBranch, // function where you call your api
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Container(
                  alignment: Alignment.center,
                  height: 200,
                  child: Text(
                    'ไม่พบข้อมูล',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Kanit',
                      color: Color.fromRGBO(0, 0, 0, 0.6),
                    ),
                  ),
                );
              } else {
                return content(snapshot.data[0]);
              }
            } else if (snapshot.hasError) {
              return Container(
                alignment: Alignment.center,
                height: 200,
                width: double.infinity,
                child: Text(
                  'Network ขัดข้อง',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Kanit',
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                  ),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  content(model) {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      children: [
        column1(model),
        SizedBox(height: 20),
        // column2(model),
        // SizedBox(height: 20),
        // news(model),
      ],
    );
  }

  void launchURLMap(String lat, String lng) async {
    String homeLat = lat;
    String homeLng = lng;

    final String googleMapslocationUrl =
        "https://www.google.com/maps/search/?api=1&query=" +
            homeLat +
            ',' +
            homeLng;

    final String encodedURl = Uri.encodeFull(googleMapslocationUrl);

    await launchInWebViewWithJavaScript(encodedURl);
  }

  column1(dynamic model) {
    print(
        'latitude ============ ${double.tryParse(model['latitude'].toString())}');
    // print('longitude ============ ${double.parse(model['longitude']).runtimeType}');
    // model['latitude'].toString() ?? lat,
    // model['longitude'].toString() ?? lng,
    return Container(
      color: Color(0xFFFFFFFF),
      // padding: const EdgeInsets.only(right: 15, left: 15, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.only(right: 15, left: 15, top: 20, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ร้านค้า',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  child: Container(
                    // height: 195,
                    height: (MediaQuery.of(context).size.width) / 2,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: model['imageUrl'] != null
                            ? NetworkImage(model['imageUrl'])
                            : AssetImage(
                                'assets/images/bg0011.jpeg',
                              ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CommercialOrganizationSearchPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 25,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      border: Border.all(
                                        color: Color(0xFF939FF9),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/search.png',
                                          height: 15,
                                          width: 15,
                                          color: Color(0xFF0B24FB)
                                              .withOpacity(0.6),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'ค้นหา สาขา',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF0B24FB),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.start,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Row(
                          //   children: [
                          //     Container(
                          //       height: 10,
                          //       width: 10,
                          //       decoration: BoxDecoration(
                          //         color: Color(0xFFFFFFFF),
                          //         borderRadius: BorderRadius.circular(100),
                          //       ),
                          //     ),
                          //     SizedBox(width: 5),
                          //     Text(
                          //       'เปิดถึง 16:00',
                          //       style: TextStyle(
                          //         fontSize: 11,
                          //         color: Color(0xFFFFFFFF),
                          //       ),
                          //       textScaleFactor: ScaleSize.textScaleFactor(context),
                          //     )
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  model['title'] ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  textScaleFactor: ScaleSize.textScaleFactor(context),
                ),
                Text(
                  model['address'] ?? '',
                  style: TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 13,
                    // fontWeight: FontWeight.bold,
                  ),
                  textScaleFactor: ScaleSize.textScaleFactor(context),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'เบอร์ติดต่อ',
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      textScaleFactor: ScaleSize.textScaleFactor(context),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        model['phone'] ?? '',
                        style: TextStyle(
                          color: Color(0xFF707070),
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => launchURLMap(
                        model['latitude'].toString() ?? lat,
                        model['longitude'].toString() ?? lng,
                      ),
                      child: Image.asset(
                        'assets/images/map.png',
                        height: 35,
                        width: 35,
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        final Uri launchUri = Uri(
                          scheme: 'tel',
                          path: model['phone'],
                        );
                        launchUrl(launchUri);
                      },
                      child: Image.asset(
                        'assets/images/phoneButton.png',
                        height: 35,
                        width: 35,
                      ),
                    ),
                    SizedBox(width: 10),
                    model['line'] == null
                        ? SizedBox()
                        : model['line'] == ' '
                            ? SizedBox()
                            : InkWell(
                                onTap: () {
                                  final Uri launchUri = Uri(
                                    scheme: 'https',
                                    path: model['line'],
                                  );
                                  launchUrl(launchUri);
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                        color: Color(0xFFf9faff),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                      'LINE',
                                      style: TextStyle(
                                          color: Color(0xFF0b24fb),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                    ))),

                    // SizedBox(width: 10),
                    // InkWell(
                    //   onTap: () => launch(model['facebook']),
                    //   child: Image.asset(
                    //     'assets/images/facebook.png',
                    //     height: 35,
                    //     width: 35,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(
            height: 15,
            child: Container(
              color: Color(0xFFF7F7F7),
            ),
          ),
          Container(
            // padding: const EdgeInsets.only(
            //   right: 10,
            //   left: 10,
            // ),
            padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
            child: Html(
              data: model['description'] ?? "",
              onLinkTap: (url, attributes, element) {
                launch(url ?? "");
              },
              // onLinkTap: (Strng url, RenderContext context,
              //     Map<String, String> attributes, element) {
              //   launch(url);
              //   // open url in a webview
              // },
            ),
          ),
          // model['phoneAdd'].length > 0
          //     ? Text(
          //         'เบอร์ติดต่อแต่ละแผนก',
          //         style: TextStyle(
          //           fontSize: 13,
          //           fontWeight: FontWeight.w400,
          //         ),
          //       )
          //     : Container(),
          // model['phoneAdd'].length > 0
          //     ? Container(
          //         child: ListView.builder(
          //           padding: EdgeInsets.zero,
          //           shrinkWrap: true,
          //           physics: ClampingScrollPhysics(),
          //           itemCount: model['phoneAdd'].length,
          //           itemBuilder: (context, index) {
          //             return Text(
          //               model['phoneAdd'][index],
          //               style: TextStyle(
          //                 color: Color(0xFF707070),
          //                 fontSize: 13,
          //                 fontWeight: FontWeight.w300,
          //               ),
          //             );
          //           },
          //         ),
          //       )
          //     : Container(),
          SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(right: 15, left: 15, top: 20),
            height: MediaQuery.of(context).size.height * 0.5,
            child: googleMap(
              // model['latitude'] ?? double.parse(lat),
              // model['longitude'] ?? double.parse(lng),
              double.tryParse(model['latitude'].toString()) ??
                  double.tryParse(lat)!,
              double.tryParse(model['longitude'].toString()) ??
                  double.tryParse(lng)!,
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            color: Colors.transparent,
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Color(0xFFA9151D),
                  ),
                ),
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  onPressed: () {
                    launchURLMap(lat.toString(), lng.toString());
                  },
                  child: Text(
                    'ตำแหน่ง Google Map',
                    style: TextStyle(
                      color: Color(0xFFA9151D),
                      fontFamily: 'Kanit',
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  column2(dynamic model) {
    return Container(
      color: Color(0xFFFFFFFF),
      padding: const EdgeInsets.only(right: 15, left: 15, top: 5, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'เวลาทำการ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 20),
              Text(
                '${model['businessDay']}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF707070),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                'ปิดทำการ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 20),
              Text(
                '${model['closed']}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF707070),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  rowBusinessHours(String day, String time) {
    Color color = day == nowDayOfWeek ? Color(0xFF0B24FB) : Color(0xFF707070);
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: day == nowDayOfWeek ? Color(0xFF0B24FB) : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        SizedBox(width: 5),
        Container(
          width: 80,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 13,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: Text(
            time,
            style: TextStyle(
              fontSize: 13,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  news(model) {
    return Container(
      // padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(15),
        color: Color(0xFFFFFFFF),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: textHeader(context, title: 'โปรโมชัน', fontSize: 17),
          ),
          SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 200,
            width: double.infinity,
            child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(width: 10),
                shrinkWrap: true, // 1st add
                physics: ClampingScrollPhysics(), // 2nd
                itemCount: model.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => LawyerNewsForm(
                      //       model: model[index],
                      //       code: model[index]['code'],
                      //     ),
                      //   ),
                      // );
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 80,
                          width: 160,
                          decoration: BoxDecoration(
                            color: Color(0xFF707070),
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: AssetImage(model[index]['imageUrl']),
                              // image: NetworkImage(model[index]['imageUrl']),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Container(
                          width: 160,
                          child: Text(
                            model[index]['title'],
                            maxLines: 2,
                            style: TextStyle(
                              color: Color(0xFF707070),
                              fontSize: 13,
                              overflow: TextOverflow.ellipsis,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  //
}
