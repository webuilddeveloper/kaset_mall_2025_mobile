// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/component/toast_fail.dart';
import 'package:kasetmall/confirm_order.dart';
import 'package:kasetmall/menu.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/widget/show_loading.dart';

class CartCentralPage extends StatefulWidget {
  const CartCentralPage({Key? key, this.changePage}) : super(key: key);

  @override
  State<CartCentralPage> createState() => _CartCentralPageState();
  final Function? changePage;
}

class AdaptiveTextSize {
  const AdaptiveTextSize();

  getadaptiveTextSize(BuildContext context, dynamic value) {
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

    setState(() {});

    _readLocalCart();
  }

  _readLocalCart() async {
    setState(() {
      loading = true;
    });

    final storage = FlutterSecureStorage();
    String? cartData = await storage.read(key: 'cartItems');

    if (cartData != null && cartData.isNotEmpty) {
      List<dynamic> cartList = jsonDecode(cartData);

      for (var e in cartList) {
        e['selected'] = false;
      }

      setState(() {
        model = cartList;
        loading = false;
      });
    } else {
      setState(() {
        model = [];
        loading = false;
      });
    }
  }

  checkItem(int indexItem) {
    if (model[indexItem]['stock'] > 0) {
      setState(
        () {
          model[indexItem]['selected'] = !model[indexItem]['selected'];
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
          (e) {
            if (e['stock'] > 0) {
              e['selected'] = buyAll;
            }
            ;
          },
        );
      },
    );
  }

  String _priceAll() {
    num totalPrice = 0;

    for (var item in model) {
      if (item['selected'] == true) {
        num price = num.tryParse(item['price'].toString()) ?? 0;
        num qty = num.tryParse(item['qty'].toString()) ?? 0;
        totalPrice += (price * qty);
      }
    }

    return '${formatPrice(totalPrice.round().toString())} บาท';
  }

  String _calculateItemPrice(dynamic item) {
    num price = num.tryParse(item['price'].toString()) ?? 0;
    num qty = num.tryParse(item['qty'].toString()) ?? 0;
    num total = price * qty;

    return total.round().toString();
  }

  String formatPrice(dynamic price) {
    if (price == null) return '0';
    final number = num.tryParse(price.toString()) ?? 0;
    return NumberFormat('#,###').format(number);
  }

