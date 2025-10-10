// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_mart_v3/blank_page/blank_loading.dart';
import 'package:mobile_mart_v3/chats_staff.dart';
import 'package:mobile_mart_v3/component/gallery_view.dart';
import 'package:mobile_mart_v3/component/link_url_in.dart';
import 'package:mobile_mart_v3/component/loading_image_network.dart';
import 'package:mobile_mart_v3/login.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/shared/extension.dart';
import 'package:mobile_mart_v3/user_profile_form.dart';
import 'package:mobile_mart_v3/verify_phone.dart';
import 'package:mobile_mart_v3/widget/data_error.dart';
import 'package:mobile_mart_v3/widget/show_loading.dart';
import 'package:mobile_mart_v3/widget/stack_tap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toast/toast.dart';

import 'package:flutter/material.dart';
import 'dart:async';

import 'cart.dart';
import 'confirm_order.dart';

class ProductFormCentralPage extends StatefulWidget {
  ProductFormCentralPage({Key? key, this.model}) : super(key: key);
  final dynamic model;

  @override
  _ProductFormCentralPageState createState() => _ProductFormCentralPageState();
}

class _ProductFormCentralPageState extends State<ProductFormCentralPage> {
  _ProductFormCentralPageState();
  bool clickArrow = false;

  final storage = new FlutterSecureStorage();
  String? profileCode;
  dynamic model;
  List<dynamic>? imageVariantsList;

  Future<dynamic>? _futureModel;
  Future<dynamic>? _futureProductDetailModel;
  Future<dynamic>? _futureSameProduct;
  Future<dynamic>? _futureComment;
  String? code;
  List urlImage = [];
  bool like = false;
  dynamic tempData;
  String shopCode = '';
  String shopName = '';
  bool loading = false;

  String selectedType = '0';

  int productQty = 1;
  int maxProduct = 16;
  String selectedInventory = '';
  dynamic selectedInventoryModel;
  int amountItemInCart = 0;
  int _currentImage = 0;
  List<String> galleryList = [''];
  String verifyPhonePage = 'false';
  int index = 0;
  TextEditingController qtyController = TextEditingController();
  bool loadingAddCart = false;
  String? profilePhone;
  String? verifyPhone;

  String? _userId = "";
  String? _username = "";

  @override
  void initState() {
    super.initState();
    read();
    sharedApi();
    _readUser();
  }

