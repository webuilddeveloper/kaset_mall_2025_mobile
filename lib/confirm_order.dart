import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_mart_v3/component/loading_image_network.dart';
import 'package:mobile_mart_v3/component/toast_fail.dart';
import 'package:mobile_mart_v3/coupons_pickup.dart';
import 'package:mobile_mart_v3/delivery_address.dart';
import 'package:mobile_mart_v3/my_credit_card.dart';
import 'package:mobile_mart_v3/payment_status.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/shared/extension.dart';
import 'package:mobile_mart_v3/widget/show_loading.dart';
import 'package:mobile_mart_v3/widget/stack_tap.dart';
import 'package:toast/toast.dart';

import 'cart.dart';

class ConfirmOrderCentralPage extends StatefulWidget {
  ConfirmOrderCentralPage({Key? key, this.modelCode, this.type})
      : super(key: key);
  final List<dynamic>? modelCode;
  final String? type;

  @override
  State<ConfirmOrderCentralPage> createState() =>
      _ConfirmOrderCentralPageState();
}

class _ConfirmOrderCentralPageState extends State<ConfirmOrderCentralPage> {
  final storage = new FlutterSecureStorage();
  late List<dynamic> modelCode;
  late String type;
  var model = [];
  String imageMock =
      'https://amarinbooks.com/wp-content/uploads/2020/11/%E0%B8%84%E0%B8%A7%E0%B8%B2%E0%B8%A1%E0%B8%A5%E0%B8%B1%E0%B8%9A%E0%B8%84%E0%B8%99%E0%B8%AD%E0%B8%B2%E0%B8%99%E0%B8%AA%E0%B8%B7%E0%B8%AD.png';
  bool buyAll = false;
  int totalPrice = 0;
  int total = 0;
  int deliveryPrice = 0;
  String creditCardCode = '3';
  String deliveryCode = '';
  String couponsCode = '';
  bool loading = false;
  String urlCartId = '';
  bool loadingSuccess = false;
  int discountAll = 0;
  // int promoAll = 0;
  dynamic couponModel;
  final FocusNode branchFocus = FocusNode();
  final FocusNode numberFocus = FocusNode();
  TextEditingController txtInvoiceBranch = TextEditingController();
  TextEditingController txtInvoiceNumber = TextEditingController();
  bool isInvoice = false;
  bool isInvoiceAddress = false;
  String nameInvoice = '';
  String phoneInvoice = '';
  dynamic addressInvoice = {
    'code': '',
    'address': '',
    'province': '',
    'district': '',
    'subDistrict': '',
    'postalCode': ''
  };

  String name = '';
  String phone = '';
  var cares_id = [];
  dynamic address = {
    'code': '',
    'address': '',
    'province': '',
    'district': '',
    'subDistrict': '',
    'postalCode': ''
  };
  bool hasAddress = false;
  bool loadingAddress = true;
  bool checkOrder = false;
  Future<dynamic>? _futureCoupons;
  List<dynamic> _futurePayments = [
    // {'id': '1', 'title': 'ชำระเงินปลายทาง'},
    // {'id': '2', 'title': 'บัตรเครดิต/เดบิต'},
    {'id': '3', 'title': 'ชำระเงินด้วย QR Code'}
  ];
  bool showOfficeTaxInvoice = false;
  TextEditingController couponController = TextEditingController();
  late String couponMessage = "";
  List<dynamic> cartId = [];

  @override
  initState() {
    setState(() {
      modelCode = widget.modelCode!;
      type = widget.type!;
    });
    print('===----==== $modelCode');
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    branchFocus.dispose();
    numberFocus.dispose();
    super.dispose();
  }

  _callRead() async {
    await _callAddress();
    _callCarts();
  }

