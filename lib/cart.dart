import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile_mart_v3/component/loading_image_network.dart';
import 'package:mobile_mart_v3/component/toast_fail.dart';
import 'package:mobile_mart_v3/confirm_order.dart';
import 'package:mobile_mart_v3/menu.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/shared/extension.dart';
import 'package:mobile_mart_v3/widget/show_loading.dart';
import 'package:uuid/uuid.dart';

class CartCentralPage extends StatefulWidget {
  const CartCentralPage({Key? key}) : super(key: key);

  @override
  State<CartCentralPage> createState() => _CartCentralPageState();
}

class AdaptiveTextSize {
  const AdaptiveTextSize();

  getadaptiveTextSize(BuildContext context, dynamic value) {
    // 720 is medium screen height
    return (value / 720) *
        ((MediaQuery.of(context).size.height +
                MediaQuery.of(context).size.width) /
            1.6);
  }
}

class ScaleSize {
  static double textScaleFactor(BuildContext context,
      {double maxTextScaleFactor = 1.5}) {
    final width = MediaQuery.of(context).size.width;
    final aspectratio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;
    double val = (width / 1080) * aspectratio;
    return max(1, min(val, aspectratio));
  }
}

class _CartCentralPageState extends State<CartCentralPage> {
  List<dynamic> model = [];
  List<dynamic> selectedProduct = [];
  bool loading = true;
  String imageMock =
      'http://122.155.223.63/td-doc/images/news/news_221814384.jpg';
  bool buyAll = false;
  String verifyPhonePage = 'true';
  String profilePhone = '1';
  String? verifyPhone;
  final storage = new FlutterSecureStorage();
  String profileCode = "";
  String? emailProfile;
  int totalPrice = 0;
  @override
  initState() {
    super.initState();
    _readProfile();
    // _callRead();
    setState(() {});

    _readLocalCart();
  }

  _readProfile() async {
    final result = await getUser(server + 'users/me');
    setState(() {
      // verifyPhonePage = result['phone_verified'].toString();
      // emailProfile = result['email'].toString();
      // profilePhone = result['id'].toString();
    });
    await _readLocalCart();
    // await _callRead();
    // profileCode = await storage.read(key: 'profileCode10');
    // dynamic valueStorage = await storage.read(key: 'dataUserLoginDDPM');
    // dynamic dataValue = valueStorage == null ? {'email': ''} : json.decode(valueStorage);
    // String phoneStorage = await storage.read(key: 'profilePhone');
    // verifyPhone = await storage.read(key: 'phoneVerified');
    // await storage.read(key: 'phoneVerified').then(((value) async {
    //   await setState(() {
    //     profilePhone = phoneStorage;
    //     emailProfile = dataValue['email'].toString() ?? "";
    //     verifyPhonePage = value;
    //     // loading = false;
    //   });
    // _callRead();
    // }));
  }

  _readLocalCart() async {
    setState(() {
      loading = true;
    });

    final storage = FlutterSecureStorage();
    String? cartData = await storage.read(key: 'cartItems');

    if (cartData != null && cartData.isNotEmpty) {
      List<dynamic> cartList = jsonDecode(cartData);

      // เพิ่ม property 'selected' ให้ทุก item
      for (var e in cartList) {
        e['selected'] = false;
      }

      setState(() {
        model = cartList;
        loading = false;
        print('==========_readLocalCart===========');
        print('model : $model');
        // print('price0 : ${model[0]['price']}');
        // print('price1 : ${model[1]['price']}');
        // print('qty1 : ${model[0]['qty']}');
        // print('qty0 : ${model[1]['qty']}');
      });
    } else {
      setState(() {
        model = [];
        loading = false;
      });
    }
  }
  // _callRead() async {
  //   var newMap = {};
  //   var arr = [];
  //   model = [];
  //   if (verifyPhonePage == 'true') {
  //     var response = await get('${server}carts');
  //     arr = response;

  //     arr.forEach((element) async {
  //       element['selected'] = false;
  //       if (element['media'] == null) {
  //         element['media'] = null;
  //       }
  //     });
  //     setState(() {
  //       model = arr;
  //       loading = false;
  //     });
  //   } else {
  //     setState(() {
  //       model = arr;
  //       loading = false;
  //     });
  //   }

  //   //  arr.add({'selected' : false});
  //   // arr.map((e) {
  //   //   var selected = false;

  //   //     // e['selected'] = e['selected'] = false;
  //   //     return e;
  //   //   });

