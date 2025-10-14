import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../shared/extension.dart';
import '../widget/header.dart';

class CouponPickUpCentralPage extends StatefulWidget {
  CouponPickUpCentralPage({Key? key, this.readMode = false}) : super(key: key);
  bool readMode;
  @override
  State<CouponPickUpCentralPage> createState() =>
      _CouponPickupCentralPageState();
}

class _CouponPickupCentralPageState extends State<CouponPickUpCentralPage> {
  late Future<dynamic> _futureModelMyReward;
  late Future<dynamic> _futureModelMyRewardPickUp;
  late Future<dynamic> _futureModelMyLike;
  late Future<dynamic> _futureModelUsed;
  late Future<dynamic> _futureModelExpired;
  late Future<dynamic> _futureBanner;
  late Future<dynamic> _futureCategory;
  late List<dynamic> _modelMyReward;
  late List<dynamic> categoryList;
  final formatPrice = NumberFormat("#,##0.00", "en_US");

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  int selectedIndexCategory = 0;
  int limit = 10;

  dynamic model = [
    {
      'title': '100',
      'imageUrl': 'assets/images/bg0011.jpeg',
      'description': 'เมื่อสั่งซื้อสินค้าครั้งแรกกับแอพ',
    },
    {
      'title': '100',
      'imageUrl': 'assets/images/bg0011.jpeg',
      'description': 'เมื่อสั่งซื้อสินค้าครั้งแรกกับแอพ',
    },
    {
      'title': '100',
      'imageUrl': 'assets/images/bg0011.jpeg',
      'description': 'เมื่อสั่งซื้อสินค้าครั้งแรกกับแอพ',
    },
  ];

  dynamic modeld = [
    {
      'title': '50',
      'imageUrl': 'assets/images/bg0011.jpeg',
      'description': 'เมื่อสั่งซื้อสินค้าครั้งแรกกับแอพ',
    },
    {
      'title': '50',
      'imageUrl': 'assets/images/bg0011.jpeg',
      'description': 'เมื่อสั่งซื้อสินค้าครั้งแรกกับแอพ',
    },
    {
      'title': '50',
      'imageUrl': 'assets/images/bg0011.jpeg',
      'description': 'เมื่อสั่งซื้อสินค้าครั้งแรกกับแอพ',
    },
  ];

