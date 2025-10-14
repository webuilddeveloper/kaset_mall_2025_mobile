import 'package:flutter/material.dart';
import 'package:kaset_mall/component/loading_image_network.dart';
import 'package:kaset_mall/event_calendar_form.dart';
import 'package:kaset_mall/shared/api_provider.dart';
import 'package:kaset_mall/widget/scroll_behavior.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EventCalendarPage extends StatefulWidget {
  const EventCalendarPage({Key? key, @required this.title}) : super(key: key);

  final title;

  @override
  State<EventCalendarPage> createState() => _EventCalendarPageState();
}

class _EventCalendarPageState extends State<EventCalendarPage>
    with TickerProviderStateMixin {
  late Future<dynamic> _futureModel;
  late Future<dynamic> _futureCategory;
  String _keySearch = '';
  String _category = '';
  int _limit = 10;
  bool _loading = false;
  bool _showSearch = false;
  bool _isSearch = false;
  late AnimationController _animationSearchController;
  TextEditingController _searchController = new TextEditingController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<dynamic> _startEnd = [];
  List<dynamic> _monthList = [];
  int _monthSelected = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _showSearch = false;
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 15,
              right: 15,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Color(0x408AD2FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2D9CED),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 30),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            _buildCategory(),
            const SizedBox(height: 10),
            Expanded(
              child: SmartRefresher(
                enablePullDown: false,
                enablePullUp: true,
                footer: ClassicFooter(
                  loadingText: ' ',
                  canLoadingText: ' ',
                  idleText: ' ',
                  idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
                ),
                controller: _refreshController,
                onLoading: _onLoading,
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    _buildEvent(),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 10, top: 5),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return Container(
                          height: 200,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Container(
                                height: 40,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'กรุณาเลือกเดือนที่ต้องการ',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.black,
                                        size: 25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 15,
                                alignment: WrapAlignment.start,
                                children: _startEnd.map(
                                  (e) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _monthSelected = e['code'];
                                          _limit = 10;
                                        });
                                        Navigator.pop(context);

                                        _onLoading();
                                      },
                                      child: Container(
                                        height: 25,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _monthSelected == e['code']
                                              ? Color(0xFF2D9CED)
                                              : Color(0x268AD2FF),
                                          borderRadius:
                                              BorderRadius.circular(12.5),
                                        ),
                                        child: Text(
                                          e['title'],
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: _monthSelected == e['code']
                                                ? Colors.white
                                                : Color(0x802D9CED),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                        );
                      });
                },
                child: Container(
                  height: 40,
                  width: 170,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFED6B2D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'เพิ่มเติม',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return SizedBox(
      height: 25,
      width: double.infinity,
      child: Row(
        children: [
          SizedBox(width: 15),
          GestureDetector(
            onTap: () {
              setState(() {
                _showSearch = !_showSearch;
              });
            },
            child: AnimatedContainer(
              height: 25,
              width: _showSearch ? MediaQuery.of(context).size.width * 0.7 : 25,
              duration: _animationSearchController.duration ??
                  const Duration(microseconds: 500),
              curve: Curves.easeIn,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0x408AD2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _showSearch
                  ? TextFormField(
                      controller: _searchController,
                      keyboardType: TextInputType.text,
                      onEditingComplete: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _isSearch = true;
                          _showSearch = false;
                          _limit = 0;
                        });
                        _onLoading();
                      },
                      style: const TextStyle(
                        color: Color(0xFF2D9CED),
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Kanit',
                        fontSize: 15.0,
                      ),
                      decoration: _decorationSearch(
                        context,
                        hintText: 'ค้นหา',
                      ),
                      validator: (model) {
                        if (model!.isEmpty) {
                          return 'กรุณากรอกวันเดือนปีเกิด.';
                        }
                        return null;
                      },
                    )
                  : Image.asset(
                      'assets/images/search.png',
                      color: Color(0x802D9CED),
                      height: 15,
                      width: 15,
                    ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: FutureBuilder(
              future: _futureCategory,
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    padding: EdgeInsets.only(right: 15),
                    physics: ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, __) =>
                        _buildItemCategory(snapshot.data[__]),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: snapshot.data.length,
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCategory(dynamic model) {
    bool thisCatgory = _category == (model['code'] ?? '');
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSearch = false;
          _loading = true;
          _category = model['code'];
          _limit = 0;
        });
        _onLoading();
      },
      child: Container(
        height: 25,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: thisCatgory ? Color(0xFF2D9CED) : Color(0x268AD2FF),
          borderRadius: BorderRadius.circular(12.5),
        ),
        child: Text(
          '${model['title']}',
          style: TextStyle(
            fontSize: 13,
            color: thisCatgory ? Colors.white : Color(0x802D9CED),
            fontWeight: thisCatgory ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildEvent() {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Center(
              child: Column(
                children: [
                  SizedBox(height: 22),
                  Image.asset(
                    "assets/images/icon_privilege_special_coming_soon.png",
                    height: 253,
                    width: 238,
                  ),
                  SizedBox(height: 21),
                  Text(
                    'ขออภัย',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w500,
                      fontSize: 40,
                    ),
                  ),
                  Text(
                    'เดือน ${_monthList[_monthSelected - 1]} ยังไม่มีกิจกรรมจากสภาทนายความฯ',
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 65),
                ],
              ),
            );
            // return Center(
            //   child:
            //       Text('ไม่พบข้อมูล เดือน ${_monthList[_monthSelected - 1]}'),
            // );
          } else {
            return ScrollConfiguration(
              behavior: CsBehavior(),
              child: ListView.separated(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                itemCount: snapshot.data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 15),
                itemBuilder: (_, __) => _buildEventGroupDay(snapshot.data[__]),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Container();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(
            child: Text('ไม่พบข้อมูล เดือน ${_monthList[_monthSelected - 1]}'),
          );
        }
      },
    );
  }

  Widget _buildEventGroupDay(dynamic model) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Column(
              children: [
                Text(
                  _getMonthTH(model['date']),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getDayTH(model['date']),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: model['items']
                  .map<Widget>(
                    (e) => _buildItemEvent(e),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemEvent(dynamic model) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventCalendarFormPage(
              code: model['code'],
              model: model,
            ),
          ),
        );
      },
      child: Container(
        height: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: loadingImageNetwork(
                model['imageUrl'],
                height: 145,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${model['title']}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  InputDecoration _decorationSearch(context, {String hintText = ''}) =>
      InputDecoration(
        // label: Text(hintText),
        // labelStyle: const TextStyle(
        //   color: Color(0xFF707070),
        //   fontSize: 12,
        // ),
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF707070),
          fontSize: 12,
        ),
        filled: true,
        fillColor: Colors.transparent,
        prefixIcon: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _isSearch = true;
              _showSearch = false;
              _limit = 0;
            });
            _onLoading();
          },
          child: Container(
            padding: EdgeInsets.all(3),
            child: Image.asset(
              'assets/images/search.png',
              color: Color(0x802D9CED),
            ),
          ),
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              if (_searchController.text == '') {
                _isSearch = false;
                _showSearch = false;
              } else {
                _searchController = TextEditingController(text: '');
              }
            });
          },
          child: Container(
            padding: EdgeInsets.all(3),
            child: _searchController.text == ''
                ? Icon(
                    Icons.arrow_back,
                    color: Color(0xFF2D9CED),
                    size: 16,
                  )
                : Image.asset(
                    'assets/images/close_noti_list.png',
                    color: Color(0x802D9CED),
                  ),
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(6.0, 1.0, 1.0, 1.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        errorStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 10.0,
        ),
      );

  @override
  void initState() {
    _animationSearchController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _monthList = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฏาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];
    _setDate();

    _futureModel = postDio('${eventCalendarApi}v2/read', {
      'skip': 0,
      'limit': _limit,
      "category": _category,
      "keySearch": _keySearch,
      "startDate":
          _startEnd.firstWhere((e) => e['code'] == _monthSelected)['month'],
    });

    _futureCategory = postDioCategory('${eventCalendarCategoryApi}read', {});
    super.initState();
  }

  _setDate() {
    var now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      String month = (i + 1).toString();
      if (i.toString().length == 1) {
        month = '0' + (i + 1).toString();
      }
      _monthSelected = now.month;

      _startEnd.add({
        'code': (i + 1),
        "title": _monthList[i],
        "month": now.year.toString() + month,
      });
    }
  }

  void _onLoading() async {
    setState(() {
      _limit += 10;

      _futureModel = postDioMessage('${eventCalendarApi}v2/read', {
        'skip': 0,
        'limit': _limit,
        "category": _category,
        "keySearch": _searchController.text,
        "startDate":
            _startEnd.firstWhere((e) => e['code'] == _monthSelected)['month'],
      });
    });
    await Future.delayed(Duration(milliseconds: 2000));

    _refreshController.loadComplete();
  }

  _getMonthTH(String date) {
    var month = int.parse(date.substring(4, 6));
    return _monthList[month - 1];
  }

  _getDayTH(String date) => int.parse(date.substring(6, 8)).toString();
}
