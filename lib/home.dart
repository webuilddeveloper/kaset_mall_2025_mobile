import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_mart_v3/cart.dart';
import 'package:mobile_mart_v3/chats_staff.dart';
import 'package:mobile_mart_v3/component/carousel_banner.dart';
import 'package:mobile_mart_v3/component/loading_image_network.dart';
import 'package:mobile_mart_v3/component/material/loading_tween.dart';
import 'package:mobile_mart_v3/component/toast_fail.dart';
import 'package:mobile_mart_v3/event_calendar.dart';
import 'package:mobile_mart_v3/event_calendar_main.dart';
import 'package:mobile_mart_v3/login.dart';
import 'package:mobile_mart_v3/math_game/math_game_main.dart';
import 'package:mobile_mart_v3/news_all.dart';
import 'package:mobile_mart_v3/product_all.dart';
import 'package:mobile_mart_v3/product_from.dart';
import 'package:mobile_mart_v3/product_list_by_category.dart';
import 'package:mobile_mart_v3/purchase_menu.dart';
import 'package:mobile_mart_v3/search.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/shared/extension.dart';
import 'package:mobile_mart_v3/shared/notification_service.dart';
import 'package:mobile_mart_v3/verify_phone.dart';
import 'package:mobile_mart_v3/widget/videoForm.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/link_url_in.dart';
import '../read_book.dart';
import '../read_book_list.dart';
import '../widget/my_video_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class HomeCentralPage extends StatefulWidget {
  HomeCentralPage({Key? key, this.changePage}) : super(key: key);
  late _HomeCentralPageState homeCentralPageState;
  Function? changePage;

  @override
  State<HomeCentralPage> createState() {
    homeCentralPageState = _HomeCentralPageState();
    return homeCentralPageState;
  }

  getState() => homeCentralPageState;
}

class _HomeCentralPageState extends State<HomeCentralPage> {
  final storage = new FlutterSecureStorage();

  TextEditingController searchController = TextEditingController();

  dynamic profile = {'firstName': '', 'lastName': '', 'imageUrl': ''};
  RefreshController? _refreshController;
  ScrollController? _scrollController;
  int _limit = 30;
  Future<dynamic>? _futureCategory;
  Future<dynamic>? _futureBanner;
  Future<dynamic>? _futureModelNew;
  List<dynamic> _futureModelTrending = [];
  List<dynamic> _futureProductHot = [];
  List<dynamic> _futureListVideo = [];

  Future<dynamic>? _futureModelForYou;

  int amountItemInCart = 0;
  String profileCode = "";
  String verifyPhonePage = '';
  DateTime? currentBackPressTime;

  String? emailProfile;
  int total_page = 0;
  int page = 1;
  Future<dynamic>? _futureknowledge;
  bool loadProduct = true;
  bool _isVisible = true;
  String? _userId;
  String? _username;

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _refreshController = RefreshController();
    _getCategory();
    _callRead();
    _getUserData();
    _getCountItemInCart();
    _callReadVideoShort();
    _callReadAll();
    _onLoading();

