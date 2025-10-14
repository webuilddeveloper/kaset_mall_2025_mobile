import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaset_mall/cart.dart';
import 'package:kaset_mall/shared/api_provider.dart';
import 'package:kaset_mall/widget/scroll_behavior.dart';
import 'package:kaset_mall/widget/search_result.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final storage = new FlutterSecureStorage();
  late Future<dynamic> _futureModel;
  late Future<dynamic> __futureHomeCategory;
  late RefreshController _refreshController;
  late TextEditingController _searchController;
  dynamic _historyModel;
  int _limit = 30;
  int amountItemInCart = 0;
  dynamic _historyGroupModel;
  dynamic _historyCategoryModel;
  late String _selectedAnimal;
  String textSearch = "";

  List<dynamic> _suggestions = [
    // 'Alligator',
    // 'Buffalo',
    // 'Chicken',
    // 'Dog',
    // 'Eagle',
    // 'Frog'
  ];
  dynamic valueStorage;
  dynamic dataValue;

  // static String _displayStringForOption(User option) => option.name;

  @override
  void initState() {
    _historyModel = [];
    _historyGroupModel = [];
    _historyCategoryModel = [];
    _refreshController = new RefreshController();
    _searchController = TextEditingController();
    _callRead();

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
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
    valueStorage = await storage.read(key: 'dataUserLoginDDPM');
    dataValue = json.decode(valueStorage);
    if (dataValue['email'] != null || dataValue['email'] != "") {
      _readHistory();
      _readGroupHistory();
      _readCategoryHistory();
    }

    _onLoadSearch();
    _getCountItemInCart();
    _readCategory();
    // setState(() {
    //   _futureModel =
    //       postDio(server + 'm/goods/isPopular/false/read', {'limit': _limit});
    // });
  }

  _readHistory() async {
    valueStorage = await storage.read(key: 'dataUserLoginDDPM');
    dataValue = json.decode(valueStorage);
    if (dataValue != null) {
      var data = await postDio(server_we_build + 'history/read',
          {'ip': '', 'email': dataValue['email']});
      setState(() {
        _historyModel = data;
      });
    }
  }

  _readGroupHistory() async {
    dynamic valueStorage = await storage.read(key: 'dataUserLoginDDPM');
    dynamic dataValue = json.decode(valueStorage);
    if (dataValue != null) {
      var data = await postDio(server_we_build + 'history/readGroup',
          {'ip': '', 'email': dataValue['email']});
      setState(() {
        _historyGroupModel = data;
      });
    }
  }

  _readCategoryHistory() async {
    dynamic valueStorage = await storage.read(key: 'dataUserLoginDDPM');
    dynamic dataValue = json.decode(valueStorage);
    if (dataValue != null) {
      var data = await postDio(server_we_build + 'history/readCategory',
          {'ip': '', 'email': dataValue['email']});
      setState(() {
        _historyCategoryModel = data;
      });
    }
  }

  _readCategory() async {
    setState(() {
      __futureHomeCategory = getData(server + 'categories');
    });
  }

  // business logic.
  void _onRefresh() async {
    setState(() {
      _limit = 30;
    });
    // _callRead();
    _getCountItemInCart();
    _readCategoryHistory();
    _readHistory();
    _readGroupHistory();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {
      _limit += 30;
      _futureModel =
          postDio(server + 'm/goods/isPopular/false/read', {'limit': _limit});
    });
    _refreshController.loadComplete();
  }

  _onLoadSearch() async {
    await postDio(server_we_build + 'autocomplete/read', {
      "title": textSearch.toString(),
      "permission": "all",
      "limit": 10
    }).then(
      (value) => {
        setState(
          () {
            _suggestions = value.map((e) => e['title']).toList();
          },
        ),
      },
    );

    // server_we_build
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
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SizedBox(
                      width: 30,
                      child: Icon(Icons.arrow_back_ios),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.only(left: 15),
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
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SearchResultPage(
                                    search: _searchController.text,
                                  ),
                                ),
                              );
                            },
                            child: Image.asset(
                              'assets/images/search.png',
                              height: 15,
                              width: 15,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child:
                                // Autocomplete<dynamic>(
                                //   optionsBuilder: (textEditingValue) {
                                //     // When the field is empty
                                //     if (textEditingValue.text.isEmpty) {
                                //       return [];
                                //     }
                                //     setState(() {
                                //       textSearch = textEditingValue.text ?? "";
                                //     });
                                //     // The logic to find out which ones should appear
                                //     return _suggestions.where((element) =>
                                //         element.contains(textEditingValue.text));
                                //   },
                                //   fieldViewBuilder: (context, _searchController,
                                //       FocusNode, onFieldSubmitted) {
                                //     return TextField(
                                //       controller: _searchController,
                                //       textInputAction: TextInputAction.search,
                                //       focusNode: FocusNode,
                                //       // onSubmitted: (value) {
                                //       //   Navigator.push(
                                //       //     context,
                                //       //     MaterialPageRoute(
                                //       //       builder: (_) => SearchResultPage(
                                //       //         search: _searchController.text,
                                //       //       ),
                                //       //     ),
                                //       //   );
                                //       // },
                                //       onEditingComplete: onFieldSubmitted,
                                //       decoration: InputDecoration(
                                //         contentPadding: EdgeInsets.only(bottom: 10),
                                //         fillColor: Colors.white,
                                //         filled: true,
                                //         border: InputBorder.none,
                                //         hintText: 'ค้นหา',
                                //         suffixIconConstraints:
                                //             BoxConstraints(maxWidth: 30),
                                //         suffixIcon: InkWell(
                                //           onTap: () => _searchController.clear(),
                                //           child: ClipRRect(
                                //             borderRadius: BorderRadius.circular(20),
                                //             child: Icon(
                                //               Icons.close,
                                //               size: 25,
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     );
                                //   },
                                //   // optionsViewBuilder:
                                //   //     ((context, onSelected, _suggestions) {
                                //   //   return Material(
                                //   //     child: ListView.separated(
                                //   //       padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                                //   //       // itemBuilder: itemBuilder,
                                //   //       itemCount: _suggestions.length,
                                //   //       separatorBuilder:
                                //   //           (BuildContext context, int index) {
                                //   //         return Divider();
                                //   //       },
                                //   //       itemBuilder:
                                //   //           (BuildContext context, int index) {
                                //   //         final x = _suggestions.elementAt(index);
                                //   //         return Text(x);
                                //   //       },
                                //   //     ),
                                //   //   );
                                //   // }),

                                //   onSelected: (value) {
                                //     setState(() {
                                //       _selectedAnimal = value;
                                //     });
                                //   },
                                // ),

                                // child:
                                TextField(
                              controller: _searchController,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SearchResultPage(
                                      search: _searchController.text,
                                    ),
                                  ),
                                );
                              },
                              onChanged: (e) {
                                _onLoadSearch();
                                setState(() {
                                  textSearch = e ?? "";
                                });
                                _suggestions
                                    .where((element) => element.contains(e));
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 10),
                                fillColor: Colors.white,
                                filled: true,
                                border: InputBorder.none,
                                hintText: 'ค้นหา',
                                suffixIconConstraints:
                                    BoxConstraints(maxWidth: 30),
                                suffixIcon: InkWell(
                                  onTap: () => _searchController.clear(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Icon(
                                      Icons.close,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => CartCentralPage()));
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
        body: ScrollConfiguration(
          behavior: CsBehavior(),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: 20 + MediaQuery.of(context).padding.bottom),
            child: textSearch.length >= 1
                ? _resultSearch()
                : SmartRefresher(
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
                          body = Text("Load Failed!Click retry!",
                              style: styleText);
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
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      children: [
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ประวัติการค้นหา',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            GestureDetector(
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WillPopScope(
                                      onWillPop: () {
                                        return Future.value(false);
                                      },
                                      child: CupertinoAlertDialog(
                                        title: new Text(
                                          'ต้องการล้างประวัติ',
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
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            onPressed: () async {
                                              dynamic valueStorage =
                                                  await storage.read(
                                                      key: 'dataUserLoginDDPM');
                                              dynamic dataValue =
                                                  json.decode(valueStorage);
                                              await postDio(
                                                  server_we_build +
                                                      'history/delete',
                                                  {
                                                    'ip': '',
                                                    'email': dataValue['email']
                                                  });
                                              _readHistory();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          CupertinoDialogAction(
                                            isDefaultAction: true,
                                            child: new Text(
                                              "ยกเลิก",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: 'Kanit',
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'ล้างประวัติ',
                                    style: TextStyle(
                                        fontSize: 11, color: Color(0xFF0B24FB)),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(width: 5),
                                  Image.asset(
                                    'assets/images/central/bin.png',
                                    height: 15,
                                    width: 15,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        _buildSearchWrap(_historyModel),
                        SizedBox(height: 20),
                        Text(
                          'ค้นหายอดนิยม',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        _buildSearchWrap(_historyGroupModel),
                        SizedBox(height: 20),
                        // Text(
                        //   'ค้นหาประเภทยอดนิยม',
                        //   style: TextStyle(
                        //       fontSize: 17, fontWeight: FontWeight.bold),
                        //   maxLines: 2,
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                        // SizedBox(height: 5),
                        // _buildCategory(_historyCategoryModel),
                        // SizedBox(height: 10),
                        // _buildTitle(title: 'สินค้าแนะนำ'),
                        // SizedBox(height: 5),
                        // _buildListSearch(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  _buildSearchWrap(List<dynamic> model) {
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      children: model
          .map(
            (e) => GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.text = e['title'];
                  textSearch = e['title'];
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchResultPage(
                      search: e['title'],
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                decoration: BoxDecoration(
                  color: Color(0xFFE3E6FE),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  e['title'],
                  style: TextStyle(
                      color: Color(0xFF0B24FB).withOpacity(0.5), fontSize: 13),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  _resultSearch() {
    return Material(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        // itemBuilder: itemBuilder,
        itemCount: _suggestions.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          final x = _suggestions.elementAt(index);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 10,
                child: InkWell(
                  onTap: () {
                    _searchController.text = x;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchResultPage(
                          search: x,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    x,
                    overflow: TextOverflow.ellipsis,
                    // style: TextStyle(
                    //     color:
                    //         textSearch == x ? Color(0x006A6ACB) : Color(0xFF000000)),
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _searchController.text = x;
                      textSearch = x;
                      _onLoadSearch();
                    });
                  },
                  child: Icon(
                    Icons.north_west,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

const List<dynamic> mockSearchPopular = [
  {
    'title': 'รองเท้านันยาง',
  },
  {
    'title': 'ชุดนักเรียนตรามือ',
  },
  {
    'title': 'ดินสอ ABC',
  },
];
