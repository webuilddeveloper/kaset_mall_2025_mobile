// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/cart.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/component/material/loading_tween.dart';
import 'package:kasetmall/product_from.dart';
import 'package:kasetmall/search.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/shared/extension.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductFavoriteCentralPage extends StatefulWidget {
  const ProductFavoriteCentralPage({Key? key}) : super(key: key);

  @override
  State<ProductFavoriteCentralPage> createState() =>
      _ProductFavoriteCentralPageState();
}

class _ProductFavoriteCentralPageState
    extends State<ProductFavoriteCentralPage> {
  Future<dynamic>? _futureModel;
  RefreshController? _refreshController;
  TextEditingController? _searchController;
  int _limit = 30;
  bool changeToListView = false;
  int amountItemInCart = 0;
  bool loadProduct = true;
  List<dynamic> _listModelMore = [];
  final storage = new FlutterSecureStorage();
  String profileCode = "";
  String? emailProfile;

  @override
  void initState() {
    _refreshController = new RefreshController();
    _searchController = TextEditingController();
    _getCountItemInCart();
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    _refreshController?.dispose();
    super.dispose();
  }

  _getCountItemInCart() async {
    //get amount item in cart.
    await get(server + 'carts').then((value) async {
      if (value != null)
        setState(() {
          amountItemInCart = value.length;
        });
    });
  }

  _callRead() async {
    profileCode = (await storage.read(key: 'profileCode10'))!;
    dynamic valueStorage = await storage.read(key: 'dataUserLoginDDPM');
    dynamic dataValue =
        valueStorage == null ? {'email': ''} : json.decode(valueStorage);

    setState(() {
      emailProfile = dataValue['email'].toString();
      // _futureModel =
      //     postDio(server + 'm/goods/isPopular/false/read', {'limit': _limit});
      _futureModel = get(server + 'users/me/favorite-products');
      _futureModel?.then((value) => {
            setState(() {
              _listModelMore = [...value];
            }),
            Timer(
              Duration(seconds: 1),
              () {
                setState(
                  () {
                    value.length == 0 ? loadProduct = false : true;
                  },
                );
              },
            ),
          });
    });
  }

  // business logic.
  void _onRefresh() async {
    setState(() {
      _limit = 30;
      loadProduct = true;
    });
    _callRead();
    _refreshController?.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {
      _limit += 30;
      // _futureModel =
      //     postDio(server + 'm/goods/isPopular/false/read', {'limit': _limit});
      _futureModel = get(
          server + 'users/me/favorite-products?per_page=' + _limit.toString());
      _futureModel?.then((value) => {
            // total_page = value[0]['total_pages'],
            _listModelMore = [...value],
            Timer(
              Duration(seconds: 1),
              () {
                setState(
                  () {
                    _listModelMore.length == 0 ? loadProduct = false : true;
                  },
                );
              },
            ),
          });
    });
    _refreshController?.loadComplete();
  }

  _addLog(param) async {
    await postObjectData(server_we_build + 'log/logGoods/create', {
      "username": emailProfile ?? "",
      "profileCode": profileCode,
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: 50,
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
                      children: [
                        Icon(Icons.arrow_back_ios),
                        Text(
                          'สินค้าที่ฉันถูกใจ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                        )
                      ],
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SearchPage()));
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFFE3E6FE).withOpacity(0.2),
                      ),
                      child: Image.asset(
                        'assets/images/kaset/search.png',
                        color: Color(0xFF09665a),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () =>
                        setState(() => changeToListView = !changeToListView),
                    child: Container(
                      height: 35,
                      width: 35,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFFE3E6FE).withOpacity(0.2),
                      ),
                      child: changeToListView
                          ? Image.asset(
                              'assets/images/kaset/grid.png',
                              color: Color(0xFF09665a),
                            )
                          : Image.asset(
                              'assets/images/kaset/list.png',
                              color: Color(0xFF09665a),
                            ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // InkWell(
                  //   onTap: () {
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (_) => CartCentralPage()));
                  //   },
                  //   child: Container(
                  //     height: 35,
                  //     width: 35,
                  //     padding: EdgeInsets.all(8),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(10),
                  //       color: Color(0xFFE3E6FE).withOpacity(0.2),
                  //     ),
                  //     child: Image.asset(
                  //       'assets/images/kaset/basket.png',
                  //       color: Color(0xFF09665a),
                  //     ),
                  //   ),
                  // )
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartCentralPage(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFE3E6FE).withOpacity(0.2),
                          ),
                          child: Image.asset(
                            'assets/images/kaset/basket.png',
                            color: Color(0xFF09665a),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            height: 15,
                            width: 15,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Text(
                              amountItemInCart.toString(),
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       SizedBox(height: 5),
            //       Row(
            //         children: [
            //           GestureDetector(
            //             onTap: () =>
            //                 setState(() => _filterSelected = 'เกี่ยวข้อง'),
            //             child: Text(
            //               'เกี่ยวข้อง',
            //               style: TextStyle(
            //                 fontSize: 13,
            //                 fontWeight: _filterSelected == 'เกี่ยวข้อง'
            //                     ? FontWeight.bold
            //                     : FontWeight.normal,
            //                 color: _filterSelected == 'เกี่ยวข้อง'
            //                     ? Color(0xFF09665a)
            //                     : Colors.black,
            //               ),
            //             ),
            //           ),
            //           SizedBox(width: 20),
            //           GestureDetector(
            //             onTap: () => setState(() => _filterSelected = 'ขายดี'),
            //             child: Text(
            //               'ขายดี',
            //               style: TextStyle(
            //                 fontSize: 13,
            //                 fontWeight: _filterSelected == 'ขายดี'
            //                     ? FontWeight.bold
            //                     : FontWeight.normal,
            //                 color: _filterSelected == 'ขายดี'
            //                     ? Color(0xFF09665a)
            //                     : Colors.black,
            //               ),
            //             ),
            //           ),
            //           SizedBox(width: 20),
            //           GestureDetector(
            //             onTap: () => setState(() => _filterSelected = 'ราคา'),
            //             child: Text(
            //               'ราคา',
            //               style: TextStyle(
            //                 fontSize: 13,
            //                 fontWeight: _filterSelected == 'ราคา'
            //                     ? FontWeight.bold
            //                     : FontWeight.normal,
            //                 color: _filterSelected == 'ราคา'
            //                     ? Color(0xFF09665a)
            //                     : Colors.black,
            //               ),
            //             ),
            //           ),
            //           SizedBox(width: 10),
            //           Expanded(
            //             child: SizedBox(),
            //           ),
            //           GestureDetector(
            //             onTap: () {},
            //             child: Row(
            //               children: [
            //                 Image.asset(
            //                   'assets/images/kaset/filter_new.png',
            //                   height: 15,
            //                   width: 15,
            //                 ),
            //                 SizedBox(width: 5),
            //                 Text(
            //                   'ขั้นสูง',
            //                   style: TextStyle(
            //                     fontSize: 13,
            //                     fontWeight: FontWeight.normal,
            //                     color: Colors.black,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            Expanded(
              child: _buildMain(),
            ),
          ],
        ),
      ),
    );
  }

  _buildMain() {
    return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(
          complete: Container(
            child: Text(''),
          ),
          completeDuration: Duration(milliseconds: 0),
        ),
        // footer: CustomFooter(
        //   builder: (BuildContext context, LoadStatus mode) {
        //     Widget body;
        //     TextStyle styleText = TextStyle(
        //       color: Color(0xFFDF0B24),
        //     );
        //     if (mode == LoadStatus.idle) {
        //       body = Text("pull up load", style: styleText);
        //     } else if (mode == LoadStatus.loading) {
        //       body = CupertinoActivityIndicator();
        //     } else if (mode == LoadStatus.failed) {
        //       body = Text("Load Failed!Click retry!", style: styleText);
        //     } else if (mode == LoadStatus.canLoading) {
        //       body = Text("release to load more", style: styleText);
        //     } else {
        //       body = Text("No more Data", style: styleText);
        //     }
        //     return Container(
        //       alignment: Alignment.center,
        //       child: body,
        //     );
        //   },
        // ),

        controller: _refreshController!,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: FutureBuilder(
              future: _futureModel,
              builder: (context, snapshot) {
                if (_listModelMore.length > 0) {
                  if (changeToListView) {
                    return _buildListView(_listModelMore);
                  } else
                    return _buildGridView(_listModelMore);
                } else {
                  return loadProduct == true
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 300,
                                  childAspectRatio: 9 / 14,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 20),
                          itemCount: 6,
                          itemBuilder: (context, index) => Column(
                            children: [
                              SizedBox(height: 10),
                              LoadingTween(
                                height: 165,
                              ),
                              SizedBox(height: 5),
                              LoadingTween(
                                height: 40,
                              ),
                              SizedBox(height: 5),
                              LoadingTween(
                                height: 17,
                              ),
                            ],
                          ),
                        )
                      : Container(
                          height: 165,
                          child: Center(
                            child: Text('ไม่พบสินค้า'),
                          ),
                        );
                }
              },
            ),
          ),
        ));
  }

  Widget _buildGridView(List<dynamic> param) {
    return GridView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          childAspectRatio: 8.5 / 14,
          crossAxisSpacing: 15,
          mainAxisSpacing: 20),
      itemCount: param.length,
      itemBuilder: (context, index) => _buildCardGrid(param[index]),
    );
  }

  _buildCardGrid(dynamic param) {
    return GestureDetector(
      onTap: () {
        _addLog(param);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductFormCentralPage(model: param),
          ),
        );
      },
      child: SizedBox(
        width: 165,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // height: 165,
              width: double.infinity,

              child: param['media']['data'].length > 0
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: loadingImageNetwork(
                        param['media']['data'][0]['url'],
                        // width: 80,
                        // height: 80,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        // color: Color(0xFF09665a),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Image.asset(
                        'assets/images/kaset/no-img.png',
                        fit: BoxFit.contain,
                        // color: Colors.white,
                      ),
                    ),
            ),
            SizedBox(height: 10),
            Text(
              param['name'],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            param['description'] != 'null'
                ? Text(
                    parseHtmlString(param['description'] ?? ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : SizedBox(),
            param['product_variants']['data'].length > 0
                ? Text(
                    (moneyFormat(param['product_variants']['data'][0]['price']
                                .toString()) +
                            " บาท") ??
                        '',
                    style: TextStyle(
                      fontSize: 17,
                      color: Color(0xFFED168B),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    'สินค้าหมด',
                    style: TextStyle(
                      fontSize: 17,
                      color: Color(0xFFED168B),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
          ],
        ),
      ),
    );
  }

  _buildListView(List<dynamic> param) {
    return ListView.separated(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (context, index) => _buildCardList(param[index]),
      separatorBuilder: (_, __) => SizedBox(height: 10),
      itemCount: param.length,
    );
  }

  _buildCardList(dynamic param) {
    return GestureDetector(
      onTap: () {
        _addLog(param);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductFormCentralPage(model: param),
          ),
        );
      },
      child: SizedBox(
          height: 165,
          child: Container(
            padding: EdgeInsets.only(
              left: 15,
              // top: 15,
              right: 15,
              // bottom: 15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  height: 165,
                  width: 165,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: param['media']['data'].length > 0
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: loadingImageNetwork(
                              param['media']['data'][0]['url'],
                              // width: 80,
                              // height: 80,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              // color: Color(0xFF09665a),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Image.asset(
                              'assets/images/kaset/no-img.png',
                              fit: BoxFit.contain,
                              // color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        param['name'],
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      param['description'] != 'null'
                          ? Text(
                              parseHtmlString(param['description'] ?? ''),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : SizedBox(),
                      SizedBox(height: 10),
                      param['product_variants']['data'].length > 0
                          ? Text(
                              (moneyFormat(param['product_variants']['data'][0]
                                              ['price']
                                          .toString()) +
                                      " บาท") ??
                                  '',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFFED168B),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              'สินค้าหมด',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFFED168B),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
