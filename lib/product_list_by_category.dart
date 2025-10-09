import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_mart_v3/component/carousel_banner.dart';
import 'package:mobile_mart_v3/component/loading_image_network.dart';
import 'package:mobile_mart_v3/component/material/loading_tween.dart';
import 'package:mobile_mart_v3/product_from.dart';
import 'package:mobile_mart_v3/search.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/shared/extension.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'cart.dart';

class ProductListByCategory extends StatefulWidget {
  ProductListByCategory({Key? key, this.changePage, this.code})
      : super(key: key);

  final String? code;
  late _ProductListByCategoryState productListByCategoryState;
  final Function? changePage;

  @override
  State<ProductListByCategory> createState() {
    productListByCategoryState = _ProductListByCategoryState();
    return productListByCategoryState;
  }

  getState() => productListByCategoryState;
}

class _ProductListByCategoryState extends State<ProductListByCategory> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  RefreshController? _refreshController;
  ScrollController? _scrollController;
  int _limit = 30;
  Future<dynamic>? _futureBanner;
  Future<dynamic>? _futureProduct;
  int selectedIndex = 0;
  String displayType = '1';
  String _filterSelected = 'เกี่ยวข้อง';
  bool changeToListView = false;
  String filter = '1';
  String orderKey = '';
  bool changOrderKey = false;
  String orderBy = '';
  String filterType = '';
  int countItem = 0;
  int page = 1;
  int total_page = 0;
  List<dynamic> _listModelMore = [];
  List<dynamic> _listCategory = [];
  TextEditingController txtPriceMin = TextEditingController();
  TextEditingController txtPriceMax = TextEditingController();
  bool loadProduct = true;
  final storage = new FlutterSecureStorage();
  String profileCode = "";
  String? emailProfile;
  String? selectedCategoryId = "";
  String? category_id = "";
  String? sub1_category_id = "";
  String? sub2_category_id = "";

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _refreshController = RefreshController();
    selectedCategoryId = widget.code;
    category_id = widget.code;
    if (widget.code != '') {
      _callRead();
      _getCategory();
    }
    txtPriceMin.text = '0';
    txtPriceMax.text = '0';
    super.initState();
  }

  @override
  void dispose() {
    _scrollController!.dispose();
    _refreshController!.dispose();
    super.dispose();
  }

  // business logic.
  void _onRefresh() async {
    setState(() {
      _limit = 30;
      orderKey = '';
      orderBy = '';
      txtPriceMin.text = '0';
      txtPriceMax.text = '0';
      loadProduct = true;
      _listModelMore = [];
    });
    _callRead();
    _refreshController!.refreshCompleted();
  }

  void _onLoading() async {
    if (page < total_page) {
      setState(() {
        if (changOrderKey) {
          _listModelMore = [];
          loadProduct = true;
          page = 0;

          // itemProductCount = 0;
        }
        page += 1;
        // _futureProduct = getData(server +
        //     'products?per_page=' +
        //     _limit.toString() +
        //     '&order_key=' +
        //     (orderKey ?? '') +
        //     '&order_by=' +
        //     (orderBy ?? '') +
        //     '&min_price=' +
        //     (txtPriceMin.text ?? '0') +
        //     '&max_price=' +
        //     (txtPriceMax.text ?? '0') +
        //     '&page=' +
        //     page.toString() +
        //     '&category_id=' +
        //     widget.code);

        _futureProduct = postProductData(
          server_we_build + 'm/Product/readProduct',
          {
            "category_id": "${widget.code}",
            "sub1_category_id": "${sub1_category_id}",
            "sub2_category_id": "${sub2_category_id}",
            "per_page": "$_limit",
            "order_key": "$orderKey",
            "order_by": "$orderBy",
            "min_price": "${txtPriceMin.text ?? '0'}",
            "max_price": "${txtPriceMax.text ?? '0'}",
            "page": "$page",
          },
        );

        _futureProduct!.then((value) => {
              total_page = value[0]['total_pages'],
              _listModelMore = [..._listModelMore, ...value],
              value.length > 0 ? loadProduct = false : true,
            });
        Timer(
          Duration(seconds: 1),
          () {
            setState(
              () {
                _listModelMore.length == 0 ? loadProduct = false : true;
              },
            );
          },
        );
        changOrderKey = false;
      });
      _refreshController!.loadComplete();
    } else {
      _refreshController!.loadNoData();
    }
  }

  _callRead() async {
    profileCode = (await storage.read(key: 'profileCode10'))!;
    dynamic valueStorage = await storage.read(key: 'dataUserLoginDDPM');
    dynamic dataValue =
        valueStorage == null ? {'email': ''} : json.decode(valueStorage);
    setState(() {
      emailProfile = dataValue['email'].toString() ?? "";
      // _futureProduct = getData(server + 'products?category_id=' + widget.code);
      _futureProduct = postProductData(
        server_we_build + 'm/Product/readProduct',
        {
          "category_id": "${category_id}",
          "sub1_category_id": "${sub1_category_id}",
          "sub2_category_id": "${sub2_category_id}"
        },
      );
      _futureBanner = postDio('${mainBannerApi}read', {'limit': 10});

      _futureProduct!.then((value) => {
            setState(() {
              total_page = value[0]['total_pages'];
              _listModelMore = [...value];
            })
          });

      Timer(
        Duration(seconds: 1),
        () => setState(
          () {
            _listModelMore.length == 0 ? loadProduct = false : true;
          },
        ),
      );
      // _futureModelTrending =
      //     postDio(server + 'm/goods/isPopular/false/read', {'limit': _limit});
      // _futureModelForYou = postDio(
      //     server + 'm/goods/isPopular/true/read', {'skip': 0, 'limit': 5});
      // _futureModelNew = postDio(
      //     server + 'm/goods/isPopular/true/read', {'skip': 0, 'limit': 5});
    });
  }

  _getCategory() async {
    List<dynamic> model = await getData(
        server + 'categories?include=sub1_categories.sub2_categories');
    final dataFind =
        model.firstWhere((f) => f['id'] == widget.code, orElse: () => null);
    if (dataFind != null) {
      setState(() {
        // เพิ่ม category หลัก
        _listCategory.add({
          'id': dataFind['id'],
          'name': dataFind['name'],
        });

        // วนลูป sub1_categories
        List<dynamic> sub1List = dataFind['sub1_categories']['data'] ?? [];

        for (var sub1 in sub1List) {
          _listCategory.add({
            'id': sub1['id'],
            'name': sub1['name'],
          });

          // วนลูป sub2_categories
          List<dynamic> sub2List = sub1['sub2_categories']['data'] ?? [];

          for (var sub2 in sub2List) {
            _listCategory.add({
              'id': sub2['id'],
              'name': sub2['name'],
            });
          }
        }
      });
    }
  }

  _hotSale() {
    setState(() {
      _limit = 30;
      orderKey = '';
      orderBy = '';
      txtPriceMin.text = '0';
      txtPriceMax.text = '0';
      loadProduct = true;
      _listModelMore = [];
      _futureProduct = null;

      // _futureProduct = getData(server +
      //     'products?category_id=${widget.code}&per_page=' +
      //     _limit.toString());
      _futureProduct =
          postProductData(server_we_build + 'm/Product/readProduct', {
        "category_id": "${category_id}",
        "sub1_category_id": "${sub1_category_id}",
        "sub2_category_id": "${sub2_category_id}",
        "per_page": "${_limit.toString()}"
      });

      _futureProduct!.then((value) => {
            setState(() {
              total_page = value[0]['total_pages'];
              _listModelMore = [...value];
              _listModelMore.shuffle();
            })
          });
      Timer(
        Duration(seconds: 1),
        () => setState(
          () {
            _listModelMore.length == 0 ? loadProduct = false : true;
          },
        ),
      );
    });
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
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _key,
        extendBody: true,
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
                    onTap: () => goBack(),
                    child: Container(
                      height: 35,
                      width: 35,
                      // padding: EdgeInsets.all(8),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(10),
                      //   color: Color(0xFFE3E6FE).withOpacity(0.2),
                      // ),
                      // child: Image.asset(
                      //   'assets/images/cart.png',
                      //   color: Color(0xFF0B24FB),
                      // ),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SearchPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 35,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFFE3E6FE),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/search.png',
                              height: 15,
                              width: 15,
                              color: Color(0xFF0B24FB).withOpacity(0.6),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'ศึกษาภัณฑ์ มอลล์',
                              style: TextStyle(
                                fontSize: 15,
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
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () =>
                        setState(() => changeToListView = !changeToListView),
                    child: Container(
                      height: 35,
                      width: 35,
                      padding: EdgeInsets.all(7),
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
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _filterSelected = 'เกี่ยวข้อง';
                            });
                            _onRefresh();
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
                          onTap: () {
                            setState(() {
                              _filterSelected = 'ขายดี';
                              orderBy = '';
                              loadProduct = true;
                              changOrderKey = true;
                              page = 0;
                            });
                            _hotSale();
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
                          onTap: () {
                            setState(
                              () {
                                _filterSelected = 'ราคา';
                                orderKey = 'min_price';
                                filterType = 'minPrice';
                                orderBy = '';
                                loadProduct = true;
                                changOrderKey = true;
                                page = 0;
                              },
                            );
                            _onLoading();
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
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      'หมวดหมู่',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Column(
                    children: _listCategory.map((category) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // หมวดหมู่หลัก
                          InkWell(
                            onTap: () {
                              setState(() {
                                category_id = "";
                                sub1_category_id = "";
                                sub2_category_id = "";

                                selectedCategoryId = category['id'];
                                String subCategoryId =
                                    (selectedCategoryId ?? "")
                                        .substring(0, 4)
                                        .toLowerCase();

                                if (subCategoryId == 'sub2') {
                                  sub2_category_id = selectedCategoryId;
                                } else if (subCategoryId == 'sub1') {
                                  sub1_category_id = selectedCategoryId;
                                } else {
                                  category_id = selectedCategoryId;
                                }
                              });
                            },
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedCategoryId == category['id']
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                category['name'],
                                style: TextStyle(
                                  color: selectedCategoryId == category['id']
                                      ? Colors.blue
                                      : Colors.black,
                                  fontWeight:
                                      selectedCategoryId == category['id']
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
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
                            // focusNode: _focusNode,
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
                            // focusNode: _focusNode,
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
                  Divider(
                    height: 20,
                    color: Color.fromARGB(255, 76, 76, 76),
                  ),
                  SizedBox(
                    height: 15,
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
      enablePullUp: true,
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
      onLoading: _onLoading,
      child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CarouselBanner(
                      model: _futureBanner,
                      url: 'main/',
                      height: (MediaQuery.of(context).size.width + (10)) / 2.4),
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder(
                future: _futureProduct,
                builder: (context, snapshot) {
                  if (_listModelMore.length > 0) {
                    if (changeToListView) {
                      return _buildListView(_listModelMore);
                    } else {
                      return _buildGridView(_listModelMore);
                    }
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
                              child: Text('รอสักครู่'),
                            ),
                          );
                  }
                },
              ),
            ],
          )),
    );
  }

  Widget _buildGridView(List<dynamic> param) {
    return GridView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.all(15),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          // childAspectRatio: AdaptiveTextSize().getadaptiveTextSize(context, 20) / AdaptiveTextSize().getadaptiveTextSize(context, 35),
          childAspectRatio: 0.55,
          crossAxisSpacing: 15,
          mainAxisSpacing: 1),
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
          SizedBox(
            // width: 165,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    // height: (250 * (MediaQuery.of(context).size.width / MediaQuery.of(context).size.height)),
                    // width: (100 * (MediaQuery.of(context).size.height / MediaQuery.of(context).size.width)),
                    width: double.infinity,
                    // width: 165,
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: param['media']['data'].length > 0
                          ? loadingImageNetwork(
                              param['media']['data'][0]['url'],
                              fit: BoxFit.cover)
                          : Image.asset(
                              'assets/images/kaset/no-img.png',
                              fit: BoxFit.cover,
                              // col
                            ),
                    )),
                SizedBox(height: 5),
                Text(
                  param['name'] ?? '',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: ScaleSize.textScaleFactor(context),
                ),
                param['description'] != 'null'
                    ? Text(
                        parseHtmlString(param['description'] ?? ''),
                        maxLines: 1,
                        style: TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: ScaleSize.textScaleFactor(context),
                      )
                    : SizedBox(),
                // SizedBox(height: 5),
                // Expanded(child: SizedBox(),),
                param['product_variants']['data'].length > 0
                    ? Text(
                        param['product_variants']['data'][0]
                                    ['promotion_active'] ==
                                true
                            ? (moneyFormat(param['product_variants']['data'][0]
                                            ['promotion_price']
                                        .toString()) +
                                    " บาท") ??
                                '0 บาท'
                            : (moneyFormat(param['product_variants']['data'][0]
                                            ['price']
                                        .toString()) +
                                    " บาท") ??
                                '0 บาท',
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFFED168B),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: ScaleSize.textScaleFactor(context),
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
                        textScaleFactor: ScaleSize.textScaleFactor(context),
                      )
              ],
            ),
          ),
          param['product_variants']['data'][0]['promotion_active'] == true
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
                )
              : Container(),
        ],
      ),
    );
  }

  _buildListView(List<dynamic> param) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 10),
      physics: ClampingScrollPhysics(),
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
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 165,
                      width: 165,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: param['media']['data'].length > 0
                            ? loadingImageNetwork(
                                param['media']['data'][0]['url'],
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/kaset/no-img.png',
                                fit: BoxFit.cover,
                                // col
                              ),
                      ),
                    ),
                    param['product_variants']['data'][0]['promotion_active'] ==
                            true
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
                        param['name'] ?? '',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 2,
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
                              param['product_variants']['data'][0]
                                          ['promotion_active'] ==
                                      true
                                  ? (moneyFormat(param['product_variants']
                                                  ['data'][0]['promotion_price']
                                              .toString()) +
                                          " บาท") ??
                                      '0 บาท'
                                  : (moneyFormat(param['product_variants']
                                                  ['data'][0]['price']
                                              .toString()) +
                                          " บาท") ??
                                      '0 บาท',
                              style: TextStyle(
                                fontSize: 17,
                                color: Color(0xFFED168B),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaleFactor:
                                  ScaleSize.textScaleFactor(context),
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

  void goBack() async {
    Navigator.pop(context);
  }
}

const homeCategoryList = [
  {
    'image': 'assets/images/central/box-coupon.png',
    'title': 'คูปอง',
  },
  {
    'image': 'assets/images/central/box-book.png',
    'title': 'หนังสือ แบบพิมพ์',
  },
  {
    'image': 'assets/images/central/box-student.png',
    'title': 'เครื่องแบบนักเรียน',
  },
  {
    'image': 'assets/images/central/box-document.png',
    'title': 'สื่อการศึกษา',
  },
  {
    'image': 'assets/images/central/box-computer.png',
    'title': 'สื่อการศึกษา',
  },
  {
    'image': 'assets/images/central/box-sport.png',
    'title': 'อุปกรณ์กีฬา',
  },
  {
    'image': 'assets/images/central/box-toys.png',
    'title': 'สินค้าพรีออเดอร์',
  },
  {
    'image': 'assets/images/central/box-notebook.png',
    'title': 'คอร์สเรียนออนไลน์',
  },
  {
    'image': 'assets/images/central/box-hospital.png',
    'title': 'คอร์สเรียนออนไลน์',
  },
  {
    'image': 'assets/images/central/box-other.png',
    'title': 'อื่น ๆ',
  },
];
