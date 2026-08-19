// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:kasetmall/blank_page/blank_loading.dart';
import 'package:kasetmall/component/gallery_view.dart';
import 'package:kasetmall/component/link_url_in.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/extension.dart';
import 'package:kasetmall/shared/login_guard.dart';
import 'package:kasetmall/shared/mock_store.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/widget/data_error.dart';
import 'package:kasetmall/widget/show_loading.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
  late final VoidCallback _cartListener;

  @override
  void initState() {
    super.initState();
    read();
    sharedApi();
    _readUser();
    _cartListener = () {
      if (mounted) {
        _readCartCount();
      }
    };
    MockStore.cartVersion.addListener(_cartListener);
    _readCartCount();
  }

  @override
  void dispose() {
    MockStore.cartVersion.removeListener(_cartListener);
    super.dispose();
  }

  _readUser() async {
    try {
      final result = await get(server + 'users/me');
      print(result['id']);
      if (result != null) {
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
    _getUserData();
    profilePhone = (await storage.read(key: 'profilePhone'));
    verifyPhone = (await storage.read(key: 'phoneVerified'));
    profileCode = (await storage.read(key: 'profileCode10'));
    _readCartCount();

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
        'rating': 0.0,
        ...widget.model
      };

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

  Future<void> _readCartCount() async {
    final items = await CartStore.getCart();
    if (!mounted) return;
    setState(() {
      amountItemInCart = items.length;
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
        appBar: KasetAppBar(
          title: 'รายละเอียดสินค้า',
          showBackButton: true,
          actions: [
            KasetAppBarAction(
              icon: Icons.shopping_cart_outlined,
              badge: amountItemInCart > 0 ? amountItemInCart : null,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CartCentralPage(),
                  ),
                );
                await _readCartCount();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: FutureBuilder<dynamic>(
            future: _futureModel,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                return buildDetail(snapshot.data[0]);
              } else if (snapshot.hasError) {
                return DataError(onTap: () => read());
              } else {
                if (widget.model != null) {
                  return buildDetail(tempData);
                } else {
                  return BlankLoading();
                }
              }
            },
          ),
        ),
        bottomNavigationBar: widget.model != null
            ? buildBtnBottom(tempData ?? widget.model)
            : null);
  }

  buildBtnBottom(model) {
    final stock = (model?['stock'] ?? 0) as num;
    final hasStock = stock > 0;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasStock
                    ? () async {
                        final allowed = await requireLogin(
                          context,
                          title: 'เพิ่มลงตะกร้า',
                          description:
                              'ต้องเข้าสู่ระบบก่อนเพื่อเพิ่มสินค้าลงตะกร้า',
                        );
                        if (!allowed) return;
                        await _addCart(
                          [Map<String, dynamic>.from(model)],
                          'cart',
                        );
                      }
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.tintGreenSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: hasStock
                      ? () async {
                          final allowed = await requireLogin(
                            context,
                            title: 'ซื้อเลย',
                            description:
                                'ต้องเข้าสู่ระบบก่อนเพื่อทำรายการสั่งซื้อ',
                          );
                          if (!allowed) return;
                          buildModal('buy');
                        }
                      : null,
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: hasStock
                          ? () async {
                              final allowed = await requireLogin(
                                context,
                                title: 'ซื้อเลย',
                                description:
                                    'ต้องเข้าสู่ระบบก่อนเพื่อทำรายการสั่งซื้อ',
                              );
                              if (!allowed) return;
                              buildModal('buy');
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            hasStock ? AppColors.primary : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        hasStock ? 'ซื้อเลย' : 'สินค้าหมด',
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // );
  }

  String formatPrice(dynamic price) {
    if (price == null) return '0';
    final number = num.tryParse(price.toString()) ?? 0;
    return NumberFormat('#,###').format(number);
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
        Transform.translate(
          offset: const Offset(0, -18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
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
                                  text: '${formatPrice(model?['price'])} บาท',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontFamily: 'Kanit',
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${model?['name']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                            textScaleFactor: ScaleSize.textScaleFactor(context),
                          ),
                          const SizedBox(height: 10),
                          Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
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
                                          (value) => _readCartCount());
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
                                                .getadaptiveTextSize(
                                                    context, 50),
                                            height: AdaptiveTextSize()
                                                .getadaptiveTextSize(
                                                    context, 50),
                                          )
                                        : _checkImage(
                                                    snapshot.data?['image']) ==
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
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: 15),
                                itemCount: snapshot.data?['image'].length,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    }),

                SizedBox(height: 20),
                Container(height: 8, color: const Color(0xFFF6F8F7)),
                SizedBox(height: 20),
                _buildReview(),
                buildSameProduct(),
                Container(
                  height: 80 + MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
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
        if (listImage.length > 1)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(listImage.length, (i) {
                final active = i == _currentImage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
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
                      const Text(
                        'สินค้าที่น่าสนใจ',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'ดูทั้งหมด',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w600,
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
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
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
    final pageContext = context;
    setState(() {
      productQty = 1;
      qtyController.text = productQty.toString();
      loadingAddCart = false;
    });

    return showCupertinoModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.32),
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return GestureDetector(
          onTap: () => FocusScope.of(sheetContext).unfocus(),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return FutureBuilder(
                future: _futureProductDetailModel,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox.shrink();
                  }

                  final model = Map<String, dynamic>.from(snapshot.data as Map);
                  final stock = num.tryParse((model['stock'] ?? 0).toString()) ?? 0;
                  final canBuy = stock > 0;
                  final imageUrl = model['image']?.toString() ?? '';
                  final description = model['description']?.toString() ?? '';
                  final bottomInset = MediaQuery.of(sheetContext).padding.bottom;

                  return Material(
                    type: MaterialType.transparency,
                    child: Container(
                      height: MediaQuery.of(sheetContext).size.height * 0.84,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(34),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              width: 54,
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.tintGreenSoft,
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: const Text(
                                            'สรุปรายการ',
                                            style: TextStyle(
                                              fontFamily: 'Kanit',
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          model['name'] ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Kanit',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                            height: 1.18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${formatPrice(model['price'])} บาท',
                                          style: const TextStyle(
                                            fontFamily: 'Kanit',
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                            height: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          description.isNotEmpty
                                              ? description
                                              : 'ตรวจสอบข้อมูลก่อนยืนยันคำสั่งซื้อ',
                                          style: const TextStyle(
                                            fontFamily: 'Kanit',
                                            fontSize: 13.2,
                                            color: AppColors.textSecondary,
                                            height: 1.45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      width: 94,
                                      height: 94,
                                      color: AppColors.tintGreenSoft,
                                      child: imageUrl.isNotEmpty
                                          ? loadingImageNetwork(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/images/kaset/no-img.png',
                                              fit: BoxFit.contain,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FBF8),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'คลังสินค้า',
                                                  style: TextStyle(
                                                    fontFamily: 'Kanit',
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '$stock ชิ้น',
                                                  style: const TextStyle(
                                                    fontFamily: 'Kanit',
                                                    fontSize: 15,
                                                    color: AppColors.textPrimary,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 34,
                                            color: AppColors.border,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'จำนวนที่เลือก',
                                                  style: TextStyle(
                                                    fontFamily: 'Kanit',
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${qtyController.text} ชิ้น',
                                                  style: const TextStyle(
                                                    fontFamily: 'Kanit',
                                                    fontSize: 15,
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    const Text(
                                      'จำนวนที่ต้องการสั่ง',
                                      style: TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          _QtyButton(
                                            icon: Icons.remove,
                                            enabled: productQty > 1,
                                            onTap: () => setModalState(() {
                                              if (productQty > 1) {
                                                productQty--;
                                                qtyController.text =
                                                    productQty.toString();
                                              }
                                            }),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: AppColors.tintGreenSoft,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: AppColors.border,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                textInputAction:
                                                    TextInputAction.done,
                                                controller: qtyController,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontFamily: 'Kanit',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                                cursorColor: AppColors.primary,
                                                decoration:
                                                    const InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                                onChanged: (value) {
                                                  final qty =
                                                      int.tryParse(value);
                                                  if (qty != null && qty > 0) {
                                                    setModalState(() {
                                                      productQty = qty;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          _QtyButton(
                                            icon: Icons.add,
                                            enabled: productQty < stock,
                                            onTap: () => setModalState(() {
                                              if (productQty < stock) {
                                                productQty++;
                                                qtyController.text =
                                                    productQty.toString();
                                              } else {
                                                Toast.show(
                                                  'สินค้าในคลังเหลือแค่ $stock ชิ้น',
                                                  backgroundColor:
                                                      Colors.red[800] ??
                                                          Colors.red,
                                                  duration: 3,
                                                  gravity: Toast.center,
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!canBuy) ...[
                                      const SizedBox(height: 14),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF6E8),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: AppColors.accentTint,
                                          ),
                                        ),
                                        child: const Text(
                                          'สินค้าหมดชั่วคราว',
                                          style: TextStyle(
                                            fontFamily: 'Kanit',
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                14 + bottomInset,
                              ),
                              child: ShowLoadingWidget(
                                loading: loadingAddCart,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: canBuy
                                          ? () async {
                                              final currentQty =
                                                  int.tryParse(qtyController.text) ??
                                                      0;
                                              if (currentQty <= 0 ||
                                                  currentQty > stock) {
                                                Toast.show(
                                                  'กรุณาเลือกจำนวนสินค้าให้ถูกต้อง',
                                                  backgroundColor:
                                                      Colors.red[800] ??
                                                          Colors.red,
                                                  duration: 3,
                                                  gravity: Toast.center,
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                );
                                                return;
                                              }

                                              setModalState(() {
                                                loadingAddCart = true;
                                              });

                                              if (type == 'cart') {
                                                await _addCart(
                                                  [Map<String, dynamic>.from(model)],
                                                  'cart',
                                                );
                                                if (sheetContext.mounted &&
                                                    Navigator.of(sheetContext)
                                                        .canPop()) {
                                                  Navigator.of(sheetContext).pop();
                                                }
                                                if (mounted) {
                                                  setState(() {
                                                    loadingAddCart = false;
                                                  });
                                                }
                                                return;
                                              }

                                              if (sheetContext.mounted &&
                                                  Navigator.of(sheetContext)
                                                      .canPop()) {
                                                Navigator.of(sheetContext).pop();
                                              }
                                              if (mounted) {
                                                setState(() {
                                                  loadingAddCart = false;
                                                });
                                              }

                                              await Future<void>.delayed(
                                                const Duration(milliseconds: 120),
                                              );
                                              if (!pageContext.mounted) return;
                                              await Navigator.push(
                                                pageContext,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ConfirmOrderCentralPage(
                                                    modelCode: [
                                                      {
                                                        ...Map<String, dynamic>.from(model),
                                                        'qty': currentQty,
                                                        'quantity': currentQty,
                                                      },
                                                    ],
                                                    type: 'buy',
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: canBuy
                                            ? AppColors.primary
                                            : Colors.grey.shade400,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        canBuy
                                            ? (type == 'cart'
                                                ? 'เพิ่มเข้าตะกร้า'
                                                : 'ยืนยันและสั่งซื้อ')
                                            : 'สินค้าหมด',
                                        style: const TextStyle(
                                          fontFamily: 'Kanit',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

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

  Widget _QtyButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: enabled ? AppColors.tintGreenSoft : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.18)
                : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.border,
          size: 20,
        ),
      ),
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
        color: AppColors.accent,
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
            const Text(
              'รีวิว ',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '( ${model.length} )',
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Kanit',
                color: AppColors.textSecondary,
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
        SizedBox(height: 6),
        _buildRatingBarIndicator(
            rating, AdaptiveTextSize().getadaptiveTextSize(context, 25)),
        SizedBox(height: 15),
        ...model
            .map<Widget>(
              (e) => Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBF9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
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
                                .getadaptiveTextSize(context, 32),
                            width: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 32),
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${e['user']['data']?['name']}',
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            textScaleFactor: ScaleSize.textScaleFactor(context),
                          ),
                        ),
                        Text(
                          dateUnixTimeThaiShort(e['created_at']),
                          style: const TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                          textScaleFactor: ScaleSize.textScaleFactor(context),
                        ),
                      ],
                    ),
                    // ratingBar('${e['rating']}'),
                    // SizedBox(height: 13),
                    SizedBox(height: 8),
                    _buildRatingBarIndicator(e['rating'].toDouble(),
                        AdaptiveTextSize().getadaptiveTextSize(context, 15)),
                    SizedBox(height: 8),
                    Text(
                      '${e['comment']}',
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: EdgeInsets.only(right: 6),
                  child: Image.network(
                    e['url'],
                    width: sizeUrl,
                    fit: BoxFit.cover,
                  ),
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
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selectedInventory == e['id']
                ? AppColors.tintGreenSoft
                : const Color(0xFFF7F7F7),
            border: Border.all(
              width: 1.2,
              color: selectedInventory == e['id']
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  e?['name'] ?? e['sku'],
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                    fontWeight: selectedInventory == e['id']
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: selectedInventory == e['id']
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                  textScaleFactor: ScaleSize.textScaleFactor(context),
                ),
              ),
            ],
          ),
        ));
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
    int qty = int.tryParse(qtyController.text) ?? 1;

    for (var product in products) {
      await CartStore.addToCart(Map<String, dynamic>.from(product), qty: qty);
    }
    setState(() {});

    if (type == 'cart') {
      Toast.show('เพิ่มลงตะกร้าแล้ว',
          backgroundColor: Color(0xFF09665a),
          duration: 3,
          gravity: Toast.bottom,
          textStyle: TextStyle(color: Colors.white));
    }
  }
}