  _callAddress() async {
    try {
      final value = await get(server + 'shipping-addresses');

      if (value == null || value.isEmpty) {
        print("No shipping addresses found.");
        return;
      }

      List<dynamic> arr = List.from(value); // ป้องกัน arr เป็น null
      var a = arr
          .where((x) => x['main'] == true)
          .toList()
          .firstOrNull; // ใช้ firstOrNull เพื่อลด error

      if (a != null) {
        setState(() {
          name = a['name'];
          phone = a['phone'];
          address = {
            'code': a['id'],
            'address': a['address'],
            'subDistrict': a['tambon']?['data']?['name_th'] ?? '',
            'district': a['amphoe']?['data']?['name_th'] ?? '',
            'province': a['province']?['data']?['name_th'] ?? '',
            'postalCode': a['zip'] ?? '',
          };
          hasAddress = true;
        });
      } else {
        print("No main address found.");
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  // _callAddress() async {
  //   await get(server + 'shipping-addresses').then((value) async {
  //     List<dynamic> arr = [];
  //     arr = value;
  //     var a = await arr.where((x) => x['main'] == true).toList().first;
  //     if (a != null)
  //       setState(() {
  //         name = a['name'];
  //         phone = a['phone'];
  //         address = {
  //           'code': a['id'],
  //           'address': a['address'],
  //           'subDistrict': a['tambon']['data']['name_th'],
  //           'district': a['amphoe']['data']['name_th'],
  //           'province': a['province']['data']['name_th'],
  //           'postalCode': a['zip'],
  //         };
  //         hasAddress = true;
  //       });
  //   });
  // }

  _callCarts() async {
    int price = 0;
    String url = '';
    Timer(
      Duration(seconds: 1),
      () async {
        modelCode.forEach((e) async {
          //(c['product_variant']['data']['promotion_active'] == true ? c['product_variant']['data']['promotion_price'] : c['product_variant']['data']['price'])
          //(e['promotion_active'] == true ? e['promotion_price'] : e['price'])

          print('----- _callCarts ' + e['promotion_active'].toString());
          print('----- _callCarts ' + e['promotion_price'].toString());
          print('----- _callCarts ' + e['price'].toString());

          e['url'] = (e['url'] ?? '') != ''
              ? e['url']
              : 'assets/images/kaset/no-img.png';
          price +=
              ((e['promotion_price'] != 0 ? e['promotion_price'] : e['price']) *
                  e['quantity']) as int;
          if (url == '') {
            url += '?carts[]=' + e['cart_id'];
          } else if ((url != '')) {
            url += '&carts[]=' + e['cart_id'];
          }
          // if (e['isPromotion'] &&
          //     (int.parse(e['promotion_price'].toString()) > 0)) {
          //   promoAll += (e['price'] - e['promotion_price']);
          // }
          setState(() {
            cares_id.add(e['cart_id']);
            urlCartId = url;
            model.add(e);
          });
        });
        _readCoupons();
        setState(
          () {
            cartId = cares_id;
            total = price;
            totalPrice = (total - discountAll);
            loadingSuccess = true;
            _readShippingPrice(cartId);
          },
        );
      },
    );
  }

  _readShippingPrice(List<dynamic> param_cart_id) async {
    print('-------123------${param_cart_id}');
    var carts = '';
    for (var i = 0; i < param_cart_id.length; i++) {
      if (i == 0) {
        carts = '?carts[]=' + param_cart_id[i];
      } else {
        carts += '&carts[]=' + param_cart_id[i];
      }
    }
    print('======555 ${carts}');
    await getShippingPrice(server + 'shipping-price/' + address['code'] + carts)
        .then(
      (value) => {
        setState(
          () {
            deliveryPrice = value ?? 0;
            totalPrice = (total - discountAll) + deliveryPrice;
          },
        )
      },
    );
  }

  _readCoupons() async {
    // setState(
    //   () {
    //     _futureCoupons = get(server + 'users/me/coupons');
    //   },
    // );
    // var ConponsMe = get(server + 'users/me/coupons').then((value) =>
    //     [...value].where((f) => f['coupon_user_status'] == 0).toList());

    var ConponsMe = get(server + 'users/me/coupons');

    get('${server}orders').then((value) {
      setState(() {
        checkOrder = true;
        _futureCoupons = ConponsMe.then((value) => [...value]
            .where(
                (f) => f['coupon_user_status'] == 0 && f['code'] != 'welcome')
            .toList());
      });
    }).onError((error, stackTrace) {
      postObjectData(server + 'coupons/apply', {'code': "welcome"})
          .then((value) {
        setState(() {
          _futureCoupons = ConponsMe;
          couponModel = value;
          discountAll = couponModel['discount'];
          totalPrice = (total + deliveryPrice) - discountAll;
          couponsCode = couponModel['id'];
        });
      });
    });

    // get('${server}orders')
    //     .then((value) => {
    //           setState(
    //             () {
    //               // _futureCoupons = get(server + 'users/me/coupons');
    //             },
    //           ),
    //         })
    //     .onError((error, stackTrace) => {
    //           postObjectData(server + 'coupons/apply', {'code': "welcome"})
    //               .then((value) => {
    //                     setState(() {
    //                       couponModel = value;
    //                       // totalPrice = total + deliveryPrice;
    //                       discountAll = couponModel['discount'];
    //                       totalPrice =
    //                           (total + deliveryPrice) - discountAll - promoAll;
    //                       couponsCode = couponModel['id'];
    //                     }),
    //                   }),
    //         });
  }

  _getCredit() async {
    // var res = await postDio('${server}m/manageCreditCard/read', {});
    var first = {'code': '0'}; // ชำระเงินปลายทาง
    var res = [{}];
    return res.length > 0 ? [first, ...res] : [];
  }

  _buy() async {
    dynamic modelData;
    if (isInvoice) {
      if (!isInvoiceAddress) {
        // return toastFail(context,
        //     text: 'กรุณาเลือกที่อยู่เพื่อใช้ในใบกำกับภาษี', duration: 3);
        return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: CupertinoAlertDialog(
                  title: new Text(
                    'กรุณาเลือกที่อยู่เพื่อใช้ในใบกำกับภาษี',
                    // '',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  content: Text(" "),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: new Text(
                        "ตกลง",
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Kanit',
                          color: Color(0xFFFF7514),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            });
      }
      // if ((txtInvoiceBranch.text ?? '') == '') {
      //   return toastFail(context,
      //       text: 'กรุณาใส่ชื่อสำนังงาน/รหัสสาขา ใบกำกับภาษี', duration: 3);
      // }
      if ((txtInvoiceNumber.text ?? '') == '') {
        // return toastFail(context,
        //     text: 'กรุณาใส่เลขประจำตัวผู้เสียภาษี', duration: 3);
        return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: CupertinoAlertDialog(
                  title: new Text(
                    'กรุณาใส่เลขประจำตัวผู้เสียภาษี',
                    // '',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Kanit',
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  content: Text(" "),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: new Text(
                        "ตกลง",
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Kanit',
                          color: Color(0xFFFF7514),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            });
      }
      setState(() {
        loading = true;

        postObjectData(server + 'orders/', {
          'shipping_address_id': address['code'],
          'coupon_id': couponsCode,
          'shipping_price': deliveryPrice,
          'tax_invoice_address_id': addressInvoice['code'],
          'tax_invoice_branch': (txtInvoiceBranch.text ?? ''),
          'tax_identification_number': txtInvoiceNumber.text,
          'carts': cares_id
        }).then(
          (value) => {
            print('-- PO 4'),
            modelData = {
              'payment_type': creditCardCode,
              // 'order_id': 'order_BYW95EGWJDN6VK'
              'order_id': value['id']
            },
            loading = false,
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentStatusCentralPage(model: modelData),
              ),
            ),
          },
        );
      });
    } else {
      setState(() {
        loading = true;
      });
      try {
        postObjectData(server + 'orders/', {
          'shipping_address_id': address['code'],
          'coupon_id': couponsCode,
          'shipping_price': deliveryPrice,
          'carts': cares_id
        }).then(
          (value) async => {
            print('--===--===--==-- ${value}'),
            setState(
              () async {
                // if (value['status2'] == 'S') {

                // } else {
                //   loading = false;
                //   toastFail(context, text: value['error_message']);
                // }
                modelData = {
                  'payment_type': creditCardCode,
                  // 'order_id': 'order_BYW95EGWJDN6VK'
                  'order_id': value['id']
                };
                loading = false;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentStatusCentralPage(model: modelData),
                  ),
                );
              },
            )
          },
        );
      } catch (e) {
        setState(() {
          loading = false;
        });
        toastFail(context, text: e.toString());
      }
    }
    // if (creditCardCode == '1') {

    // } else if (creditCardCode == '2') {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (_) => PaymentStatusCentralPage(),
    //     ),
    //   );
    // } else if (creditCardCode == '3') {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (_) => PaymentStatusCentralPage(),
    //     ),
    //   );
    // }
  }