    super.initState();
  }

  Future<bool> sendPushMessage({
    String? recipientToken,
    String? title,
    String? body,
  }) async {
    const rootFilePath =
        'assets/json/suksapan-mall-firebase-adminsdk-86uob-5a14014c90.json';
    final jsonCredentials = await rootBundle.loadString(rootFilePath);
    final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);
    final client = await auth.clientViaServiceAccount(
      creds,
      ['https://www.googleapis.com/auth/cloud-platform'],
    ).then((value) => {});
    return true;
  }

  _getUserData() async {
    var _token = await storage.read(key: 'tokenD');
    var _category = await storage.read(key: 'profileCategory');
    final result = await getUser(server + 'users/me');

    if (result != null) if (result['id'] != '') {
      storage.write(key: 'email', value: result['email']);

      postDio(
        '${server_we_build}log/logToken/create',
        {
          'userId': result['id'],
          'email': result['email'],
          'category': _category,
          'token': _token,
        },
      );
      setState(() {
        verifyPhonePage = result['phone_verified'].toString();
        emailProfile = result['email'].toString();
        _userId = result['id'];
        _username = result['name'];
      });
    }
  }

  _getCountItemInCart() async {
    await get(server + 'carts').then((value) async {
      if (value != null) {
        setState(() {
          amountItemInCart = value.length;
        });

        if (amountItemInCart > 0) {
          NotificationService.subscribeToAllTopic('suksapan-item');
        } else {
          NotificationService.subscribeToAllTopic('suksapan-mall');
        }
      }
    });
  }

  _getCategory() async {
    List<dynamic> model = await getData(server + 'categories');
    model.sort((a, b) => a['description'].compareTo(b['description']));
    setState(() {
      _futureCategory = Future.value(model);
      // logWTF(_futureCategory);
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _refreshController?.dispose();
    super.dispose();
  }

  // business logic.
  void onRefresh() async {
    // _onLoading();
    setState(() {
      _futureModelTrending = [];
      _futureProductHot = [];
      _limit = 30;
    });
    _scrollToTop();
    _callRead();
    _getCategory();
    _getCountItemInCart();
    // _callReadVideoShort();
    _refreshController?.refreshCompleted();
    _callReadAll();
  }

  void _scrollToTop() {
    _scrollController?.animateTo(0,
        duration: const Duration(milliseconds: 100), curve: Curves.linear);
  }

  void _onLoading() async {
    if (page < total_page) {
      setState(() {
        page += 1;
      });

      try {
        var productData = await postProductData(
          server_we_build + 'm/Product/readProduct',
          {
            "search": "",
            "page": "$page",
            "per_page": _limit.toString(),
          },
        );
        var hotProductData = await postProductHot(
          server_we_build + 'm/Product/readProductHot',
          {"per_page": "${page.toString()}"},
          _limit,
        );

        // อัปเดตค่าที่ได้จาก API
        setState(() {
          _futureModelTrending = [..._futureModelTrending, ...productData];
          total_page = productData[0]['total_pages'];
          _futureProductHot = [..._futureProductHot, ...hotProductData];
        });
      } catch (e) {
        print("Error loading data: $e");
      }
    }
  }

  _callRead() async {
    _futureBanner = postDio('${mainBannerApi}read', {'limit': 999});

    List<String> keySearchRandom;
    var element1 = "";
    var element2 = "";
    var element3 = "";

    var value = await postProductData(
      server_we_build + 'm/Product/readProduct',
      {
        "search": "$element3",
        "per_page": _limit.toString(),
      },
    );

    setState(() {
      _futureModelTrending = value;
      total_page = value[0]['total_pages'];
    });

    var value2 = await postProductHot(
      server_we_build + 'm/Product/readProductHot',
      {"per_page": "${page.toString()}"},
      _limit,
    );

    setState(() {
      _futureProductHot = value2;
    });

    value = await postProductHotSale(
      server_we_build + 'm/Product/readProduct',
      {
        "search": "$element3",
        "per_page": _limit.toString(),
      },
    );

    setState(() {
      if (value != null && value.isNotEmpty) {
        total_page = value[0]['total_pages'];
      } else {
        total_page = 0;
      }
    });

    _futureModelForYou = postProductData(
        server_we_build + 'm/Product/readProduct', {"search": "$element1"});

    _futureModelNew =
        postProductHotSale(server_we_build + 'm/Product/readProductHot', {});

    profileCode = (await storage.read(key: 'profileCode10')) ?? '';

    if (profileCode == '') {
      NotificationService.subscribeToAllTopic('suksapan-general');
    } else {
      _readCoupons();
    }
  }

  _callReadVideoShort() async {
    var value = await postDio('${server_we_build}videoShort/read', {});
    setState(() {
      _futureListVideo = value;
    });
  }

  _addLog(param) async {
    await postObjectData(server_we_build + 'log/logGoods/create', {
      "username": emailProfile ?? "",
      "profileCode": profileCode,
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

  _callReadAll() async {
    _callReadBanner();
    _callReadKnowledge();
  }

  _callReadBanner() {
    _futureBanner = postDio('${mainBannerApi}read', {'limit': 10});
  }

  _callReadKnowledge() {
    _futureknowledge = postDio(server_we_build + 'm/knowledge/read', {
      "limit": _limit,
    });
  }

  _readCoupons() async {
    var ConponsMe = await get(server + 'users/me/coupons');
    if (ConponsMe.any((s) => s['code'] == "welcome" && s['status'] == 0)) {
      if (amountItemInCart > 0)
        NotificationService.subscribeToAllTopic('suksapan-register-item');
      else
        NotificationService.subscribeToAllTopic('suksapan-register');
    }
  }

  Offset _offset = Offset(300, 300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: (MediaQuery.of(context).size.height /
                MediaQuery.of(context).size.width) +
            AdaptiveTextSize().getadaptiveTextSize(context, 60),
        flexibleSpace: Container(
          color: Colors.transparent,
          child: Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    // Check if user has previously logged in
                    final prefs = await SharedPreferences.getInstance();
                    final String? savedCardId =
                        prefs.getString('saved_card_id');

                    if (savedCardId != null && savedCardId.isNotEmpty) {
                      // User has logged in before, navigate directly to PurchaseMenuPage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PurchaseMenuPage(
                            cardid: savedCardId,
                          ),
                        ),
                      );
                    } else {
                      // First time login, go to verification screen
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => IDVerificationScreen(),
                      //   ),
                      // );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สวัสดีตอนเช้า',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000000),
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context),
                      ),
                      Text(
                        'คุณออกแบบ ทดลอง',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF000000),
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    if (profileCode == '') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => LoginCentralPage(),
                        ),
                      );
                    } else if (verifyPhonePage == 'false') {
                      _showVerifyCheckDialog();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartCentralPage(),
                        ),
                      ).then((value) => _getCountItemInCart());
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        height:
                            AdaptiveTextSize().getadaptiveTextSize(context, 35),
                        width:
                            AdaptiveTextSize().getadaptiveTextSize(context, 35),
                        padding: EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/kaset/basket.png',
                          color: Color(0xFF000000),
                          scale: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 1),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          height: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 15),
                          width: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFe4253f),
                          ),
                          child: Text(
                            amountItemInCart > 99
                                ? '99+'
                                : amountItemInCart.toString(),
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: amountItemInCart.toString().length <= 1
                                  ? 10
                                  : amountItemInCart.toString().length == 2
                                      ? 9
                                      : 8,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                            textScaleFactor: ScaleSize.textScaleFactor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: SmartRefresher(
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
                  Widget body;
                  TextStyle styleText = TextStyle(
                    color: Color(0xFFDF0B24),
                  );

                  if (mode == LoadStatus.idle) {
                    body = Text("Pull up to load", style: styleText);
                  } else if (mode == LoadStatus.loading) {
                    body = CupertinoActivityIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = Text("Load Failed! Click retry!", style: styleText);
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text("Release to load more", style: styleText);
                  } else {
                    body = Text("No more Data", style: styleText);
                  }
                  return SizedBox(
                    height: 60.0,
                    child: Center(child: body),
                  );
                },
              ),
              controller: _refreshController!,
              onRefresh: onRefresh,
              onLoading: _onLoading,
              child: ListView(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.only(top: 10),
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search_rounded),
                        suffixIcon: Image.asset(
                          'assets/images/kaset/filter.png',
                          scale: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CarouselBanner(
                        model: _futureBanner,
                        url: 'main/',
                        height:
                            (MediaQuery.of(context).size.width + (10)) / 2.4,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {},
                    child: _buildTitle(
                      title: 'หมวดหมู่',
                      // color: Color(0xFFF7F7F7),
                      showAll: true,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildCategory(),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {},
                    child: _buildTitle(
                      code: 'news',
                      title: 'ข่าวสารประชาสัมพันธ์',
                      // color: Color(0xFFF7F7F7),
                      showAll: true,
                    ),
                  ),
                  _buildNew(),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {},
                    child: _buildTitle(
                      code: 'event',
                      title: 'ปฏิทินกิจกรรมที่น่าสนใจ',
                      // color: Color(0xFFF7F7F7),
                      showAll: true,
                    ),
                  ),
                  _buildNew(),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {},
                    child: _buildTitle(
                      title: 'สิทธิประโยชน์',
                      // color: Color(0xFFF7F7F7),
                      showAll: true,
                    ),
                  ),
                  _buildForYou(),

                  // SizedBox(height: 10),
                  // GestureDetector(
                  //   onTap: () => launchInWebViewWithJavaScript(
                  //       'https://teaching.suksapanpanit.com/th'),
                  //   child: Image.asset(
                  //     'assets/ssp-teching-banner.jpg',
                  //     fit: BoxFit.contain,
                  //   ),
                  // ),
                  // SizedBox(height: 15),
                  // _buildVideoShort(),
                  SizedBox(height: 15),
                  _buildTitle(title: 'สินค้าศึกษาภัณฑ์มอลล์', showAll: true),
                  SizedBox(height: 5),
                  _buildTrending(),
                ],
              ),
            ),
          ),
          // // เนื้อหาอื่นใน Stack ของคุณ
          // if (_isVisible)
          //   StatefulBuilder(
          //     builder: (context, setStateFloating) {
          //       return Positioned(
          //         top: _offset.dy,
          //         left: _offset.dx,
          //         child: Draggable(
          //           feedback: _buildFloatingButton(),
          //           childWhenDragging: Container(),
          //           child: _buildFloatingButton(),
          //           onDragEnd: (details) {
          //             setStateFloating(() {
          //               _offset = details.offset;
          //             });
          //           },
          //         ),
          //       );
          //     },
          //   ),
        ],
      ),
    );
  }

  // Widget _buildFloatingButton() {
  //   return Stack(
  //     alignment: Alignment.topRight,
  //     children: [
  //       Container(
  //         width: 90.0,
  //         height: 90.0,
  //         decoration: BoxDecoration(
  //           color: Colors.transparent,
  //           shape: BoxShape.circle,
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.pinkAccent
  //                   .withOpacity(0.4), // สีของเงา ปรับความเข้มขึ้น
  //               spreadRadius: 10, // การกระจายเงา
  //               blurRadius: 20, // ความเบลอของเงา
  //               offset: Offset(0, 12), // ตำแหน่งของเงา (แนวนอน, แนวตั้ง)
  //             ),
  //           ],
  //         ),
  //         child: FloatingActionButton(
  //           onPressed: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (_) => MathGameMain(),
  //               ),
  //             );
  //           },
  //           backgroundColor: Colors.transparent,
  //           elevation: 0,
  //           child: Image.asset(
  //             'assets/images/Icon-quickMath.png',
  //             fit: BoxFit.cover,
  //           ),
  //           tooltip: 'คณิตคิดไว',
  //         ),
  //       ),
  //       Positioned(
  //         top: 0,
  //         right: 0,
  //         child: GestureDetector(
  //           onTap: () {
  //             setState(() {
  //               _isVisible = false; // ซ่อนปุ่มเมื่อกด "X"
  //             });
  //           },
  //           child: Container(
  //             width: 25,
  //             height: 25,
  //             decoration: BoxDecoration(
  //               color: Colors.red,
  //               shape: BoxShape.circle,
  //             ),
  //             child: Icon(
  //               Icons.close,
  //               color: Colors.white,
  //               size: 16,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Future<bool> confirmExit() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      toastFail(
        context,
        text: 'กดอีกครั้งเพื่อออก',
        color: Colors.black,
        fontColor: Colors.white,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  _buildTitle({
    String? code,
    String? title,
    bool showAll = false,
    Color color = Colors.white,
    Widget? nextPage,
  }) {
    return Container(
      color: color,
      // padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: EdgeInsets.only(
        left: 15,
        top: 10,
        right: 15,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title!,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: ScaleSize.textScaleFactor(context),
          ),
          GestureDetector(
              onTap: () {
                if (nextPage != null) {
                  // ไปหน้าที่กำหนด
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => nextPage),
                  );
                } else if (showAll) {
                  // EventCalendarPage
                  if (code == 'event') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EventCalendarMain(title: title),
                      ),
                    );
                  } else if (code == 'news') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            NewsAllPage(title: title, mode: showAll),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductAllCentralPage(title: title, mode: showAll),
                      ),
                    ).then((value) => _getCountItemInCart());
                  }
                }
              },
              child: showAll
                  ? Row(
                      children: [
                        Text(
                          'ดูทั้งหมด',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFFfd3131)),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textScaleFactor: ScaleSize.textScaleFactor(context),
                        ),
                        SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFFfd3131),
                          size: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 12),
                        ),
                      ],
                    )
                  : Container())
        ],
      ),
    );
  }

  _buildCategory() {
    return FutureBuilder(
      future: _futureCategory,
      builder: (context, snapshot) {
        return SizedBox(
          height: AdaptiveTextSize().getadaptiveTextSize(context, 105),
          width: double.infinity,
          child: ListView(
            padding: EdgeInsets.only(left: 14),
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              if (snapshot.hasData)
                for (var i = 0; i < snapshot.data.length; i++)
                  SizedBox(
                    width: AdaptiveTextSize().getadaptiveTextSize(context, 70),
                    child: GestureDetector(
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductListByCategory(
                                code: snapshot.data[i]['id']),
                          ),
                        ).then((value) => _getCountItemInCart()),
                      },
                      child: Column(
                        children: [
                          Container(
                              // constraints: BoxConstraints(),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Color(0xFF09665a),
                              ),
                              height: AdaptiveTextSize()
                                  .getadaptiveTextSize(context, 60),
                              width: AdaptiveTextSize()
                                  .getadaptiveTextSize(context, 60),
                              child:
                                  //snapshot.data[i]['thumbnail_url'] == null
                                  // ?
                                  Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  "assets/images/kaset/tractor.png",
                                  color: Colors.white,
                                ),
                              )
                              // : Image.network(
                              //     snapshot.data[i]['thumbnail_url'],
                              //   ),
                              ),
                          SizedBox(height: 5),
                          Expanded(
                            child: Text(
                              snapshot.data[i]['name'],
                              style: TextStyle(fontSize: 13),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textScaleFactor:
                                  ScaleSize.textScaleFactor(context),
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  )
              else
                Text(
                  'ไม่มีหมวดหมู่',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        );
      },
    );
  }

  _buildNew() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 215,
            child: FutureBuilder<dynamic>(
              future: _futureModelNew,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    separatorBuilder: (_, __) => SizedBox(width: 14),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        //newdetail
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 145,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              // color: Colors.red,
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.grey.withOpacity(0.3),
                              //     spreadRadius: 2,
                              //     blurRadius: 5,
                              //     offset: Offset(0, 3),
                              //   ),
                              // ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 145,
                                  width: 145,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16)),
                                  ),
                                  child: snapshot.data[index]['media']['data']
                                              .length >
                                          0
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: loadingImageNetwork(
                                            // snapshot.data[index]['imageUrl'],
                                            snapshot.data[index]['media']
                                                ['data'][0]['thumbnail'],
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            // color: Color(0XFF0B24FB),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Image.asset(
                                            'assets/images/no_image.png',
                                            fit: BoxFit.contain,
                                            // color: Colors.white,
                                          ),
                                        ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  snapshot.data[index]['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return _buildWaitingCard(scrollDirection: Axis.horizontal);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  // _buildVideoShortOld() {
  //   return Container(
  //     color: Color(0xFFF7F7F7),
  //     padding: const EdgeInsets.only(
  //       top: 10,
  //       bottom: 10,
  //     ),
  //     child: Column(
  //       children: [
  //         GestureDetector(
  //           onTap: () {
  //           },
  //           child: _buildTitle(
  //             title: 'SSP Video',
  //             color: Color(0xFFF7F7F7),
  //             showAll: false,
  //           ),
  //         ),
  //         SizedBox(
  //           height: 180,
  //           child: ListView.separated(
  //             padding: EdgeInsets.symmetric(horizontal: 8),
  //             scrollDirection: Axis.horizontal,
  //             separatorBuilder: (context, index) => SizedBox(width: 8),
  //             shrinkWrap: false,
  //             itemCount:
  //                 _futureListVideo.length > 7 ? 7 : _futureListVideo.length,
  //             itemBuilder: (context, index) {
  //               VideoPlayerController controller = VideoPlayerController
  //                   .network(_futureListVideo[index]['videoUrl'])
  //                 ..initialize().then((_) {});
  //               controller.setLooping(true);
  //               controller.setVolume(0.0);
  //               controller.seekTo(Duration(
  //                   seconds: controller.value.position.inSeconds + 10));
  //               return GestureDetector(
  //                 onTap: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (_) =>
  //                           VideoApp(model: _futureListVideo[index]),
  //                     ),
  //                   );
  //                 },
  //                 child: Stack(
  //                   alignment: Alignment.center,
  //                   children: <Widget>[
  //                     FittedBox(
  //                       fit: BoxFit.cover,
  //                       child: SizedBox(
  //                         width: 160,
  //                         height: 260,
  //                         child: ClipRRect(
  //                           borderRadius: BorderRadius.circular(9),
  //                           child: AspectRatio(
  //                             aspectRatio: controller.value.aspectRatio,
  //                             child: VideoPlayer(controller),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Positioned.fill(
  //                       bottom: 0,
  //                       left: 0,
  //                       child: Container(
  //                         padding: EdgeInsets.all(10),
  //                         decoration: BoxDecoration(
  //                             ),
  //                         alignment: Alignment.bottomLeft,
  //                         child: Text(
  //                           (_futureListVideo[index]['title'] ?? ''),
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 13.0,
  //                             fontFamily: 'Kanit',
  //                           ),
  //                           maxLines: 2,
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ),
  //                     ),
  //                     Positioned.fill(
  //                       top: 0,
  //                       left: 0,
  //                       child: Container(
  //                         padding: EdgeInsets.all(3),
  //                         decoration: BoxDecoration(
  //                             ),
  //                         alignment: Alignment.topLeft,
  //                         child: Row(
  //                           children: [
  //                             Icon(
  //                               Icons.play_arrow_outlined,
  //                               size: 25,
  //                               color: Colors.white,
  //                             ),
  //                             Text(
  //                               _futureListVideo[index]['viewTotal'].toString(),
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontSize: 13.0,
  //                                 fontFamily: 'Kanit',
  //                               ),
  //                               maxLines: 3,
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // _buildVideoShort() {
  //   return Container(
  //     color: Color(0xFFF7F7F7),
  //     padding: const EdgeInsets.only(top: 10, bottom: 10),
  //     child: Column(
  //       children: [
  //         GestureDetector(
  //           onTap: () {},
  //           child: _buildTitle(
  //               title: 'SSP Video', color: Color(0xFFF7F7F7), showAll: false),
  //         ),
  //         SizedBox(
  //           height: 180,
  //           child: ListView.separated(
  //             padding: EdgeInsets.symmetric(horizontal: 8),
  //             scrollDirection: Axis.horizontal,
  //             separatorBuilder: (context, index) => SizedBox(width: 8),
  //             shrinkWrap: false,
  //             itemCount:
  //                 _futureListVideo.length > 7 ? 7 : _futureListVideo.length,
  //             itemBuilder: (context, index) {
  //               return MyVideoWidget(
  //                 videoUrl: _futureListVideo[index]['videoUrl'],
  //                 title: _futureListVideo[index]['title'], // เพิ่ม title
  //                 model: _futureListVideo[index],
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  _buildForYou() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 215,
            child: FutureBuilder<dynamic>(
              future: _futureModelNew,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    separatorBuilder: (_, __) => SizedBox(width: 14),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        //newdetail
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 145,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              // color: Colors.red,
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.grey.withOpacity(0.3),
                              //     spreadRadius: 2,
                              //     blurRadius: 5,
                              //     offset: Offset(0, 3),
                              //   ),
                              // ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 145,
                                  width: 145,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16)),
                                  ),
                                  child: snapshot.data[index]['media']['data']
                                              .length >
                                          0
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: loadingImageNetwork(
                                            // snapshot.data[index]['imageUrl'],
                                            snapshot.data[index]['media']
                                                ['data'][0]['thumbnail'],
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            // color: Color(0XFF0B24FB),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Image.asset(
                                            'assets/images/no_image.png',
                                            fit: BoxFit.contain,
                                            // color: Colors.white,
                                          ),
                                        ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  snapshot.data[index]['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return _buildWaitingCard(scrollDirection: Axis.horizontal);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  _buildDealOfTheDay() {
    return Container(
      color: Color(0xFFF7F7F7),
      height: 215,
      child: FutureBuilder<dynamic>(
          future: _futureModelForYou,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.length,
                separatorBuilder: (_, __) => SizedBox(width: 14),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    _addLog(snapshot.data[index]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductFormCentralPage(
                          model: snapshot.data[index],
                        ),
                      ),
                    ).then((value) => _getCountItemInCart());
                  },
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 145,
                              width: 145,
                              // padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                color: Color(0xFFF7F7F7),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: snapshot.data[index]['media']['data']
                                            .length >
                                        0
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(9),
                                        child: loadingImageNetwork(
                                          // snapshot.data[index]['imageUrl'],
                                          snapshot.data[index]['media']['data']
                                              [0]['thumbnail'],
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          // color: Color(0XFF0B24FB),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Image.asset(
                                          'assets/images/no_image.png',
                                          fit: BoxFit.contain,
                                          // color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '1x' + snapshot.data[index]['name'] ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              // textScaleFactor: ScaleSize.textScaleFactor(context),
                            ),
                            // Text(
                            //   parseHtmlString(
                            //       snapshot.data[index]['description'] ?? ''),
                            //   maxLines: 2,
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                            // Expanded(child: SizedBox()),
                            snapshot.data[index]['product_variants']['data'][0]
                                    ['promotion_active']
                                ? Text(
                                    (moneyFormat(snapshot.data[index]
                                                ['product_variants']['data'][0]
                                                ['price']
                                            .toString()) +
                                        " บาท"),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFED168B),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    // textScaleFactor: ScaleSize.textScaleFactor(context),
                                  )
                                : Expanded(child: Container()),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                snapshot.data[index]['product_variants']['data']
                                            .length >
                                        0
                                    ? snapshot.data[index]['product_variants']
                                                    ['data'][0]
                                                ['discount_percent'] >
                                            0

                                        // i.product_variants.data[0]?.discount_percent > 0
                                        ? Text(
                                            (moneyFormat(snapshot.data[index]
                                                        ['product_variants']
                                                        ['data'][0]
                                                        ['promotion_price']
                                                    .toString()) +
                                                " บาท"),
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: Color(0xFFED168B),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            // textScaleFactor: ScaleSize.textScaleFactor(context),
                                          )
                                        : Text(
                                            (moneyFormat(snapshot.data[index]
                                                        ['product_variants']
                                                        ['data'][0]['price']
                                                    .toString()) +
                                                " บาท"),
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: Color(0xFFED168B),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            // textScaleFactor: ScaleSize.textScaleFactor(context),
                                          )
                                    : Text(
                                        'สินค้าหมด',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color(0xFFED168B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        // textScaleFactor: ScaleSize.textScaleFactor(context),
                                      ),
                                snapshot.data[index]['product_variants']['data']
                                            .length >
                                        0
                                    ? Text(
                                        (_callSumStock(snapshot.data[index]
                                                        ['product_variants']
                                                    ['data']) ==
                                                0
                                            ? 'สินค้าหมด'
                                            : _callSumStock(snapshot.data[index]
                                                            ['product_variants']
                                                        ['data'])
                                                    .toString() +
                                                " ชิ้น"),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _callSumStock(snapshot
                                                              .data[index]
                                                          ['product_variants']
                                                      ['data']) ==
                                                  0
                                              ? Color(0xFFED168B)
                                              : Colors.black,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        // textScaleFactor: ScaleSize.textScaleFactor(context),
                                      )
                                    : Text(
                                        'สินค้าหมด',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color(0xFFED168B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        // textScaleFactor: ScaleSize.textScaleFactor(context),
                                      ),
                              ],
                            )
                          ],
                        ),
                      ),
                      snapshot.data[index]['product_variants']['data'][0]
                              ['promotion_active']
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
                          : Container(
                              color: Color(0xFFF7F7F7),
                            ),
                    ],
                  ),
                ),
              );
            } else {
              return _buildWaitingCard(scrollDirection: Axis.horizontal);
            }
          }),
    );
  }

  late bool isBestSeller;
  String _filterSelected = 'ทั้งหมด';
  _buildTrending() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          // Filter Tabs
          Row(
            children: [
              _buildFilterTab('ทั้งหมด'),
              SizedBox(width: 20),
              _buildFilterTab('ขายดี'),
            ],
          ),
          SizedBox(height: 12),

          // Product Grid
          _buildProductGrid(),
        ],
      ),
    );
  }

