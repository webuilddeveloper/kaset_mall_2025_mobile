import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HistoryCouponCentralPage extends StatefulWidget {
  @override
  _HistoryCouponCentralPageState createState() =>
      _HistoryCouponCentralPageState();
}

class _HistoryCouponCentralPageState extends State<HistoryCouponCentralPage> {
  late List<dynamic> categoryList;

  ScrollController scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String keySearch = '';
  String category = '';
  int selectedIndexCategory = 0;

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

  @override
  void initState() {
    categoryList = [
      {'title': 'คูปองที่ใช้ไม่ได้', 'value': '0'},
      {'title': 'คูปองที่ใช้ไปแล้ว', 'value': '1'},
    ];
    selectedIndexCategory = 0;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 10,
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHead(),
            SizedBox(height: 15),
            listView(model),
          ],
        ),
      ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 75,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/back_black.png',
                      height: 15,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'ประวัติ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
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
    return ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 5),
        shrinkWrap: true, // 1st add
        physics: ClampingScrollPhysics(), // 2nd
        itemCount: model.length,
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
                        color: Color(0x80707070),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            model[index]['title'],
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 35,
                              height: 1,
                            ),
                          ),
                          Text(
                            'บาท',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ส่วนลด ${model[index]['title']} บาท',
                                style: TextStyle(
                                  color: Color(0xFF0000000),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                model[index]['description'],
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }
}