  @override
  void initState() {
    categoryList = [
      {'title': 'ทั้งหมด', 'value': '0'},
      {'title': 'คูปองล่าสุด', 'value': '1'},
      {'title': 'คูปองใกล้หมดอายุ', 'value': '2'}
    ];
    selectedIndexCategory = 0;
    _callRead();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _pickUpCoupon(coupon_id) async {
    _modelMyReward = await get('${server}users/me/coupons?');
    var response =
        await postObjectData(server + 'coupons/${coupon_id}/pick', {});
    if (response != null) {
      _showDialog('Already have coupon in your stock');
    } else {
      _showDialog('Success').then((value) => {_callRead()});
    }
    // .then((value) => {Navigator.pop(context, 'success')});
  }

  _showDialog(String title) {
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
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              // content: Text(" "),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    "Agree",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFFFF7514),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerCentral(context, title: 'คูปองของฉัน'),
      backgroundColor: Color(0xFFFFFFFF),
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: _buildSmartRefresher(
          ListView(
            children: [
              _buildHead(),
              SizedBox(height: 15),
              listView(model),
              // textInteresting(),
              // listViewInteresting(_modelMyReward),
            ],
          ),
        ),
      ),
    );
  }

  textInteresting() {
    return Padding(
      padding: EdgeInsets.only(right: 15, left: 15, bottom: 5),
      child: Text(
        'คูปองที่น่าสนใจ',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000),
        ),
      ),
    );
  }

  listViewInteresting(_modelMyReward) {
    return FutureBuilder(
        future: _futureModelMyReward,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(height: 5),
                  shrinkWrap: true, // 1st add
                  physics: ClampingScrollPhysics(), // 2nd
                  itemCount: snapshot.data.length,
                  // scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: Color(0x4DE3E6FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  color: Color(0xFFE3E6FE),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Color(0x660B24FB),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      moneyFormat(snapshot.data[index]
                                              ['discount']
                                          .toString()),
                                      style: TextStyle(
                                        color: Color(0xFF0B24FB),
                                        fontSize: moneyFormat(snapshot
                                                            .data[index]
                                                                ['discount']
                                                            .toString())
                                                        .length >=
                                                    3 &&
                                                moneyFormat(snapshot.data[index]
                                                                ['discount']
                                                            .toString())
                                                        .length <
                                                    5
                                            ? 30
                                            : moneyFormat(snapshot.data[index]
                                                                ['discount']
                                                            .toString())
                                                        .length >=
                                                    5
                                                ? 20
                                                : 10,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      'บาท',
                                      style: TextStyle(
                                        color: Color(0xFF0B24FB),
                                        fontSize: 20,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5, right: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data[index]['name'],
                                          style: TextStyle(
                                            color: Color(0xFF0000000),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'เมื่อซื้อสินค้าครบ ' +
                                              moneyFormat((snapshot.data[index]
                                                      ['minimum_order_total'])
                                                  .toString()) +
                                              ' บาท',
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Color(0xFF707070),
                                            fontSize: 13,
                                            overflow: TextOverflow.ellipsis,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          snapshot.data[index]['expired_at'] !=
                                                  null
                                              ? dateThai(snapshot.data[index]
                                                      ['started_at']) +
                                                  ' - ' +
                                                  dateThai(snapshot.data[index]
                                                      ['expired_at'])
                                              : dateThai(snapshot.data[index]
                                                  ['started_at']),
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Color(0xFF707070),
                                            fontSize: 13,
                                            overflow: TextOverflow.ellipsis,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(child: SizedBox()),
                                        InkWell(
                                          onTap: () {
                                            _pickUpCoupon(
                                                snapshot.data[index]['id']);
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 25,
                                            width: 85,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFDF0B24),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: Text(
                                              'เก็บคูปอง',
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 13,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        });
  }

  _buildSmartRefresher(Widget child) {
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
        builder: (context, mode) {
          Widget? body;
          return Container(
            height: 60,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: child,
    );
  }

  _buildHead() {
    return Container(
      // color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _categorySelector(
              model: categoryList,
              onChange: (String val) {
                setState(
                  () => {},
                );
                _onLoading();
              },
            ),
          ],
        ),
      ),
    );
  }

  _categorySelector({dynamic model, Function? onChange}) {
    return Container(
      height: 25.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: model.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              // widget.onChange(model[index]['code']);
              setState(() {
                selectedIndexCategory = index;
              });
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(
                horizontal: 7.0,
                // vertical: 5.0,
              ),
              child: Text(
                model[index]['title'],
                style: TextStyle(
                  color: index == selectedIndexCategory
                      ? Color(0xFF0B24FB)
                      : Color(0x80707070),
                  // decoration: index == selectedIndex
                  //     ? TextDecoration.underline
                  //     : null,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1.2,
                  fontFamily: 'Kanit',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  listView(model) {
    return FutureBuilder(
        future: _futureModelMyRewardPickUp,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 5),
                shrinkWrap: true, // 1st add
                physics: ClampingScrollPhysics(), // 2nd
                itemCount: snapshot.data.length,
                // scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: Color(0x4DE3E6FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                color: Color(0xFFE3E6FE),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color(0x660B24FB),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    moneyFormat(snapshot.data[index]['discount']
                                        .toString()),
                                    style: TextStyle(
                                      color: Color(0xFF0B24FB),
                                      fontSize: moneyFormat(snapshot.data[index]
                                                              ['discount']
                                                          .toString())
                                                      .length >=
                                                  3 &&
                                              moneyFormat(snapshot.data[index]
                                                              ['discount']
                                                          .toString())
                                                      .length <
                                                  5
                                          ? 20
                                          : moneyFormat(snapshot.data[index]
                                                              ['discount']
                                                          .toString())
                                                      .length >=
                                                  5
                                              ? 20
                                              : 20,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    'บาท',
                                    style: TextStyle(
                                      color: Color(0xFF0B24FB),
                                      fontSize: 20,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10, left: 5, right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data[index]['name'],
                                        style: TextStyle(
                                          color: Color(0xFF0000000),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'เมื่อซื้อสินค้าครบ ' +
                                            moneyFormat((snapshot.data[index]
                                                    ['minimum_order_total'])
                                                .toString()) +
                                            ' บาท',
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Color(0xFF707070),
                                          fontSize: 13,
                                          overflow: TextOverflow.ellipsis,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        snapshot.data[index]['expired_at'] !=
                                                null
                                            ? dateThai(snapshot.data[index]
                                                    ['started_at']) +
                                                ' - ' +
                                                dateThai(snapshot.data[index]
                                                    ['expired_at'])
                                            : dateThai(snapshot.data[index]
                                                ['started_at']),
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Color(0xFF707070),
                                          fontSize: 13,
                                          overflow: TextOverflow.ellipsis,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: SizedBox()),
                                      InkWell(
                                        onTap: () {
                                          widget.readMode == false
                                              ? _checkCoupon(snapshot
                                                      .data[index]['code'])
                                                  .then((e) => {
                                                        if (e['status'] == 'F')
                                                          {}
                                                        else
                                                          {
                                                            Navigator.pop(
                                                                context, e),
                                                          }
                                                      })
                                              : null;
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 25,
                                          width: 85,
                                          decoration: BoxDecoration(
                                            color: widget.readMode == false
                                                ? Color(0xFFDF0B24)
                                                : Colors.grey.shade400,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Text(
                                            widget.readMode == false
                                                ? 'ใช้เลย'
                                                : 'เก็บแล้ว',
                                            style: TextStyle(
                                              color: widget.readMode == false
                                                  ? Color(0xFFFFFFFF)
                                                  : Colors.grey.shade200,
                                              fontSize: 13,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          } else {
            return Container(
              alignment: Alignment.center,
              height: 100,
              child: Text('ไม่พบคูปองที่เก็บ'),
            );
          }
        });
  }

  void _onRefresh() async {
    _callRead();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    _callRead();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  _checkCoupon(code) async {
    var status = await postObjectData(server + 'coupons/apply', {'code': code});
    return status;
  }

  _callRead() async {
    setState(
      () {
        // _futureBanner = postDio('${mainBannerApi}read', {'limit': 10});
        _futureModelMyReward = getData('${server}coupons?');
        _futureModelMyRewardPickUp = get('${server}users/me/coupons?');

        _futureModelMyLike = postDio('${server}m/coupon/readMyLike', {
          "category": category,
          "limit": 10,
          "keySearch": keySearch,
        });

        // _futureModelUsed = postDio('${server}m/coupon/readMyReward', {
        //   "category": category,
        //   "limit": 10,
        //   "keySearch": keySearch,
        //   "status": "A"
        // });

        // _futureModelExpired = postDio('${server}m/coupon/readMyReward', {
        //   "category": category,
        //   "limit": 10,
        //   "keySearch": keySearch,
        //   "status": "Z"
        // });

        // _futureCategory = postDioCategory(
        //   '${couponCategoryApi}read',
        //   {
        //     'skip': 0,
        //     'limit': 100,
        //   },
        // );
      },
    );
  }
}
