import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_mart_v3/cart.dart';
import 'package:mobile_mart_v3/component/loading_image_network.dart';
import 'package:mobile_mart_v3/component/material/loading_tween.dart';
import 'package:mobile_mart_v3/product_from.dart';
import 'package:mobile_mart_v3/search.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/shared/extension.dart';
import 'package:mobile_mart_v3/verify_phone.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'login.dart';

class ProductAllCentralPage extends StatefulWidget {
  ProductAllCentralPage({Key? key, @required this.title, required this.mode})
      : super(key: key);
  final String? title;
  late bool mode;

  @override
  State<ProductAllCentralPage> createState() => _ProductAllCentralPageState();
}

class _ProductAllCentralPageState extends State<ProductAllCentralPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final storage = new FlutterSecureStorage();
  Future<dynamic>? _futureModel;
  List<dynamic> _listModelMore = [];
  RefreshController? _refreshController;
  TextEditingController? _searchController;
  TextEditingController txtPriceMin = TextEditingController();
  TextEditingController txtPriceMax = TextEditingController();
  String _filterSelected = 'เกี่ยวข้อง';
  int _limit = 20;
  bool changeToListView = false;
  int amountItemInCart = 0;
  String profileCode = "";
  String verifyPhonePage = '';
  String orderKey = '';
  bool changOrderKey = false;
  String orderBy = '';
  String filterType = '';
  int page = 1;
  int total_page = 0;
  bool loadProduct = true;
  String? emailProfile;

  @override
  void initState() {
    _refreshController = new RefreshController();
    _searchController = TextEditingController();
    _getCountItemInCart();
    _callRead();
    txtPriceMin.text = '';
    txtPriceMax.text = '';
    super.initState();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    _refreshController?.dispose();
    super.dispose();
  }

  _callRead() async {
    // dashboard/readTop20
    // postProductData(
    //       server_we_build + 'dashboard/readTop20',
    //       {"per_page": "${_limit.toString()}"}).then((value) => {
    //         print('value >>> ${value}'),
    //       });

    // profileCode = await storage.read(key: 'profileCode10');
    // dynamic valueStorage = await storage.read(key: 'dataUserLoginDDPM');
    // dynamic dataValue = valueStorage == null ? {'email': ''} : json.decode(valueStorage);

    setState(() {
      loadProduct = true;
      // emailProfile = dataValue['email'].toString() ?? "";
      // _futureModel = getData(server + 'products?per_page=' + _limit.toString());
      if (widget.mode) {
        _futureModel = postProductHotSale(
            server_we_build + 'm/Product/readProductHot',
            // {"per_page": "${_limit.toString()}"}
            {});
        _futureModel!.then((value) async => {
              setState(() {
                // total_page = value[0]['total_pages'];
                _listModelMore = [...value];
                _listModelMore.length == 0 ? loadProduct = false : true;
              })
            });
      } else {
        _futureModel =
            postProductData(server_we_build + 'm/Product/readProduct', {});
        _futureModel!.then((value) async => {
              setState(() {
                total_page = value[0]['total_pages'];
                _listModelMore = [...value];
                _listModelMore.length == 0 ? loadProduct = false : true;
                print('total_page ========== ${total_page}');
              })
            });
      }

      // Timer(
      //   Duration(seconds: 1),
      //   () => {
      //     setState(
      //       () {
      //         _listModelMore.length == 0 ? loadProduct = false : true;
      //       },
      //     ),
      //   },
      // );
    });
  }

  _hotSale() {
    setState(() {
      loadProduct = true;
      _limit = 20;
      orderKey = '';
      orderBy = '';
      txtPriceMin.text = '';
      txtPriceMax.text = '';
      loadProduct = true;
      _listModelMore = [];
      _futureModel = null;

      // _futureModel = getData(server + 'products?per_page=' + _limit.toString());
      _futureModel = postProductHotSale(
          // server_we_build + 'm/Product/readProduct',
          server_we_build + 'm/Product/readProductHot',
          // {"per_page": "${_limit.toString()}"}
          {});

      _futureModel!.then((value) async => {
            setState(() {
              // total_page = value[0]['total_pages'];
              _listModelMore = [...value];
              _listModelMore.shuffle();
              _listModelMore.length == 0 ? loadProduct = false : true;
            })
          });
      // Timer(
      //   Duration(seconds: 1),
      //   () => {
      //     setState(
      //       () {
      //         _listModelMore.length == 0 ? loadProduct = false : true;
      //       },
      //     ),
      //   },
      // );
    });
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

  // business logic.
  void _onRefresh() async {
    setState(() {
      _limit = 20;
      orderKey = '';
      orderBy = '';
      txtPriceMin.text = '';
      txtPriceMax.text = '';
      loadProduct = true;
      _listModelMore = [];
      _futureModel = null;
    });
    _filterSelected == 'เกี่ยวข้อง' ? _callRead() : _hotSale;
    _getCountItemInCart();
    _refreshController?.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {
      // loadProduct = true;
      if (widget.mode) {
        // _listModelMore = [];
        // _futureModel = postProductHotSale(
        //   server_we_build + 'm/Product/readProductHot',
        //   {
        //     // "per_page": "$_limit",
        //     "order_key": "$orderKey",
        //     "order_by": "$orderBy",
        //     "min_price": "${txtPriceMin.text}",
        //     "max_price": "${txtPriceMax.text}",
        //     // "page": "$page",
        //   },
        // );

        // _futureModel.then((value) async => {
        //       await setState(() {
        //         // total_page = value[0]['total_pages'],
        //         // _listModelMore = [..._listModelMore, ...value],
        //         _listModelMore = [...value];
        //         _filterSelected == 'เกี่ยวข้อง'
        //             ? null
        //             : _listModelMore.shuffle();
        //         _listModelMore.length == 0 ? loadProduct = false : true;
        //       })
        //     });
      } else {
        // if (_listModelMore.length < 20) {
        if (page < total_page) {
          page += 1;
          if (changOrderKey) {
            _listModelMore = [];
            page = 0;
            // itemProductCount = 0;
          }
          // print('mode ========== ${page}');
          //      _futureModel = getData(server +
          // 'products?per_page=' +
          // _limit.toString() +
          // '&order_key=' +
          // (orderKey ?? '') +
          // '&order_by=' +
          // (orderBy ?? '') +
          // '&min_price=' +
          // (txtPriceMin.text ?? '0') +
          // '&max_price=' +
          // (txtPriceMax.text ?? '0') +
          // '&page=' +
          // page.toString());

          _futureModel = postProductData(
            server_we_build + 'm/Product/readProduct',
            {
              "per_page": "$_limit",
              "order_key": "$orderKey",
              "order_by": "$orderBy",
              "min_price": "${txtPriceMin.text}",
              "max_price": "${txtPriceMax.text}",
              "page": "$page",
            },
          );

          _futureModel!.then((value) async => {
                setState(() {
                  total_page = value[0]['total_pages'];
                  _listModelMore = [..._listModelMore, ...value];
                  // _listModelMore = [...value];
                  // _filterSelected == 'เกี่ยวข้อง' ? null : _listModelMore.shuffle();
                  _listModelMore.length == 0 ? loadProduct = false : true;
                  print('total_page ========== ${total_page}');
                })
              });

          changOrderKey = false;
          _refreshController?.loadComplete();
        } else {
          // _refreshController.loadNoData();
        }
        // } else {
        //   _refreshController.loadNoData();
        // }
      }
    });

    // if (_listModelMore.length < 20) {
    //   if (page < total_page) {
    //     setState(() {
    //       if (changOrderKey) {
    //         _listModelMore = [];
    //         page = 0;
    //         // itemProductCount = 0;
    //       }
    //       page += 1;
    //       // _futureModel = getData(server +
    //       //     'products?per_page=' +
    //       //     _limit.toString() +
    //       //     '&order_key=' +
    //       //     (orderKey ?? '') +
    //       //     '&order_by=' +
    //       //     (orderBy ?? '') +
    //       //     '&min_price=' +
    //       //     (txtPriceMin.text ?? '0') +
    //       //     '&max_price=' +
    //       //     (txtPriceMax.text ?? '0') +
    //       //     '&page=' +
    //       //     page.toString());
    //       _futureModel = postProductData(
    //         server_we_build_local + 'm/Product/readProductHot',
    //         {
    //           // "per_page": "$_limit",
    //           "order_key": "$orderKey",
    //           "order_by": "$orderBy",
    //           "min_price": "${txtPriceMin.text ?? '0'}",
    //           "max_price": "${txtPriceMax.text ?? '0'}",
    //           // "page": "$page",
    //         },
    //       );
    //       _futureModel.then((value) => {
    //             // total_page = value[0]['total_pages'],
    //             // _listModelMore = [..._listModelMore, ...value],
    //             _listModelMore = [...value['objectData']],

    //             _listModelMore.shuffle(),
    //             _listModelMore.length == 0 ? loadProduct = false : true,
    //           });
    //       // Timer(
    //       //   Duration(seconds: 1),
    //       //   () => {
    //       //     setState(
    //       //       () {
    //       //         _listModelMore.length == 0 ? loadProduct = false : true;
    //       //       },
    //       //     ),
    //       //   },
    //       // );
    //       changOrderKey = false;
    //     });
    // _refreshController.loadComplete();
    //   } else {
    //     _refreshController.loadNoData();
    //   }
    // } else {
    //   _refreshController.loadNoData();
    // }
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _key,
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: <Widget>[
            new Container(),
          ],
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
                          widget.title!,
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
                        'assets/images/search.png',
                        color: Color(0xFF0B24FB),
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
                              'assets/images/grid.png',
                              color: Color(0xFF0B24FB),
                            )
                          : Image.asset(
                              'assets/images/list.png',
                              color: Color(0xFF0B24FB),
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
                  //       'assets/images/cart.png',
                  //       color: Color(0xFF0B24FB),
                  //     ),
                  //   ),
                  // )
                  GestureDetector(
                    onTap: () {
                      if (profileCode == null || profileCode == '') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                LoginCentralPage(),
                          ),
                        );
                      } else if (verifyPhonePage == 'false') {
                        _showVerifyCheckDialog();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CartCentralPage(),
                          ),
                        ).then((value) => _getCountItemInCart());
                      }
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
                            'assets/images/cart.png',
                            color: Color(0xFF0B24FB),
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
                              amountItemInCart > 99
                                  ? '99+'
                                  : amountItemInCart.toString(),
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: amountItemInCart.toString().length <=
                                        1
                                    ? 10
                                    : amountItemInCart.toString().length == 2
                                        ? 9
                                        : 8,
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => {
                          setState(() => {_filterSelected = 'เกี่ยวข้อง'}),
                          _onRefresh(),
                        },
                        child: Text(
                          'เกี่ยวข้อง',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _filterSelected == 'เกี่ยวข้อง'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _filterSelected == 'เกี่ยวข้อง'
                                ? Color(0xFF0B24FB)
                                : Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () => {
                          setState(() => {
                                _filterSelected = 'ขายดี',
                                orderBy = '',
                                loadProduct = true,
                                changOrderKey = true,
                                page = 0,
                              }),
                          _hotSale(),
                        },
                        child: Text(
                          'ขายดี',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _filterSelected == 'ขายดี'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _filterSelected == 'ขายดี'
                                ? Color(0xFF0B24FB)
                                : Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () => {
                          setState(
                            () => {
                              _filterSelected = 'ราคา',
                              orderKey = 'min_price',
                              filterType = 'minPrice',
                              orderBy = '',
                              loadProduct = true,
                              changOrderKey = true,
                              page = 0,
                            },
                          ),
                          _onLoading(),
                        },
                        child: Text(
                          'ราคา',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _filterSelected == 'ราคา'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _filterSelected == 'ราคา'
                                ? Color(0xFF0B24FB)
                                : Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(),
                      ),
                      GestureDetector(
                        onTap: () {
                          _key.currentState!.openEndDrawer();
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/filter.png',
                              height: 15,
                              width: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'ขั้นสูง',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildMain(),
            ),
          ],
        ),
        endDrawer: Drawer(
            child: SafeArea(
                child: Column(
          children: [
            Expanded(
              flex: 12,
              child: ListView(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/filter.png',
                          height: 25,
                          width: 25,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'ขั้นสูง',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 20,
                    color: Color.fromARGB(255, 76, 76, 76),
                  ),
                  Container(
                    // padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            'ราคาต่ำสุด',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF000000),
                              // fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            controller: txtPriceMin,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                            cursorColor: Color(0xFF0B24FB),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF0B24FB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF0B24FB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),
                              errorStyle: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 10.0,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              // labelText: "กรุณากรอกหมายเลขบัตร",
                              hintText: 'ราคาต่ำสุด',
                            ),
                            onSaved: (String? value) {},
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    // padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            'ราคาสูงสุด',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF000000),
                              // fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            controller: txtPriceMax,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                            cursorColor: Color(0xFF0B24FB),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF0B24FB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF0B24FB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),
                              errorStyle: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 10.0,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              // labelText: "กรุณากรอกหมายเลขบัตร",
                              hintText: 'ราคาสูงสุด',
                            ),
                            onSaved: (String? value) {},
                          ),
                        )
                      ],
                    ),
                  ),

                  Divider(
                    height: 20,
                    color: Color.fromARGB(255, 76, 76, 76),
                  ),

                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      'ราคา',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              orderKey = 'min_price';
                              filterType = 'minPrice';
                              orderBy = '';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            constraints: BoxConstraints(minWidth: 10),
                            decoration: BoxDecoration(
                              color: filterType == 'minPrice'
                                  ? Color(0XFFE3E6FE)
                                  : Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: filterType == 'minPrice'
                                    ? Color(0XFFE3E6FE)
                                    : Color(0xFF000000),
                              ),
                            ),
                            child: Text(
                              'น้อย - มาก',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                // fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              orderKey = 'max_price';
                              filterType = 'maxPrice';
                              orderBy = '';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            constraints: BoxConstraints(minWidth: 10),
                            decoration: BoxDecoration(
                              color: filterType == 'maxPrice'
                                  ? Color(0XFFE3E6FE)
                                  : Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: filterType == 'maxPrice'
                                    ? Color(0XFFE3E6FE)
                                    : Color(0xFF000000),
                              ),
                            ),
                            child: Text(
                              'มาก - น้อย',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                // fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    height: 20,
                    color: Color.fromARGB(255, 76, 76, 76),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      'ชื่อสินค้า',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              orderBy = 'asc';
                              filterType = 'abc';
                              orderKey = 'name';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            constraints: BoxConstraints(minWidth: 10),
                            decoration: BoxDecoration(
                              color: filterType == 'abc'
                                  ? Color(0XFFE3E6FE)
                                  : Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: filterType == 'abc'
                                    ? Color(0XFFE3E6FE)
                                    : Color(0xFF000000),
                              ),
                            ),
                            child: Text(
                              'ก-ฮ หรือ a-z',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                // fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              orderBy = 'desc';
                              filterType = 'cba';
                              orderKey = 'name';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            constraints: BoxConstraints(minWidth: 10),
                            decoration: BoxDecoration(
                              color: filterType == 'cba'
                                  ? Color(0XFFE3E6FE)
                                  : Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: filterType == 'cba'
                                    ? Color(0XFFE3E6FE)
                                    : Color(0xFF000000),
                              ),
                            ),
                            child: Text(
                              'ฮ-ก หรือ z-a',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                // fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  // ListTile(
                  //   title: const Text('Item 1'),
                  //   onTap: () {
                  //     // Update the state of the app
                  //     // ...
                  //     // Then close the drawer
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  // ListTile(
                  //   title: const Text('Item 2'),
                  //   onTap: () {
                  //     // Update the state of the app
                  //     // ...
                  //     // Then close the drawer
                  //     Navigator.pop(context);
                  //   },
                  // ),
                ],
              ),
            ),
            Expanded(
                flex: 1,
                child: InkWell(
                  onTap: (() {
                    setState(
                      () {
                        loadProduct = true;
                        changOrderKey = true;
                        page = 0;
                      },
                    );
                    _onLoading();
                    Navigator.pop(context);
                  }),
                  child: Container(
                      decoration: BoxDecoration(
                        // color: Color(0xFFDF0B24),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      padding:
                          EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        color: Color(0xFFDF0B24),
                        child: Text(
                          'ตกลง',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ))
          ],
        ))),
      ),
    );
  }

  _buildMain() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: widget.mode ? false : true,
      header: WaterDropHeader(
        complete: Container(
          child: Text(''),
        ),
        completeDuration: Duration(milliseconds: 0),
      ),
      footer: CustomFooter(
        builder: (BuildContext? context, LoadStatus? mode) {
          Widget body;
          TextStyle styleText = TextStyle(
            color: Color(0xFFDF0B24),
          );
          if (mode == LoadStatus.idle) {
            body = Text("pull up load", style: styleText);
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("Load Failed!Click retry!", style: styleText);
          } else if (mode == LoadStatus.canLoading) {
            body = Text("release to load more", style: styleText);
          } else {
            body = Text("No more Data", style: styleText);
          }
          return Container(
            alignment: Alignment.center,
            child: body,
          );
        },
      ),
      controller: _refreshController!,
      onRefresh: _onRefresh,
      onLoading:
          widget.mode ? (() => _refreshController?.loadComplete()) : _onLoading,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: FutureBuilder(
          future: _futureModel,
          builder: (context, snapshot) {
            if (_listModelMore.length > 0) {
              if (changeToListView) {
                return _buildListView(_listModelMore);
              } else
                return
                    // Container();
                    _buildGridView(_listModelMore);
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
    );
  }

  Widget _buildGridView(List<dynamic> param) {
    return GridView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.55,
          // 9/15,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15),
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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // height: 200,
                width: MediaQuery.of(context).size.width,
                // padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: Colors.white,
                ),
                // alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: param['media']['data'].length > 0
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: loadingImageNetwork(
                            // snapshot.data[index]['imageUrl'],
                            param['media']['data'][0]['url'],
                            fit: BoxFit.cover,
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
                ),
              ),
              SizedBox(height: 5),
              Text(
                param['name'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              param['description'] != 'null'
                  ? Expanded(
                      child: Text(
                        parseHtmlString(param['description'] ?? ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : Expanded(child: SizedBox()),
              // Expanded(
              //   child: SizedBox(),
              // ),
              param['product_variants']['data'].length > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        param['product_variants']['data'][0]['promotion_active']
                            ? Text(
                                (moneyFormat(param['product_variants']['data']
                                            [0]['promotion_price']
                                        .toString()) +
                                    " บาท"),
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFFED168B),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                // textScaleFactor: ScaleSize.textScaleFactor(context),
                              )
                            : Text(
                                (moneyFormat(param['product_variants']['data']
                                                [0]['price']
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
                              ),
                        param['product_variants']['data'].length > 0
                            ? Text(
                                (_callSumStock(param['product_variants']
                                            ['data']) ==
                                        0
                                    ? 'สินค้าหมด'
                                    : _callSumStock(param['product_variants']
                                                ['data'])
                                            .toString() +
                                        " ชิ้น"),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _callSumStock(param['product_variants']
                                              ['data']) ==
                                          0
                                      ? Color(0xFFED168B)
                                      : Colors.black,
                                  // fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                // textScaleFactor: ScaleSize.textScaleFactor(context),
                              )
                            : Text(
                                'สินค้าหมด',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFFED168B),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                // textScaleFactor: ScaleSize.textScaleFactor(context),
                              )
                      ],
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
                    ),
            ],
          ),
          param['product_variants']['data'][0]['promotion_active']
              ? Positioned(
                  // left: 15,
                  top: 5,
                  right: 0,
                  // top: MediaQuery.of(context).padding.top + 5,
                  child: Container(
                    // height: AdaptiveTextSize()
                    //     .getadaptiveTextSize(context, 42),
                    // width: AdaptiveTextSize()
                    //     .getadaptiveTextSize(context, 20),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(40),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFD45A),
                            Color(0xFFFFD45A),
                          ],
                        )),
                    child: Text(
                      'โปรโมชั่น',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0XFFee4d2d),
                        fontWeight: FontWeight.bold,
                      ),
                      textScaleFactor: ScaleSize.textScaleFactor(context),
                    ),
                  ),
                  // child: snapshot.data[index]
                  //                 ['product_variants']['data']
                  //             [0]['promotions']['data'] >
                  //         0
                  //     ? Container(
                  //         // height: AdaptiveTextSize()
                  //         //     .getadaptiveTextSize(context, 42),
                  //         // width: AdaptiveTextSize()
                  //         //     .getadaptiveTextSize(context, 20),
                  //         padding: EdgeInsets.symmetric(
                  //             horizontal: 10),
                  //         alignment: Alignment.center,
                  //         decoration: BoxDecoration(
                  //             borderRadius:
                  //                 BorderRadius.horizontal(
                  //               left: Radius.circular(40),
                  //             ),
                  //             gradient: LinearGradient(
                  //               begin: Alignment.topLeft,
                  //               end: Alignment.bottomRight,
                  //               colors: [
                  //                 Color(0xFFFFD45A),
                  //                 Color(0xFFFFD45A),
                  //               ],
                  //             )),
                  //         child: Text(
                  //           'โปรโมชั่น',
                  //           style: TextStyle(
                  //             fontSize: 11,
                  //             color: Color(0XFFee4d2d),
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //           textScaleFactor:
                  //               ScaleSize.textScaleFactor(
                  //                   context),
                  //         ),
                  //       )
                  //     : Container(),
                )
              : Container(),
        ],
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
                Stack(
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
                                  // color: Color(0XFF0B24FB),
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
                    param['product_variants']['data'][0]['promotion_active']
                        ? Positioned(
                            // left: 15,
                            top: 5,
                            right: 0,
                            // top: MediaQuery.of(context).padding.top + 5,
                            child: Container(
                              // height: AdaptiveTextSize()
                              //     .getadaptiveTextSize(context, 42),
                              // width: AdaptiveTextSize()
                              //     .getadaptiveTextSize(context, 20),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(40),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFD45A),
                                      Color(0xFFFFD45A),
                                    ],
                                  )),
                              child: Text(
                                'โปรโมชั่น',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0XFFee4d2d),
                                  fontWeight: FontWeight.bold,
                                ),
                                textScaleFactor:
                                    ScaleSize.textScaleFactor(context),
                              ),
                            ),
                            // child: snapshot.data[index]
                            //                 ['product_variants']['data']
                            //             [0]['promotions']['data'] >
                            //         0
                            //     ? Container(
                            //         // height: AdaptiveTextSize()
                            //         //     .getadaptiveTextSize(context, 42),
                            //         // width: AdaptiveTextSize()
                            //         //     .getadaptiveTextSize(context, 20),
                            //         padding: EdgeInsets.symmetric(
                            //             horizontal: 10),
                            //         alignment: Alignment.center,
                            //         decoration: BoxDecoration(
                            //             borderRadius:
                            //                 BorderRadius.horizontal(
                            //               left: Radius.circular(40),
                            //             ),
                            //             gradient: LinearGradient(
                            //               begin: Alignment.topLeft,
                            //               end: Alignment.bottomRight,
                            //               colors: [
                            //                 Color(0xFFFFD45A),
                            //                 Color(0xFFFFD45A),
                            //               ],
                            //             )),
                            //         child: Text(
                            //           'โปรโมชั่น',
                            //           style: TextStyle(
                            //             fontSize: 11,
                            //             color: Color(0XFFee4d2d),
                            //             fontWeight: FontWeight.bold,
                            //           ),
                            //           textScaleFactor:
                            //               ScaleSize.textScaleFactor(
                            //                   context),
                            //         ),
                            //       )
                            //     : Container(),
                          )
                        : Container(),
                  ],
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
                          ? param['product_variants']['data'][0]
                                  ['promotion_active']
                              ? Text(
                                  (moneyFormat(param['product_variants']['data']
                                                  [0]['promotion_price']
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
                                  (moneyFormat(param['product_variants']['data']
                                                  [0]['price']
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

  _showVerifyCheckDialog() {
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
                      color: Color(0xFFFF7514),
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
                      color: Color(0xFFFF7514),
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

  _callSumStock(param) {
    // print(param.toString());
    int qty = 0;
    for (var item in param) {
      // print("stock ${item['stock'].toString()}");
      qty += int.parse(item['stock'].toString());
    }

    // print(qty);
    return qty;
  }
}