  _readUser() async {
    try {
      final result = await get(server + 'users/me');
      print(result['id']);
      if (result != null) {
        _userId = result['id'] ?? '';
        _username = result?['name'] ?? '';
      } else {
        print('No result from API');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  _getUserData() async {
    var a = await storage.read(key: 'phoneVerified') ?? '';
    setState(() {
      verifyPhonePage = a;
    });
  }

  read() async {
    print('model ============ ${widget.model}');
    print('img : ${widget.model['image']}');
    print(widget.model['image'].runtimeType);
    _getUserData();
    profilePhone = (await storage.read(key: 'profilePhone'));
    verifyPhone = (await storage.read(key: 'phoneVerified'));
    profileCode = (await storage.read(key: 'profileCode10'));
    getCountItemInCartV2();

    // readFavoriteProduct();
    readGoodsInventory();
    // _readComment();
    // _futureComment = getData(server + 'products/${widget.model['id']}/reviews');
    setState(() {
      tempData = {
        'price': 0,
        'netPrice': 0,
        'minPrice': 0,
        'maxPrice': 0,
        'like': false,
        'rating': 0.0,
        ...widget.model
      };

      print('================= tempData =================');
      print(tempData);
    });
  }

  Future<dynamic> sharedApi() async {
    var value = await postConfigShare();
    setState(() {
      if (value['status'] == 'S') {
        setState(() {});
      }
    });
  }

  // readFavoriteProduct() async {
  //   await get(server + 'users/me/favorite-products').then((value) async {
  //     List<dynamic> arr = value ?? [];
  //     if (arr.isNotEmpty) {
  //       var a = arr.where((x) => x['id'] == widget.model['id']).toList();

  //       if (a.isNotEmpty) {
  //         setState(() {
  //           like = true;
  //         });
  //       }
  //     }
  //   });
  // }

  getCountItemInCartV2() async {
    //get amount item in cart.
    await get(server + 'carts').then((value) async {
      if (value != null)
        setState(() {
          amountItemInCart = value.length;
        });
    });
  }

  readGoodsInventory() async {
    // print(server + 'products/' + widget.model['id']);
    setState(() {
      _futureProductDetailModel = Future.value(widget.model);
      // getData(server + 'products/' + widget.model['id']);
      _futureProductDetailModel!.then((value) => {
            setState(() {
              imageVariantsList = value['image'];
            })
          });
    });
    // return await getData(server + 'products/' + widget.model['id']);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    ToastContext().init(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FutureBuilder<dynamic>(
            future: _futureModel,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                print('--1---');
                return Stack(
                  children: [
                    buildDetail(snapshot.data[0]),
                    buildBtnBottom(snapshot.data[0]),
                  ],
                );
              } else if (snapshot.hasError) {
                return Stack(
                  children: [
                    DataError(onTap: () => read()),
                    buildBtnHeader(),
                  ],
                );
              } else {
                if (widget.model != null) {
                  return Container(
                    // color: Colors.amber,
                    height: double.maxFinite,
                    child: Column(
                      children: [
                        // Expanded(
                        //   flex: 1,
                        //   child: buildBtnBottom(
                        //     tempData), // add cart button, buy now button.

                        // ),
                        Expanded(
                          child: Stack(children: [
                            // buildBtnHeaderShare(),
                            buildDetail(tempData), // detail && same product.
                            buildBtnHeader(), // back button, cart page button, other button.
                            // SizedBox(height: 15),
                          ]),
                          flex: 12,
                        ),
                        buildBtnBottom(tempData)
                        // Flexible(
                        //   // flex: 1,
                        //   child: buildBtnBottom(
                        //       tempData), // add cart button, buy now button.
                        // )
                      ],
                    ),
                  );
                } else {
                  return BlankLoading();
                }
              }
            },
          ),
        ));
  }

  buildBtnBottom(model) {
    return Container(
      height: AdaptiveTextSize().getadaptiveTextSize(context, 60),
      width: double.infinity,
      color: Colors.white,
      child: model != null &&
              model['image'] != null &&
              model['image'].isNotEmpty
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  child: StackTap(
                    onTap: () {
                      // ##### ถูกใจ #####
                      setState(() => like = !like);

                      // if (profileCode != '' && profileCode != null) {
                      //   if (profilePhone == null || profilePhone == '') {
                      //     _dialogCheckPhone();
                      //   } else if (verifyPhonePage == 'true') {
                      //     setState(() => like = !like);
                      //     if (like == true) {
                      //       postObjectData(
                      //           server +
                      //               'products/' +
                      //               widget.model['id'] +
                      //               '/favorite',
                      //           {});
                      //     } else {
                      //       delete(
                      //         server +
                      //             'products/' +
                      //             widget.model['id'] +
                      //             '/favorite',
                      //       );
                      //     }
                      //     ;
                      //   } else {
                      //     _dialogCheckVerify();
                      //   }
                      // } else {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (BuildContext context) =>
                      //           LoginCentralPage(),
                      //     ),
                      //   );
                      // }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            like
                                ? 'assets/images/heart_full.png'
                                : 'assets/images/heart.png',
                            height: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 25),
                            width: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 25),
                            color: like ? Colors.red : Color(0xFF09665a),
                          ),
                          Text(
                            'ถูกใจ',
                            // (MediaQuery.maybeOf(context).size.height / MediaQuery.maybeOf(context).size.width).toString(),
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 13,
                              color: like ? Colors.red : Color(0xFF09665a),
                            ),
                            textScaleFactor: ScaleSize.textScaleFactor(context),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                // รถเข็น
                Flexible(
                  flex: 1,
                  child: StackTap(
                    onTap: () => {
                      // if (profileCode != '' && profileCode != null)
                      // {
                      // if (profilePhone == null || profilePhone == '')
                      //   {
                      //     _dialogCheckPhone(),
                      //   }
                      // else if (verifyPhonePage == 'true')
                      //   {
                      buildModal('cart')
                          .then((value) => getCountItemInCartV2()),
                      // }
                      // else
                      //   {
                      //     _dialogCheckVerify(),
                      //   }
                      // }
                      // else
                      //   {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (BuildContext context) =>
                      //             LoginCentralPage(),
                      //       ),
                      //     )
                      //   }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/cart.png',
                            height: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 25),
                            width: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 25),
                            color: Color(0xFF09665a),
                          ),
                          Text(
                            'ใส่รถเข็น',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 13,
                              color: Color(0xFF09665a),
                            ),
                            textScaleFactor: ScaleSize.textScaleFactor(context),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                //ชื้อเลย
                Flexible(
                  flex: 2,
                  child: StackTap(
                    onTap: () => {
                      // if (profileCode != '' && profileCode != null)
                      //   {
                      //     if (profilePhone == null || profilePhone == '')
                      //       {
                      //         _dialogCheckPhone(),
                      //       }
                      //     else if (verifyPhone == 'true')
                      //       {
                      buildModal('buy'),
                      //   }
                      // else
                      //   {
                      //     _dialogCheckVerify(),
                      //   }
                      // }
                      // else
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (BuildContext context) =>
                      //           LoginCentralPage(),
                      //     ),
                      //   )
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      color: Color(0xFF09665a),
                      child: Text(
                        'ซื้อเลย',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  child: StackTap(
                    onTap: () {
                      if (profileCode != '' && profileCode != null) {
                        if (profilePhone == null || profilePhone == '') {
                          _dialogCheckPhone();
                        } else if (verifyPhonePage == 'true') {
                          setState(() => like = !like);
                          if (like == true) {
                            postObjectData(
                                server +
                                    'products/' +
                                    widget.model['id'] +
                                    '/favorite',
                                {});
                          } else {
                            delete(
                              server +
                                  'products/' +
                                  widget.model['id'] +
                                  '/favorite',
                            );
                          }
                          ;
                        } else {
                          _dialogCheckVerify();
                        }
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                LoginCentralPage(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            like
                                ? 'assets/images/heart_full.png'
                                : 'assets/images/heart.png',
                            height: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 25),
                            width: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 25),
                            color: like ? Colors.red : Color(0xFF09665a),
                          ),
                          Text(
                            'ถูกใจ',
                            // (MediaQuery.maybeOf(context).size.height / MediaQuery.maybeOf(context).size.width).toString(),
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 13,
                              color: like ? Colors.red : Color(0xFF09665a),
                            ),
                            textScaleFactor: ScaleSize.textScaleFactor(context),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
    // );
  }

  _dialogCheckVerify() {
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
                'บัญชีนี้ยังไม่ได้ยืนยันเบอร์โทรศัพท์\nกด ตกลง เพื่อยืนยัน',
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
                      color: Color(0xFFc50817),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerifyPhonePage(),
                      ),
                    );
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: false,
                  child: new Text(
                    "ไม่ใช่ตอนนี้",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFF000000),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                ),
              ],
            ),
          );
        });
  }

  _dialogCheckPhone() {
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
                'บัญชีนี้ยังไม่ได้เพิ่มเบอร์โทรศัพท์',
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
                    "เพิ่ม",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFFc50817),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              UserProfileForm(mode: "addPhone"),
                        )).then((value) => {read()});
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: false,
                  child: new Text(
                    "ไม่ใช่ตอนนี้",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFF000000),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                ),
              ],
            ),
          );
        });
  }

  Positioned buildBtnHeader() {
    return Positioned(
      left: 15,
      right: 0,
      // top: MediaQuery.of(context).padding.top + 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              // width: 35,
              // height: 35,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFF09665a).withOpacity(0.4),
              ),
              child: Icon(
                Icons.close,
                size: AdaptiveTextSize().getadaptiveTextSize(context, 25),
                color: Color(0xFF09665a),
              ),
            ),
          ),
          // Container(
          //   height: AdaptiveTextSize().getadaptiveTextSize(context, 42),
          //   width: AdaptiveTextSize().getadaptiveTextSize(context, 130),
          //   padding: EdgeInsets.symmetric(horizontal: 10),
          //   // alignment: Alignment.center,
          //   decoration: BoxDecoration(
          //       borderRadius: BorderRadius.horizontal(
          //         left: Radius.circular(40),
          //       ),
          //       gradient: LinearGradient(
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //         colors: [
          //           Color(0xFFDF0B24),
          //           Color(0xFFB80711),
          //         ],
          //       )),
          //   child: Row(
          //     // crossAxisAlignment: CrossAxisAlignment.center,
          //     // mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Icon(
          //         Icons.check_circle_rounded,
          //         color: Colors.white,
          //         size: AdaptiveTextSize().getadaptiveTextSize(context, 20),
          //       ),
          //       SizedBox(width: 7),
          //       Expanded(
          //         child: Text(
          //           'เป็นพันธมิตร \nกับองค์การค้า',
          //           style: TextStyle(
          //             fontSize: 11,
          //             color: Colors.white,
          //             fontWeight: FontWeight.bold,
          //           ),
          //           textScaleFactor: ScaleSize.textScaleFactor(context),
          //         ),
          //       )
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  Positioned buildBtnHeaderShare() {
    return Positioned(
      left: 15,
      right: 5,
      top: MediaQuery.of(context).padding.top + 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              final RenderBox? box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                Share.share(
                  'dlapp.we-builds.com/' +
                      'ssp-app' +
                      '?code=' +
                      '${widget.model['id']}',
                  subject: '${widget.model?['name']}',
                  sharePositionOrigin:
                      box.localToGlobal(Offset.zero) & box.size,
                );
              }
            },
            child: Container(
              // width: 35,
              // height: 35,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFFE3E6FE).withOpacity(0.7),
              ),
              child: Icon(
                Icons.share,
                size: AdaptiveTextSize().getadaptiveTextSize(context, 25),
                color: Color(0xFF09665a),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildDetail(dynamic model) {
    List<dynamic> images = [];

    try {
      if (model != null &&
          model['image'] != null &&
          model['image'].toString().isNotEmpty) {
        final imageData = model['image'];

        if (imageData.trim().startsWith('[')) {
          // 🔹 ถ้าเป็น JSON array เช่น ["url1", "url2"]
          images = jsonDecode(imageData);
        } else {
          // 🔹 ถ้าเป็น URL เดี่ยว
          images = [imageData];
        }
      }
    } catch (e) {
      print('❌ Error decoding images: $e');
      images = [];
    }
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        imageProductView(images),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: new TextSpan(
                            children: <TextSpan>[
                              new TextSpan(
                                text: '${model?['price']} บาท',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF09665a),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${model?['name']}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w500,
                          ),
                          textScaleFactor: ScaleSize.textScaleFactor(context),
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: model?['description'] != 'null'
                                ? Html(
                                    data: model?['description'] ?? '',
                                    onLinkTap: (url, attributes, element) {
                                      if (url != null) {
                                        launchInWebViewWithJavaScript(url);
                                      }
                                    },
                                  )
                                : SizedBox()),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 15),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Row(
              //         children: [
              //           ratingBar(model['rating']),
              //           SizedBox(width: 5),
              //           if (model['rating'] > 0)
              //             Text(
              //               double.parse(model['rating'].toString())
              //                       .toStringAsFixed(1) +
              //                   '/5',
              //               style: TextStyle(
              //                 fontFamily: 'Kanit',
              //                 fontSize: 14,
              //                 color: Colors.red,
              //               ),
              //             ),
              //           SizedBox(width: 5),
              //           Text(
              //             '(' + model['totalComment'].toString() + ' รีวิว)',
              //             style: TextStyle(
              //                 fontFamily: 'Kanit',
              //                 fontSize: 13,
              //                 color: Colors.grey[600]),
              //           ),
              //         ],
              //       ),
              //       Row(
              //         children: [
              //           StatefulBuilder(
              //             builder: (context, setState) {
              //               return InkWell(
              //                 onTap: () {
              //                   setState(() {
              //                     like = !like;
              //                   });
              //                   postDio(
              //                     server + 'm/like/check',
              //                     {
              //                       'reference': model['code'],
              //                       'isActive': like,
              //                       'category': model['category'],
              //                     },
              //                   );
              //                 },
              //                 child: Image.asset(
              //                   like
              //                       ? 'assets/images/heart_full.png'
              //                       : 'assets/images/heart.png',
              //                   height: 20,
              //                   width: 20,
              //                   color: like ? Colors.red : Colors.black,
              //                 ),
              //               );
              //             },
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),

              // SizedBox(height: 25),

              FutureBuilder(
                  future: _futureModel,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row(
                          //   children: [
                          //     Text(
                          //       'ตัวเลือกสินค้า ',
                          //       style: TextStyle(
                          //         fontSize: 15,
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //       textScaleFactor:
                          //           ScaleSize.textScaleFactor(context),
                          //     ),
                          //     Text(
                          //       '${snapshot.data?['product_variants']['data'].length} แบบ',
                          //       style: TextStyle(
                          //         fontSize: 13,
                          //         color: Color(0xFF707070),
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //       textScaleFactor:
                          //           ScaleSize.textScaleFactor(context),
                          //     ),
                          //   ],
                          // ),
                          // ),
                          Container(
                            height: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 60),
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: GestureDetector(
                                  onTap: () {
                                    // setState(() {
                                    //   selectedInventory =
                                    //       snapshot.data?['product_variants']
                                    //           ['data'][index]['id'];
                                    //   selectedInventoryModel =
                                    //       snapshot.data?['product_variants']
                                    //           ['data'][index];
                                    //   if (selectedInventoryModel['media_id'] ==
                                    //       null) {
                                    //     selectedInventoryModel['url'] = null;
                                    //   } else {
                                    //     var url = snapshot.data['media']['data']
                                    //         .firstWhere((i) =>
                                    //             i['id'] ==
                                    //             selectedInventoryModel[
                                    //                 'media_id']);
                                    //     selectedInventoryModel['url'] =
                                    //         url['url'];
                                    //   }
                                    // });
                                    // if (profileCode != '' &&
                                    //     profileCode != null) {
                                    // if (profilePhone == null ||
                                    //     profilePhone == '') {
                                    //   print('---------- this 1');
                                    //   _dialogCheckPhone();
                                    // } else if (verifyPhonePage == 'true') {
                                    print('---------- this 2');
                                    buildModal('cart').then(
                                        (value) => getCountItemInCartV2());
                                    // }
                                    // else {
                                    //   print('---------- this 3');
                                    //   _dialogCheckVerify();
                                    // }
                                    // }
                                    // else {
                                    //   print('---------- this 4');
                                    //   Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //       builder: (BuildContext context) =>
                                    //           LoginCentralPage(),
                                    //     ),
                                    //   );
                                    // }
                                  },
                                  child: snapshot.data['image'].length <= 0
                                      ? Image.asset(
                                          'assets/images/kaset/no-img.png',
                                          // fit: BoxFit.contain,
                                          width: AdaptiveTextSize()
                                              .getadaptiveTextSize(context, 50),
                                          height: AdaptiveTextSize()
                                              .getadaptiveTextSize(context, 50),
                                        )
                                      : _checkImage(snapshot.data?['image']) ==
                                              null
                                          ? Image.asset(
                                              'assets/images/kaset/no-img.png',
                                              // fit: BoxFit.contain,
                                              width: AdaptiveTextSize()
                                                  .getadaptiveTextSize(
                                                      context, 50),
                                              height: AdaptiveTextSize()
                                                  .getadaptiveTextSize(
                                                      context, 50),
                                            )
                                          : loadingImageNetwork(
                                              _checkImage(
                                                  snapshot.data?['image']),
                                              height: AdaptiveTextSize()
                                                  .getadaptiveTextSize(
                                                      context, 50),
                                              width: AdaptiveTextSize()
                                                  .getadaptiveTextSize(
                                                      context, 50),
                                            ),
                                ),
                              ),
                              separatorBuilder: (_, __) => SizedBox(width: 15),
                              itemCount: snapshot.data?['image'].length,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  }),

              SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "การจัดส่ง",
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w500,
                    ),
                    textScaleFactor: ScaleSize.textScaleFactor(context),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "(โดยประมาณ)",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w300,
                    ),
                    textScaleFactor: ScaleSize.textScaleFactor(context),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "แบบธรรมดา (รับภายใน 3-5 วัน)",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF707070),
                    ),
                    textScaleFactor: ScaleSize.textScaleFactor(context),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    "30 บาท",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w500,
                    ),
                    textScaleFactor: ScaleSize.textScaleFactor(context),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),

              SizedBox(height: 25),
              _buildReview(),
              buildSameProduct(),
              Container(
                height: 80 + MediaQuery.of(context).padding.bottom,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container buildDiscountTag(model) {
    String unit = model['disCountUnit'] == 'C' ? ' บาท' : '%';

    return Container(
      height: 65,
      constraints: BoxConstraints(minWidth: 50),
      alignment: Alignment.center,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'ลด\n${model['discount']}' + unit,
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 15,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // -------------- widget method
  Widget imageProductView(List<dynamic> listImage) {
    return Stack(
      children: [
        Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(
                maxHeight:
                    AdaptiveTextSize().getadaptiveTextSize(context, 400)),
            child: listImage.length <= 0
                ? Image.asset(
                    'assets/images/kaset/no-img.png',
                    // "",
                    fit: BoxFit.contain,
                    height: double.infinity,
                    width: double.infinity,
                  )
                : CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.width,
                      aspectRatio: 5.0,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      enableInfiniteScroll:
                          listImage.length > 1, // ถ้ามีรูปเดียว ปิดเลื่อนวนซ้ำ
                      scrollPhysics: listImage.length > 1
                          ? BouncingScrollPhysics()
                          : NeverScrollableScrollPhysics(), // ปิดการเลื่อน
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImage = index;
                        });
                      },
                    ),
                    items: listImage.map((i) {
                      final imageUrl = i is String ? i : i['url'].toString();
                      return GestureDetector(
                        onTap: () => showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return ImageViewer(
                              initialIndex: _currentImage,
                              imageProviders: listImage
                                  .map((e) => NetworkImage(
                                      e is String ? e : e['url'].toString()))
                                  .toList(),
                            );
                          },
                        ),
                        child: loadingImageNetwork(
                          imageUrl,
                          fit: BoxFit.contain,
                          height: AdaptiveTextSize()
                              .getadaptiveTextSize(context, double.infinity),
                          width: AdaptiveTextSize()
                              .getadaptiveTextSize(context, double.infinity),
                        ),
                      );
                    }).toList(),
                  )),
        // buildBtnHeader(), // back button, cart page button, other button.
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentImage + 1}/${listImage.length}',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF707070),
              ),
              textScaleFactor: ScaleSize.textScaleFactor(context),
            ),
          ),
        )
      ],
    );
  }

  buildSameProduct() {
    return FutureBuilder(
      future: _futureSameProduct,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print('------------------ same product ---------------');
          print(snapshot.data);
          return Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 280,
            ),
            child: Column(
              children: [
                SizedBox(height: 15),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'สินค้าที่น่าสนใจ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ดูทั้งหมด',
                        style: TextStyle(
                          color: Color(0xFF09665a),
                          fontSize: 13,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 250,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length,
                    separatorBuilder: (_, __) => SizedBox(width: 15),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductFormCentralPage(
                                model: snapshot.data[index],
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 165,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 165,
                                width: 165,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  color: Colors.white,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: loadingImageNetwork(
                                    snapshot.data[index]['imageUrl'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return Container(height: 150);
        }
      },
    );
  }

  buildModal(String type) {
    setState(() {
      productQty = 1;
      qtyController.text = productQty.toString();
    });

    return showCupertinoModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return FutureBuilder(
                future: _futureProductDetailModel,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == null) {
                      return Container();
                    }

                    var model = snapshot.data;

                    if (model['stock'] == null) {
                      model['stock'] = 0;
                    }
                    return Material(
                      type: MaterialType.transparency,
                      child: Container(
                        height:
                            WidgetsBinding.instance.window.viewInsets.bottom >
                                    0.0
                                ? MediaQuery.of(context).size.height
                                : MediaQuery.of(context).size.height * 0.60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(40),
                          ),
                        ),
                        child: Scaffold(
                          body: ShowLoadingWidget(
                            loading: loadingAddCart,
                            children: [
                              Stack(
                                children: [
                                  Positioned(
                                    top: AdaptiveTextSize()
                                        .getadaptiveTextSize(context, 15),
                                    right: AdaptiveTextSize()
                                        .getadaptiveTextSize(context, 15),
                                    child: InkWell(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        height: AdaptiveTextSize()
                                            .getadaptiveTextSize(context, 35),
                                        width: AdaptiveTextSize()
                                            .getadaptiveTextSize(context, 35),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF09665a),
                                        ),
                                        child: Icon(
                                          Icons.clear,
                                          size: AdaptiveTextSize()
                                              .getadaptiveTextSize(context, 20),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        25,
                                        AdaptiveTextSize()
                                            .getadaptiveTextSize(context, 50),
                                        15,
                                        80),
                                    child: ListView(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            // แสดงรูปภาพสินค้า
                                            Container(
                                              height: AdaptiveTextSize()
                                                  .getadaptiveTextSize(
                                                      context, 130),
                                              width: AdaptiveTextSize()
                                                  .getadaptiveTextSize(
                                                      context, 100),
                                              child: model['image'] != null &&
                                                      model['image']
                                                          .toString()
                                                          .isNotEmpty
                                                  ? loadingImageNetwork(
                                                      model['image'],
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/kaset/no-img.png',
                                                      fit: BoxFit.contain,
                                                    ),
                                            ),
                                            SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // ชื่อสินค้า
                                                  Text(
                                                    model['name'] ?? '',
                                                    style: TextStyle(
                                                      fontFamily: 'Kanit',
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                    ),
                                                    textScaleFactor: ScaleSize
                                                        .textScaleFactor(
                                                            context),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    "${model['price']} บาท",
                                                    style: TextStyle(
                                                      fontSize: 23,
                                                      fontFamily: 'Kanit',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textScaleFactor: ScaleSize
                                                        .textScaleFactor(
                                                            context),
                                                  ),
                                                  // แสดงจำนวนสต็อก
                                                  Text(
                                                    'คลัง : ' +
                                                        (model['stock'] ?? 0)
                                                            .toString() +
                                                        ' ชิ้น',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontFamily: 'Kanit',
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    textScaleFactor: ScaleSize
                                                        .textScaleFactor(
                                                            context),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 15),

                                        // คำอธิบายสินค้า
                                        if (model['description'] != null &&
                                            model['description']
                                                .toString()
                                                .isNotEmpty) ...[
                                          Text(
                                            'รายละเอียดสินค้า',
                                            style: TextStyle(
                                              fontFamily: 'Kanit',
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textScaleFactor:
                                                ScaleSize.textScaleFactor(
                                                    context),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            model['description'],
                                            style: TextStyle(
                                              fontFamily: 'Kanit',
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                            textScaleFactor:
                                                ScaleSize.textScaleFactor(
                                                    context),
                                          ),
                                          SizedBox(height: 15),
                                        ],

                                        // จำนวนสินค้า
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'จำนวน',
                                              style: TextStyle(
                                                fontFamily: 'Kanit',
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textScaleFactor:
                                                  ScaleSize.textScaleFactor(
                                                      context),
                                            ),
                                            Row(
                                              children: [
                                                // ปุ่มลด
                                                InkWell(
                                                  onTap: () => setState(() {
                                                    if (productQty > 1) {
                                                      productQty--;
                                                    }
                                                    qtyController.text =
                                                        productQty.toString();
                                                  }),
                                                  child: Container(
                                                    height: AdaptiveTextSize()
                                                        .getadaptiveTextSize(
                                                            context, 30),
                                                    width: AdaptiveTextSize()
                                                        .getadaptiveTextSize(
                                                            context, 30),
                                                    alignment:
                                                        Alignment.topCenter,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                      border: Border.all(
                                                        width: 1,
                                                        color: productQty == 1
                                                            ? Color(0xFFFAF9F9)
                                                            : Color(0xFFF7F7F7),
                                                      ),
                                                      color: productQty == 1
                                                          ? Color(0xFFFAF9F9)
                                                          : Color(0xFFF7F7F7),
                                                    ),
                                                    child: Text(
                                                      '-',
                                                      style: TextStyle(
                                                        fontFamily: 'Kanit',
                                                        fontSize: 16,
                                                        color: productQty == 1
                                                            ? Colors.grey[400]
                                                            : Color(0xFF707070),
                                                      ),
                                                      textScaleFactor: ScaleSize
                                                          .textScaleFactor(
                                                              context),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                // ช่องกรอกจำนวน
                                                Container(
                                                  width: AdaptiveTextSize()
                                                      .getadaptiveTextSize(
                                                          context, 50),
                                                  height: AdaptiveTextSize()
                                                      .getadaptiveTextSize(
                                                          context, 30),
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    controller: qtyController,
                                                    style: TextStyle(
                                                      fontSize: AdaptiveTextSize()
                                                          .getadaptiveTextSize(
                                                              context, 13),
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.black,
                                                    ),
                                                    cursorColor:
                                                        Color(0xFF09665a),
                                                    decoration: InputDecoration(
                                                      fillColor: Colors.white,
                                                      filled: true,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFF09665a)),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFF09665a)),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide: BorderSide(
                                                          color: Colors.black
                                                              .withOpacity(0.2),
                                                        ),
                                                      ),
                                                      errorStyle:
                                                          const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 10.0,
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                    ),
                                                    onChanged: (value) {
                                                      if (value.isNotEmpty) {
                                                        int? qty =
                                                            int.tryParse(value);
                                                        if (qty != null &&
                                                            qty > 0) {
                                                          setState(() {
                                                            productQty = qty;
                                                          });
                                                        }
                                                      }
                                                    },
                                                    onSaved: (String? value) {},
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                // ปุ่มเพิ่ม
                                                InkWell(
                                                  onTap: () => setState(() {
                                                    if (productQty <
                                                        (model['stock'] ?? 0)) {
                                                      productQty++;
                                                    } else {
                                                      Toast.show(
                                                        'สินค้าในคลังเหลือแค่ ' +
                                                            (model['stock'] ??
                                                                    0)
                                                                .toString() +
                                                            ' ชิ้น',
                                                        backgroundColor:
                                                            Colors.red[800] ??
                                                                Colors.red,
                                                        duration: 3,
                                                        gravity: Toast.center,
                                                        textStyle: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      );
                                                    }
                                                    qtyController.text =
                                                        productQty.toString();
                                                  }),
                                                  child: Container(
                                                    height: AdaptiveTextSize()
                                                        .getadaptiveTextSize(
                                                            context, 30),
                                                    width: AdaptiveTextSize()
                                                        .getadaptiveTextSize(
                                                            context, 30),
                                                    alignment:
                                                        Alignment.topCenter,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                      border: Border.all(
                                                        width: 1,
                                                        color: (model['stock'] ??
                                                                    0) ==
                                                                productQty
                                                            ? Color.fromARGB(
                                                                255,
                                                                250,
                                                                249,
                                                                249)
                                                            : Color(0xFFF7F7F7),
                                                      ),
                                                      color: (model['stock'] ??
                                                                  0) ==
                                                              productQty
                                                          ? Color.fromARGB(255,
                                                              250, 249, 249)
                                                          : Color(0xFFF7F7F7),
                                                    ),
                                                    child: Text(
                                                      '+',
                                                      style: TextStyle(
                                                        fontFamily: 'Kanit',
                                                        fontSize: 16,
                                                        color:
                                                            (model['stock'] ??
                                                                        0) ==
                                                                    productQty
                                                                ? Colors
                                                                    .grey[400]
                                                                : Color(
                                                                    0xFF707070),
                                                      ),
                                                      textScaleFactor: ScaleSize
                                                          .textScaleFactor(
                                                              context),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  // ปุ่มด้านล่าง
                                  Positioned(
                                    bottom: 0 +
                                        MediaQuery.of(context).padding.bottom,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(15, 0, 15, 15),
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              int currentQty = int.tryParse(
                                                      qtyController.text) ??
                                                  0;
                                              int stock = model['stock'] ?? 0;

                                              if (stock <= 0) {
                                                Toast.show(
                                                  'สินค้าหมด',
                                                  backgroundColor:
                                                      Colors.red[800] ??
                                                          Colors.red,
                                                  duration: 3,
                                                  gravity: Toast.center,
                                                  textStyle: TextStyle(
                                                      color: Colors.white),
                                                );
                                                return;
                                              }

                                              if (currentQty <= 0) {
                                                Toast.show(
                                                  'กรุณาใส่จำนวนสินค้าอย่างน้อย 1 ชิ้น',
                                                  backgroundColor:
                                                      Colors.red[800] ??
                                                          Colors.red,
                                                  duration: 3,
                                                  gravity: Toast.center,
                                                  textStyle: TextStyle(
                                                      color: Colors.white),
                                                );
                                                return;
                                              }

                                              if (currentQty > stock) {
                                                Toast.show(
                                                  'สินค้าในคลังเหลือแค่ ' +
                                                      stock.toString() +
                                                      ' ชิ้น',
                                                  backgroundColor:
                                                      Colors.red[800] ??
                                                          Colors.red,
                                                  duration: 3,
                                                  gravity: Toast.center,
                                                  textStyle: TextStyle(
                                                      color: Colors.white),
                                                );
                                                return;
                                              }

                                              setState(() {
                                                loadingAddCart = true;
                                              });

                                              if (type == 'cart') {
                                                // เพิ่มสินค้าลงตะกร้า
                                                print('-----------------');
                                                print('เพิ่มสินค้าลงตะกร้า');
                                                print(model);
                                                print(model.runtimeType);
                                                await _addCart([model], 'cart');
                                                Navigator.pop(context);
                                                print('-----------------');
                                              } else {
                                                // ซื้อสินค้าทันที
                                                var result = await _addCart(
                                                    [model], 'buy');

                                                // List<dynamic> data = [
                                                //   {
                                                //     'product_name':
                                                //         model['name'],
                                                //     'url': model['image'],
                                                //     'product_variant':
                                                //         model['name'],
                                                //     'price': model['price'],
                                                //     'cart_id': model['id'],
                                                //     'quantity': currentQty,
                                                //     'promotion_price':
                                                //         model['netPrice'] ??
                                                //             model['price'],
                                                //     'isPromotion':
                                                //         model['price'] !=
                                                //             model['netPrice'],
                                                //   }
                                                // ];

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ConfirmOrderCentralPage(
                                                      modelCode: [model],
                                                      type: 'buy',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: ShowLoadingWidget(
                                              loading: loading,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10),
                                                  color:
                                                      (model['stock'] ?? 0) <= 0
                                                          ? Colors.grey
                                                          : Color(0xFF09665a),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    (model['stock'] ?? 0) <= 0
                                                        ? 'สินค้าหมด'
                                                        : type == 'cart'
                                                            ? 'เพิ่มไปยังรถเข็น'
                                                            : 'ซื้อสินค้า',
                                                    style: TextStyle(
                                                      fontFamily: 'Kanit',
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textScaleFactor: ScaleSize
                                                        .textScaleFactor(
                                                            context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Container();
                  } else {
                    return Container();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
  // buildModal(String type) {
  //   setState(() {
  //     productQty = 1;
  //     qtyController.text = productQty.toString();
  //   });

  //   return showCupertinoModalBottomSheet(
  //     context: context,
  //     barrierColor: Colors.black.withOpacity(0.3),
  //     backgroundColor: Colors.transparent,
  //     builder: (context) {
  //       return GestureDetector(
  //         onTap: () => FocusScope.of(context).unfocus(),
  //         child: StatefulBuilder(
  //           builder: (BuildContext context,
  //               StateSetter setState /*You can rename this!*/) {
  //             return FutureBuilder(
  //                 future: _futureProductDetailModel,
  //                 builder: (contect, snapshot) {
  //                   print(
  //                       '================== _futureProductDetailModel =================');
  //                   print(snapshot.data);
  //                   print(
  //                       '==============================================================');
  //                   if (snapshot.hasData) {
  //                     if (snapshot.data.length == 0) {
  //                       // toastFail(context, text: 'ไม่พบสินค้า', duration: 1);
  //                       // Navigator.pop(context, true);
  //                       return Container();
  //                     }
  //                     var model = snapshot.data?['image'];
  //                     if ((selectedInventory) == '') {
  //                       if (snapshot.data?['image'].length > 0) {
  //                         selectedInventory = snapshot.data?['image'];
  //                         selectedInventoryModel = snapshot.data?['image'];
  //                       }
  //                     }
  //                     return Material(
  //                       type: MaterialType.transparency,
  //                       child: new Container(
  //                         height:
  //                             WidgetsBinding.instance.window.viewInsets.bottom >
  //                                     0.0
  //                                 ? MediaQuery.of(context).size.height
  //                                 : MediaQuery.of(context).size.height * 0.60,
  //                         width: double.infinity,
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           borderRadius: BorderRadius.vertical(
  //                             top: Radius.circular(40),
  //                           ),
  //                         ),
  //                         child: Scaffold(
  //                             body: ShowLoadingWidget(
  //                           loading: loadingAddCart,
  //                           children: [
  //                             Stack(
  //                               children: [
  //                                 Positioned(
  //                                   top: AdaptiveTextSize()
  //                                       .getadaptiveTextSize(context, 15),
  //                                   right: AdaptiveTextSize()
  //                                       .getadaptiveTextSize(context, 15),
  //                                   child: InkWell(
  //                                     onTap: () => Navigator.pop(context),
  //                                     child: Container(
  //                                       height: AdaptiveTextSize()
  //                                           .getadaptiveTextSize(context, 35),
  //                                       width: AdaptiveTextSize()
  //                                           .getadaptiveTextSize(context, 35),
  //                                       decoration: BoxDecoration(
  //                                         shape: BoxShape.circle,
  //                                         color: Color(0xFF09665a),
  //                                       ),
  //                                       child: Icon(
  //                                         Icons.clear,
  //                                         size: AdaptiveTextSize()
  //                                             .getadaptiveTextSize(context, 20),
  //                                         color: Colors.white,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 Padding(
  //                                   padding: EdgeInsets.fromLTRB(
  //                                       25,
  //                                       AdaptiveTextSize()
  //                                           .getadaptiveTextSize(context, 50),
  //                                       15,
  //                                       80),
  //                                   child: ListView(
  //                                     // shrinkWrap: true,
  //                                     // physics: ClampingScrollPhysics(),
  //                                     children: [
  //                                       Row(
  //                                         crossAxisAlignment:
  //                                             CrossAxisAlignment.start,
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.start,
  //                                         children: [
  //                                           selectedInventoryModel != null
  //                                               ? Container(
  //                                                   height: AdaptiveTextSize()
  //                                                       .getadaptiveTextSize(
  //                                                           context, 130),
  //                                                   width: AdaptiveTextSize()
  //                                                       .getadaptiveTextSize(
  //                                                           context, 100),
  //                                                   child: selectedInventoryModel[
  //                                                               'url'] !=
  //                                                           null
  //                                                       ? loadingImageNetwork(
  //                                                           selectedInventoryModel[
  //                                                               'url'],
  //                                                           fit: BoxFit.cover,
  //                                                         )
  //                                                       : Image.asset(
  //                                                           'assets/images/kaset/no-img.png',
  //                                                           fit: BoxFit.contain,
  //                                                         ))
  //                                               : Container(
  //                                                   height: AdaptiveTextSize()
  //                                                       .getadaptiveTextSize(
  //                                                           context, 130),
  //                                                   width: AdaptiveTextSize()
  //                                                       .getadaptiveTextSize(
  //                                                           context, 100),
  //                                                   child: snapshot
  //                                                               .data['image']
  //                                                               .length >
  //                                                           0
  //                                                       ? loadingImageNetwork(
  //                                                           snapshot.data[
  //                                                                       'image']
  //                                                                   ['data'][0]
  //                                                               ['url'],
  //                                                           fit: BoxFit.cover,
  //                                                         )
  //                                                       : Image.asset(
  //                                                           'assets/images/kaset/no-img.png',
  //                                                           fit: BoxFit.contain,
  //                                                         )),
  //                                           SizedBox(width: 20),
  //                                           Expanded(
  //                                             child: Column(
  //                                               crossAxisAlignment:
  //                                                   CrossAxisAlignment.start,
  //                                               children: [
  //                                                 Text(
  //                                                   snapshot.data?['name'],
  //                                                   style: TextStyle(
  //                                                     fontFamily: 'Kanit',
  //                                                     fontSize: 13,
  //                                                     color: Colors.black,
  //                                                   ),
  //                                                   textScaleFactor: ScaleSize
  //                                                       .textScaleFactor(
  //                                                           context),
  //                                                   maxLines: 2,
  //                                                   overflow:
  //                                                       TextOverflow.ellipsis,
  //                                                 ),
  //                                                 if (model['price'] !=
  //                                                     model['netPrice'])
  //                                                   Text(
  //                                                     selectedInventoryModel !=
  //                                                             null
  //                                                         ? moneyFormat(selectedInventoryModel[
  //                                                                     'price']
  //                                                                 .toString()) +
  //                                                             " บาทX"
  //                                                         : moneyFormat(model[
  //                                                                     'price']
  //                                                                 .toString()) +
  //                                                             " บาทY",
  //                                                     style: TextStyle(
  //                                                       fontSize: 16,
  //                                                       fontFamily: 'Kanit',
  //                                                       color: Colors.grey,
  //                                                       fontWeight:
  //                                                           FontWeight.w500,
  //                                                       decoration:
  //                                                           TextDecoration
  //                                                               .lineThrough,
  //                                                     ),
  //                                                     textScaleFactor: ScaleSize
  //                                                         .textScaleFactor(
  //                                                             context),
  //                                                   ),
  //                                                 Text(
  //                                                   selectedInventoryModel !=
  //                                                           null
  //                                                       ? moneyFormat(
  //                                                               selectedInventoryModel[
  //                                                                       'price']
  //                                                                   .toString()) +
  //                                                           " บาท"
  //                                                       : moneyFormat(model[
  //                                                                   'price']
  //                                                               .toString()) +
  //                                                           " บาท",
  //                                                   style: TextStyle(
  //                                                     fontSize: 23,
  //                                                     fontFamily: 'Kanit',
  //                                                     fontWeight:
  //                                                         FontWeight.w500,
  //                                                   ),
  //                                                   textScaleFactor: ScaleSize
  //                                                       .textScaleFactor(
  //                                                           context),
  //                                                 ),
  //                                                 Text(
  //                                                   selectedInventoryModel !=
  //                                                           null
  //                                                       ? 'คลัง : ' +
  //                                                           (selectedInventoryModel[
  //                                                                       'stock'] ??
  //                                                                   0)
  //                                                               .toString() +
  //                                                           ' ชิ้น'
  //                                                       : '',
  //                                                   style: TextStyle(
  //                                                     fontSize: 13,
  //                                                     fontFamily: 'Kanit',
  //                                                     color: Colors.grey,
  //                                                     fontWeight:
  //                                                         FontWeight.w400,
  //                                                   ),
  //                                                   textScaleFactor: ScaleSize
  //                                                       .textScaleFactor(
  //                                                           context),
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           )
  //                                         ],
  //                                       ),
  //                                       SizedBox(height: 15),
  //                                       Text(
  //                                         'ระบุลักษณะสินค้า',
  //                                         style: TextStyle(
  //                                           fontFamily: 'Kanit',
  //                                           fontSize: 15,
  //                                           fontWeight: FontWeight.bold,
  //                                         ),
  //                                         textScaleFactor:
  //                                             ScaleSize.textScaleFactor(
  //                                                 context),
  //                                       ),
  //                                       // SizedBox(height: 25),
  //                                       // Expanded(
  //                                       //   child:
  //                                       ListView(
  //                                         shrinkWrap: true,
  //                                         physics: ClampingScrollPhysics(),
  //                                         children: [
  //                                           SizedBox(height: 10),
  //                                           buildWrap(setState, snapshot.data),
  //                                           // SizedBox(height: 100),
  //                                         ],
  //                                       ),

  //                                       SizedBox(height: 15),
  //                                       Row(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.spaceBetween,
  //                                         children: [
  //                                           Text(
  //                                             'จำนวน',
  //                                             style: TextStyle(
  //                                               fontFamily: 'Kanit',
  //                                               fontSize: 15,
  //                                               fontWeight: FontWeight.bold,
  //                                             ),
  //                                             textScaleFactor:
  //                                                 ScaleSize.textScaleFactor(
  //                                                     context),
  //                                           ),
  //                                           Row(
  //                                             children: [
  //                                               InkWell(
  //                                                 onTap: () => setState(() {
  //                                                   if (productQty > 1) {
  //                                                     productQty--;
  //                                                   }
  //                                                   ;
  //                                                   qtyController.text =
  //                                                       productQty.toString();
  //                                                 }),
  //                                                 child: Container(
  //                                                   height: AdaptiveTextSize()
  //                                                       .getadaptiveTextSize(
  //                                                           context, 30),
  //                                                   width: AdaptiveTextSize()
  //                                                       .getadaptiveTextSize(
  //                                                           context, 30),
  //                                                   alignment:
  //                                                       Alignment.topCenter,
  //                                                   decoration: BoxDecoration(
  //                                                       borderRadius:
  //                                                           BorderRadius
  //                                                               .circular(7),
  //                                                       border: Border.all(
  //                                                           width: 1,
  //                                                           color: productQty ==
  //                                                                   1
  //                                                               ? Color(
  //                                                                   0xFFFAF9F9)
  //                                                               : Color(
  //                                                                   0xFFF7F7F7)),
  //                                                       color: productQty == 1
  //                                                           ? Color(0xFFFAF9F9)
  //                                                           : Color(
  //                                                               0xFFF7F7F7)),
  //                                                   child: Text(
  //                                                     '-',
  //                                                     style: TextStyle(
  //                                                       fontFamily: 'Kanit',
  //                                                       fontSize: 16,
  //                                                       color: productQty == 1
  //                                                           ? Colors.grey[400]
  //                                                           : Color(0xFF707070),
  //                                                     ),
  //                                                     textScaleFactor: ScaleSize
  //                                                         .textScaleFactor(
  //                                                             context),
  //                                                     textAlign:
  //                                                         TextAlign.start,
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                               SizedBox(width: 15),
  //                                               Container(
  //                                                 width: AdaptiveTextSize()
  //                                                     .getadaptiveTextSize(
  //                                                         context, 50),
  //                                                 height: AdaptiveTextSize()
  //                                                     .getadaptiveTextSize(
  //                                                         context, 30),
  //                                                 // constraints:
  //                                                 //     BoxConstraints(minWidth: 220),
  //                                                 alignment:
  //                                                     Alignment.topCenter,

  //                                                 child: TextFormField(
  //                                                   keyboardType:
  //                                                       TextInputType.number,
  //                                                   textInputAction:
  //                                                       TextInputAction.next,
  //                                                   controller: qtyController,
  //                                                   style: TextStyle(
  //                                                     fontSize: AdaptiveTextSize()
  //                                                         .getadaptiveTextSize(
  //                                                             context, 13),
  //                                                     fontWeight:
  //                                                         FontWeight.w300,
  //                                                     color: Colors.black,
  //                                                   ),
  //                                                   cursorColor:
  //                                                       Color(0xFF09665a),
  //                                                   decoration: InputDecoration(
  //                                                     fillColor: Colors.white,
  //                                                     filled: true,
  //                                                     border:
  //                                                         OutlineInputBorder(
  //                                                       borderRadius:
  //                                                           BorderRadius
  //                                                               .circular(5),
  //                                                       borderSide: BorderSide(
  //                                                           color: Color(
  //                                                               0xFF09665a)),
  //                                                     ),
  //                                                     focusedBorder:
  //                                                         OutlineInputBorder(
  //                                                       borderRadius:
  //                                                           BorderRadius
  //                                                               .circular(10.0),
  //                                                       borderSide: BorderSide(
  //                                                           color: Color(
  //                                                               0xFF09665a)),
  //                                                     ),
  //                                                     enabledBorder:
  //                                                         OutlineInputBorder(
  //                                                       borderRadius:
  //                                                           BorderRadius
  //                                                               .circular(10.0),
  //                                                       borderSide: BorderSide(
  //                                                         color: Colors.black
  //                                                             .withOpacity(0.2),
  //                                                       ),
  //                                                     ),
  //                                                     errorStyle:
  //                                                         const TextStyle(
  //                                                       fontWeight:
  //                                                           FontWeight.normal,
  //                                                       fontSize: 10.0,
  //                                                     ),
  //                                                     contentPadding:
  //                                                         EdgeInsets.symmetric(
  //                                                             horizontal: 15),
  //                                                   ),
  //                                                   onSaved: (String? value) {},
  //                                                 ),
  //                                                 // Text(
  //                                                 //   productQty.toString(),
  //                                                 //   style: TextStyle(
  //                                                 //     fontFamily: 'Kanit',
  //                                                 //     fontSize: 16,
  //                                                 //   ),
  //                                                 //   textAlign: TextAlign.start,
  //                                                 // ),
  //                                               ),
  //                                               SizedBox(width: 15),
  //                                               InkWell(
  //                                                 onTap: () => setState(() {
  //                                                   if (productQty <
  //                                                       model['stock']) {
  //                                                     productQty++;
  //                                                   } else {
  //                                                     Toast.show(
  //                                                         'สินค้าในคลังเหลือแค่ ' +
  //                                                             (model['stock'] ??
  //                                                                     0)
  //                                                                 .toString() +
  //                                                             ' ชิ้น',
  //                                                         backgroundColor:
  //                                                             Colors.red[800] ??
  //                                                                 Colors.red,
  //                                                         duration: 3,
  //                                                         gravity: Toast.center,
  //                                                         textStyle: TextStyle(
  //                                                             color: Colors
  //                                                                 .white));
  //                                                   }
  //                                                   qtyController.text =
  //                                                       productQty.toString();
  //                                                 }),
  //                                                 child: Container(
  //                                                   height: AdaptiveTextSize()
  //                                                       .getadaptiveTextSize(
  //                                                           context, 30),
  //                                                   width: AdaptiveTextSize()
  //                                                       .getadaptiveTextSize(
  //                                                           context, 30),
  //                                                   alignment:
  //                                                       Alignment.topCenter,
  //                                                   decoration: BoxDecoration(
  //                                                     borderRadius:
  //                                                         BorderRadius.circular(
  //                                                             7),
  //                                                     border: Border.all(
  //                                                       width: 1,
  //                                                       color: model['stock'] ==
  //                                                               productQty
  //                                                           ? Color.fromARGB(
  //                                                               255,
  //                                                               250,
  //                                                               249,
  //                                                               249)
  //                                                           : Color(0xFFF7F7F7),
  //                                                     ),
  //                                                     color: model['stock'] ==
  //                                                             productQty
  //                                                         ? Color.fromARGB(255,
  //                                                             250, 249, 249)
  //                                                         : Color(0xFFF7F7F7),
  //                                                   ),
  //                                                   child: Text(
  //                                                     '+',
  //                                                     style: TextStyle(
  //                                                       fontFamily: 'Kanit',
  //                                                       fontSize: 16,
  //                                                       color: model['stock'] ==
  //                                                               productQty
  //                                                           ? Colors.grey[400]
  //                                                           : Color(0xFF707070),
  //                                                     ),
  //                                                     textScaleFactor: ScaleSize
  //                                                         .textScaleFactor(
  //                                                             context),
  //                                                     textAlign:
  //                                                         TextAlign.start,
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                             ],
  //                                           )
  //                                         ],
  //                                       )

  //                                       // )
  //                                     ],
  //                                   ),
  //                                 ),
  //                                 Positioned(
  //                                   bottom: 0 +
  //                                       MediaQuery.of(context).padding.bottom,
  //                                   left: 0,
  //                                   right: 0,
  //                                   // top: 20 + MediaQuery.of(context).padding.bottom,
  //                                   child: Container(
  //                                     padding:
  //                                         EdgeInsets.fromLTRB(15, 0, 15, 15),
  //                                     color: Colors.white,
  //                                     child: Column(
  //                                       children: [
  //                                         InkWell(
  //                                           onTap: () async {
  //                                             if (type == 'cart') {
  //                                               if ((selectedInventoryModel[
  //                                                               'stock'] ??
  //                                                           0) >
  //                                                       0 &&
  //                                                   (int.parse(qtyController
  //                                                           .text) <=
  //                                                       (selectedInventoryModel[
  //                                                               'stock'] ??
  //                                                           0)) &&
  //                                                   (int.parse(qtyController
  //                                                           .text) >
  //                                                       0)) {
  //                                                 setState(() {
  //                                                   loadingAddCart = true;
  //                                                 });
  //                                                 _addCart(selectedInventory,
  //                                                     'cart');
  //                                               } else if (int.parse(
  //                                                       qtyController.text) >
  //                                                   (selectedInventoryModel[
  //                                                           'stock'] ??
  //                                                       0)) {
  //                                                 Toast.show(
  //                                                     'สินค้าในคลังเหลือแค่ ' +
  //                                                         (selectedInventoryModel[
  //                                                                     'stock'] ??
  //                                                                 0)
  //                                                             .toString() +
  //                                                         ' ชิ้น',
  //                                                     backgroundColor:
  //                                                         Colors.red[800] ??
  //                                                             Colors.red,
  //                                                     duration: 3,
  //                                                     gravity: Toast.center,
  //                                                     textStyle: TextStyle(
  //                                                         color: Colors.white));
  //                                               } else if (int.parse(
  //                                                       qtyController.text) <=
  //                                                   0) {
  //                                                 Toast.show(
  //                                                     'กรุณาใส่จำนวนสินค้าอย่างน้อย 1 ชิ้น ',
  //                                                     backgroundColor:
  //                                                         Colors.red[800] ??
  //                                                             Colors.red,
  //                                                     duration: 3,
  //                                                     gravity: Toast.center,
  //                                                     textStyle: TextStyle(
  //                                                         color: Colors.white));
  //                                               }
  //                                             } else {
  //                                               if ((selectedInventoryModel[
  //                                                               'stock'] ??
  //                                                           0) >
  //                                                       0 &&
  //                                                   int.parse(qtyController
  //                                                           .text) <=
  //                                                       (selectedInventoryModel[
  //                                                               'stock'] ??
  //                                                           0) &&
  //                                                   int.parse(qtyController
  //                                                           .text) >
  //                                                       0) {
  //                                                 setState(() {
  //                                                   loadingAddCart = true;
  //                                                 });
  //                                                 List<dynamic> data = [];
  //                                                 _addCart(selectedInventory,
  //                                                         'buy')
  //                                                     .then(
  //                                                   (value) => {
  //                                                     // getCountItemInCartV2());
  //                                                     data.add({
  //                                                       'product_name':
  //                                                           value['product']
  //                                                                   ['data']
  //                                                               ?['name'],
  //                                                       'url': value['media']
  //                                                           ['data']['url'],
  //                                                       'product_variant':
  //                                                           value['product_variant']
  //                                                                       ['data']
  //                                                                   ?['name'] ??
  //                                                               value['product_variant']
  //                                                                       ['data']
  //                                                                   ['sku'],
  //                                                       'price': value[
  //                                                               'product_variant']
  //                                                           ['data']['price'],
  //                                                       'cart_id': value['id'],
  //                                                       'quantity':
  //                                                           value['quantity'],
  //                                                       'promotion_price': value[
  //                                                                           'product_variant']
  //                                                                       ['data']
  //                                                                   [
  //                                                                   'promotion_active'] ==
  //                                                               true
  //                                                           ? value['product_variant']
  //                                                                   ['data'][
  //                                                               'promotion_price']
  //                                                           : 0,
  //                                                       'isPromotion':
  //                                                           value['product_variant']
  //                                                                           [
  //                                                                           'data']
  //                                                                       [
  //                                                                       'promotion_active:'] ==
  //                                                                   true
  //                                                               ? true
  //                                                               : false,
  //                                                     }),
  //                                                     Navigator.push(
  //                                                       context,
  //                                                       MaterialPageRoute(
  //                                                         builder: (context) =>
  //                                                             ConfirmOrderCentralPage(
  //                                                                 modelCode:
  //                                                                     data,
  //                                                                 type: 'buy'),
  //                                                         //     ConfirmOrderPage(
  //                                                         //   productList: [allProduct],
  //                                                         //   from: 'buyNow',
  //                                                         // ),
  //                                                       ),
  //                                                     ),
  //                                                   },
  //                                                 );
  //                                               } else {
  //                                                 Toast.show(
  //                                                     'สินค้าในคลังเหลือแค่ ' +
  //                                                         (selectedInventoryModel[
  //                                                                     'stock'] ??
  //                                                                 0)
  //                                                             .toString() +
  //                                                         ' ชิ้น',
  //                                                     backgroundColor:
  //                                                         Colors.red[800] ??
  //                                                             Colors.red,
  //                                                     duration: 3,
  //                                                     gravity: Toast.center,
  //                                                     textStyle: TextStyle(
  //                                                         color: Colors.white));
  //                                               }
  //                                             }
  //                                           },
  //                                           child: ShowLoadingWidget(
  //                                             loading: loading,
  //                                             children: [
  //                                               Container(
  //                                                 padding: EdgeInsets.symmetric(
  //                                                     vertical: 10),
  //                                                 // height: AdaptiveTextSize().getadaptiveTextSize(context, 50),
  //                                                 color: selectedInventoryModel ==
  //                                                         null
  //                                                     ? Colors.grey
  //                                                     : (selectedInventoryModel[
  //                                                                     'stock'] ??
  //                                                                 0) <=
  //                                                             0
  //                                                         ? Colors.grey
  //                                                         : Color(0xFF09665a),
  //                                                 alignment: Alignment.center,
  //                                                 child: Text(
  //                                                   selectedInventoryModel ==
  //                                                           null
  //                                                       ? 'กรุณาเลือกลักษณะสินค้า'
  //                                                       : (selectedInventoryModel[
  //                                                                       'stock'] ??
  //                                                                   0) <=
  //                                                               0
  //                                                           ? 'สินค้าหมด'
  //                                                           : type == 'cart'
  //                                                               ? 'เพิ่มไปยังรถเข็น'
  //                                                               : 'ซื้อสินค้า',
  //                                                   style: TextStyle(
  //                                                     fontFamily: 'Kanit',
  //                                                     fontSize: 20,
  //                                                     color: Colors.white,
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                   ),
  //                                                   textScaleFactor: ScaleSize
  //                                                       .textScaleFactor(
  //                                                           context),
  //                                                   // textAlign: TextAlign.center,
  //                                                 ),
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 )
  //                               ],
  //                             ),
  //                           ],
  //                         )),
  //                       ),
  //                     );
  //                   } else if (snapshot.hasError) {
  //                     return Container();
  //                   } else {
  //                     return Container();
  //                   }
  //                 });
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  Row buildCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 30,
          width: 50,
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 1),
            color: Colors.white,
          ),
          child: Text(
            '-',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Container(
            height: 30,
            constraints: BoxConstraints(minWidth: 220),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1),
              color: Colors.white,
            ),
            child: Text(
              productQty.toString(),
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        SizedBox(width: 15),
        InkWell(
          onTap: () => setState(() {
            productQty++;
          }),
          child: Container(
            height: 30,
            width: 50,
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1),
              color: Colors.white,
            ),
            child: Text(
              '+',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ],
    );
  }

  _buildReview() {
    return FutureBuilder(
      future: _futureComment,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) return Container();
          return _buildUserReview(snapshot.data);
        } else if (snapshot.hasError) {
          // return DataError(onTap: () => _readComment());
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  _buildRatingBarIndicator(double rating, double itemSize) {
    return RatingBarIndicator(
      rating: rating,
      itemBuilder: (context, index) => Icon(
        Icons.star,
        color: Color(0xFF929DFC),
      ),
      itemSize: itemSize,
    );
  }

  _buildUserReview(dynamic model) {
    double sumRating = 0;
    double rating;
    model.forEach((o) => sumRating += o['rating']);
    rating = sumRating / model.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Text.rich(
            //   TextSpan(
            //     children: [
            Text(
              'รีวิว ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              textScaleFactor: ScaleSize.textScaleFactor(context),
            ),
            Text(
              '( ${model.length} )',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF707070),
                fontWeight: FontWeight.w500,
              ),
              textScaleFactor: ScaleSize.textScaleFactor(context),
            ),
            //     ],
            //   ),
            // ),
            // Text(
            //   'ทั้งหมด',
            //   style: TextStyle(
            //     fontSize: 15,
            //     color: Color(0xFF09665a).withOpacity(0.7),
            //     decoration: TextDecoration.underline,
            //   ),
            // ),
          ],
        ),
        _buildRatingBarIndicator(
            rating, AdaptiveTextSize().getadaptiveTextSize(context, 25)),
        SizedBox(height: 15),
        ...model
            .map<Widget>(
              (e) => Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: loadingImageNetwork(
                            '${e['user']['data']['profile_picture_url']}',
                            height: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 20),
                            width: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 20),
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            '${e['user']['data']?['name']}',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF707070),
                            ),
                            textScaleFactor: ScaleSize.textScaleFactor(context),
                          ),
                        ),
                        Text(
                          dateUnixTimeThaiShort(e['created_at']),
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF707070),
                          ),
                          textScaleFactor: ScaleSize.textScaleFactor(context),
                        ),
                      ],
                    ),
                    // ratingBar('${e['rating']}'),
                    // SizedBox(height: 13),
                    SizedBox(height: 6),
                    _buildRatingBarIndicator(e['rating'].toDouble(),
                        AdaptiveTextSize().getadaptiveTextSize(context, 15)),
                    SizedBox(height: 6),
                    Text(
                      '${e['comment']}',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                      ),
                      textScaleFactor: ScaleSize.textScaleFactor(context),
                    ),
                    SizedBox(height: 6),
                    // Container(height: 1, color: Colors.grey),
                    e['media']['data'].length > 0
                        ? _listViewImageList(e['media']['data'])
                        : Container(),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  _listViewImageList(model) {
    var sizeUrl = (MediaQuery.of(context).size.width / 5.5);
    List<dynamic> listImage = model;
    print('=============>${listImage} ');
    return Container(
      height: sizeUrl,
      child: ListView(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        children: [
          ...listImage.map<Widget>(
            (e) => GestureDetector(
              onTap: () {
                var index = listImage.indexOf(e);
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return ImageViewer(
                      initialIndex: _currentImage,
                      imageProviders:
                          listImage.map((e) => NetworkImage(e['url'])).toList(),
                    );
                  },
                );
                setState(() {
                  _currentImage = index;
                });
              },
              child: Container(
                margin: EdgeInsets.only(right: 1),
                child: Image.network(
                  e['url'],
                  width: sizeUrl,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildWrap(StateSetter setState, param) {
    List<dynamic> arrUrl = param['media']['data'];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: param?['product_variants']['data'].map<Widget>(
        (e) {
          if (e['media_id'] == null) {
            e['url'] = null;
          } else {
            var url = arrUrl.firstWhere((i) => i['id'] == e['media_id']);
            e['url'] = url['url'];
          }

          return buildAttribute(setState, e);
        },
      ).toList(),
    );
  }

  _checkImage(param) {
    if (param['media_id'] == null) {
      return null;
    } else {
      var url =
          imageVariantsList!.firstWhere((i) => i['id'] == param['media_id']);
      return url['url'];
    }
  }

  InkWell buildAttribute(StateSetter setState, e) {
    return InkWell(
        onTap: () => {
              setState(() {
                selectedInventory = e['id'];
                selectedInventoryModel = e;
              }),
            },
        child: Container(
          // height: e['name'] == null ? 30 : 50,
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Color(0xFFF7F7F7),
            border: Border.all(
              width: 1,
              color: selectedInventory == e['id']
                  ? Color(0xFF1434F7)
                  : Color(0xFFF7F7F7),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: e['url'] != null
                    ? loadingImageNetwork(
                        e['url'] ?? '',
                        // model['imageUrl'],
                        height:
                            AdaptiveTextSize().getadaptiveTextSize(context, 40),
                        width:
                            AdaptiveTextSize().getadaptiveTextSize(context, 40),
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/kaset/no-img.png',
                        fit: BoxFit.contain,
                        height:
                            AdaptiveTextSize().getadaptiveTextSize(context, 40),
                        width:
                            AdaptiveTextSize().getadaptiveTextSize(context, 40),
                        // color: Colors.white,
                      ),
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  e?['name'] ?? e['sku'],
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                    color: selectedInventory == e['id']
                        ? Color(0xFF1434F7)
                        : Color(0xFF000000),
                  ),
                  textScaleFactor: ScaleSize.textScaleFactor(context),
                  // overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ));
    // return Container(
    //   height: 20,
    //   width: 30,
    //   color: Colors.red,
    // );
  }

  Widget ratingBar(param) {
    if (param == null) param = 0;
    var rating = double.parse(param.toString());
    if (rating == 0)
      return Container(
        child: Text(
          'ยังไม่มีรีวิวสำหรับสินค้าชิ้นนี้',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      );
    const starFull = 'assets/images/star_full.png';
    const starHalf = 'assets/images/star_half_empty.png';
    const starEmpty = 'assets/images/star_empty.png';

    var strStar = <String>[];

    for (int i = 1; i <= 5; i++) {
      double decimalRating = i - rating;

      if (decimalRating > 0 && decimalRating < 1) {
        strStar.add(starHalf);
      } else {
        if (i <= rating) {
          strStar.add(starFull);
        } else {
          strStar.add(starEmpty);
        }
      }
    }
    return Row(
      children:
          strStar.map((e) => Image.asset(e, height: 15, width: 15)).toList(),
    );
  }

  List<Map<String, dynamic>> cartItems = [];

  _addCart(List<Map<String, dynamic>> products, String type) async {
    print('===================> Add Cart <===================');
    print('type: $type');
    print('products: $products');
    print('qtyController: ${qtyController.text}');
    print('===============================================');

    int qty = int.tryParse(qtyController.text) ?? 1;

    // วนเช็คทุกสินค้าใน products
    for (var product in products) {
      // สร้าง Map ของสินค้าที่จะเพิ่ม
      var newItem = {
        ...product,
        'qty': qty,
      };

      // ตรวจสอบว่ามีสินค้าเดิมใน cart แล้วหรือยัง (เช็คจาก id)
      int existingIndex =
          cartItems.indexWhere((item) => item['id'] == newItem['id']);

      if (existingIndex != -1) {
        // ถ้ามีอยู่แล้ว → บวกจำนวน
        setState(() {
          cartItems[existingIndex]['qty'] =
              (cartItems[existingIndex]['qty'] ?? 0) + qty;
        });
        print(
            '🟢 อัปเดตจำนวนสินค้า id=${newItem['id']} รวมเป็น ${cartItems[existingIndex]['qty']}');
      } else {
        // ถ้ายังไม่มี → เพิ่มเข้าใหม่
        setState(() {
          cartItems.add(newItem);
        });
        print('🟩 เพิ่มสินค้าใหม่ id=${newItem['id']}');
      }
    }

    setState(() {
      loadingAddCart = false;
    });

    print('====================> Cart Items ===================>');
    print(cartItems);
    print('==================================================');
    if (type == 'cart') {
      Toast.show(
        'เพิ่มลงรถเข็นแล้ว',
        backgroundColor: Color(0xFF09665a),
        duration: 3,
        gravity: Toast.bottom,
        textStyle: TextStyle(color: Colors.white),
      );
    }

    Navigator.pop(context, 'success');
  }

  // _addCart(product_variant_id, type) async {
  //   var cartData;
  //   if (product_variant_id == null || product_variant_id == '') {
  //     Toast.show('กรุณาเลือกลักษณะสินค้า',
  //         backgroundColor: Colors.red[800] ?? Colors.red,
  //         duration: 3,
  //         gravity: Toast.center,
  //         textStyle: TextStyle(color: Colors.white));
  //   } else {
  //     await postObjectData(server + 'carts', {
  //       'product_variant_id': product_variant_id,
  //       'quantity': int.parse(qtyController.text),
  //       // 'isDefault': isDefault,
  //     }).then((value) => {
  //           setState(() {
  //             loadingAddCart = false;
  //           }),
  //           Navigator.pop(context, 'success'),
  //           cartData = value,
  //           if (type == 'cart')
  //             {
  //               Toast.show('เพิ่มลงรถเข็นแล้ว',
  //                   backgroundColor: Colors.red[800] ?? Colors.red,
  //                   duration: 3,
  //                   gravity: Toast.center,
  //                   textStyle: TextStyle(color: Colors.white)),
  //             }
  //         });
  //     return cartData;
  //   }
}