// แยก Widget สำหรับ Filter Tab
  Widget _buildFilterTab(String label) {
    final isSelected = _filterSelected == label;
    return GestureDetector(
      onTap: () {
        setState(() => _filterSelected = label);
        if (label == 'ทั้งหมด') {
          onRefresh();
        }
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Color(0xFF0B24FB) : Colors.black,
        ),
      ),
    );
  }

// แยก Widget สำหรับ Product Grid
  Widget _buildProductGrid() {
    final products =
        _filterSelected == 'ทั้งหมด' ? _futureModelTrending : _futureProductHot;

    if (products.isEmpty) {
      return Center(
        child: Text(
          'ไม่พบสินค้า',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.zero, // ✅ เปลี่ยนจาก horizontal: 15
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.7, // ✅ ใช้ค่าคงที่แทนการคำนวณซับซ้อน
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          _buildProductCard(products[index], index),
    );
  }

// แยก Widget สำหรับ Product Card
  Widget _buildProductCard(dynamic product, int index) {
    final hasVariants = product['product_variants']['data'].isNotEmpty;
    final hasMedia = product['media']['data'].isNotEmpty;
    final isPromotion = hasVariants &&
        product['product_variants']['data'][0]['promotion_active'];

    return GestureDetector(
      onTap: () {
        _addLog(product);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductFormCentralPage(model: product),
          ),
        ).then((_) => _getCountItemInCart());
      },
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              _buildProductImage(hasMedia, product),
              SizedBox(height: 5),

              // Product Name
              Text(
                product['name'] ?? '',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Original Price (if promotion)
              if (isPromotion) _buildOriginalPrice(product),

              // Current Price & Stock
              _buildPriceAndStock(product, hasVariants),
            ],
          ),

          // Hot Sale Badge (only for "ทั้งหมด" tab)
          if (_filterSelected == 'ทั้งหมด' && index % 36 < 6)
            _buildHotSaleBadge(),

          // Promotion Badge
          if (isPromotion) _buildPromotionBadge(),
        ],
      ),
    );
  }

