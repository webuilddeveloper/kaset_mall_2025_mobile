import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_mart_v3/cart.dart';
import 'package:mobile_mart_v3/component/carousel_banner.dart';
import 'package:mobile_mart_v3/component/loading_image_network.dart';
import 'package:mobile_mart_v3/component/material/loading_tween.dart';
import 'package:mobile_mart_v3/component/toast_fail.dart';
import 'package:mobile_mart_v3/event_calendar_main.dart';
import 'package:mobile_mart_v3/news_all.dart';
import 'package:mobile_mart_v3/privilege_all.dart';
import 'package:mobile_mart_v3/product_all.dart';
import 'package:mobile_mart_v3/product_from.dart';
import 'package:mobile_mart_v3/purchase_menu.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/shared/extension.dart';
import 'package:mobile_mart_v3/shared/notification_service.dart';
import 'package:mobile_mart_v3/verify_phone.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../read_book.dart';
import '../read_book_list.dart';
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
  Future<dynamic>? _futureModelEvent;
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
    String? value = await storage.read(key: 'cartItems');

    if (value != null) {
      // แปลง JSON เป็น List
      List<dynamic> items = jsonDecode(value);

      setState(() {
        amountItemInCart = items.length;
        print('------->>_getCountItemInCart  ');
        print(amountItemInCart);
      });

      // ถ้าต้องการทำ logic กับ notification
      // if (amountItemInCart > 0) {
      //   NotificationService.subscribeToAllTopic('suksapan-item');
      // } else {
      //   NotificationService.subscribeToAllTopic('suksapan-mall');
      // }
    } else {
      setState(() {
        amountItemInCart = 0;
      });
    }
  }

  _getCategory() async {
    // List<dynamic> model = await getData(server + 'categories');
    // model.sort((a, b) => a['description'].compareTo(b['description']));
    print('-------mockCategories---------');
    print(mockCategories);
    print('----------------');

    setState(() {
      _futureCategory = Future.value(mockCategories);
      // _futureCategory = mockCategories as Future?;
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
    _futureModelNew = postDio(server_we_build + 'm/news/read', {'limit': 999});

    _futureModelEvent =
        postDio('$server_we_build/m/eventCalendar/read', {'limit': 999});

    _futureModelForYou =
        postDio('$server_we_build/m/privilege/read', {'limit': 999});

    profileCode = (await storage.read(key: 'profileCode10')) ?? '';
    // _futureBanner = postDio('${mainBannerApi}read', {'limit': 999})
    _futureBanner = postDio(
        'https://gateway.we-builds.com/kaset-mall-api/m/Banner/main/read',
        {'limit': 999});
    _futureModelNew = postDio(server_we_build + 'm/news/read', {'limit': 999});

    _futureModelEvent =
        postDio('$server_we_build/m/eventCalendar/read', {'limit': 999});

    _futureModelForYou =
        postDio('$server_we_build/m/privilege/read', {'limit': 999});

    profileCode = (await storage.read(key: 'profileCode10')) ?? '';

    List<String> keySearchRandom;
    var element1 = "";
    var element2 = "";
    var element3 = "";

    // var value = await postProductData(
    //   server_we_build + 'm/Product/readProduct',
    //   {
    //     "search": "$element3",
    //     "per_page": _limit.toString(),
    //   },
    // );

    // setState(() {
    //   _futureModelTrending = value;
    //   total_page = value[0]['total_pages'];
    // });

    // var value2 = await postProductHot(
    //   server_we_build + 'm/Product/readProductHot',
    //   {"per_page": "${page.toString()}"},
    //   _limit,
    // );

    // setState(() {
    //   _futureProductHot = value2;
    // });

    // value = await postProductHotSale(
    //   server_we_build + 'm/Product/readProduct',
    //   {
    //     "search": "$element3",
    //     "per_page": _limit.toString(),
    //   },
    // );

    // setState(() {
    //   if (value != null && value.isNotEmpty) {
    //     total_page = value[0]['total_pages'];
    //   } else {
    //     total_page = 0;
    //   }
    // });

    // postProductHotSale(server_we_build + 'm/Product/readProductHot', {});

    // _futureModelForYou = postProductData(
    //     server_we_build + 'm/Product/readProduct', {"search": "$element1"});

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

  // _addLog(param) async {
  //   await postObjectData(server_we_build + 'log/logGoods/create', {
  //     "username": emailProfile ?? "",
  //     "profileCode": profileCode,
  //     "platform": Platform.isAndroid
  //         ? "android"
  //         : Platform.isIOS
  //             ? "ios"
  //             : "other",
  //     "prodjctId": param['id'] ?? "",
  //     "title": param['name'] ?? "",
  //     "categoryId": param['category']['data']['id'] ?? "",
  //     "category": param['category']['data']['name'] ?? "",
  //   });
  // }

  _callReadAll() async {
    _callReadBanner();
    _callReadKnowledge();
  }

  _callReadBanner() {
    _futureBanner = postDio(
        'https://gateway.we-builds.com/kaset-mall-api/m/Banner/main/read',
        {'limit': 10});
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
          color: Colors.white,
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

                    // if (savedCardId != null && savedCardId.isNotEmpty) {
                    // User has logged in before, navigate directly to PurchaseMenuPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchaseMenuPage(
                          cardid: savedCardId,
                        ),
                      ),
                    );
                    // }
                    // else {
                    // First time login, go to verification screen
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => IDVerificationScreen(),
                    //   ),
                    // );
                    // }
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
                    // if (profileCode == '') {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (BuildContext context) => LoginCentralPage(),
                    //     ),
                    //   );
                    // } else if (verifyPhonePage == 'false') {
                    //   _showVerifyCheckDialog();
                    // } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartCentralPage(),
                      ),
                    ).then((value) => _getCountItemInCart());
                    // }
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
              enablePullUp: false,
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
                  SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {},
                    child: _buildTitle(
                      title: 'หมวดหมู่',
                      showAll: false,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildCategory(),

                  GestureDetector(
                    onTap: () {},
                    child: _buildTitle(
                      code: 'news',
                      title: 'ข่าวสารประชาสัมพันธ์',
                      showAll: true,
                    ),
                  ),
                  _buildNew(),

                  GestureDetector(
                    onTap: () {},
                    child: _buildTitle(
                      code: 'event',
                      title: 'ปฏิทินกิจกรรมที่น่าสนใจ',
                      showAll: true,
                    ),
                  ),
                  _buildEvent(),

                  GestureDetector(
                    onTap: () {},
                    child: _buildTitle(
                      code: 'privilege',
                      title: 'สิทธิประโยชน์',
                      showAll: true,
                    ),
                  ),
                  _buildForYou(),

                  _buildTitle(title: 'สินค้า', showAll: true),
                  SizedBox(height: 5),
                  _buildTrending(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

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
                        builder: (_) => EventCalendarMain(title: title),
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
                  } else if (code == 'privilege') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PrivilegeAllPage(title: title, mode: showAll),
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
        if (!snapshot.hasData) {
          return const Center(
            child: Text(
              'ไม่มีหมวดหมู่',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          );
        }

        final categories = snapshot.data;

        return Container(
            height: 100,
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: List.generate(categories.length, (i) {
                final item = categories[i];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF09665a),
                      child: item['img'] == null
                          ? Image.asset("assets/images/kaset/no-img.png")
                          : Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                item['img'],
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 75,
                      child: Text(
                        item['name'],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }),
            ));
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
                    itemCount:
                        snapshot.data.length > 10 ? 10 : snapshot.data.length,
                    separatorBuilder: (_, __) => SizedBox(width: 14),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {},
                      child: Stack(
                        children: [
                          Container(
                            width: 145,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
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
                                  child: snapshot
                                              .data[index]['imageUrl'].length >
                                          0
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: loadingImageNetwork(
                                            snapshot.data[index]['imageUrl'],
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Image.asset(
                                            'assets/images/kaset/no-img.png',
                                            fit: BoxFit.contain,
                                            // color: Colors.white,
                                          ),
                                        ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  snapshot.data[index]['title'] ?? '',
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

  _buildEvent() {
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
              future: _futureModelEvent,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        snapshot.data.length > 10 ? 10 : snapshot.data.length,
                    separatorBuilder: (_, __) => SizedBox(width: 14),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {},
                      child: Stack(
                        children: [
                          Container(
                            width: 145,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
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
                                  child: snapshot
                                              .data[index]['imageUrl'].length >
                                          0
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: loadingImageNetwork(
                                            snapshot.data[index]['imageUrl'],
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
                                            'assets/images/kaset/no-img.png',
                                            fit: BoxFit.contain,
                                            // color: Colors.white,
                                          ),
                                        ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  snapshot.data[index]['title'] ?? '',
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
              future: _futureModelForYou,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        snapshot.data.length > 10 ? 10 : snapshot.data.length,
                    separatorBuilder: (_, __) => SizedBox(width: 14),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        // Foryou
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 145,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
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
                                  child: snapshot
                                              .data[index]['imageUrl'].length >
                                          0
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: loadingImageNetwork(
                                            snapshot.data[index]['imageUrl'],
                                            // snapshot.data[index]['media']
                                            //     ['data'][0]['thumbnail'],
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
                                            'assets/images/kaset/no-img.png',
                                            fit: BoxFit.contain,
                                            // color: Colors.white,
                                          ),
                                        ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  snapshot.data[index]['title'] ?? '',
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

  late bool isBestSeller;
  String _filterSelected = '0';

  _buildTrending() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildFilterTab('0'),
                SizedBox(width: 12),
                _buildFilterTab('1'),
                SizedBox(width: 12),
                _buildFilterTab('2'),
                SizedBox(width: 12),
                _buildFilterTab('3'),
                SizedBox(width: 12),
                _buildFilterTab('4'),
              ],
            ),
          ),
          SizedBox(height: 12),
          _buildProductGrid(),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String type) {
    final isSelected = _filterSelected == type;
    return GestureDetector(
        onTap: () {
          setState(() {
            _filterSelected = type;
            if (type == '0') {
              onRefresh();
            } else if (type == '1') {
              onRefresh(); // พรรณพืช
            } else if (type == '2') {
              onRefresh(); // เคมีภัณฑ์
            } else if (type == '2') {
              onRefresh(); // เคมีภัณฑ์
            } else if (type == '3') {
              onRefresh(); // อาหารสัตว์
            } else if (type == '4') {
              onRefresh(); // เครื่องมือ
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF09665a) : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            type == '0'
                ? 'ทั้งหมด'
                : type == '1'
                    ? 'พรรณพืช'
                    : type == '2'
                        ? 'เครื่องมือ'
                        : type == '3'
                            ? 'อาหารสัตว์'
                            : 'เคมีภัณฑ์',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ));
  }

  Widget _buildProductGrid() {
    final products = _filterSelected == '0'
        ? mockProductList
        : mockProductList
            .where((item) => item['type'] == _filterSelected)
            .toList();
    ;

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
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.7,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: products.length > 10 ? 10 : products.length,
      itemBuilder: (context, index) =>
          _buildProductCard(products[index], index),
    );
  }

  Widget _buildProductCard(dynamic product, int index) {
    final hasMedia = product['image'].isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductFormCentralPage(model: product),
          ),
        ).then((_) => _getCountItemInCart());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(hasMedia, product),
          SizedBox(height: 5),
          Text(
            product['name'] ?? '',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            product['description'] ?? '',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

// แยก Widget สำหรับรูปภาพสินค้า
  Widget _buildProductImage(bool hasMedia, dynamic product) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: hasMedia
            ? loadingImageNetwork(
                product['image'],
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/images/kaset/no-img.png',
                fit: BoxFit.contain,
              ),
      ),
    );
  }

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
                                              'assets/images/kaset/no-img.png',
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
                      'assets/images/kaset/no-img.png',
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
                            'assets/images/kaset/no-img.png',
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

  final List<Map<String, dynamic>> mockCategories = [
    {'id': '1', 'name': 'พรรณพืช', 'img': "assets/images/kaset/pngegg.png"},
    {'id': '2', 'name': 'เครื่องมือ', 'img': "assets/images/kaset/tractor.png"},
    {
      'id': '3',
      'name': 'อาหารสัตว์',
      'img': "assets/images/kaset/pet-bowl.png"
    },
    {
      'id': '4',
      'name': 'เคมีภัณฑ์',
      'img': "assets/images/kaset/fertilizer.png"
    },
  ];
  final List<Map<String, dynamic>> mockProductList = [
    {
      'id': 1,
      'name': 'เมล็ดพันธุ์ข้าวหอมมะลิ 105',
      'type': '1', // พรรณพืช
      'price': 120.0,
      'description':
          'เมล็ดพันธุ์ข้าวหอมมะลิคุณภาพดี ให้ผลผลิตสูง เหมาะกับการปลูกในทุกภาคของประเทศไทย',
      'image':
          'https://www.doae.go.th/wp-content/uploads/2021/03/rice-seed.jpg',
      'stock': 10,
    },
    {
      'id': 2,
      'name': 'เครื่องพ่นยาแบตเตอรี่ 20 ลิตร',
      'type': '2', // เครื่องมือ
      'price': 890.0,
      'description':
          'เครื่องพ่นยาคุณภาพสูง ทำงานด้วยระบบไฟฟ้าแบตเตอรี่ ใช้งานต่อเนื่องได้ยาวนาน เหมาะกับการฉีดพ่นปุ๋ยหรือยาฆ่าแมลง',
      'image':
          'https://www.sprayerthai.com/wp-content/uploads/2021/07/sprayer-20L.jpg',
      'stock': 10,
    },
    {
      'id': 3,
      'name': 'อาหารไก่เนื้อเบอร์ 910',
      'type': '3', // อาหารสัตว์
      'price': 250.0,
      'description':
          'อาหารชนิดเม็ด สำหรับไก่เล็กถึงอายุ 3 สัปดาห์ มีโปรตีนคุณภาพสูง เหมาะสำหรับฟาร์มไก่เนื้อ',
      'image':
          'https://www.cpffeed.com/wp-content/uploads/2019/12/910-181x300.png',
      'stock': 10,
    },
    {
      'id': 4,
      'name': 'ปุ๋ยเคมีสูตร 15-15-15',
      'type': '4', // เคมีภัณฑ์
      'price': 450.0,
      'description':
          'ปุ๋ยเคมีสูตรมาตรฐาน เหมาะสำหรับพืชสวนและพืชไร่ ให้ธาตุอาหารครบถ้วนสำหรับการเจริญเติบโต',
      'image':
          'https://www.chiataigroup.com/imgadmins/product_photo/pro20220214154701.png',
      'stock': 10,
    },
    {
      'id': 5,
      'name': 'ยาฆ่าแมลงตราช้างแดง',
      'type': '4', // เคมีภัณฑ์
      'price': 195.0,
      'description':
          'ยาฆ่าแมลงประสิทธิภาพสูง ปลอดภัยเมื่อใช้ตามคำแนะนำ เหมาะสำหรับพืชสวน พืชไร่ และไม้ดอก',
      'image':
          'https://cache-igetweb-v2.mt108.info/uploads/images-cache/7290/product/b654e0d438dd11dea08713efa34e6386_full.jpg',
      'stock': 0,
    },
  ];
}