  Future<void> checkCoupon(String code) async {
    // เรียก API ที่คุณเขียนไว้
    try {
      // ตัวอย่าง mock API call
      // final response = await Future.delayed(
      //   Duration(seconds: 2),
      //   () => {"valid": code != "invalid", "message": "Coupon Applied!"},
      // );

      Dio dio = new Dio();
      var response = await dio.get(
          'https://gateway.we-builds.com/py-api/ssp/coupon/coupon/read?code=$code');

      if (response.data['data'] != null) {
        setState(() {
          couponMessage =
              "คูปองใช้ได้: ${response.data['data']['data']['name']}";

          discountAll = response.data['data']['data']['discount'];
          totalPrice = (total + deliveryPrice) - discountAll;
          couponsCode = response.data['data']['data']['id'];
        });
      } else {
        setState(() {
          couponMessage = "ไม่พบคูปอง";
        });
      }
    } catch (e) {
      setState(() {
        discountAll = 0;
        totalPrice = (total + deliveryPrice) - 0;
        couponsCode = '';
        couponMessage = "ไม่พบคูปอง";
      });
    }
  }

  Future<String> _validate() async {
    List<String> failureList = [
      'ที่อยู่จัดส่ง',
      'ตัวเลือกจัดส่ง',
      'ตัวเลือกชำระเงิน',
      'คูปอง'
    ];
    String status = '';
    if (address['code'] == '') return failureList[0];
    // if (deliveryCode == '') return failureList[1];
    if (creditCardCode == '') return failureList[2];

    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: AdaptiveTextSize().getadaptiveTextSize(context, 50),
        flexibleSpace: Container(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top +
                  AdaptiveTextSize().getadaptiveTextSize(context, 10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_ios,
                          size: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 20)),
                      Text(
                        'สั่งซื้อ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context),
                        textAlign: TextAlign.start,
                      )
                    ],
                  ),
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
      body: ShowLoadingWidget(
        loading: loading,
        children: [
          SizedBox(
            height: double.infinity,
            child: ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).padding.bottom +
                    AdaptiveTextSize().getadaptiveTextSize(context, 70),
              ),
              children: [
                Text(
                  'ที่อยู่จัดส่ง',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                  textScaleFactor: ScaleSize.textScaleFactor(context),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeliveryAddressCentralPage(
                        notChange: true,
                      ),
                    ),
                  ).then(
                    (value) async => {
                      if (value['status'] == '1') // เลือกที่อยู่
                        {
                          hasAddress = true,
                          setState(
                            () {
                              name = value['name'];
                              phone = value['phone'];
                              address = {
                                'code': value['id'],
                                'address': value['address'],
                                'subDistrict': value['tambon']['data']
                                    ['name_th'],
                                'district': value['amphoe']['data']['name_th'],
                                'province': value['province']['data']
                                    ['name_th'],
                                'postalCode': value['zip'],
                              };
                              _readShippingPrice(cartId);
                            },
                          ),
                        }
                      else if (value['status'] == '2') // ไม่มีที่อยู่
                        {
                          setState(
                            () {
                              name = '';
                              phone = '';
                              address = {
                                'code': '',
                                'address': '',
                                'province': '',
                                'district': '',
                                'subDistrict': '',
                                'postalCode': ''
                              };
                              _readShippingPrice(cartId);
                            },
                          ),
                        }
                    },
                  ),
                  child: hasAddress
                      ? Container(
                          padding: EdgeInsets.fromLTRB(15, 10, 15, 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1,
                              color: Color(0xFF1434F7),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textScaleFactor:
                                        ScaleSize.textScaleFactor(context),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xFF0B24FB),
                                    size: AdaptiveTextSize()
                                        .getadaptiveTextSize(context, 20),
                                  )
                                ],
                              ),
                              // SizedBox(height: 7),
                              Row(
                                children: [
                                  Text(
                                    '|  ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF707070),
                                    ),
                                    textScaleFactor:
                                        ScaleSize.textScaleFactor(context),
                                  ),
                                  Text(
                                    phone,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF707070),
                                    ),
                                    textScaleFactor:
                                        ScaleSize.textScaleFactor(context),
                                  ),
                                ],
                              ),
                              SizedBox(height: 7),
                              Wrap(
                                // crossAxisAlignment: WrapCrossAlignment.start,
                                alignment: WrapAlignment.start,
                                runAlignment: WrapAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        width: 1,
                                        color: Color(0xFF1434F7),
                                      ),
                                    ),
                                    child: Text(
                                      'ที่บ้าน',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFF0B24FB),
                                      ),
                                      textScaleFactor:
                                          ScaleSize.textScaleFactor(context),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '${address['address']}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF707070),
                                    ),
                                    textScaleFactor:
                                        ScaleSize.textScaleFactor(context),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '${address['subDistrict']}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF707070),
                                    ),
                                    textScaleFactor:
                                        ScaleSize.textScaleFactor(context),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '${address['district']}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF707070),
                                    ),
                                    textScaleFactor:
                                        ScaleSize.textScaleFactor(context),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '${address['province']}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF707070),
                                    ),
                                    textScaleFactor:
                                        ScaleSize.textScaleFactor(context),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '${address['postalCode']}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF707070),
                                    ),
                                    textScaleFactor:
                                        ScaleSize.textScaleFactor(context),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      : Container(
                          height: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1,
                              color: Color(0xFF1434F7),
                            ),
                          ),
                          child: Text(
                            "เลือกที่อยู่จัดส่งของคุณของคุณ",
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                ),
                SizedBox(height: 20),
                Text(
                  'รายการสินค้า',
                  style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 17),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10),
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) =>
                      _buildCard(model[index], index),
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemCount: model.length,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ตัวเลือกจัดส่ง',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      textScaleFactor: ScaleSize.textScaleFactor(context),
                    ),
                    Container(
                      // height: 25,
                      // width: 25,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(
                        color: Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF0B24FB),
                          size: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 17)),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: Color(0xFFE4E4E4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('แบบธรรมดา',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textScaleFactor:
                                  ScaleSize.textScaleFactor(context)),
                          Text('รับภายใน 3-5 วัน',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF707070),
                              ),
                              textScaleFactor:
                                  ScaleSize.textScaleFactor(context)),
                        ],
                      ),
                      Text(moneyFormat(deliveryPrice.toString()) + ' บาท',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          textScaleFactor: ScaleSize.textScaleFactor(context)),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // ตัวเลือกชำระเงิน
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ตัวเลือกชำระเงิน',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyCreditCardCentralPage(),
                        ),
                      ),
                      child: Container(
                        // height: 25,
                        // width: 25,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF0B24FB),
                          size: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 17),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  // height: 70,
                  height: AdaptiveTextSize().getadaptiveTextSize(context, 70),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: _futurePayments.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, index) {
                      // if (index == 0) {
                      return StackTap(
                        borderRadius: BorderRadius.circular(10),
                        splashColor: Color(0xFF1434F7).withOpacity(0.2),
                        onTap: () {
                          setState(() {
                            creditCardCode = _futurePayments[index]['id'];
                          });
                        },
                        child: Container(
                          // width: 169,
                          padding: EdgeInsets.fromLTRB(12, 10, 15, 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1,
                              color:
                                  _futurePayments[index]['id'] == creditCardCode
                                      ? Color(0xFF1434F7)
                                      : Color(0xFFE4E4E4),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_futurePayments[index]['title'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textScaleFactor:
                                      ScaleSize.textScaleFactor(context)),
                              Text('ชำระเงินเมื่อได้รับสินค้า',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF707070),
                                  ),
                                  textScaleFactor:
                                      ScaleSize.textScaleFactor(context)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // คูปอง

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('คูปอง',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CouponPickUpCentralPage(
                              // readMode: false,
                              ),
                        ),
                      ).then(
                        (value) => {
                          if (checkOrder && value['code'] == 'welcome')
                            toastFail(
                              context,
                              text: 'ไม่สามารถใช้คูปองนี้ได้',
                              color: Colors.black,
                              fontColor: Colors.white,
                            )
                          else
                            setState(
                              () {
                                couponModel = value;
                                // totalPrice = total + deliveryPrice;
                                discountAll = couponModel['discount'];
                                totalPrice =
                                    (total + deliveryPrice) - discountAll;
                                couponsCode = couponModel['id'];
                              },
                            ),
                        },
                      ),
                      child: Container(
                        // height: 25,
                        // width: 25,
                        // height: AdaptiveTextSize()
                        //     .getadaptiveTextSize(context, 25),
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF0B24FB),
                          size: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 17),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(fontSize: 12),
                        controller: couponController,
                        decoration: InputDecoration(
                          hintText: "กรอกรหัสคูปอง",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        // ตรวจสอบรหัสคูปอง
                        await checkCoupon(couponController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.pinkAccent, // ✅ ใช้ backgroundColor แทน
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: Text(
                        "ใช้",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                if (couponMessage != null)
                  Text(
                    couponMessage,
                    style: TextStyle(
                      color: couponMessage.contains("ใช้ได้")
                          ? Colors.green
                          : Colors.red,
                      fontSize: 13,
                    ),
                  ),
                couponModel != null
                    ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 15),
                            vertical: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 6)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1,
                            color: Color(0xFFE3E6FE),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text('คูปองที่ใช้ : ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  textScaleFactor:
                                      ScaleSize.textScaleFactor(context)),
                              Text(couponModel['name'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textScaleFactor:
                                      ScaleSize.textScaleFactor(context)),
                            ]),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('เงื่อนไข : ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      textScaleFactor:
                                          ScaleSize.textScaleFactor(context)),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'ส่วนลด ' +
                                              moneyFormat(
                                                  couponModel['discount']
                                                      .toString()) +
                                              ' บาท',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textScaleFactor:
                                              ScaleSize.textScaleFactor(
                                                  context)),
                                      Text(
                                          'เมื่อซื้อครบ ' +
                                              moneyFormat(couponModel[
                                                      'minimum_order_total']
                                                  .toString()) +
                                              ' บาท',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF707070),
                                          ),
                                          textScaleFactor:
                                              ScaleSize.textScaleFactor(
                                                  context)),
                                    ],
                                  )
                                ]),
                          ],
                        ),
                      )
                    : SizedBox(height: 0),
                SizedBox(height: 10),
                SizedBox(
                  // height: 70,
                  height: AdaptiveTextSize().getadaptiveTextSize(context, 70),
                  child: FutureBuilder<dynamic>(
                    future: _futureCoupons,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.length > 0) {
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            // padding: EdgeInsets.zero,
                            itemCount: snapshot.data.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, index) {
                              return StackTap(
                                borderRadius: BorderRadius.circular(10),
                                splashColor: Color(0xFF1434F7).withOpacity(0.2),
                                onTap: () {
                                  if (couponsCode ==
                                      snapshot.data[index]['id']) {
                                    setState(() {
                                      couponModel = null;
                                      couponsCode = '';
                                      totalPrice = totalPrice + discountAll;
                                      discountAll = 0;
                                    });
                                  } else {
                                    _checkCoupon(snapshot.data[index]['code'])
                                        .then(
                                      (data) => {
                                        if (data['status'] == 'F')
                                          {
                                            Toast.show(data['error_message'],
                                                backgroundColor:
                                                    Colors.red[800] ??
                                                        Colors.red,
                                                duration: 3,
                                                gravity: Toast.center,
                                                textStyle: TextStyle(
                                                    color: Colors.white)),
                                          }
                                        else
                                          {
                                            setState(
                                              () {
                                                couponModel = data;
                                                // totalPrice = total + deliveryPrice;
                                                discountAll = data['discount'];
                                                totalPrice =
                                                    (total + deliveryPrice) -
                                                        discountAll;
                                                couponsCode = couponModel['id'];
                                              },
                                            ),
                                          },
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  // width: 169,
                                  // height: 0,
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      width: 1,
                                      // color: Color(0xFF1434F7)
                                      color: snapshot.data[index]['id'] ==
                                              couponsCode
                                          ? Color(0xFF1434F7)
                                          : Color(0xFFE4E4E4),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'ส่วนลด ' +
                                              moneyFormat(snapshot.data[index]
                                                      ['discount']
                                                  .toString()) +
                                              ' บาท',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textScaleFactor:
                                              ScaleSize.textScaleFactor(
                                                  context)),
                                      Text(
                                          'เมื่อซื้อครบ ' +
                                              moneyFormat(snapshot.data[index]
                                                      ['minimum_order_total']
                                                  .toString()) +
                                              ' บาท',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF707070),
                                          ),
                                          textScaleFactor:
                                              ScaleSize.textScaleFactor(
                                                  context)),
                                    ],
                                  ),
                                ),
                              );
                              // if (index == 0) {
                              //   return StackTap(
                              //     borderRadius: BorderRadius.circular(10),
                              //     splashColor:
                              //         Color(0xFF1434F7).withOpacity(0.2),
                              //     onTap: () {

                              //       setState(() {
                              //         couponsCode =
                              //             snapshot.data[index]['id'];
                              //       });
                              //     },
                              //     child: Container(
                              //       width: 169,
                              //       padding: EdgeInsets.fromLTRB(
                              //           12, 10, 15, 15),
                              //       decoration: BoxDecoration(
                              //         borderRadius:
                              //             BorderRadius.circular(10),
                              //         border: Border.all(
                              //             width: 1,
                              //             // color: Color(0xFF1434F7)
                              //             color:
                              //             creditCardCode == snapshot.data[index]['id']
                              //                 ? Color(0xFF1434F7)
                              //                 : Color(0xFFE4E4E4),
                              //             ),
                              //       ),
                              //       child: Column(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.center,
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           Text(
                              //             'ส่วนลด ' +
                              //                 (snapshot.data[index]
                              //                         ['discount']
                              //                     .toString()) +
                              //                 ' บาท',
                              //             style: TextStyle(
                              //               fontSize: 13,
                              //               fontWeight: FontWeight.w500,
                              //             ),
                              //           ),
                              //           Text(
                              //             'ชำระเงินเมื่อได้รับสินค้า',
                              //             style: TextStyle(
                              //               fontSize: 11,
                              //               color: Color(0xFF707070),
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   );
                              // } else {
                              //   return StackTap(
                              //     borderRadius: BorderRadius.circular(10),
                              //     splashColor:
                              //         Color(0xFF1434F7).withOpacity(0.2),
                              //     onTap: () {
                              //       setState(() {
                              //         couponsCode =
                              //             snapshot.data[index]['id'];
                              //       });
                              //     },
                              //     child: Container(
                              //       width: 169,
                              //       padding: EdgeInsets.fromLTRB(
                              //           12, 10, 15, 15),
                              //       decoration: BoxDecoration(
                              //         borderRadius:
                              //             BorderRadius.circular(10),
                              //         border: Border.all(
                              //           width: 1,
                              //           color: snapshot.data[index]
                              //                       ['code'] ==
                              //                   creditCardCode
                              //               ? Color(0xFF1434F7)
                              //               : Color(0xFFE4E4E4),
                              //         ),
                              //       ),
                              //       child: Column(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.center,
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           Text(
                              //             'บัตรเครดิต / เดบิต',
                              //             style: TextStyle(
                              //               fontSize: 13,
                              //               fontWeight: FontWeight.w500,
                              //             ),
                              //           ),
                              //           // Text(
                              //           //   'บัตร ${snapshot.data[index]['type']} xxx - ${snapshot.data[index]['number']}',
                              //           //   style: TextStyle(
                              //           //     fontSize: 11,
                              //           //     color: Color(0xFF707070),
                              //           //   ),
                              //           // ),
                              //         ],
                              //       ),
                              //     ),
                              //   );
                              // }
                            },
                          );
                        } else {
                          return Container(
                            // width: 169,
                            height: 165,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 1,
                                // color: Color(0xFF1434F7)
                                color: Color(0xFFE4E4E4),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ไม่มีส่วนลดที่ใช้ได้',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textScaleFactor:
                                        ScaleSize.textScaleFactor(context)),
                              ],
                            ),
                          );
                        }
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                // width: 169,
                                // height: 165,
                                height: AdaptiveTextSize()
                                    .getadaptiveTextSize(context, 70),
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: 1,
                                    // color: Color(0xFF1434F7)
                                    color: Color(0xFFE4E4E4),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('ไม่มีส่วนลดที่ใช้ได้',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        // textAlign: TextAlign.center,
                                        textScaleFactor:
                                            ScaleSize.textScaleFactor(context)),
                                  ],
                                )),
                          ],
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 10),

                //ใบกำกับภาษี
                GestureDetector(
                  onTap: () => setState(
                    () {
                      isInvoice = !isInvoice;
                      !isInvoice ? showOfficeTaxInvoice = false : null;
                      !isInvoice ? isInvoiceAddress = false : null;
                      nameInvoice = '';
                      phoneInvoice = '';
                      addressInvoice = {
                        'code': '',
                        'address': '',
                        'province': '',
                        'district': '',
                        'subDistrict': '',
                        'postalCode': ''
                      };
                      txtInvoiceBranch.text = '';
                      txtInvoiceNumber.text = '';
                    },
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ใบกำกับภาษี',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context),
                      ),
                      SizedBox(
                        width: 20,
                        child: Checkbox(
                          activeColor: Theme.of(context).primaryColor,
                          value: isInvoice,
                          onChanged: (newValue) {
                            setState(() {
                              isInvoice = !isInvoice;
                              !isInvoice ? showOfficeTaxInvoice = false : null;
                              !isInvoice ? isInvoiceAddress = false : null;
                              nameInvoice = '';
                              phoneInvoice = '';
                              addressInvoice = {
                                'code': '',
                                'address': '',
                                'province': '',
                                'district': '',
                                'subDistrict': '',
                                'postalCode': ''
                              };
                              txtInvoiceBranch.text = '';
                              txtInvoiceNumber.text = '';
                            });
                          },
                          // controlAffinity: ListTileControlAffinity
                          //     .leading, //  <-- leading Checkbox
                        ),
                        //   Icon(
                        //     isInvoice
                        //         ? Icons.check_box_rounded
                        //         : Icons.check_box_outline_blank_rounded,
                        //     color:
                        //         isInvoice ? Color(0xFFDF0B24) : Color(0xFF707070),
                        //     size: 25,
                        //   ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: 10),
                isInvoice
                    ? Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          '**กรณีท่านต้องการใบกำกับภาษี โปรดกรอก ชื่อ/ที่อยู่ และตรวจสอบความถูกต้อง',
                          style: TextStyle(
                              color: Colors.red,
                              fontStyle: FontStyle.italic,
                              fontSize: 12),
                        ),
                      )
                    : Container(),
                isInvoice
                    ? GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeliveryAddressCentralPage(
                              notChange: true,
                            ),
                          ),
                        ).then(
                          (value) async => {
                            if (value['status'] == '1') // เลือกที่อยู่
                              {
                                isInvoiceAddress = true,
                                setState(
                                  () {
                                    nameInvoice = value['name'];
                                    phoneInvoice = value['phone'];
                                    addressInvoice = {
                                      'code': value['id'],
                                      'address': value['address'],
                                      'subDistrict': value['tambon']['data']
                                          ['name_th'],
                                      'district': value['amphoe']['data']
                                          ['name_th'],
                                      'province': value['province']['data']
                                          ['name_th'],
                                      'postalCode': value['zip'],
                                    };
                                  },
                                ),
                              }
                            else
                              {
                                setState(
                                  () {
                                    nameInvoice = '';
                                    phoneInvoice = '';
                                    addressInvoice = {
                                      'code': '',
                                      'address': '',
                                      'province': '',
                                      'district': '',
                                      'subDistrict': '',
                                      'postalCode': ''
                                    };
                                  },
                                ),
                              }
                          },
                        ),
                        child: isInvoiceAddress
                            ? Container(
                                padding: EdgeInsets.fromLTRB(15, 10, 15, 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xFF1434F7),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          nameInvoice,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textScaleFactor:
                                              ScaleSize.textScaleFactor(
                                                  context),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Color(0xFF0B24FB),
                                          size: AdaptiveTextSize()
                                              .getadaptiveTextSize(context, 20),
                                        )
                                      ],
                                    ),
                                    // SizedBox(height: 7),
                                    Row(
                                      children: [
                                        Text(
                                          '|  ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF707070),
                                          ),
                                          textScaleFactor:
                                              ScaleSize.textScaleFactor(
                                                  context),
                                        ),
                                        Text(
                                          phoneInvoice,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF707070),
                                          ),
                                          textScaleFactor:
                                              ScaleSize.textScaleFactor(
                                                  context),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 7),
                                    Wrap(
                                      // crossAxisAlignment: WrapCrossAlignment.start,
                                      alignment: WrapAlignment.start,
                                      runAlignment: WrapAlignment.start,
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            border: Border.all(
                                              width: 1,
                                              color: Color(0xFF1434F7),
                                            ),
                                          ),
                                          child: Text(
                                            'ที่บ้าน',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Color(0xFF0B24FB),
                                            ),
                                            textScaleFactor:
                                                ScaleSize.textScaleFactor(
                                                    context),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          '${addressInvoice['address']}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF707070),
                                          ),
                                          textScaleFactor:
                                              ScaleSize.textScaleFactor(
                                                  context),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          '${addressInvoice['subDistrict']}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF707070),
                                          ),
                                          textScaleFactor:
                                              ScaleSize.textScaleFactor(
                                                  context),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          '${addressInvoice['district']}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF707070),
                                          ),
                                          textScaleFactor:
                                              ScaleSize.textScaleFactor(
                                                  context),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          '${addressInvoice['province']}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF707070),
                                          ),
                                          textScaleFactor:
                                              ScaleSize.textScaleFactor(
                                                  context),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          '${addressInvoice['postalCode']}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF707070),
                                          ),
                                          textScaleFactor:
                                              ScaleSize.textScaleFactor(
                                                  context),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                height: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xFF1434F7),
                                  ),
                                ),
                                child: Text(
                                  "เลือกที่อยู่เพื่อใช้ในใบกำกับภาษี",
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                      )
                    : Container(),
                isInvoice
                    ? Container(
                        padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding:
                                      EdgeInsets.only(left: 15.0, bottom: 5),
                                  child: Text(
                                    'ชื่อสำนักงานใหญ่/รหัสสาขา ใบกำกับภาษี',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF000000),
                                      // fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Checkbox(
                                  activeColor: Theme.of(context).primaryColor,
                                  value: showOfficeTaxInvoice,
                                  onChanged: (newValue) {
                                    setState(() {
                                      showOfficeTaxInvoice =
                                          !showOfficeTaxInvoice;
                                      !showOfficeTaxInvoice
                                          ? txtInvoiceBranch.text = ''
                                          : null;
                                    });
                                  },
                                  // controlAffinity: ListTileControlAffinity
                                  //     .leading, //  <-- leading Checkbox
                                ),
                              ],
                            ),
                            TextField(
                              // autofocus: widget.nameFocus,
                              focusNode: branchFocus,
                              // keyboardType: TextInputType.multiline,
                              // maxLines: 4,
                              // maxLength: 100,
                              enabled: showOfficeTaxInvoice,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Kanit',
                                color: Color(0xFF005C9E),
                              ),
                              decoration: InputDecoration(
                                fillColor: Color(0xFFFFFFFF),
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFF0B5C9E), width: 1.0),
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFE4E4E4),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(7.0),
                                  gapPadding: 1,
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFE4E4E4),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(7.0),
                                  gapPadding: 1,
                                ),
                                hintText:
                                    'กรุณาใส่ชื่อสำนักงานใหญ่/รหัสสาขา ใบกำกับภาษี',
                                contentPadding: const EdgeInsets.all(10.0),
                              ),
                              controller: txtInvoiceBranch,
                            ),
                          ],
                        ),
                      )
                    : Container(),
                isInvoice
                    ? Container(
                        padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 15.0, bottom: 5),
                              child: Text(
                                'เลขประจำตัวผู้เสียภาษี สำหรับออกใบกำกับภาษี',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF000000),
                                  // fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            TextField(
                              // autofocus: widget.nameFocus,
                              focusNode: numberFocus,
                              // keyboardType: TextInputType.multiline,
                              // maxLines: 4,
                              // maxLength: 100,
                              enabled: true,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Kanit',
                                color: Color(0xFF005C9E),
                              ),
                              decoration: InputDecoration(
                                fillColor: Color(0xFFFFFFFF),
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFF0B5C9E), width: 1.0),
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFE4E4E4),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(7.0),
                                  gapPadding: 1,
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFE4E4E4),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(7.0),
                                  gapPadding: 1,
                                ),
                                hintText:
                                    'กรุณาใส่เลขประจำตัวผู้เสียภาษี สำหรับออกใบกำกับภาษี',
                                contentPadding: const EdgeInsets.all(10.0),
                              ),
                              controller: txtInvoiceNumber,
                            ),
                          ],
                        ),
                      )
                    : Container(),

                // ข้อมูลชำระเงิน
                SizedBox(height: 10),
                Text('ข้อมูลการชำระเงิน',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                    textScaleFactor: ScaleSize.textScaleFactor(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ราคาสินค้า',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context)),
                    Text(moneyFormat(total.toString()) + ' บาท',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ค่าส่ง',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context)),
                    Text(moneyFormat(deliveryPrice.toString()) + ' บาท',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ส่วนลด',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context)),
                    Text(moneyFormat((discountAll).toString()) + ' บาท',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ยอดชำระทั้งหมด',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context)),
                    Text(moneyFormat(totalPrice.toString()) + ' บาท',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context)),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              // padding: EdgeInsets.symmetric(horizontal: 15),
              height: AdaptiveTextSize().getadaptiveTextSize(context, 50) +
                  MediaQuery.of(context).padding.bottom,
              // height: 50 + MediaQuery.of(context).padding.bottom,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.3),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(child: SizedBox()),
                  // LoadingTween(
                  //           height: 30,
                  //           width: 100,
                  //         ),
                  Text('ยอดรวม',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                      textScaleFactor: ScaleSize.textScaleFactor(context)),
                  SizedBox(width: 10),
                  Text(
                    moneyFormat(totalPrice.toString()) + ' บาท',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textScaleFactor: ScaleSize.textScaleFactor(context),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      print('-- PO 1');
                      var status = await _validate();
                      print('-- PO 2');
                      if (status == '') {
                        await _buy();
                      } else {
                        // toastFail(context, text: status);
                        return showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return WillPopScope(
                                onWillPop: () {
                                  return Future.value(false);
                                },
                                child: CupertinoAlertDialog(
                                  title: new Text(
                                    status,
                                    // '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Kanit',
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  content: Text(" "),
                                  actions: [
                                    CupertinoDialogAction(
                                      isDefaultAction: true,
                                      child: new Text(
                                        "ตกลง",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Kanit',
                                          color: Color(0xFFFF7514),
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            });
                      }
                    },
                    child: Container(
                      color: Color(0xFFDF0B24),
                      alignment: Alignment.center,
                      height: double.infinity,
                      width:
                          AdaptiveTextSize().getadaptiveTextSize(context, 110),
                      // padding: EdgeInsets.symmetric(horizontal: 30 , vertical: 10),
                      child: Text('ชำระเงิน',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textScaleFactor: ScaleSize.textScaleFactor(context)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _checkCoupon(code) async {
    var status = await postObjectData(server + 'coupons/apply', {'code': code});

    return status;
  }

  _buildCard(param, index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          param['url'] != 'null'
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: loadingImageNetwork(
                    param['url'],
                    // width: 80,
                    // height: 80,
                    height: (MediaQuery.of(context).size.width + (100)) / 5.0,
                    fit: BoxFit.contain,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    // color: Color(0XFF0B24FB),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Image.asset(
                    'assets/images/kaset/no-img.png',
                    fit: BoxFit.contain,
                    // color: Colors.white,
                  ),
                ),
          SizedBox(width: 15),
          Expanded(
              child: Container(
            // height: (MediaQuery.of(context).size.width + (100)) / 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // SizedBox(
                //   height: (MediaQuery.of(context).size.width + (100)) / 5.0,
                //   child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      param['product_name'],
                      style: TextStyle(
                        fontSize: 13,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textScaleFactor: ScaleSize.textScaleFactor(context),
                      maxLines: 2,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Color(0xFFE4E4E4),
                                borderRadius: BorderRadius.circular(
                                  7,
                                ),
                              ),
                              child: Text(
                                param['product_variant'] ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                                textScaleFactor:
                                    ScaleSize.textScaleFactor(context),
                              ),
                            ),
                          ),
                        ),
                        param['isPromotion']
                            ? Expanded(
                                child: Text(
                                  '${moneyFormat(param['price'].toString())} บาท',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                  textScaleFactor:
                                      ScaleSize.textScaleFactor(context),
                                ),
                              )
                            : Container(),
                      ],
                    )
                  ],
                ),
                // ),
                SizedBox(height: 18),
                SizedBox(
                  // height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                            param['isPromotion']
                                ? '${moneyFormat(param['promotion_price'].toString())} บาท'
                                : '${moneyFormat(param['price'].toString())} บาท',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                            textScaleFactor:
                                ScaleSize.textScaleFactor(context)),
                      ),
                      Text('จำนวน',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                          textScaleFactor: ScaleSize.textScaleFactor(context)),
                      SizedBox(width: 10),
                      Container(
                        // height:
                        //     AdaptiveTextSize().getadaptiveTextSize(context, 20),
                        // width:
                        //     AdaptiveTextSize().getadaptiveTextSize(context, 20),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFFf7f7f7),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text('${param['quantity']}',
                            style: TextStyle(
                              // height: AdaptiveTextSize()
                              //     .getadaptiveTextSize(context, 0.8),
                              fontSize: 12,
                            ),
                            textScaleFactor:
                                ScaleSize.textScaleFactor(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