  _changeCarts(action, param) async {
    if (action == 0) {
      if (param['qty'] == 1) {
        return null;
      } else {
        setState(() {
          param['qty']--;
        });
        await _saveCartToStorage();
      }
    } else {
      int stock = param['stock'] ?? 999;

      if (param['qty'] >= stock) {
        toastFail(context, text: 'สินค้าเหลือเพียง $stock ชิ้น เท่านั้น');
        return null;
      } else {
        setState(() {
          param['qty']++;
        });
        await _saveCartToStorage();
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
    model.removeWhere((item) => item['selected'] == true);
    await _saveCartToStorage();

    setState(() {
      loading = false;
      buyAll = false;
    });

    Navigator.pop(context);
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
                    if (widget.changePage != null) {
                      widget.changePage!(0);
                    } else {
                      Navigator.pop(context); // fallback ถ้าไม่มี changePage
                    }
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
          if (model.isEmpty)
            _cartEmpty()
          else ...[
            SizedBox(
              height: double.infinity,
              child: Container(
                margin: EdgeInsets.only(
                  bottom: AdaptiveTextSize().getadaptiveTextSize(context, 45) +
                      MediaQuery.of(context).padding.bottom,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, indexItem) =>
                      _buildCard(model[indexItem], indexItem),
                  separatorBuilder: (_, __) => SizedBox(
                    height: AdaptiveTextSize().getadaptiveTextSize(context, 10),
                  ),
                  itemCount: model.length,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
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
                      style: TextStyle(fontSize: 13),
                      textScaleFactor: ScaleSize.textScaleFactor(context),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'ยอดรวม',
                      style: TextStyle(fontSize: 13),
                      textScaleFactor: ScaleSize.textScaleFactor(context),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _priceAll(),
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

                        if (data.isNotEmpty) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConfirmOrderCentralPage(
                                  modelCode: data, type: 'cart'),
                            ),
                          );

                          await _readLocalCart();
                        } else {
                          toastFail(context,
                              text: 'กรุณาเลือกสินค้าที่ต้องการชำระเงิน');
                        }
                      },
                      child: Container(
                        color: Color(0xFFDF0B24),
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        child: Text(
                          'ชำระเงิน ',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                          textScaleFactor: ScaleSize.textScaleFactor(context),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
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
          onTap: () async {},
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
                                style: TextStyle(
                                  fontSize: 13,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                textScaleFactor:
                                    ScaleSize.textScaleFactor(context),
                                maxLines: 2,
                              ),
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
                                        param['name'],
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
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height:
                            AdaptiveTextSize().getadaptiveTextSize(context, 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${formatPrice(_calculateItemPrice(param))} บาท',
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
            'ตะกร้ายังว่างอยู่ ต้องหาอะไรมาเพิ่มหน่อยแล้ว!',
            style: TextStyle(fontFamily: 'Kanit', fontSize: 15),
          ),
          SizedBox(height: 15),
          Image.asset(
            'assets/images/kaset/basket.png',
            height: 50,
            width: 50,
            color: Color(0xFF09665a),
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

  // _cartNoVerify() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text(
  //           'บัญชีนี้ยังไม่ได้ยืนยันเบอร์โทรศัพท์',
  //           style: TextStyle(fontFamily: 'Kanit', fontSize: 18),
  //         ),
  //         SizedBox(height: 15),
  //         Icon(Icons.perm_device_info, size: 70, color: Color(0xFFDF0B24)),
  //         // Image.asset(
  //         //   'assets/images/kaset/basket.png',
  //         //   height: 50,
  //         //   width: 50,
  //         //   color: Color(0xFF09665a),
  //         // ),
  //         SizedBox(height: 15),
  //         InkWell(
  //           onTap: () {},
  //           // Navigator.pushAndRemoveUntil(
  //           //     context,
  //           //     MaterialPageRoute(builder: (context) => VerifyPhonePage()),
  //           //     (route) => false),
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(3),
  //               border: Border.all(
  //                 width: 1,
  //                 color: Color(0xFFDF0B24),
  //               ),
  //             ),
  //             child: Text(
  //               'ยืนยันเบอร์โทรศัพท์',
  //               style: TextStyle(
  //                 fontFamily: 'Kanit',
  //                 fontSize: 15,
  //                 color: Color(0xFFDF0B24),
  //               ),
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  // _cartNoAddPhone() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text(
  //           'บัญชีนี้ยังไม่ได้เพิ่มเบอร์โทรศัพท์',
  //           style: TextStyle(fontFamily: 'Kanit', fontSize: 18),
  //         ),
  //         SizedBox(height: 15),
  //         Icon(Icons.add_call, size: 70, color: Color(0xFFDF0B24)),
  //         // Image.asset(
  //         //   'assets/images/kaset/basket.png',
  //         //   height: 50,
  //         //   width: 50,
  //         //   color: Color(0xFF09665a),
  //         // ),
  //         SizedBox(height: 15),
  //         InkWell(
  //           onTap: () => {
  //             // Navigator.push(
  //             //     context,
  //             //     MaterialPageRoute(
  //             //       builder: (BuildContext context) =>
  //             //           UserProfileForm(mode: "addPhone"),
  //             //     )).then((value) => {_readProfile()})
  //           },
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(3),
  //               border: Border.all(
  //                 width: 1,
  //                 color: Color(0xFFDF0B24),
  //               ),
  //             ),
  //             child: Text(
  //               'เพิ่มเบอร์โทรศัพท์',
  //               style: TextStyle(
  //                 fontFamily: 'Kanit',
  //                 fontSize: 15,
  //                 color: Color(0xFFDF0B24),
  //               ),
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

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
                      color: Color(0xFF09665a),
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
                      color: Color(0xFF09665a),
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

 
}
