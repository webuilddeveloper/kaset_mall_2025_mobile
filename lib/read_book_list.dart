import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_mart_v3/cart.dart';
import 'package:mobile_mart_v3/component/loading_image_network.dart';
import 'package:mobile_mart_v3/component/material/loading_tween.dart';
import 'package:mobile_mart_v3/read_book.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/shared/extension.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ReadBookList extends StatefulWidget {
  final String? pdfUrl;

  ReadBookList({this.pdfUrl});

  @override
  _ReadBookListState createState() => _ReadBookListState();
}

class _ReadBookListState extends State<ReadBookList> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  RefreshController? _refreshController;
  ScrollController? _scrollController;
  int _limit = 30;
  Future<dynamic>? _futureBanner;
  Future<dynamic>? _futureknowledge;
  int selectedIndex = 0;
  String displayType = '1';
  bool changeToListView = false;
  String filter = '1';
  String orderKey = '';
  bool changOrderKey = false;
  String orderBy = '';
  String filterType = '';
  int countItem = 0;
  int page = 1;
  int total_page = 0;
  bool loadProduct = true;
  final storage = new FlutterSecureStorage();
  String profileCode = "";
  String? emailProfile;
  Future<dynamic>? _futureCategory;
  String category = '';
  TextEditingController _searchController = new TextEditingController();

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _refreshController = RefreshController();
    _onLoading();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _refreshController?.dispose();

    super.dispose();
  }

  void goBack() async {
    Navigator.pop(context);
  }

  void _onLoading() async {
    _futureCategory = postDio(
      '${knowledgeCategoryApi}read',
      {
        'skip': 0,
        'limit': 100,
      },
    );
    _callReadAll();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController?.loadComplete();
  }

  void _onRefresh() async {
    setState(() {
      _limit = _limit + 10;
      ;
      loadProduct = true;
    });
    _callReadAll();
    _refreshController?.refreshCompleted();
  }

  _callReadAll() async {
    _callReadBanner();
    _callReadKnowledge();
    // _futureBanner = postDio('${mainBannerApi}read', {'limit': 10});
    // _futureknowledge = postDio(server_we_build + 'm/knowledge/read', {
    //   "limit": _limit,
    //   "category": category,
    // });
  }

  _callReadBanner() {
    _futureBanner = postDio('${mainBannerApi}read', {'limit': 10});
  }

  _callReadKnowledge() {
    _futureknowledge = postDio(server_we_build + 'm/knowledge/read', {
      "limit": _limit,
      "category": category,
      "keySearch": _searchController.text,
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
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => goBack(),
                      child: Container(
                        height: 35,
                        width: 35,
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
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
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (value) {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (_) => SearchResultPage(
                                    //       search: _searchController.text,
                                    //     ),
                                    //   ),
                                    // );
                                  },
                                  onChanged: (e) {
                                    // setState(() {
                                    //   textSearch = e ?? "";
                                    // });
                                    setState(() {
                                      _callReadKnowledge();
                                    });
                                    // _suggestions.where((element) => element.contains(e));
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
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() {
                                          _callReadKnowledge();
                                        });
                                      },
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
          body: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/novel_bg.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Column(
                children: [
                  _buildCategory(),
                  Expanded(
                    child: _buildMain(),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  _buildCategory() {
    return FutureBuilder<dynamic>(
      future: _futureCategory,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          var data = [
            ...[
              {'code': "", 'title': 'ทั้งหมด'}
            ],
            ...snapshot.data
          ];
          return Container(
            height: 45.0,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      category = data[index]['code'];
                      selectedIndex = index;
                    });
                    _callReadAll();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      data[index]['title'],
                      style: TextStyle(
                        color:
                            index == selectedIndex ? Colors.black : Colors.grey,
                        decoration: index == selectedIndex
                            ? TextDecoration.underline
                            : null,
                        fontSize: 16.0,
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
        } else {
          return Container(
            height: 45.0,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
          );
        }
      },
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
        builder: (BuildContext context, LoadStatus? mode) {
          Widget? body;
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
              // SizedBox(height: 10),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 15),
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(10),
              //     child: CarouselBanner(
              //         model: _futureBanner,
              //         url: 'main/',
              //         height: (MediaQuery.of(context).size.width + (10)) / 2.4),
              //   ),
              // ),
              // SizedBox(height: 10),
              FutureBuilder(
                future: _futureknowledge,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length > 0) {
                      if (changeToListView) {
                        return _buildListView(snapshot.data);
                      } else {
                        return _buildGridView(snapshot.data);
                      }
                    } else {
                      return Container(
                        width: double.infinity,
                        height: 300,
                        alignment: Alignment.center,
                        child: Text(
                          'ไม่พบข้อมูล',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 15,
                          ),
                        ),
                      );
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              title: param['title'],
              pdfUrl: (param['fileUrl'] ?? ""),
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: (param['imageUrl'] ?? "") != ""
                  ? loadingImageNetwork(
                      param['imageUrl'],
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/no_image.png',
                      fit: BoxFit.cover,
                      // col
                    ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            param['title'] ?? '',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: ScaleSize.textScaleFactor(context),
          ),
          (param['description'] ?? "") != ''
              ? Text(
                  parseHtmlString(param['description'] ?? ''),
                  maxLines: 1,
                  style: TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: ScaleSize.textScaleFactor(context),
                )
              : SizedBox(),
          SizedBox(height: 10),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              title: param['title'],
              pdfUrl: (param['fileUrl'] ?? ""),
            ),
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
                Container(
                  height: 165,
                  width: 165,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: (param['imageUrl'] ?? "") != ""
                        ? loadingImageNetwork(
                            param['imageUrl'],
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/no_image.png',
                            fit: BoxFit.cover,
                            // col
                          ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        param['title'] ?? '',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      (param['description'] ?? "") != ''
                          ? Text(
                              parseHtmlString(param['description'] ?? ''),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            )
                          : SizedBox(),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