// แยก Widget สำหรับรูปภาพสินค้า
  Widget _buildProductImage(bool hasMedia, dynamic product) {
    return Container(
      width: double.infinity,
      height: 150, // ✅ กำหนดความสูงชัดเจน
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: hasMedia
            ? loadingImageNetwork(
                product['media']['data'][0]['thumbnail'],
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/images/no_image.png',
                fit: BoxFit.contain,
              ),
      ),
    );
  }

// แยก Widget สำหรับราคาเดิม (ขีดฆ่า)
  Widget _buildOriginalPrice(dynamic product) {
    return Text(
      "${moneyFormat(product['product_variants']['data'][0]['price'].toString())} บาท",
      style: TextStyle(
        fontSize: 12,
        color: Color(0xFFED168B),
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.lineThrough,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

// แยก Widget สำหรับราคาและสต็อก
  Widget _buildPriceAndStock(dynamic product, bool hasVariants) {
    if (!hasVariants) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildOutOfStockText(),
          _buildOutOfStockText(),
        ],
      );
    }

    final variant = product['product_variants']['data'][0];
    final isPromotion = variant['promotion_active'];
    final price = isPromotion ? variant['promotion_price'] : variant['price'];
    final stock = _callSumStock(product['product_variants']['data']);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price
        Flexible(
          // ✅ เพิ่ม Flexible เพื่อป้องกัน overflow
          child: Text(
            "${moneyFormat(price.toString())} บาท",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFED168B),
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8), // ✅ เพิ่มระยะห่าง
        // Stock
        Text(
          stock == 0 ? 'สินค้าหมด' : '$stock ชิ้น',
          style: TextStyle(
            fontSize: 14,
            color: stock == 0 ? Color(0xFFED168B) : Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildOutOfStockText() {
    return Text(
      'สินค้าหมด',
      style: TextStyle(
        fontSize: 16,
        color: Color(0xFFED168B),
        fontWeight: FontWeight.bold,
      ),
    );
  }

// Badge สำหรับสินค้าขายดี
  Widget _buildHotSaleBadge() {
    return Positioned(
      top: 5,
      left: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade900,
              Colors.redAccent.shade400,
              Colors.orangeAccent.shade200,
            ],
            stops: [0.2, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.red, Colors.orange, Colors.yellow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Icon(
                Icons.local_fire_department,
                size: 12,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 3),
            Text(
              'ขายดี',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 3,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Badge สำหรับโปรโมชั่น
  Widget _buildPromotionBadge() {
    return Positioned(
      top: 5,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(40)),
          gradient: LinearGradient(
            colors: [Color(0xFFFFD45A), Color(0xFFFFD45A)],
          ),
        ),
        child: Text(
          'โปรโมชั่น',
          style: TextStyle(
            fontSize: 11,
            color: Color(0XFFee4d2d),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  // _buildTrending() {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: 15,
  //     ),
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             GestureDetector(
  //               onTap: () => {
  //                 setState(() => _filterSelected = 'ทั้งหมด'),
  //                 onRefresh(),
  //               },
  //               child: Text(
  //                 'ทั้งหมด',
  //                 style: TextStyle(
  //                   fontSize: 13,
  //                   fontWeight: _filterSelected == 'ทั้งหมด'
  //                       ? FontWeight.bold
  //                       : FontWeight.normal,
  //                   color: _filterSelected == 'ทั้งหมด'
  //                       ? Color(0xFF0B24FB)
  //                       : Colors.black,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: 20),
  //             GestureDetector(
  //               onTap: () => {
  //                 setState(
  //                   () => _filterSelected = 'ขายดี',
  //                 ),
  //                 // _hotSale(),
  //               },
  //               child: Text(
  //                 'ขายดี',
  //                 style: TextStyle(
  //                   fontSize: 13,
  //                   fontWeight: _filterSelected == 'ขายดี'
  //                       ? FontWeight.bold
  //                       : FontWeight.normal,
  //                   color: _filterSelected == 'ขายดี'
  //                       ? Color(0xFF0B24FB)
  //                       : Colors.black,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 12),
  //         _filterSelected == 'ทั้งหมด'
  //             ? _futureModelTrending.isNotEmpty ?? false
  //                 ? GridView.builder(
  //                     shrinkWrap: true,
  //                     physics: ClampingScrollPhysics(),
  //                     padding: EdgeInsets.symmetric(horizontal: 15),
  //                     gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
  //                         maxCrossAxisExtent: 200,
  //                         childAspectRatio:
  //                             ((MediaQuery.of(context).size.height - (140)) /
  //                                     1.2) /
  //                                 (MediaQuery.of(context).size.height),
  //                         crossAxisSpacing: 15,
  //                         mainAxisSpacing: 15),
  //                     itemCount: _futureModelTrending.length,
  //                     itemBuilder: (context, index) => GestureDetector(
  //                       onTap: () {
  //                         _addLog(_futureModelTrending[index]);
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                             builder: (_) => ProductFormCentralPage(
  //                               model: _futureModelTrending[index],
  //                             ),
  //                           ),
  //                         ).then((value) => _getCountItemInCart());
  //                       },
  //                       child: Stack(
  //                         children: [
  //                           Center(
  //                             child: SizedBox(
  //                               // width: 165,
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Container(
  //                                     // height: 200,
  //                                     width: MediaQuery.of(context).size.width,
  //                                     // padding: EdgeInsets.all(5),
  //                                     decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(9),
  //                                       color: Colors.white,
  //                                     ),
  //                                     // alignment: Alignment.center,
  //                                     child: ClipRRect(
  //                                       borderRadius: BorderRadius.circular(9),
  //                                       child: _futureModelTrending[index]
  //                                                       ['media']['data']
  //                                                   .length >
  //                                               0
  //                                           ? ClipRRect(
  //                                               borderRadius:
  //                                                   BorderRadius.circular(9),
  //                                               child: loadingImageNetwork(
  //                                                 // snapshot.data[index]['imageUrl'],
  //                                                 _futureModelTrending[index]
  //                                                         ['media']['data'][0]
  //                                                     ['thumbnail'],
  //                                                 fit: BoxFit.cover,
  //                                               ),
  //                                             )
  //                                           : Container(
  //                                               decoration: BoxDecoration(
  //                                                 // color: Color(0XFF0B24FB),
  //                                                 borderRadius:
  //                                                     BorderRadius.circular(5),
  //                                               ),
  //                                               child: Image.asset(
  //                                                 'assets/images/no_image.png',
  //                                                 fit: BoxFit.contain,
  //                                                 // color: Colors.white,
  //                                               ),
  //                                             ),
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 5),
  //                                   Text(
  //                                     // _futureModelTrending[index]['media']['data'].toString(),
  //                                     _futureModelTrending[index]['name'] ?? '',
  //                                     style: TextStyle(
  //                                       fontSize: 15,
  //                                       fontWeight: FontWeight.bold,
  //                                     ),
  //                                     maxLines: 1,
  //                                     overflow: TextOverflow.ellipsis,
  //                                     // textScaleFactor: ScaleSize.textScaleFactor(context),
  //                                   ),
  //                                   // Text(
  //                                   //   parseHtmlString(
  //                                   //       snapshot.data[index]['description'] ?? ''),
  //                                   //   maxLines: 2,
  //                                   //   overflow: TextOverflow.ellipsis,
  //                                   // ),
  //                                   // // SizedBox(height: 2),
  //                                   // Expanded(
  //                                   //   child: SizedBox(),
  //                                   // ),
  //                                   _futureModelTrending[index]
  //                                               ['product_variants']['data'][0]
  //                                           ['promotion_active']
  //                                       ? Text(
  //                                           (moneyFormat(_futureModelTrending[
  //                                                               index]
  //                                                           ['product_variants']
  //                                                       ['data'][0]['price']
  //                                                   .toString()) +
  //                                               " บาท"),
  //                                           style: TextStyle(
  //                                             fontSize: 12,
  //                                             color: Color(0xFFED168B),
  //                                             fontWeight: FontWeight.bold,
  //                                             decoration:
  //                                                 TextDecoration.lineThrough,
  //                                           ),
  //                                           maxLines: 1,
  //                                           overflow: TextOverflow.ellipsis,
  //                                           // textScaleFactor: ScaleSize.textScaleFactor(context),
  //                                         )
  //                                       : Expanded(child: Container()),
  //                                   Row(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.spaceBetween,
  //                                     children: [
  //                                       _futureModelTrending[index]
  //                                                           ['product_variants']
  //                                                       ['data']
  //                                                   .length >
  //                                               0
  //                                           ? _futureModelTrending[index]
  //                                                           ['product_variants']
  //                                                       ['data'][0]
  //                                                   ['promotion_active']
  //                                               ? Text(
  //                                                   (moneyFormat(_futureModelTrending[
  //                                                                           index]
  //                                                                       [
  //                                                                       'product_variants']
  //                                                                   ['data'][0][
  //                                                               'promotion_price']
  //                                                           .toString()) +
  //                                                       " บาท"),
  //                                                   style: TextStyle(
  //                                                     fontSize: 16,
  //                                                     color: Color(0xFFED168B),
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                   ),
  //                                                   maxLines: 1,
  //                                                   overflow:
  //                                                       TextOverflow.ellipsis,
  //                                                   // textScaleFactor: ScaleSize.textScaleFactor(context),
  //                                                 )
  //                                               : Text(
  //                                                   (moneyFormat(_futureModelTrending[
  //                                                                       index][
  //                                                                   'product_variants']
  //                                                               [
  //                                                               'data'][0]['price']
  //                                                           .toString()) +
  //                                                       " บาท"),
  //                                                   style: TextStyle(
  //                                                     fontSize: 16,
  //                                                     color: Color(0xFFED168B),
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                   ),
  //                                                   maxLines: 1,
  //                                                   overflow:
  //                                                       TextOverflow.ellipsis,
  //                                                   // textScaleFactor: ScaleSize.textScaleFactor(context),
  //                                                 )
  //                                           : Text(
  //                                               'สินค้าหมด',
  //                                               style: TextStyle(
  //                                                 fontSize: 16,
  //                                                 color: Color(0xFFED168B),
  //                                                 fontWeight: FontWeight.bold,
  //                                               ),
  //                                               maxLines: 1,
  //                                               overflow: TextOverflow.ellipsis,
  //                                               // textScaleFactor: ScaleSize.textScaleFactor(context),
  //                                             ),
  //                                       _futureModelTrending[index]
  //                                                           ['product_variants']
  //                                                       ['data']
  //                                                   .length >
  //                                               0
  //                                           ? Text(
  //                                               (_callSumStock(_futureModelTrending[
  //                                                                   index][
  //                                                               'product_variants']
  //                                                           ['data']) ==
  //                                                       0
  //                                                   ? 'สินค้าหมด'
  //                                                   : _callSumStock(_futureModelTrending[
  //                                                                       index][
  //                                                                   'product_variants']
  //                                                               ['data'])
  //                                                           .toString() +
  //                                                       " ชิ้น"),
  //                                               style: TextStyle(
  //                                                 fontSize: 14,
  //                                                 color: _callSumStock(
  //                                                             _futureModelTrending[
  //                                                                         index]
  //                                                                     [
  //                                                                     'product_variants']
  //                                                                 ['data']) ==
  //                                                         0
  //                                                     ? Color(0xFFED168B)
  //                                                     : Colors.black,
  //                                                 // fontWeight: FontWeight.bold,
  //                                               ),
  //                                               maxLines: 1,
  //                                               overflow: TextOverflow.ellipsis,
  //                                               // textScaleFactor: ScaleSize.textScaleFactor(context),
  //                                             )
  //                                           : Text(
  //                                               'สินค้าหมด',
  //                                               style: TextStyle(
  //                                                 fontSize: 17,
  //                                                 color: Color(0xFFED168B),
  //                                                 fontWeight: FontWeight.bold,
  //                                               ),
  //                                               maxLines: 1,
  //                                               overflow: TextOverflow.ellipsis,
  //                                               // textScaleFactor: ScaleSize.textScaleFactor(context),
  //                                             )
  //                                     ],
  //                                   )
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                           if (index % 36 < 6)
  //                             Positioned(
  //                               top: 5,
  //                               left: 0,
  //                               child: Container(
  //                                 padding: EdgeInsets.symmetric(
  //                                     horizontal: 10, vertical: 3),
  //                                 alignment: Alignment.center,
  //                                 decoration: BoxDecoration(
  //                                   borderRadius: BorderRadius.horizontal(
  //                                     right: Radius.circular(30),
  //                                   ),
  //                                   gradient: LinearGradient(
  //                                     begin: Alignment.topLeft,
  //                                     end: Alignment.bottomRight,
  //                                     colors: [
  //                                       Colors.red.shade900, // เฉดสีแดงเข้ม
  //                                       Colors
  //                                           .redAccent.shade400, // เฉดสีแดงกลาง
  //                                       Colors.orangeAccent
  //                                           .shade200, // เพิ่มสีส้มทองเพื่อมิติ
  //                                     ],
  //                                     stops: [0.2, 0.7, 1.0], // ตำแหน่งการไล่สี
  //                                   ),
  //                                   boxShadow: [
  //                                     BoxShadow(
  //                                       color: Colors.black.withOpacity(0.2),
  //                                       blurRadius: 8,
  //                                       offset: Offset(2, 3),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 child: Row(
  //                                   mainAxisSize: MainAxisSize.min,
  //                                   children: [
  //                                     ShaderMask(
  //                                       shaderCallback: (bounds) =>
  //                                           LinearGradient(
  //                                         colors: [
  //                                           Colors.red,
  //                                           Colors.orange,
  //                                           Colors.yellow
  //                                         ],
  //                                         begin: Alignment.topLeft,
  //                                         end: Alignment.bottomRight,
  //                                       ).createShader(bounds),
  //                                       child: Icon(
  //                                         Icons.local_fire_department,
  //                                         size: 12,
  //                                         color: Colors
  //                                             .white, // Use white to let the gradient colors show
  //                                       ),
  //                                     ),
  //                                     SizedBox(width: 3),
  //                                     Text(
  //                                       'ขายดี',
  //                                       style: TextStyle(
  //                                         fontSize: 12,
  //                                         color: Colors.white,
  //                                         fontWeight: FontWeight.bold,
  //                                         shadows: [
  //                                           Shadow(
  //                                             color: Colors.black.withOpacity(
  //                                                 0.3), // เงาที่ข้อความ
  //                                             blurRadius: 3,
  //                                             offset: Offset(1, 1),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           _futureModelTrending[index]['product_variants']
  //                                   ['data'][0]['promotion_active']
  //                               ? Positioned(
  //                                   // left: 15,
  //                                   top: 5,
  //                                   right: 0,
  //                                   // top: MediaQuery.of(context).padding.top + 5,
  //                                   child: Container(
  //                                     // height: AdaptiveTextSize()
  //                                     //     .getadaptiveTextSize(context, 42),
  //                                     // width: AdaptiveTextSize()
  //                                     //     .getadaptiveTextSize(context, 20),
  //                                     padding:
  //                                         EdgeInsets.symmetric(horizontal: 10),
  //                                     alignment: Alignment.center,
  //                                     decoration: BoxDecoration(
  //                                         borderRadius: BorderRadius.horizontal(
  //                                           left: Radius.circular(40),
  //                                         ),
  //                                         gradient: LinearGradient(
  //                                           begin: Alignment.topLeft,
  //                                           end: Alignment.bottomRight,
  //                                           colors: [
  //                                             Color(0xFFFFD45A),
  //                                             Color(0xFFFFD45A),
  //                                           ],
  //                                         )),
  //                                     child: Text(
  //                                       'โปรโมชั่น',
  //                                       style: TextStyle(
  //                                         fontSize: 11,
  //                                         color: Color(0XFFee4d2d),
  //                                         fontWeight: FontWeight.bold,
  //                                       ),
  //                                       textScaleFactor:
  //                                           ScaleSize.textScaleFactor(context),
  //                                     ),
  //                                   ),
  //                                   // child: _futureModelTrending[index]['product_variants']
  //                                   //                 ['data'][0]['promotions']['data']
  //                                   //             .length >
  //                                   //         0
  //                                   //     ? Container(
  //                                   //         // height: AdaptiveTextSize()
  //                                   //         //     .getadaptiveTextSize(context, 42),
  //                                   //         // width: AdaptiveTextSize()
  //                                   //         //     .getadaptiveTextSize(context, 20),
  //                                   //         padding: EdgeInsets.symmetric(horizontal: 10),
  //                                   //         alignment: Alignment.center,
  //                                   //         decoration: BoxDecoration(
  //                                   //             borderRadius: BorderRadius.horizontal(
  //                                   //               left: Radius.circular(40),
  //                                   //             ),
  //                                   //             gradient: LinearGradient(
  //                                   //               begin: Alignment.topLeft,
  //                                   //               end: Alignment.bottomRight,
  //                                   //               colors: [
  //                                   //                 Color(0xFFFFD45A),
  //                                   //                 Color(0xFFFFD45A),
  //                                   //               ],
  //                                   //             )),
  //                                   //         child: Text(
  //                                   //           'โปรโมชั่น',
  //                                   //           style: TextStyle(
  //                                   //             fontSize: 11,
  //                                   //             color: Color(0XFFee4d2d),
  //                                   //             fontWeight: FontWeight.bold,
  //                                   //           ),
  //                                   //           textScaleFactor:
  //                                   //               ScaleSize.textScaleFactor(context),
  //                                   //         ),
  //                                   //       )
  //                                   //     : Container(),
  //                                 )
  //                               : Container(),
  //                         ],
  //                       ),
  //                     ),
  //                   )
  //                 : Container()
  //             // : Text('${_futureProductHot.length}')
  //             : _futureProductHot.isNotEmpty ?? false
  //                 ? GridView.builder(
  //                     shrinkWrap: true,
  //                     physics: ClampingScrollPhysics(),
  //                     padding: EdgeInsets.symmetric(horizontal: 15),
  //                     gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
  //                         maxCrossAxisExtent: 200,
  //                         childAspectRatio:
  //                             ((MediaQuery.of(context).size.height - (140)) /
  //                                     1.2) /
  //                                 (MediaQuery.of(context).size.height),
  //                         crossAxisSpacing: 15,
  //                         mainAxisSpacing: 15),
  //                     itemCount: _futureProductHot.length,
  //                     itemBuilder: (context, index) => GestureDetector(
  //                       onTap: () {
  //                         _addLog(_futureProductHot[index]);
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                             builder: (_) => ProductFormCentralPage(
  //                               model: _futureProductHot[index],
  //                             ),
  //                           ),
  //                         ).then((value) => _getCountItemInCart());
  //                       },
  //                       child: Stack(
  //                         children: [
  //                           Center(
  //                             child: SizedBox(
  //                               // width: 165,
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Container(
  //                                     // height: 200,
  //                                     width: MediaQuery.of(context).size.width,
  //                                     // padding: EdgeInsets.all(5),
  //                                     decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(9),
  //                                       color: Colors.white,
  //                                     ),
  //                                     // alignment: Alignment.center,
  //                                     child: ClipRRect(
  //                                       borderRadius: BorderRadius.circular(9),
  //                                       child: _futureProductHot[index]['media']
  //                                                       ['data']
  //                                                   .length >
  //                                               0
  //                                           ? ClipRRect(
  //                                               borderRadius:
  //                                                   BorderRadius.circular(9),
  //                                               child: loadingImageNetwork(
  //                                                 // snapshot.data[index]['imageUrl'],
  //                                                 _futureProductHot[index]
  //                                                         ['media']['data'][0]
  //                                                     ['thumbnail'],
  //                                                 fit: BoxFit.cover,
  //                                               ),
  //                                             )
  //                                           : Container(
  //                                               decoration: BoxDecoration(
  //                                                 // color: Color(0XFF0B24FB),
  //                                                 borderRadius:
  //                                                     BorderRadius.circular(5),
  //                                               ),
  //                                               child: Image.asset(
  //                                                 'assets/images/no_image.png',
  //                                                 fit: BoxFit.contain,
  //                                                 // color: Colors.white,
  //                                               ),
  //                                             ),
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 5),
  //                                   Text(
  //                                     _futureProductHot[index]['name'] ?? '',
  //                                     style: TextStyle(
  //                                       fontSize: 15,
  //                                       fontWeight: FontWeight.bold,
  //                                     ),
  //                                     maxLines: 1,
  //                                     overflow: TextOverflow.ellipsis,
  //                                   ),
  //                                   _futureProductHot[index]['product_variants']
  //                                           ['data'][0]['promotion_active']
  //                                       ? Text(
  //                                           (moneyFormat(_futureProductHot[
  //                                                               index]
  //                                                           ['product_variants']
  //                                                       ['data'][0]['price']
  //                                                   .toString()) +
  //                                               " บาท"),
  //                                           style: TextStyle(
  //                                             fontSize: 12,
  //                                             color: Color(0xFFED168B),
  //                                             fontWeight: FontWeight.bold,
  //                                             decoration:
  //                                                 TextDecoration.lineThrough,
  //                                           ),
  //                                           maxLines: 1,
  //                                           overflow: TextOverflow.ellipsis,
  //                                           // textScaleFactor: ScaleSize.textScaleFactor(context),
  //                                         )
  //                                       : Expanded(child: Container()),
  //                                   Row(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.spaceBetween,
  //                                     children: [
  //                                       _futureProductHot[index]
  //                                                           ['product_variants']
  //                                                       ['data']
  //                                                   .length >
  //                                               0
  //                                           ? _futureProductHot[index]
  //                                                           ['product_variants']
  //                                                       ['data'][0]
  //                                                   ['promotion_active']
  //                                               ? Text(
  //                                                   (moneyFormat(_futureProductHot[
  //                                                                           index]
  //                                                                       [
  //                                                                       'product_variants']
  //                                                                   ['data'][0][
  //                                                               'promotion_price']
  //                                                           .toString()) +
  //                                                       " บาท"),
  //                                                   style: TextStyle(
  //                                                     fontSize: 16,
  //                                                     color: Color(0xFFED168B),
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                   ),
  //                                                   maxLines: 1,
  //                                                   overflow:
  //                                                       TextOverflow.ellipsis,
  //                                                   // textScaleFactor: ScaleSize.textScaleFactor(context),
  //                                                 )
  //                                               : Text(
  //                                                   (moneyFormat(_futureProductHot[
  //                                                                       index][
  //                                                                   'product_variants']
  //                                                               [
  //                                                               'data'][0]['price']
  //                                                           .toString()) +
  //                                                       " บาท"),
  //                                                   style: TextStyle(
  //                                                     fontSize: 16,
  //                                                     color: Color(0xFFED168B),
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                   ),
  //                                                   maxLines: 1,
  //                                                   overflow:
  //                                                       TextOverflow.ellipsis,
  //                                                   // textScaleFactor: ScaleSize.textScaleFactor(context),
  //                                                 )
  //                                           : Text(
  //                                               'สินค้าหมด',
  //                                               style: TextStyle(
  //                                                 fontSize: 16,
  //                                                 color: Color(0xFFED168B),
  //                                                 fontWeight: FontWeight.bold,
  //                                               ),
  //                                               maxLines: 1,
  //                                               overflow: TextOverflow.ellipsis,
  //                                             ),
  //                                       _futureProductHot[index]
  //                                                           ['product_variants']
  //                                                       ['data']
  //                                                   .length >
  //                                               0
  //                                           ? Text(
  //                                               (_callSumStock(_futureProductHot[
  //                                                                   index][
  //                                                               'product_variants']
  //                                                           ['data']) ==
  //                                                       0
  //                                                   ? 'สินค้าหมด'
  //                                                   : _callSumStock(_futureProductHot[
  //                                                                       index][
  //                                                                   'product_variants']
  //                                                               ['data'])
  //                                                           .toString() +
  //                                                       " ชิ้น"),
  //                                               style: TextStyle(
  //                                                 fontSize: 14,
  //                                                 color: _callSumStock(
  //                                                             _futureProductHot[
  //                                                                         index]
  //                                                                     [
  //                                                                     'product_variants']
  //                                                                 ['data']) ==
  //                                                         0
  //                                                     ? Color(0xFFED168B)
  //                                                     : Colors.black,
  //                                                 // fontWeight: FontWeight.bold,
  //                                               ),
  //                                               maxLines: 1,
  //                                               overflow: TextOverflow.ellipsis,
  //                                               // textScaleFactor: ScaleSize.textScaleFactor(context),
  //                                             )
  //                                           : Text(
  //                                               'สินค้าหมด',
  //                                               style: TextStyle(
  //                                                 fontSize: 17,
  //                                                 color: Color(0xFFED168B),
  //                                                 fontWeight: FontWeight.bold,
  //                                               ),
  //                                               maxLines: 1,
  //                                               overflow: TextOverflow.ellipsis,
  //                                               // textScaleFactor: ScaleSize.textScaleFactor(context),
  //                                             )
  //                                     ],
  //                                   )
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                           Positioned(
  //                             top: 5,
  //                             left: 0,
  //                             child: Container(
  //                               padding: EdgeInsets.symmetric(
  //                                   horizontal: 10, vertical: 3),
  //                               alignment: Alignment.center,
  //                               decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.horizontal(
  //                                   right: Radius.circular(30),
  //                                 ),
  //                                 gradient: LinearGradient(
  //                                   begin: Alignment.topLeft,
  //                                   end: Alignment.bottomRight,
  //                                   colors: [
  //                                     Colors.red.shade900, // เฉดสีแดงเข้ม
  //                                     Colors.redAccent.shade400, // เฉดสีแดงกลาง
  //                                     Colors.orangeAccent
  //                                         .shade200, // เพิ่มสีส้มทองเพื่อมิติ
  //                                   ],
  //                                   stops: [0.2, 0.7, 1.0], // ตำแหน่งการไล่สี
  //                                 ),
  //                                 boxShadow: [
  //                                   BoxShadow(
  //                                     color: Colors.black.withOpacity(0.2),
  //                                     blurRadius: 8,
  //                                     offset: Offset(2, 3),
  //                                   ),
  //                                 ],
  //                               ),
  //                               child: Row(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: [
  //                                   ShaderMask(
  //                                     shaderCallback: (bounds) =>
  //                                         LinearGradient(
  //                                       colors: [
  //                                         Colors.red,
  //                                         Colors.orange,
  //                                         Colors.yellow
  //                                       ],
  //                                       begin: Alignment.topLeft,
  //                                       end: Alignment.bottomRight,
  //                                     ).createShader(bounds),
  //                                     child: Icon(
  //                                       Icons.local_fire_department,
  //                                       size: 12,
  //                                       color: Colors
  //                                           .white, // Use white to let the gradient colors show
  //                                     ),
  //                                   ),
  //                                   SizedBox(width: 3),
  //                                   Text(
  //                                     'ขายดี',
  //                                     style: TextStyle(
  //                                       fontSize: 12,
  //                                       color: Colors.white,
  //                                       fontWeight: FontWeight.bold,
  //                                       shadows: [
  //                                         Shadow(
  //                                           color: Colors.black.withOpacity(
  //                                               0.3), // เงาที่ข้อความ
  //                                           blurRadius: 3,
  //                                           offset: Offset(1, 1),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                   )
  //                 : Container()
  //       ],
  //     ),
  //   );
  // }

  _buildWaitingCard({Axis scrollDirection = Axis.vertical}) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 15),
      scrollDirection: scrollDirection,
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(width: 14),
      itemBuilder: (context, index) => Column(
        children: [
          LoadingTween(
            width: 145,
            height: 145,
          ),
          SizedBox(height: 5),
          // LoadingTween(
          //   width: 145,
          //   height: 40,
          // ),
          // SizedBox(height: 5),
          // LoadingTween(
          //   width: 145,
          //   height: 17,
          // ),
        ],
      ),
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
                    Navigator.pushReplacement(
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

  _buildnovel() {
    return Container(
      color: Color(0xFFF7F7F7),
      padding: const EdgeInsets.only(),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: _buildTitle(
              title: 'อ่านนิยาย',
              color: Color(0xFFF7F7F7),
              showAll: true,
              nextPage: ReadBookList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: SizedBox(
              height: 250, // ความสูงของคอนเทนเนอร์แนวนอน
              child: FutureBuilder(
                future: _futureknowledge,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length > 0) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal, // แสดงข้อมูลแนวนอน
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          final param = snapshot.data[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PdfViewerScreen(
                                      title: param['title'],
                                      pdfUrl: param['fileUrl'] ?? '',
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 110, // กำหนดความกว้างของแต่ละการ์ด
                                    height: 160, // ความสูงของภาพ
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
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  SizedBox(
                                    width: 120, // กำหนดความกว้างของข้อความ
                                    child: Text(
                                      param['title'] ?? '',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2, // จำกัดข้อความไว้ 2 บรรทัด
                                      overflow: TextOverflow
                                          .ellipsis, // ตัดข้อความที่เกิน
                                    ),
                                  ),
                                  if ((param['description'] ?? "") != '')
                                    SizedBox(
                                      width: 110, // กำหนดความกว้างของข้อความ
                                      child: Text(
                                        parseHtmlString(
                                            param['description'] ?? ''),
                                        maxLines: 2, // จำกัดข้อความไว้ 2 บรรทัด
                                        overflow: TextOverflow
                                            .ellipsis, // ตัดข้อความที่เกิน
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
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
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                            itemBuilder: (context, index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  LoadingTween(height: 165, width: 120),
                                  SizedBox(height: 5),
                                  LoadingTween(height: 40, width: 120),
                                  SizedBox(height: 5),
                                  LoadingTween(height: 17, width: 80),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            child: Center(
                              child: Text('รอสักครู่'),
                            ),
                          );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<dynamic> param) {
    return GridView.builder(
      // scrollDirection: Axis.horizontal,
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
            height: 120,
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
      // scrollDirection: Axis.horizontal,
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
