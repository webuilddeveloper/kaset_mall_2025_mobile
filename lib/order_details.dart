import 'dart:async';
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_mart_v3/component/toast_fail.dart';
import 'package:mobile_mart_v3/payment_status.dart';
import 'package:mobile_mart_v3/product_from.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/widget/scroll_behavior.dart';
import 'package:url_launcher/url_launcher.dart';

import '../component/link_url_in.dart';
import '../component/loading_image_network.dart';
import '../shared/extension.dart';
import '../widget/header.dart';

class OrderDetailsPage extends StatefulWidget {
  OrderDetailsPage({Key? key, this.model, this.statusText, this.modePage})
      : super(key: key);
  final model;
  final String? statusText;
  final String? modePage;
  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String? get modePage => widget.modePage;
  bool loading = true;
  dynamic modelAboutUs;
  dynamic modelProduct = {};
  String nowDayOfWeek = '';
  String lat = '13.7910237';
  String lng = '100.600868';
  String phone = '02 538 3020';
  dynamic subDistrict;
  dynamic district;
  dynamic province;
  DateTime? now;
  int qty = 0;
  final storage = new FlutterSecureStorage();
  String profileCode = "";
  String? emailProfile;
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
    setState(() {
      modelProduct = widget.model;
      modelProduct['order_details']['data'].forEach((element) => {
            qty += ((element['quantity'] ?? 0) as num).toInt(),
          });
      modelProduct['qty'] = qty;
      readAddress();
      _callReadProfileCode();
      Timer(
        Duration(seconds: 1),
        () => {
          setState(
            () {
              loading = false;
            },
          ),
        },
      );
    });
    // _readAboutUs();

