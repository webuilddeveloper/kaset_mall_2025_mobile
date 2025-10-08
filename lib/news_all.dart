import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_mart_v3/component/loading_image_network.dart';
import 'package:mobile_mart_v3/news_form.dart';
import 'package:mobile_mart_v3/product_from.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/shared/extension.dart';
import 'package:mobile_mart_v3/verify_phone.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class NewsAllPage extends StatefulWidget {
  NewsAllPage({Key? key, @required this.title, required this.mode})
      : super(key: key);
  final String? title;
  late bool mode;

  @override
  State<NewsAllPage> createState() => _NewsAllPageState();
}

class _NewsAllPageState extends State<NewsAllPage> {
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
    // _getCountItemInCart();
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
    setState(() {
      loadProduct = true;
      _futureModel = postObjectData(server_we_build + 'm/news/read', {});

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
    setState(
      () {
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
            _futureModel = post(
              server_we_build + 'm/news/read',
              {},
            );

            _futureModel!.then((value) async => {
                  setState(() {
                    // total_page = value[0]['total_pages'];
                    // _listModelMore = [..._listModelMore, ...value];
                    // // _listModelMore = [...value];
                    // // _filterSelected == 'เกี่ยวข้อง' ? null : _listModelMore.shuffle();
                    // _listModelMore.length == 0 ? loadProduct = false : true;
                    print('total_page ========== ${value}');
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
      },
    );
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
            if (snapshot.hasData) {
              if (snapshot.data.length > 0) {
                return _buildListView(snapshot.data['objectData']);
              } else {
                return Container(
                  height: 165,
                  child: Center(
                    child: Text('ไม่มีข่าวประชาสัมพันธ์'),
                  ),
                );
              }
            } else {
              return Container(
                height: 165,
                child: Center(
                  child: Text('ไม่มีข่าวประชาสัมพันธ์'),
                ),
              );
              // return loadProduct == true
              //     ? GridView.builder(
              //         shrinkWrap: true,
              //         physics: ClampingScrollPhysics(),
              //         gridDelegate:
              //             const SliverGridDelegateWithMaxCrossAxisExtent(
              //                 maxCrossAxisExtent: 300,
              //                 childAspectRatio: 9 / 14,
              //                 crossAxisSpacing: 15,
              //                 mainAxisSpacing: 20),
              //         itemCount: 6,
              //         itemBuilder: (context, index) => Column(
              //           children: [
              //             SizedBox(height: 10),
              //             LoadingTween(
              //               height: 165,
              //             ),
              //             SizedBox(height: 5),
              //             LoadingTween(
              //               height: 40,
              //             ),
              //             SizedBox(height: 5),
              //             LoadingTween(
              //               height: 17,
              //             ),
              //           ],
              //         ),
              //       )
              //     :
            }
          },
        ),
      ),
    );
  }

  Widget _buildGridView(param) {
    return GridView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // จำนวนคอลัมน์
        crossAxisSpacing: 10, // ระยะห่างแนวนอน
        mainAxisSpacing: 10, // ระยะห่างแนวตั้ง
      ),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: loadingImageNetwork(
                        // snapshot.data[index]['imageUrl'],
                        param['imageUrl'],
                        fit: BoxFit.cover,
                      ),
                    )),
              ),
              SizedBox(height: 5),
              Text(
                param['title'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
            builder: (_) => NewsForm(model: param),
          ),
        );
      },
      child: IntrinsicHeight(
          // height: 165,
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
              height: 115,
              width: 165,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: loadingImageNetwork(
                    param['imageUrl'],
                    // width: 80,
                    // height: 80,
                    fit: BoxFit.contain,
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
                    param['title'],
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Expanded(child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Text(
                          dateStringToDate(param['createDate']),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
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
