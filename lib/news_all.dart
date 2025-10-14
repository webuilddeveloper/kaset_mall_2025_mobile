import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaset_mall/component/key_search.dart';
import 'package:kaset_mall/component/loading_image_network.dart';
import 'package:kaset_mall/component/material/loading_tween.dart';
import 'package:kaset_mall/news_form.dart';
import 'package:kaset_mall/product_from.dart';
import 'package:kaset_mall/shared/api_provider.dart';
import 'package:kaset_mall/shared/extension.dart';
import 'package:kaset_mall/verify_phone.dart';
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
  bool isMain = true;
  String categorySelected = '';
  String keySearch = '';
  bool isHighlight = false;
  bool hideSearch = true;

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
      _futureModel = postObjectData(newsApi + '/read',
          {"keySearch": keySearch, "category": categorySelected});

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
  //     _futureModel = null;

  //     // _futureModel = getData(server + 'products?per_page=' + _limit.toString());
  //     _futureModel = postProductHotSale(
  //         // server_we_build + 'm/Product/readProduct',
  //         server_we_build + 'm/Product/readProductHot',
  //         // {"per_page": "${_limit.toString()}"}
  //         {});

  //     _futureModel!.then((value) async => {
  //           setState(() {
  //             // total_page = value[0]['total_pages'];
  //             _listModelMore = [...value];
  //             _listModelMore.shuffle();
  //             _listModelMore.length == 0 ? loadProduct = false : true;
  //           })
  //         });
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
    // _filterSelected == 'เกี่ยวข้อง' ? _callRead() : _hotSale;
    _callRead();
    // _getCountItemInCart();
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                tabCategory(),
                SizedBox(height: 5),
                KeySearch(
                  show: hideSearch,
                  onKeySearchChange: (String val) {
                    setState(() {
                      keySearch = val;
                      _callRead();
                    });
                  },
                ),
              ],
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
              return _buildLoading();
            }
          },
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

  tabCategory() {
    return FutureBuilder<dynamic>(
      future: postCategory(
        '${newsCategoryApi}read',
        {'skip': 0, 'limit': 100},
      ),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Container(
            height: 40.0,
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: new BoxDecoration(
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey.withOpacity(0.5),
              //     spreadRadius: 0,
              //     blurRadius: 7,
              //     offset: Offset(0, 3), // changes position of shadow
              //   ),
              // ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 10,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    if (snapshot.data[index]['code'] != '') {
                      setState(() {
                        keySearch = '';
                        isMain = false;
                        isHighlight = false;
                        categorySelected = snapshot.data[index]['code'];
                      });
                    } else {
                      setState(() {
                        isHighlight = true;
                        categorySelected = '';
                        isMain = true;
                      });
                    }
                    setState(() {
                      categorySelected = snapshot.data[index]['code'];
                      _callRead();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: categorySelected == snapshot.data[index]['code']
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 1, color: Theme.of(context).primaryColor),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 5.0,
                    ),
                    child: Text(
                      snapshot.data[index]['title'],
                      style: TextStyle(
                        color: categorySelected == snapshot.data[index]['code']
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                        // decoration: index == selectedIndex
                        //     ? TextDecoration.underline
                        //     : null,
                        fontSize: 15,
                        fontWeight:
                            categorySelected == snapshot.data[index]['code']
                                ? FontWeight.bold
                                : FontWeight.normal,
                        // letterSpacing: 1.2,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            height: 45.0,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            decoration: new BoxDecoration(
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey.withOpacity(0.5),
              //     spreadRadius: 0,
              //     blurRadius: 7,
              //     offset: Offset(0, 3), // changes position of shadow
              //   ),
              // ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
          );
        }
      },
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      padding: EdgeInsets.only(top: 16),
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => SizedBox(
        height: 16,
      ),
      itemBuilder: (context, index) => IntrinsicHeight(
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
            LoadingTween(
              height: 165,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingTween(
                    height: 40,
                  ),
                  Expanded(child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        LoadingTween(
                          height: 17,
                        ),
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
}