  //   // newMap = groupBy(response, (obj) => obj['id'] = 1);
  // }

  checkItem(int indexItem) {
    var currentShopChecked;
    var arr = {};
    var a;
    if (model[indexItem]['stock'] > 0) {
      setState(
        () => {
          model[indexItem]['selected'] = !model[indexItem]['selected'],
        },
      );
    }
    return;
  }

  checkAll() {
    setState(
      () {
        buyAll = !buyAll;
        model.forEach(
          (e) => {
            if (e['stock'] > 0)
              {
                e['selected'] = buyAll,
              }
            // if (e['selected'] == true) {}
          },
        );
      },
    );
  }

  // deleteAll() {
  //   setState(
  //     () {
  //       Dio dio = new Dio();
  //       loading = true;
  //       model.forEach(
  //         (c) async => {
  //           if (c['selected'])
  //             {
  //               // await delete(server + 'carts/' + c['id']).then(
  //               //   (res) async {
  //               //     if (res['success'] == true) {
  //               //       // _callRead();
  //               //       setState(() {
  //               //         loading = false;
  //               //       });
  //               //     }
  //               //   },
  //               // )
  //             }
  //         },
  //       );
  //     },
  //   );
  //   Navigator.pop(context);
  // }
  String _priceAll() {
    num totalPrice = 0;

    for (var item in model) {
      if (item['selected'] == true) {
        num price = num.tryParse(item['price'].toString()) ?? 0;
        num qty = num.tryParse(item['qty'].toString()) ?? 0;
        totalPrice += (price * qty);
      }
    }

    return '${totalPrice.round().toString()} บาท';
  }
  // _priceAll() {
  //   num totalPrice = 0;

  //   // model.forEach((c) {
  //   //   if (c['selected'] == true) {
  //   //     num price = num.tryParse(c['price'].toString()) ?? 0;
  //   //     num qty = num.tryParse(c['qty'].toString()) ?? 0;

  //   //     totalPrice += price * qty;
  //   //   }
  //   // });

  //   // แปลงเป็น int ก่อนแสดง
  //   int totalInt = totalPrice.round(); // ปัดเป็นจำนวนเต็ม

  //   print('totalPrice ------------->> $totalInt');
  //   return totalInt.toString() + ' บาท';
  // }

  String _calculateItemPrice(dynamic item) {
    num price = num.tryParse(item['price'].toString()) ?? 0;
    num qty = num.tryParse(item['qty'].toString()) ?? 0;
    num total = price * qty;

    return total.round().toString();
  }

  _changeCarts(action, param) async {
    if (action == 0) {
      // ลดจำนวน
      if (param['qty'] == 1) {
        return null;
      } else {
        setState(() {
          param['qty']--;
        });
        await _saveCartToStorage(); // บันทึกลง storage
      }
    } else {
      // เพิ่มจำนวน
      int stock = param['stock'] ?? 999; // ถ้าไม่มีข้อมูล stock ให้ใช้ค่าสูงๆ

      if (param['qty'] >= stock) {
        toastFail(context, text: 'สินค้าเหลือเพียง $stock ชิ้น เท่านั้น');
        return null;
      } else {
        setState(() {
          param['qty']++;
        });
        await _saveCartToStorage(); // บันทึกลง storage
      }
    }
  }

  Future<void> _saveCartToStorage() async {
    final storage = FlutterSecureStorage();
    String cartData = jsonEncode(model);
    await storage.write(key: 'cartItems', value: cartData);
  }

  deleteAll() async {
    setState(() {
      loading = true;
    });

    // ลบเฉพาะรายการที่เลือก
    model.removeWhere((item) => item['selected'] == true);

    // บันทึกกลับลง storage
    await _saveCartToStorage();

    setState(() {
      loading = false;
      buyAll = false;
    });

    Navigator.pop(context);
  }
  // void deleteItem(int index, String id) async {
  //   setState(() {
  //     loading = true;
  //   });

  //   // ลบออกจาก model
  //   setState(() {
  //     model.removeAt(index);
  //   });

  //   // บันทึกกลับลง storage
  //   await _saveCartToStorage();

  //   setState(() {
  //     loading = false;
  //   });

  //   Navigator.pop(context);
  // }