    now = DateTime.now();
    nowDayOfWeek = DateFormat('EEEE').format(now!);
    // _futureNews = postDio(newsApi + 'read', {});
    super.initState();
  }

  _callReadProfileCode() async {
    // profileCode = await storage.read(key: 'profileCode10');
    // dynamic valueStorage = await storage.read(key: 'dataUserLoginDDPM');
    // dynamic dataValue = valueStorage == null ? {'email': ''} : json.decode(valueStorage);

    setState(() {
      // emailProfile = dataValue['email'].toString() ?? "";
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  readAddress() async {
    setState(() {
      get(server + 'provinces').then((value) => {
            province = value.firstWhere(
                (x) => x['id'] == int.parse(modelProduct['province'])),
          });
      get(server + 'provinces/' + modelProduct['province'] + '/districts')
          .then((value) => {
                district = value.firstWhere(
                    (x) => x['id'] == int.parse(modelProduct['amphoe'])),
              });
      get(server +
              'provinces/' +
              modelProduct['province'] +
              '/districts/' +
              modelProduct['amphoe'] +
              '/sub-districts')
          .then((value) => {
                subDistrict = value.firstWhere(
                    (x) => x['id'] == int.parse(modelProduct['tambon'])),
              });
    });
  }

  readProduct(param) async {
    var result;
    await get(server + 'products/' + param).then((value) => {
          setState(
            () {
              result = value;
            },
          )
        });
    return result;
  }

  _addLog(param) async {
    await postObjectData(server_we_build + 'log/logGoods/create', {
      "username": emailProfile ?? "",
      "profileCode": profileCode ?? "",
      "platform": Platform.isAndroid
          ? "android"
          : Platform.isIOS
              ? "ios"
              : "other",
      "prodjctId": param['id'] ?? "",
      "title": param['name'] ?? "",
      "categoryId": param['category']['data']['id'] ?? "",
      "category": param['category']['data']['name'] ?? "",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: headerCentral(context, title: 'รายละเอียดคำสั่งซื้อ'),
      // AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   automaticallyImplyLeading: false,
      //   toolbarHeight: 10,
      // ),
      body: ScrollConfiguration(
        behavior: CsBehavior(),
        child: modePage == '0'
            ? mode0()
            : modePage == '10'
                ? mode10()
                : modePage == '20'
                    ? mode20()
                    : mode30(),
        // loading == true
        //     ? Center(
        //         child: CircularProgressIndicator(
        //         strokeWidth: 2,
        //       ))
        //     :
      ),
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

    // ignore: deprecated_member_use
    if (await canLaunch(encodedURl)) {
      // ignore: deprecated_member_use
      await launch(encodedURl);
    } else {
      throw 'Could not launch $encodedURl';
    }
  }

  mode0() {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      children: [
        Container(
          padding: const EdgeInsets.only(right: 15, left: 15, bottom: 15),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    'รายละเอียดรายการ',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        // alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xFFFBE3E6),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: Text(
                          'รอชำระเงิน',
                          style: TextStyle(
                              fontSize: 13,
                              // fontWeight: FontWeight.bold,
                              color: Color(0xFFDF0B24)),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () {
                          toPay(modelProduct['id']);
                        },
                        style: ElevatedButton.styleFrom(
                          // primary: Color.fromARGB(255, 208, 141, 147),
                          backgroundColor: Color(0xFFDF0B24),
                          // backgroundColor: Colors.teal,
                          side: BorderSide(
                              color: Color(0xFFDF0B24),
                              width: 1,
                              style: BorderStyle.solid),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                        ),
                        child: Text(
                          'ชำระเงินตอนนี้',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        child: Text(
                          'วันที่ทำรายการ',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF707070)
                                  // fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        child: Text(
                          dateTimeThai(modelProduct['ordered_at']),
                          style: TextStyle(
                            fontSize: 13,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        child: Text(
                          'TaxID',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF707070)
                                  // fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        child: Text(
                          (modelProduct['tax_identification_number'] ?? '-')
                              .toString(),
                          style: TextStyle(
                            fontSize: 13,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
        ),
        Container(
          color: Color(0xFFF7F7F7),
          child: SizedBox(height: 10),
        ),
        Container(
          color: Color(0xFFFFFFFF),
          padding:
              const EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'ที่อยู่จัดส่ง',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: Text(
                  modelProduct['name'] ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    // color: Color(0xFF707070)
                  ),
                ),
              ),
              Container(
                child: Text(
                  modelProduct['phone'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF707070),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                child: Text(
                  (modelProduct['address'] ?? '') +
                      ' ' +
                      (modelProduct['tambon'] ?? '') +
                      ' ' +
                      (modelProduct['amphoe'] ?? '') +
                      ' ' +
                      (modelProduct['province'] ?? '') +
                      ' ' +
                      (modelProduct['zip'] ?? ''),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF707070),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                child: Text(
                  'รายการสั่งซื้อ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) => _buildListProduct(
                    modelProduct['order_details']['data'][index],
                  ),
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemCount: modelProduct['order_details']['data'].length,
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Color(0xFFF7F7F7),
          child: SizedBox(height: 10),
        ),
        Container(
          color: Color(0xFFFFFFFF),
          padding:
              const EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'สรุปค่าใช้จ่าย',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'การชำระเงิน',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    // alignment: Alignment.centerRight,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFFFBE3E6),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Text(
                      'รอชำระเงิน',
                      style: TextStyle(
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                          color: Color(0xFFDF0B24)),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              for (var i = 0;
                  i < modelProduct['order_details']['data'].length;
                  i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'ยอดสินค้า ชิ้นที่ ${(i + 1).toString()}',
                        style: TextStyle(fontSize: 14, color: Color(0xFF707070)
                            // fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      child: Text(
                        '${moneyFormat(modelProduct['order_details']['data'][i]['total'].toString())} บาท',
                        style: TextStyle(
                          fontSize: 14,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'ค่าจัดส่ง',
                      style: TextStyle(fontSize: 14, color: Color(0xFF707070)
                          // fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${moneyFormat(modelProduct['shipping'].toString())} บาท',
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'ส่วนลด',
                      style: TextStyle(fontSize: 14, color: Color(0xFF707070)
                          // fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${moneyFormat((modelProduct['discount'] ?? 0).toString())} บาท',
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'ยอดรวมทั้งสิ้น',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${moneyFormat(modelProduct['total'].toString())} บาท',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  mode10() {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      children: [
        Container(
          padding: const EdgeInsets.only(right: 15, left: 15, bottom: 15),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    'รายละเอียดรายการ',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Flexible(
                    //   child: Container(
                    //     child: Text(
                    //       'หมายเลขติดตามพัสดุ',
                    //       style: TextStyle(
                    //         fontSize: 13,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   width: 10,
                    // ),
                    Flexible(
                      child: Container(
                        // alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xFFFBE3E6).withOpacity(0.5),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: Text(
                          'พัสดุจะถูกส่งมอบให้บริษัทขนส่งภายในวันที่ ${dateThai(modelProduct['shipped_at']).toString()}',
                          style: TextStyle(
                              fontSize: 13,
                              // fontWeight: FontWeight.bold,
                              color: Color(0xFFDF0B24).withOpacity(0.5)),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                modelProduct['receipt'] != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                              child: Text(
                                'ใบเสร็จ',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF707070)
                                    // fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: ElevatedButton(
                              onPressed: () {
                                modelProduct['receipt'] != null
                                    ? launchUrl(
                                        Uri.parse(modelProduct['receipt']
                                            ['data']['url']),
                                        mode: LaunchMode.inAppWebView)
                                    : null;
                              },
                              style: ElevatedButton.styleFrom(
                                // primary: Color.fromARGB(255, 208, 141, 147),
                                backgroundColor: Color(0xFF0B24FB),
                                // backgroundColor: Colors.teal,
                                side: BorderSide(
                                    color: Color(0xFF0B24FB),
                                    width: 1,
                                    style: BorderStyle.solid),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40)),
                                ),
                              ),
                              child: Text(
                                'ใบเสร็จสินค้า',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Kanit',
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
                modelProduct['receipt_shipping'] != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                              child: Text(
                                'ใบเสร็จค่าขนส่ง',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF707070)
                                    // fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: ElevatedButton(
                              onPressed: () {
                                modelProduct['receipt_shipping'] != null
                                    ? launchUrl(
                                        Uri.parse(
                                            modelProduct['receipt_shipping']
                                                ['data']['url']),
                                        mode: LaunchMode.inAppWebView)
                                    : null;
                              },
                              style: ElevatedButton.styleFrom(
                                // primary: Color.fromARGB(255, 208, 141, 147),
                                backgroundColor: Color(0xFF0B24FB),
                                // backgroundColor: Colors.teal,
                                side: BorderSide(
                                    color: Color(0xFF0B24FB),
                                    width: 1,
                                    style: BorderStyle.solid),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40)),
                                ),
                              ),
                              child: Text(
                                'ใบเสร็จค่าขนส่ง',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Kanit',
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        child: Text(
                          'วันที่สั่งซื้อ',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF707070)
                                  // fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        child: Text(
                          dateTimeThai(modelProduct['ordered_at']),
                          style: TextStyle(
                            fontSize: 13,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        child: Text(
                          'วันที่ชำระเงิน',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF707070)
                                  // fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        child: Text(
                          dateTimeThai(modelProduct['paid_at']),
                          style: TextStyle(
                            fontSize: 13,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        child: Text(
                          'TaxID',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF707070)
                                  // fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        child: Text(
                          (modelProduct['tax_identification_number'] ?? '-')
                              .toString(),
                          style: TextStyle(
                            fontSize: 13,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
        ),
        Container(
          color: Color(0xFFF7F7F7),
          child: SizedBox(height: 10),
        ),
        Container(
          color: Color(0xFFFFFFFF),
          padding:
              const EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'ที่อยู่จัดส่ง',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: Text(
                  modelProduct['name'] ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    // color: Color(0xFF707070)
                  ),
                ),
              ),
              Container(
                child: Text(
                  modelProduct['phone'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF707070),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                child: Text(
                  (modelProduct['address'] ?? '') +
                      ' ' +
                      (modelProduct['tambon'] ?? '') +
                      ' ' +
                      (modelProduct['amphoe'] ?? '') +
                      ' ' +
                      (modelProduct['province'] ?? '') +
                      ' ' +
                      (modelProduct['zip'] ?? ''),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF707070),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                child: Text(
                  'รายการสั่งซื้อ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) => _buildListProduct(
                    modelProduct['order_details']['data'][index],
                  ),
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemCount: modelProduct['order_details']['data'].length,
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Color(0xFFF7F7F7),
          child: SizedBox(height: 10),
        ),
        Container(
          color: Color(0xFFFFFFFF),
          padding:
              const EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'สรุปค่าใช้จ่าย',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'การชำระเงิน',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      'QR Payment',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0B24FB)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              for (var i = 0;
                  i < modelProduct['order_details']['data'].length;
                  i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'ยอดสินค้า ชิ้นที่ ${(i + 1).toString()}',
                        style: TextStyle(fontSize: 14, color: Color(0xFF707070)
                            // fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      child: Text(
                        '${moneyFormat(modelProduct['order_details']['data'][i]['total'].toString())} บาท',
                        style: TextStyle(
                          fontSize: 14,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'ค่าจัดส่ง',
                      style: TextStyle(fontSize: 14, color: Color(0xFF707070)
                          // fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${moneyFormat(modelProduct['shipping'].toString())} บาท',
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'ส่วนลด',
                      style: TextStyle(fontSize: 14, color: Color(0xFF707070)
                          // fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${moneyFormat((modelProduct['discount'] ?? 0).toString())} บาท',
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'ยอดรวมทั้งสิ้น',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${moneyFormat(modelProduct['total'].toString())} บาท',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  mode20() {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      children: [
        Container(
          padding: const EdgeInsets.only(right: 15, left: 15, bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'รายละเอียดรายการ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // alignment: Alignment.centerRight,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFFFBE3E6).withOpacity(0.5),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Text(
                      'ท่านจะได้รับพัสดุภายในวันที่ ${dateThai(modelProduct['destination_shipped_at']).toString()}',
                      style: TextStyle(
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                          color: Color(0xFFDF0B24).withOpacity(0.5)),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Text(
                        'ติดตามพัสดุ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () {
                              modelProduct['tracking_code'] != null
                                  ? launchInWebViewWithJavaScript(
                                      'https://ems.thaiware.com/${modelProduct['tracking_code']}')
                                  : null;
                            },
                            style: ElevatedButton.styleFrom(
                              // primary: Color.fromARGB(255, 208, 141, 147),
                              backgroundColor: Color(0xFF0B24FB),
                              // backgroundColor: Colors.teal,
                              side: BorderSide(
                                  color: Color(0xFF0B24FB),
                                  width: 1,
                                  style: BorderStyle.solid),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                              ),
                            ),
                            child: Text(
                              'ติดตามพัสดุ',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Text(
                        'หมายเลขพัสดุ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                            child: GestureDetector(
                          onTap: () async => await FlutterClipboard.copy(
                                  modelProduct['tracking_code'] ?? "")
                              .then(
                            (value) =>
                                toastFail(context, text: '✓  คัดลอกสำเร็จ'),
                          ),
                          child: Image.asset(
                            'assets/images/central/copy_clipboard.png',
                            height: 25,
                            width: 25,
                          ),
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Container(
                            child: Text(
                              modelProduct['tracking_code'] ?? "",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0B24FB)),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Text(
                        'วันที่ทำรายการ',
                        style: TextStyle(fontSize: 13, color: Color(0xFF707070)
                            // fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      child: Text(
                        dateTimeThai(modelProduct['ordered_at']),
                        style: TextStyle(
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Text(
                        'วันที่ชำระเงิน',
                        style: TextStyle(fontSize: 13, color: Color(0xFF707070)
                            // fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      child: Text(
                        dateTimeThai(modelProduct['paid_at']),
                        style: TextStyle(
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Text(
                        'TaxID',
                        style: TextStyle(fontSize: 13, color: Color(0xFF707070)
                            // fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      child: Text(
                        (modelProduct['tax_identification_number'] ?? '-')
                            .toString(),
                        style: TextStyle(
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              modelProduct['receipt'] != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            child: Text(
                              'ใบเสร็จ',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF707070)
                                  // fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () {
                              modelProduct['receipt'] != null
                                  ? launchUrl(
                                      Uri.parse(modelProduct['receipt']['data']
                                          ['url']),
                                      mode: LaunchMode.inAppWebView)
                                  : null;
                            },
                            style: ElevatedButton.styleFrom(
                              // primary: Color.fromARGB(255, 208, 141, 147),
                              backgroundColor: Color(0xFF0B24FB),
                              // backgroundColor: Colors.teal,
                              side: BorderSide(
                                  color: Color(0xFF0B24FB),
                                  width: 1,
                                  style: BorderStyle.solid),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                              ),
                            ),
                            child: Text(
                              'ใบเสร็จสินค้า',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              modelProduct['receipt_shipping'] != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            child: Text(
                              'ใบเสร็จค่าขนส่ง',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF707070)
                                  // fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () {
                              modelProduct['receipt_shipping'] != null
                                  ? launchUrl(
                                      Uri.parse(modelProduct['receipt_shipping']
                                          ['data']['url']),
                                      mode: LaunchMode.inAppWebView)
                                  : null;
                            },
                            style: ElevatedButton.styleFrom(
                              // primary: Color.fromARGB(255, 208, 141, 147),
                              backgroundColor: Color(0xFF0B24FB),
                              // backgroundColor: Colors.teal,
                              side: BorderSide(
                                  color: Color(0xFF0B24FB),
                                  width: 1,
                                  style: BorderStyle.solid),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                              ),
                            ),
                            child: Text(
                              'ใบเสร็จค่าขนส่ง',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
            ],
          ),
        ),
        Container(
          color: Color(0xFFF7F7F7),
          child: SizedBox(height: 10),
        ),
        Container(
          color: Color(0xFFFFFFFF),
          padding:
              const EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'ที่อยู่จัดส่ง',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: Text(
                  modelProduct['name'] ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    // color: Color(0xFF707070)
                  ),
                ),
              ),
              Container(
                child: Text(
                  modelProduct['phone'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF707070),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                child: Text(
                  (modelProduct['address'] ?? '') +
                      ' ' +
                      (modelProduct['tambon'] ?? '') +
                      ' ' +
                      (modelProduct['amphoe'] ?? '') +
                      ' ' +
                      (modelProduct['province'] ?? '') +
                      ' ' +
                      (modelProduct['zip'] ?? ''),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF707070),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                child: Text(
                  'รายการสั่งซื้อ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) => _buildListProduct(
                    modelProduct['order_details']['data'][index],
                  ),
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemCount: modelProduct['order_details']['data'].length,
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Color(0xFFF7F7F7),
          child: SizedBox(height: 10),
        ),
        Container(
          color: Color(0xFFFFFFFF),
          padding:
              const EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'สรุปค่าใช้จ่าย',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'การชำระเงิน',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      'QR Payment',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0B24FB)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              for (var i = 0;
                  i < modelProduct['order_details']['data'].length;
                  i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'ยอดสินค้า ชิ้นที่ ${(i + 1).toString()}',
                        style: TextStyle(fontSize: 14, color: Color(0xFF707070)
                            // fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      child: Text(
                        '${moneyFormat(modelProduct['order_details']['data'][i]['total'].toString())} บาท',
                        style: TextStyle(
                          fontSize: 14,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'ค่าจัดส่ง',
                      style: TextStyle(fontSize: 14, color: Color(0xFF707070)
                          // fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${moneyFormat(modelProduct['shipping'].toString())} บาท',
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'ส่วนลด',
                      style: TextStyle(fontSize: 14, color: Color(0xFF707070)
                          // fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${moneyFormat((modelProduct['discount'] ?? 0).toString())} บาท',
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'ยอดรวมทั้งสิ้น',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${moneyFormat(modelProduct['total'].toString())} บาท',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  mode30() {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg_order_details.png"),
              fit: BoxFit.fitWidth,
            ),
          ),
          // margin: const EdgeInsets.only(top: 15),
          padding:
              const EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 15),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    'จัดส่งสำเร็จ',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0B24FB)),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  child: Text(
                    'ขอบคุณที่ไว้วางใจที่ซื้อสินค้ากับเรา \nเราจะรอท่านกลับมาอีกครั้ง',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                //           Material(
                // // elevation: 5.0,
                // // borderRadius: BorderRadius.circular(30.0),
                // shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(22.0) ),
                // color: Color(0XFFE00923),
                // child:
                //           MaterialButton(
                //             color: Color(0XFFE00923),
                //             // shape:
                //   minWidth: MediaQuery.of(context).size.width,
                //   // height: 40,
                //   onPressed: () {
                //     // loginWithGuest();
                //   },
                //   child: new Text(
                //     'ซื้ออีกครั้ง',
                //     style: new TextStyle(
                //       fontSize: 18.0,
                //       color: Color(0xFFDF0B24),
                //       fontWeight: FontWeight.normal,
                //       fontFamily: 'Kanit',
                //     ),
                //   ),
                // ),
                //           )

                // Center(
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                //     decoration: BoxDecoration(
                //       border: Border.all(width: 1, color: Color(0xFFDF0B24),style: BorderStyle.solid),
                //       borderRadius: BorderRadius.all(Radius.circular(50))
                //     ),
                //     child: Text(
                //       'ซื้ออีกครั้ง',
                //       style: TextStyle(
                //         fontSize: 15,
                //         fontWeight: FontWeight.w400,
                //         color: Color(0xFFDF0B24)
                //       ),
                //     ),
                //   ),
                // ),
              ]),
        ),
        Container(
          color: Color(0xFFF7F7F7),
          child: SizedBox(height: 10),
        ),
        Container(
          padding: const EdgeInsets.only(right: 15, left: 15, bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'รายละเอียดรายการ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Text(
                        'หมายเลขติดตามพัสดุ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: 10,
                  // ),
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                            child: GestureDetector(
                          onTap: () async => await FlutterClipboard.copy(
                                  modelProduct['tracking_code'] ?? "")
                              .then(
                            (value) =>
                                toastFail(context, text: '✓  คัดลอกสำเร็จ'),
                          ),
                          child: Image.asset(
                            'assets/images/central/copy_clipboard.png',
                            height: 25,
                            width: 25,
                          ),
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Container(
                            child: Text(
                              modelProduct['tracking_code'] ?? "",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0B24FB)),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Text(
                        'วันที่ทำรายการ',
                        style: TextStyle(fontSize: 13, color: Color(0xFF707070)
                            // fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      child: Text(
                        dateTimeThai(modelProduct['ordered_at']),
                        style: TextStyle(
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Text(
                        'วันที่ชำระเงิน',
                        style: TextStyle(fontSize: 13, color: Color(0xFF707070)
                            // fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      child: Text(
                        dateTimeThai(modelProduct['paid_at']),
                        style: TextStyle(
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Text(
                        'TaxID',
                        style: TextStyle(fontSize: 13, color: Color(0xFF707070)
                            // fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      child: Text(
                        (modelProduct['tax_identification_number'] ?? '-')
                            .toString(),
                        style: TextStyle(
                          fontSize: 13,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              modelProduct['receipt'] != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            child: Text(
                              'ใบเสร็จ',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF707070)
                                  // fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () {
                              modelProduct['receipt'] != null
                                  ? launchUrl(
                                      Uri.parse(modelProduct['receipt']['data']
                                          ['url']),
                                      mode: LaunchMode.inAppWebView)
                                  : null;
                            },
                            style: ElevatedButton.styleFrom(
                              // primary: Color.fromARGB(255, 208, 141, 147),
                              backgroundColor: Color(0xFF0B24FB),
                              // backgroundColor: Colors.teal,
                              side: BorderSide(
                                  color: Color(0xFF0B24FB),
                                  width: 1,
                                  style: BorderStyle.solid),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                              ),
                            ),
                            child: Text(
                              'ใบเสร็จสินค้า',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              modelProduct['receipt_shipping'] != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            child: Text(
                              'ใบเสร็จค่าขนส่ง',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF707070)
                                  // fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () {
                              modelProduct['receipt_shipping'] != null
                                  ? launchUrl(
                                      Uri.parse(modelProduct['receipt_shipping']
                                          ['data']['url']),
                                      mode: LaunchMode.inAppWebView)
                                  : null;
                            },
                            style: ElevatedButton.styleFrom(
                              // primary: Color.fromARGB(255, 208, 141, 147),
                              backgroundColor: Color(0xFF0B24FB),
                              // backgroundColor: Colors.teal,
                              side: BorderSide(
                                  color: Color(0xFF0B24FB),
                                  width: 1,
                                  style: BorderStyle.solid),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                              ),
                            ),
                            child: Text(
                              'ใบเสร็จค่าขนส่ง',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
            ],
          ),
        ),
        Container(
          color: Color(0xFFF7F7F7),
          child: SizedBox(height: 10),
        ),
        Container(
          color: Color(0xFFFFFFFF),
          padding:
              const EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'ที่อยู่จัดส่ง',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: Text(
                  modelProduct['name'] ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    // color: Color(0xFF707070)
                  ),
                ),
              ),
              Container(
                child: Text(
                  modelProduct['phone'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF707070),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                child: Text(
                  (modelProduct['address'] ?? '') +
                      ' ' +
                      (modelProduct['tambon'] ?? '') +
                      ' ' +
                      (modelProduct['amphoe'] ?? '') +
                      ' ' +
                      (modelProduct['province'] ?? '') +
                      ' ' +
                      (modelProduct['zip'] ?? ''),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF707070),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                child: Text(
                  'รายการสั่งซื้อ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) => _buildListProduct(
                    modelProduct['order_details']['data'][index],
                  ),
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemCount: modelProduct['order_details']['data'].length,
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Color(0xFFF7F7F7),
          child: SizedBox(height: 10),
        ),
        Container(
          color: Color(0xFFFFFFFF),
          padding:
              const EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'สรุปค่าใช้จ่าย',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'การชำระเงิน',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      'QR Payment',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0B24FB)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              for (var i = 0;
                  i < modelProduct['order_details']['data'].length;
                  i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'ยอดสินค้า ชิ้นที่ ${(i + 1).toString()}',
                        style: TextStyle(fontSize: 14, color: Color(0xFF707070)
                            // fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      child: Text(
                        '${moneyFormat(modelProduct['order_details']['data'][i]['total'].toString())} บาท',
                        style: TextStyle(
                          fontSize: 14,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'ค่าจัดส่ง',
                      style: TextStyle(fontSize: 14, color: Color(0xFF707070)
                          // fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${moneyFormat(modelProduct['shipping'].toString())} บาท',
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'ส่วนลด',
                      style: TextStyle(fontSize: 14, color: Color(0xFF707070)
                          // fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${moneyFormat((modelProduct['discount'] ?? 0).toString())} บาท',
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'ยอดรวมทั้งสิ้น',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '${moneyFormat(modelProduct['total'].toString())} บาท',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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

  _buildListProduct(param) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            // var models = {};
            // models['product']['data'] = param['product']['data'];
            // models['product_variant']['data'] = param['product_variant']['data'];
            // models['media']['data'] = param['media']['data'];

            var productModel =
                await readProduct(param['product']['data']['id']);
            await _addLog(productModel);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductFormCentralPage(
                  model: productModel,
                ),
              ),
            );
          },
          child: Container(
            // padding: EdgeInsets.only(top: 10, bottom: 5),
            child: Row(
              children: [
                // InkWell(
                //   onTap: () {
                //     // _getProductById(param['product']['data']['id']);
                //     // Navigator.pop(context);
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => OrderDetailsPage(
                //           model: param,
                //         ),
                //       ),
                //     );
                //   },
                //   child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: loadingImageNetwork(
                    param['media']['data']['url'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                // ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        // height: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              param['product']['data']['name'],
                              style: TextStyle(
                                fontSize: 13,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${moneyFormat(param['product_variant']['data']['price'].toString())} บาท',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Text(
                              'จำนวน ' + param['quantity'].toString(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [

        //   ],
        // ),
        SizedBox(height: 10),
      ],
    );
  }

  toPay(order_id) {
    dynamic modelData = {
      'payment_type': '3',
      // 'order_id': 'order_BYW95EGWJDN6VK'
      'order_id': order_id
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentStatusCentralPage(model: modelData),
      ),
    );
  }
}
