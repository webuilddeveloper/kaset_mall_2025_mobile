// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/component/material/loading_tween.dart';
import 'package:kasetmall/product_from.dart';
import 'package:kasetmall/data/mock_kaset_data.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/shared/extension.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductAllCentralPage extends StatefulWidget {
  ProductAllCentralPage(
      {Key? key,
      @required this.title,
      required this.mode,
      required this.typeelect})
      : super(key: key);
  final String? title;
  late bool mode;
  final String typeelect;
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
  String _filterSelected = '0';
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

  String _categoryTitle() {
    switch (widget.typeelect) {
      case '1':
        return 'สินค้าเกษตร';
      case '2':
        return 'ปุ๋ยและเคมีภัณฑ์';
      case '3':
        return 'เครื่องมือการเกษตร';
      case '4':
        return 'อาหารสัตว์';
      default:
        return widget.title ?? 'สินค้า';
    }
  }

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
      _filterSelected = widget.typeelect;
      if (_filterSelected == '0') {
        setState(() {
          _listModelMore = [...mockProductList];
          loadProduct = _listModelMore.isNotEmpty;
        });
      } else {
        if (_filterSelected != '0') {
          _applyFilter();
        }
      }
      // else {
      // _futureModel =
      //     postProductData(server_we_build + 'm/Product/readProduct', {});
      // _futureModel!.then((value) async => {
      //       setState(() {
      //         total_page = value[0]['total_pages'];
      //         _listModelMore = [...value];
      //         _listModelMore.length == 0 ? loadProduct = false : true;
      //         print('total_page ========== ${total_page}');
      //       })
      //     });
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
        // }
        );
  }

  _applyFilter() {
    setState(() {
      loadProduct = true;

      // เริ่มต้นจากข้อมูลทั้งหมด
      List<dynamic> filteredList = [...mockProductList];

      // กรองตาม type
      if (_filterSelected != '0') {
        filteredList = filteredList
            .where((item) => item['type'] == _filterSelected)
            .toList();
      } else {
        filteredList = [...mockProductList];
      }

      // กรองตามราคา (ถ้ามี)
      if (txtPriceMin.text.isNotEmpty) {
        double minPrice = double.tryParse(txtPriceMin.text) ?? 0;
        filteredList = filteredList
            .where((item) => (item['price'] as num) >= minPrice)
            .toList();
      }

      if (txtPriceMax.text.isNotEmpty) {
        double maxPrice = double.tryParse(txtPriceMax.text) ?? double.infinity;
        filteredList = filteredList
            .where((item) => (item['price'] as num) <= maxPrice)
            .toList();
      }

      // เรียงลำดับข้อมูล
      if (orderKey == 'min_price') {
        // เรียงราคาน้อย -> มาก
        filteredList
            .sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
      } else if (orderKey == 'max_price') {
        // เรียงราคามาก -> น้อย
        filteredList
            .sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
      } else if (orderKey == 'name') {
        if (orderBy == 'asc') {
          // เรียง ก-ฮ หรือ a-z
          filteredList.sort(
              (a, b) => (a['name'] as String).compareTo(b['name'] as String));
        } else if (orderBy == 'desc') {
          // เรียง ฮ-ก หรือ z-a
          filteredList.sort(
              (a, b) => (b['name'] as String).compareTo(a['name'] as String));
        }
      }

      _listModelMore = filteredList;
      loadProduct = _listModelMore.isNotEmpty;
    });
  }

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

    // เรียกใช้ตามประเภทที่เลือก
    // if (_filterSelected == '0') {
    //   _callRead();
    // } else {
    _applyFilter();
    // }

    _getCountItemInCart();
    _refreshController?.refreshCompleted();
  }

  // _hotSale() {
  //   setState(() {
  //     loadProduct = true;
  //     _limit = 20;
  //     orderKey = '';
  //     orderBy = '';
  //     txtPriceMin.text = '';
  //     txtPriceMax.text = '';
  //     loadProduct = true;
  //     _listModelMore = [];
  //     _futureModel = [...mockProductList] as Future?;

  //     _futureModel!.then((value) async {
  //       setState(() {
  //         // ดึงข้อมูลทั้งหมดก่อน
  //         _listModelMore = [...value];

  //         // 🔹 กรองข้อมูลตาม _filterSelected
  //         if (_filterSelected != null &&
  //             _filterSelected.toString().isNotEmpty) {
  //           _listModelMore = _listModelMore
  //               .where((item) =>
  //                   item['category'] ==
  //                       _filterSelected || // ตัวอย่างเงื่อนไขที่ใช้เทียบ
  //                   item['type'] == _filterSelected)
  //               .toList();
  //         }

  //         // สุ่มข้อมูล
  //         _listModelMore.shuffle();

  //         // ตรวจสอบว่ามีข้อมูลหรือไม่
  //         loadProduct = _listModelMore.isNotEmpty;
  //       });
  //     });
  //     // _futureModel = getData(server + 'products?per_page=' + _limit.toString());
  //     // _futureModel = postProductHotSale(
  //     //     // server_we_build + 'm/Product/readProduct',
  //     //     server_we_build + 'm/Product/readProductHot',
  //     //     // {"per_page": "${_limit.toString()}"}
  //     //     {});

  //     // _futureModel!.then((value) async => {
  //     //       setState(() {
  //     //         // total_page = value[0]['total_pages'];
  //     //         _listModelMore = [...value];
  //     //         _listModelMore.shuffle();
  //     //         _listModelMore.length == 0 ? loadProduct = false : true;
  //     //       })
  //     //     });
  //     // Timer(
  //     //   Duration(seconds: 1),
  //     //   () => {
  //     //     setState(
  //     //       () {
  //     //         _listModelMore.length == 0 ? loadProduct = false : true;
  //     //       },
  //     //     ),
  //     //   },
  //     // );
  //   });
  // }

  _getCountItemInCart() async {
    String? value = await storage.read(key: 'cartItems');

    if (value != null) {
      List<dynamic> items = jsonDecode(value);

      setState(() {
        amountItemInCart = items.length;
      });
    } else {
      setState(() {
        amountItemInCart = 0;
      });
    }
  }

  // business logic.
  // void _onRefresh() async {
  //   setState(() {
  //     _limit = 20;
  //     orderKey = '';
  //     orderBy = '';
  //     txtPriceMin.text = '';
  //     txtPriceMax.text = '';
  //     loadProduct = true;
  //     _listModelMore = [];
  //     _futureModel = null;
  //   });
  //   _filterSelected == '0' ? _callRead() : _hotSale;
  //   _getCountItemInCart();
  //   _refreshController?.refreshCompleted();
  // }

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
        //         _filterSelected == 'ทั้งหมด'
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
                  // _filterSelected == 'ทั้งหมด' ? null : _listModelMore.shuffle();
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

  // _addLog(param) async {
  //   await postObjectData(server_we_build + 'log/logGoods/create', {
  //     "username": emailProfile ?? "",
  //     "profileCode": profileCode ?? "",
  //     "platform": Platform.isAndroid
  //         ? "android"
  //         : Platform.isIOS
  //             ? "ios"
  //             : "other",
  //     "prodjctId": param['id'] ?? "",
  //     "title": param['name'] ?? "",
  //     "categoryId": param['category']['data']['id'] ?? "",
  //     "category": param['category']['data']['name'] ?? "",
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _key,
        backgroundColor: Colors.white,
        appBar: KasetAppBar(
          title: _categoryTitle(),
          actions: const [],
        ),
        body: Column(
          children: [
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
                          // "assets/images/kaset/filter_new.png",
                          'assets/images/kaset/filter_new.png',
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
                            cursorColor: Color(0xFF09665a),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF09665a)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF09665a)),
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
                            cursorColor: Color(0xFF09665a),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF09665a)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    BorderSide(color: Color(0xFF09665a)),
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
                        mainAxisSpacing: 15,
                      ),
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
          childAspectRatio: 0.65,
          // 9/15,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemCount: param.length,
      itemBuilder: (context, index) => _buildCardGrid(param[index]),
    );
  }

  Widget _buildCardGrid(dynamic param) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductFormCentralPage(model: param),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพ
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child:
                  param['image'] != null && param['image'].toString().isNotEmpty
                      ? AdaptiveProductImage(
                          url: param['image'],
                          fit: BoxFit.contain,
                          height: 160,
                          width: double.infinity,
                          blurThreshold: 0.45,
                          padding: const EdgeInsets.all(10),
                        )
                      : Image.asset(
                          'assets/images/kaset/no-img.png',
                          fit: BoxFit.contain,
                          height: 160,
                          width: double.infinity,
                        ),
            ),

            // เนื้อหา
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    param['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (param['description'] != null &&
                      param['description'].toString().trim().isNotEmpty)
                    Text(
                      parseHtmlString(param['description'] ?? ''),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                ],
              ),
            ),
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
        // _addLog(param);
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
                        child: param['image'].length > 0
                            ? AdaptiveProductImage(
                                url: param['image'],
                                fit: BoxFit.contain,
                                blurThreshold: 0.45,
                                padding: const EdgeInsets.all(10),
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
                    // param['product_variants']['data'][0]['promotion_active']
                    //     ? Positioned(
                    //         // left: 15,
                    //         top: 5,
                    //         right: 0,
                    //         // top: MediaQuery.of(context).padding.top + 5,
                    //         child: Container(
                    //           // height: AdaptiveTextSize()
                    //           //     .getadaptiveTextSize(context, 42),
                    //           // width: AdaptiveTextSize()
                    //           //     .getadaptiveTextSize(context, 20),
                    //           padding: EdgeInsets.symmetric(horizontal: 10),
                    //           alignment: Alignment.center,
                    //           decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.horizontal(
                    //                 left: Radius.circular(40),
                    //               ),
                    //               gradient: LinearGradient(
                    //                 begin: Alignment.topLeft,
                    //                 end: Alignment.bottomRight,
                    //                 colors: [
                    //                   Color(0xFFFFD45A),
                    //                   Color(0xFFFFD45A),
                    //                 ],
                    //               )),
                    //           child: Text(
                    //             'โปรโมชั่น',
                    //             style: TextStyle(
                    //               fontSize: 11,
                    //               color: Color(0XFFee4d2d),
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //             textScaleFactor:
                    //                 ScaleSize.textScaleFactor(context),
                    //           ),
                    //         ),
                    //         // child: snapshot.data[index]
                    //         //                 ['product_variants']['data']
                    //         //             [0]['promotions']['data'] >
                    //         //         0
                    //         //     ? Container(
                    //         //         // height: AdaptiveTextSize()
                    //         //         //     .getadaptiveTextSize(context, 42),
                    //         //         // width: AdaptiveTextSize()
                    //         //         //     .getadaptiveTextSize(context, 20),
                    //         //         padding: EdgeInsets.symmetric(
                    //         //             horizontal: 10),
                    //         //         alignment: Alignment.center,
                    //         //         decoration: BoxDecoration(
                    //         //             borderRadius:
                    //         //                 BorderRadius.horizontal(
                    //         //               left: Radius.circular(40),
                    //         //             ),
                    //         //             gradient: LinearGradient(
                    //         //               begin: Alignment.topLeft,
                    //         //               end: Alignment.bottomRight,
                    //         //               colors: [
                    //         //                 Color(0xFFFFD45A),
                    //         //                 Color(0xFFFFD45A),
                    //         //               ],
                    //         //             )),
                    //         //         child: Text(
                    //         //           'โปรโมชั่น',
                    //         //           style: TextStyle(
                    //         //             fontSize: 11,
                    //         //             color: Color(0XFFee4d2d),
                    //         //             fontWeight: FontWeight.bold,
                    //         //           ),
                    //         //           textScaleFactor:
                    //         //               ScaleSize.textScaleFactor(
                    //         //                   context),
                    //         //         ),
                    //         //       )
                    //         //     : Container(),
                    //       )
                    //     : Container(),
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
                      // SizedBox(height: 10),
                      // param['product_variants']['data'].length > 0
                      //     ? param['product_variants']['data'][0]
                      //             ['promotion_active']
                      //         ? Text(
                      //             (moneyFormat(param['product_variants']['data']
                      //                             [0]['promotion_price']
                      //                         .toString()) +
                      //                     " บาท") ??
                      //                 '',
                      //             style: TextStyle(
                      //               fontSize: 20,
                      //               color: Color(0xFFED168B),
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //             textAlign: TextAlign.center,
                      //             maxLines: 1,
                      //             overflow: TextOverflow.ellipsis,
                      //           )
                      //         : Text(
                      //             (moneyFormat(param['product_variants']['data']
                      //                             [0]['price']
                      //                         .toString()) +
                      //                     " บาท") ??
                      //                 '',
                      //             style: TextStyle(
                      //               fontSize: 20,
                      //               color: Color(0xFFED168B),
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //             textAlign: TextAlign.center,
                      //             maxLines: 1,
                      //             overflow: TextOverflow.ellipsis,
                      //           )
                      //     : Text(
                      //         'สินค้าหมด',
                      //         style: TextStyle(
                      //           fontSize: 20,
                      //           color: Color(0xFFED168B),
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //         textAlign: TextAlign.center,
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //       )
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  // _showVerifyCheckDialog() {
  //   return showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return WillPopScope(
  //           onWillPop: () {
  //             return Future.value(false);
  //           },
  //           child: CupertinoAlertDialog(
  //             title: new Text(
  //               'บัญชีนี้ยังไม่ได้ยืนยันเบอร์โทรศัพท์\nกด ตกลง เพื่อยืนยัน',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontFamily: 'Kanit',
  //                 color: Colors.black,
  //                 fontWeight: FontWeight.normal,
  //               ),
  //             ),
  //             content: Text(" "),
  //             actions: [
  //               CupertinoDialogAction(
  //                 isDefaultAction: true,
  //                 child: new Text(
  //                   "ตกลง",
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontFamily: 'Kanit',
  //                     color: Color(0xFF09665a),
  //                     fontWeight: FontWeight.normal,
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => VerifyPhonePage(),
  //                     ),
  //                   );
  //                 },
  //               ),
  //               CupertinoDialogAction(
  //                 isDefaultAction: false,
  //                 child: new Text(
  //                   "ไม่ใช่ตอนนี้",
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontFamily: 'Kanit',
  //                     color: Color(0xFF09665a),
  //                     fontWeight: FontWeight.normal,
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.pop(
  //                     context,
  //                   );
  //                 },
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }
}