  // void deleteItem(int index, String id) async {
  //   setState(() {
  //     loading = true;
  //   });
  //   Dio dio = new Dio();
  //   await delete(server + 'carts/' + id).then((res) async {
  //     if (res['success'] == true) {
  //       setState(() => model.removeAt(index));
  //       // if (model[index]['items'].length == 0) model.removeAt(index);
  //       setState(() {
  //         loading = false;
  //       });
  //     }
  //     Navigator.pop(context);
  //   });
  // }

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
    try {
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
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
                      Icon(Icons.arrow_back_ios,
                          size: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 20)),
                      Text(
                        'ตะกร้า',
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
                Expanded(child: SizedBox(width: 50)),
                if (model.where((x) => x['selected'] == true).length > 0)
                  GestureDetector(
                    onTap: () {
                      _buildDialogDeleteAll();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_rounded,
                            color: Colors.red,
                            size: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 25)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: ShowLoadingWidget(
        loading: loading,
        children: [
          if (model.length == 0 && profilePhone == null ||
              profilePhone == '' ||
              profilePhone == 'false')
            _cartNoAddPhone(),
          if (model.length == 0 &&
              verifyPhonePage == 'false' &&
              profilePhone != null)
            _cartNoVerify(),
          if (model.length == 0 && verifyPhonePage == 'true' && !loading)
            _cartEmpty(),
          if (model.length > 0)
            // SizedBox(
            //     height: double.infinity,
            //     child: ListView.separated(
            //       shrinkWrap: true,
            //       physics: ClampingScrollPhysics(),
            //       padding: EdgeInsets.only(
            //         bottom: MediaQuery.of(context).padding.bottom + 70,
            //       ),
            //       itemCount: 1,
            //       separatorBuilder: (_, __) => SizedBox(height: 20),
            //       itemBuilder: (context, index) => _buildGroup(model, index),
            //     )),
            SizedBox(
              height: double.infinity,
              child: Container(
                  margin: EdgeInsets.only(
                      bottom:
                          AdaptiveTextSize().getadaptiveTextSize(context, 45) +
                              MediaQuery.of(context).padding.bottom),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, indexItem) =>
                        _buildCard(model[indexItem], indexItem),
                    separatorBuilder: (_, __) => SizedBox(
                      height:
                          AdaptiveTextSize().getadaptiveTextSize(context, 10),
                    ),
                    itemCount: model.length,
                  )),
            ),
          if (model.length > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
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
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => checkAll(),
                      child: SizedBox(
                        width: 20,
                        child: Icon(
                          buyAll
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          color: buyAll ? Color(0xFFDF0B24) : Color(0xFF707070),
                          size: 25,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'ทั้งหมด',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                      textScaleFactor: ScaleSize.textScaleFactor(context),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'ยอดรวม',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                      textScaleFactor: ScaleSize.textScaleFactor(context),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _priceAll(),
                        // '_priceAll',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        List<dynamic> data = [];

                        model.forEach((e) {
                          if (e['selected']) {
                            data.add({
                              'name': e['name'] ?? '',
                              'image': e['image'] ?? '',
                              'price': e['price'] ?? 0,
                              'quantity': e['qty'] ?? 1,
                              'cart_id': e['id']
                            });
                          }
                        });

                        if (data.length > 0) {
                          print(
                              '================ ข้อมูลที่เลือก ================');
                          print('จำนวนรายการ: ${data.length}');
                          print('ข้อมูล: $data');

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConfirmOrderCentralPage(
                                  modelCode: data, type: 'cart'),
                            ),
                          );

                          // Refresh cart หลังกลับมาจากหน้า Confirm Order
                          await _readLocalCart();
                        } else {
                          // แสดง toast เมื่อไม่มีรายการที่เลือก
                          toastFail(context,
                              text: 'กรุณาเลือกสินค้าที่ต้องการชำระเงิน');
                        }
                      },
                      child: Container(
                        color: Color(0xFFDF0B24),
                        alignment: Alignment.center,
                        // height: double.infinity,
                        // width: 130,
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        child: Text(
                          'ชำระเงิน',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textScaleFactor: ScaleSize.textScaleFactor(context),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // _buildGroup(dynamic param, index) {
  //   return Container(
  //     color: Colors.white,
  //     padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
  //     child: Column(
  //       children: [
  //         // Row(
  //         //   children: [
  //         //     GestureDetector(
  //         //       onTap: () {
  //         //         setState(() => {
  //         //               model[index]['selected'] = !model[index]['selected'],
  //         //             });
  //         //         model[index]['items'].forEach(
  //         //           (e) {
  //         //             setState(() {
  //         //               e['selected'] = model[index]['selected'];
  //         //             });
  //         //           },
  //         //         );
  //         //       },
  //         //       child: SizedBox(
  //         //         width: 20,
  //         //         child: Icon(
  //         //           param['selected']
  //         //               ? Icons.check_box_rounded
  //         //               : Icons.check_box_outline_blank_rounded,
  //         //           color: param['selected']
  //         //               ? Color(0xFFDF0B24)
  //         //               : Color(0xFF707070),
  //         //           size: 25,
  //         //         ),
  //         //       ),
  //         //     ),
  //         //     SizedBox(width: 10),
  //         //     Text('${param['lv1ShopName']}')
  //         //   ],
  //         // ),
  //         SizedBox(height: 5),
  //         ListView.separated(
  //           shrinkWrap: true,
  //           padding: EdgeInsets.zero,
  //           physics: ClampingScrollPhysics(),
  //           itemBuilder: (context, indexItem) =>
  //               _buildCard(param[indexItem], index, indexItem),
  //           separatorBuilder: (_, __) => SizedBox(height: 10),
  //           itemCount: param.length,
  //         )
  //       ],
  //     ),
  //   );
  // }

  _buildCard(param, indexItem) {
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 20, right: 20),
      color: Colors.white,
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              flex: 2,
              onPressed: (_) => _buildDialogDelete(indexItem, param['id']),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete_forever,
              label: 'ลบ',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () async {
            // var productModel = await readProduct(param['product_id']);
            // await _addLog(productModel);
            // await Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => ProductFormCentralPage(
            //       model: productModel,
            //     ),
            //   ),
            // );
          },
          child: SizedBox(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 15),
                GestureDetector(
                  onTap: () => checkItem(indexItem),
                  child: Icon(
                    param['selected']
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: param['selected']
                        ? Color(0xFFDF0B24)
                        : Color(0xFF707070),
                    size: AdaptiveTextSize().getadaptiveTextSize(context, 20),
                  ),
                ),
                SizedBox(width: 10),
                ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: param['image'] != null
                        ? loadingImageNetwork(
                            param['image'],
                            width: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 80),
                            height: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 80),
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/kaset/no-img.png',
                            fit: BoxFit.contain,
                            width: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 80),
                            height: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 80),
                          )),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height:
                            AdaptiveTextSize().getadaptiveTextSize(context, 80),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Text(
                                param['name'],
                                // ??
                                //     param['product']['data']['sku'],
                                style: TextStyle(
                                  fontSize: 13,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                textScaleFactor:
                                    ScaleSize.textScaleFactor(context),
                                maxLines: 2,
                              ),
                            ),
                            // SizedBox(height: 5),
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
                                        param['name'],
                                        // ?? param['product_variant']['data']
                                        //     ['sku'],
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
                                // param['product_variant']['data']
                                //             ['promotion_active'] ==
                                //         true
                                //     ?
                                // Expanded(
                                //         child: Text(
                                //           '${moneyFormat(param['product_variant']['data']['price'].toString())} บาท',
                                //           style: TextStyle(
                                //             fontSize: 13,
                                //             fontWeight: FontWeight.bold,
                                //             decoration:
                                //                 TextDecoration.lineThrough,
                                //           ),
                                //           textScaleFactor:
                                //               ScaleSize.textScaleFactor(
                                //                   context),
                                //         ),
                                //       )
                                //     : Container(),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height:
                            AdaptiveTextSize().getadaptiveTextSize(context, 10),
                      ),
                      SizedBox(
                        height:
                            AdaptiveTextSize().getadaptiveTextSize(context, 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                // param['product_variant']['data']
                                //             ['promotion_active'] ==
                                //         true
                                //     ? '${moneyFormat(param['product_variant']['data']['promotion_price'].toString())} บาท'
                                // :
                                '${_calculateItemPrice(param)} บาท',
                                // 'TEST',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                textScaleFactor:
                                    ScaleSize.textScaleFactor(context),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _changeCarts(0, param);
                                });
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Color(0xFFf7f7f7),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    height: 0.9,
                                    fontSize: 25,
                                    color: param['qty'] > 1
                                        ? Color(0xFF707070)
                                        : Color.fromARGB(255, 184, 183, 183),
                                  ),
                                  textScaleFactor:
                                      ScaleSize.textScaleFactor(context),
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Container(
                              height: 30,
                              width: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFFf7f7f7),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                param['qty'].toString(),
                                style: TextStyle(
                                  height: 0.9,
                                  fontSize: 8,
                                ),
                                textScaleFactor:
                                    ScaleSize.textScaleFactor(context),
                              ),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                _changeCarts(1, param);
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Color(0xFFf7f7f7),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                    height: 0.9,
                                    fontSize: 25,
                                    color: Color(0xFF707070),
                                  ),
                                  textScaleFactor:
                                      ScaleSize.textScaleFactor(context),
                                ),
                              ),
                            )
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
      ),
    );
  }

  _cartEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'รถเข็นยังว่างอยู่ ต้องหาอะไรมาเพิ่มหน่อยแล้ว!',
            style: TextStyle(fontFamily: 'Kanit', fontSize: 15),
          ),
          SizedBox(height: 15),
          Image.asset(
            'assets/images/cart.png',
            height: 50,
            width: 50,
            color: Color(0xFF0B24FB),
          ),
          SizedBox(height: 15),
          InkWell(
            onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MenuCentralPage()),
                (route) => false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  width: 1,
                  color: Color(0xFFDF0B24),
                ),
              ),
              child: Text(
                'ช้อปตอนนี้',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15,
                  color: Color(0xFFDF0B24),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _cartNoVerify() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'บัญชีนี้ยังไม่ได้ยืนยันเบอร์โทรศัพท์',
            style: TextStyle(fontFamily: 'Kanit', fontSize: 18),
          ),
          SizedBox(height: 15),
          Icon(Icons.perm_device_info, size: 70, color: Color(0xFFDF0B24)),
          // Image.asset(
          //   'assets/images/cart.png',
          //   height: 50,
          //   width: 50,
          //   color: Color(0xFF0B24FB),
          // ),
          SizedBox(height: 15),
          InkWell(
            onTap: () {},
            // Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(builder: (context) => VerifyPhonePage()),
            //     (route) => false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  width: 1,
                  color: Color(0xFFDF0B24),
                ),
              ),
              child: Text(
                'ยืนยันเบอร์โทรศัพท์',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15,
                  color: Color(0xFFDF0B24),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _cartNoAddPhone() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'บัญชีนี้ยังไม่ได้เพิ่มเบอร์โทรศัพท์',
            style: TextStyle(fontFamily: 'Kanit', fontSize: 18),
          ),
          SizedBox(height: 15),
          Icon(Icons.add_call, size: 70, color: Color(0xFFDF0B24)),
          // Image.asset(
          //   'assets/images/cart.png',
          //   height: 50,
          //   width: 50,
          //   color: Color(0xFF0B24FB),
          // ),
          SizedBox(height: 15),
          InkWell(
            onTap: () => {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (BuildContext context) =>
              //           UserProfileForm(mode: "addPhone"),
              //     )).then((value) => {_readProfile()})
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  width: 1,
                  color: Color(0xFFDF0B24),
                ),
              ),
              child: Text(
                'เพิ่มเบอร์โทรศัพท์',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15,
                  color: Color(0xFFDF0B24),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildDialogDelete(index, id) {
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
                'ต้องการลบสินค้าหรือไม่ ?',
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
                  isDefaultAction: false,
                  child: new Text(
                    "ไม่",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    "ใช่",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFFFF7514),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    (index, id);
                  },
                ),
              ],
            ),
          );
        });
  }

  _buildDialogDeleteAll() {
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
                'ต้องการลบสินค้าหรือไม่ ?',
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
                  isDefaultAction: false,
                  child: new Text(
                    "ไม่",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    "ใช่",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFFFF7514),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    deleteAll();
                  },
                ),
              ],
            ),
          );
        });
  }

  // _changeCartsn, param) {
  //   if (action == 0) {
  //     if (param['qty'] == 1) {
  //       return null;
  //     } else {
  //       param['qty']--;
  //       // _updateCart(param);
  //     }
  //   } else {
  //     if (param['qty'] >= param['product_variant']['data']['stock']) {
  //       toastFail(context,
  //           text:
  //               'สินค้าเหลือเพียง ${param['product_variant']['data']['stock']} ชิ้น เท่านั้น');
  //       return null;
  //     } else {
  //       param['qty']++;
  //       // _updateCart(param);
  //     }
  //   }
  // }

  // _updateCart(param) {
  //   setState(() {
  //     widget;
  //     put(server + 'carts/' + param['id'], {
  //       'product_variant_id': param['product_variant_id'],
  //       'quantity': param['quantity']
  //     });
  //   });
  // }
}
