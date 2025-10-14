import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kaset_mall/component/key_search.dart';
import 'package:kaset_mall/event_calendar_list_vertical.dart';
import 'package:kaset_mall/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EventCalendarList extends StatefulWidget {
  const EventCalendarList({super.key, required this.title});
  final String title;
  @override
  // ignore: library_private_types_in_public_api
  _EventCalendarList createState() => _EventCalendarList();
}

class _EventCalendarList extends State<EventCalendarList> {
  late EventCalendarList eventCalendarList;
  bool hideSearch = true;
  List<dynamic> listData = [];
  List<dynamic> category = [];
  bool isMain = true;
  String categorySelected = '';
  String keySearch = '';
  bool isHighlight = false;
  int _limit = 10;
  late Future futureModel;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // _futureEventCalendarCategory =
    //     post('${eventCalendarCategoryApi}read', {'skip': 0, 'limit': 100});
    futureModel = postDio('${eventCalendarApi}read', {
      'skip': 0,
      'limit': _limit,
      'keySearch': keySearch,
      'isHighlight': isHighlight,
      'category': categorySelected
    });
    categoryRead();
    super.initState();
  }

  Future<dynamic> categoryRead() async {
    var response = await postDio(eventCalendarCategoryApi + 'read',
        {"permission": "all", "skip": 0, "limit": 999});

    setState(() {
      category = response;
    });

    if (category.isNotEmpty) {
      for (int i = 0; i <= category.length - 1; i++) {
        var res = post('${eventCalendarApi}read', {
          'skip': 0,
          'limit': 100,
          'category': category[i]['code'],
          'keySearch': keySearch
        });
        listData.add(res);
      }
    }
  }

  reloadList() {
    return EventCalendarListVertical(
      model: futureModel,
      urlGallery: eventCalendarGalleryApi,
      urlComment: eventCalendarCommentApi,
      url: '${eventCalendarApi}read',
      title: '',
    );
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;
      futureModel = postDioMessage('${eventCalendarApi}read', {
        'skip': 0,
        'limit': _limit,
        'keySearch': keySearch,
        'isHighlight': isHighlight,
        'category': categorySelected
      });
    });

    await Future.delayed(const Duration(milliseconds: 10000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  tabCategory() {
    return FutureBuilder<dynamic>(
      future: postCategory(
        '${eventCalendarCategoryApi}read',
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
                        categorySelected = snapshot.data[index]['code'];
                      });
                    } else {
                      setState(() {
                        categorySelected = '';
                        isMain = true;
                      });
                    }
                    _onLoading();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.pop(context);
        } else if (details.delta.dx < -0) {
          //Left Swipe
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: header(context, goBack, title: widget.title),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            overScroll.disallowIndicator();
            return false;
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: [
                const SizedBox(
                  height: 5.0,
                ),
                tabCategory(),
                const SizedBox(
                  height: 10.0,
                ),
                KeySearch(
                  show: hideSearch,
                  onKeySearchChange: (String val) {
                    setState(() {
                      keySearch = val;
                      _onLoading();
                    });
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  child: SmartRefresher(
                    enablePullDown: false,
                    enablePullUp: true,
                    footer: const ClassicFooter(
                      loadingText: ' ',
                      canLoadingText: ' ',
                      idleText: ' ',
                      idleIcon:
                          Icon(Icons.arrow_upward, color: Colors.transparent),
                    ),
                    controller: _refreshController,
                    onLoading: _onLoading,
                    child: EventCalendarListVertical(
                      model: futureModel,
                      urlGallery: eventCalendarGalleryApi,
                      urlComment: eventCalendarCommentApi,
                      url: '${eventCalendarApi}read',
                      title: '',
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
