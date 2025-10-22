// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/cart.dart';
import 'package:kasetmall/component/carousel_banner.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/component/material/loading_tween.dart';
import 'package:kasetmall/component/toast_fail.dart';
import 'package:kasetmall/event_calendar_form.dart';
import 'package:kasetmall/event_calendar_main.dart';
import 'package:kasetmall/kasetpay/loan/agricultureLoan.dart'
    show AgricultureLoanPage;
import 'package:kasetmall/kasetpay/pay/kaset_pay.dart';
import 'package:kasetmall/news_all.dart';
import 'package:kasetmall/news_form.dart';
import 'package:kasetmall/privilege_all.dart';
import 'package:kasetmall/privilege_form.dart';
import 'package:kasetmall/product_all.dart';
import 'package:kasetmall/product_from.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/shared/notification_service.dart';

import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
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

  Future<dynamic>? _futureModelForYou;

  int amountItemInCart = 0;
  String profileCode = "";
  // String verifyPhonePage = '';
  DateTime? currentBackPressTime;

  String? emailProfile;
  int total_page = 0;
  int page = 1;
  bool loadProduct = true;

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _refreshController = RefreshController();
    _getCategory();
    _callRead();
    // _getUserData();
    _getCountItemInCart();
    // _callReadVideoShort();
    _callReadAll();
    _onLoading();

    super.initState();
  }

  Future<bool> sendPushMessage({
    String? recipientToken,
    String? title,
    String? body,
  }) async {
    return true;
  }

  // _getUserData() async {
  //   var _token = await storage.read(key: 'tokenD');
  //   var _category = await storage.read(key: 'profileCategory');
  //   final result = await getUser(server + 'users/me');

  //   if (result != null) if (result['id'] != '') {
  //     storage.write(key: 'email', value: result['email']);

  //     postDio(
  //       '${server_we_build}log/logToken/create',
  //       {
  //         'userId': result['id'],
  //         'email': result['email'],
  //         'category': _category,
  //         'token': _token,
  //       },
  //     );
  //     setState(() {
  //       verifyPhonePage = result['phone_verified'].toString();
  //       emailProfile = result['email'].toString();
  //       _userId = result['id'];
  //       _username = result['name'];
  //     });
  //   }
  // }

  _getCountItemInCart() async {
    String? value = await storage.read(key: 'cartItems');

    if (value != null) {
      List<dynamic> items = jsonDecode(value);

      setState(() {
        amountItemInCart = items.length;
      });
    } else {
      setState(() {
        amountItemInCart = 0;
      });
    }
  }

  _getCategory() async {
    setState(() {
      _futureCategory = Future.value(mockCategories);
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

    if (profileCode == '') {
      NotificationService.subscribeToAllTopic('suksapan-general');
    } else {
      _readCoupons();
    }
  }

  // _callReadVideoShort() async {
  //   var value = await postDio('${server_we_build}videoShort/read', {});
  //   setState(() {
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

  _callReadKnowledge() {}

  _readCoupons() async {
    var ConponsMe = await get(server + 'users/me/coupons');
    if (ConponsMe.any((s) => s['code'] == "welcome" && s['status'] == 0)) {
      if (amountItemInCart > 0)
        NotificationService.subscribeToAllTopic('suksapan-register-item');
      else
        NotificationService.subscribeToAllTopic('suksapan-register');
    }
  }

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
            child: Stack(
              children: [
                Lottie.asset('assets/lotties/bee.json'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        // Check if user has previously logged in
                        // final prefs = await SharedPreferences.getInstance();
                        // final String? savedCardId =
                        //     prefs.getString('saved_card_id');

                        // if (savedCardId != null && savedCardId.isNotEmpty) {
                        // User has logged in before, navigate directly to PurchaseMenuPage
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => PurchaseMenuPage(
                        //       cardid: savedCardId,
                        //     ),
                        //   ),
                        // );
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
                            'คุณสมศักดิ์ เกษตร',
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
                            height: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 35),
                            width: AdaptiveTextSize()
                                .getadaptiveTextSize(context, 35),
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
                                  fontSize: amountItemInCart
                                              .toString()
                                              .length <=
                                          1
                                      ? 10
                                      : amountItemInCart.toString().length == 2
                                          ? 9
                                          : 8,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                textScaleFactor:
                                    ScaleSize.textScaleFactor(context),
                              ),
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
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              print('.........Kaset Pay clicked');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => KasetPayPage(),
                                  ));
                            },
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    child: Image.asset(
                                      'assets/logo/pay.png',
                                      color: Theme.of(context).primaryColor,
                                      width: 35,
                                      height: 35,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Kaset Pay',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '฿15,000',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Theme.of(context).primaryColor,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              print('.........loans clicked');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AgricultureLoanPage(),
                                  ));
                            },
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'สินเชื่อเพื่อการเกษตร ',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'อนุมัติทันที',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Theme.of(context).primaryColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CarouselBanner(
                        model: _futureBanner,
                        url: 'main/',
                        height: MediaQuery.of(context).size.height * 0.25,
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
                  _buildTitle(
                    code: 'product',
                    title: 'สินค้า',
                    showAll: true,
                  ),
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
                        builder: (_) => PrivilegeAllPage(
                          title: title,
                          mode: showAll,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductAllCentralPage(
                          title: title,
                          mode: showAll,
                          typeelect: '0',
                        ),
                      ),
                    ).then((value) => _getCountItemInCart());
                  }
                }
              },
              child: showAll
                  ? Row(
                      children: [
                        Text(
                          'ดูทั้งหมด   ',
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

        final categories = snapshot.data as List<dynamic>;

        return Container(
          height: 100,
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: List.generate(categories.length, (i) {
              final item = categories[i];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductAllCentralPage(
                        title: 'สินค้า',
                        mode: true,
                        typeelect: item['id'], // ส่งค่า id ของหมวดหมู่ที่เลือก
                      ),
                    ),
                  );
                },
                child: Column(
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
                ),
              );
            }),
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
                    itemCount:
                        snapshot.data.length > 10 ? 10 : snapshot.data.length,
                    separatorBuilder: (_, __) => SizedBox(width: 14),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                NewsForm(model: snapshot.data[index]),
                          ),
                        );
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventCalendarFormPage(
                              model: snapshot.data[index],
                            ),
                          ),
                        );
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
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            // color: Color(0xFF09665a),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PrivilegeForm(model: snapshot.data[index]),
                          ),
                        );
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
                                            // color: Color(0xFF09665a),
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
        ],
      ),
    );
  }

  // _showVerifyCheckDialog() {
  //   return showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return WillPopScope(
  //           onWillPop: () {
  //             return Future.value(false);
  //           },
  //           child: CupertinoAlertDialog(
  //             title: new Text(
  //               'บัญชีนี้ยังไม่ได้ยืนยันเบอร์โทรศัพท์\nกด ตกลง เพื่อยืนยัน',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontFamily: 'Kanit',
  //                 color: Colors.black,
  //                 fontWeight: FontWeight.normal,
  //               ),
  //             ),
  //             content: Text(" "),
  //             actions: [
  //               CupertinoDialogAction(
  //                 isDefaultAction: true,
  //                 child: new Text(
  //                   "ตกลง",
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontFamily: 'Kanit',
  //                     color: Color(0xFF09665a),
  //                     fontWeight: FontWeight.normal,
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.pushReplacement(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => VerifyPhonePage(),
  //                     ),
  //                   );
  //                 },
  //               ),
  //               CupertinoDialogAction(
  //                 isDefaultAction: false,
  //                 child: new Text(
  //                   "ไม่ใช่ตอนนี้",
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontFamily: 'Kanit',
  //                     color: Color(0xFF09665a),
  //                     fontWeight: FontWeight.normal,
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.pop(
  //                     context,
  //                   );
  //                 },
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }

  // _buildnovel() {
  //   return Container(
  //     color: Color(0xFFF7F7F7),
  //     padding: const EdgeInsets.only(),
  //     child: Column(
  //       children: [
  //         GestureDetector(
  //           onTap: () {},
  //           child: _buildTitle(
  //             title: 'อ่านนิยาย',
  //             color: Color(0xFFF7F7F7),
  //             showAll: true,
  //             nextPage: ReadBookList(),
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 6.0),
  //           child: SizedBox(
  //             height: 250, // ความสูงของคอนเทนเนอร์แนวนอน
  //             child: FutureBuilder(
  //               future: _futureknowledge,
  //               builder: (context, snapshot) {
  //                 if (snapshot.hasData) {
  //                   if (snapshot.data.length > 0) {
  //                     return ListView.builder(
  //                       scrollDirection: Axis.horizontal, // แสดงข้อมูลแนวนอน
  //                       itemCount: snapshot.data.length,
  //                       itemBuilder: (context, index) {
  //                         final param = snapshot.data[index];
  //                         return Padding(
  //                           padding:
  //                               const EdgeInsets.symmetric(horizontal: 2.0),
  //                           child: GestureDetector(
  //                             onTap: () {
  //                               Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                   builder: (context) => PdfViewerScreen(
  //                                     title: param['title'],
  //                                     pdfUrl: param['fileUrl'] ?? '',
  //                                   ),
  //                                 ),
  //                               );
  //                             },
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Container(
  //                                   width: 110, // กำหนดความกว้างของแต่ละการ์ด
  //                                   height: 160, // ความสูงของภาพ
  //                                   child: ClipRRect(
  //                                     borderRadius: BorderRadius.circular(9),
  //                                     child: (param['imageUrl'] ?? "") != ""
  //                                         ? loadingImageNetwork(
  //                                             param['imageUrl'],
  //                                             fit: BoxFit.cover,
  //                                           )
  //                                         : Image.asset(
  //                                             'assets/images/kaset/no-img.png',
  //                                             fit: BoxFit.cover,
  //                                           ),
  //                                   ),
  //                                 ),
  //                                 SizedBox(height: 5),
  //                                 SizedBox(
  //                                   width: 120, // กำหนดความกว้างของข้อความ
  //                                   child: Text(
  //                                     param['title'] ?? '',
  //                                     style: TextStyle(
  //                                         fontSize: 15,
  //                                         fontWeight: FontWeight.bold),
  //                                     maxLines: 2, // จำกัดข้อความไว้ 2 บรรทัด
  //                                     overflow: TextOverflow
  //                                         .ellipsis, // ตัดข้อความที่เกิน
  //                                   ),
  //                                 ),
  //                                 if ((param['description'] ?? "") != '')
  //                                   SizedBox(
  //                                     width: 110, // กำหนดความกว้างของข้อความ
  //                                     child: Text(
  //                                       parseHtmlString(
  //                                           param['description'] ?? ''),
  //                                       maxLines: 2, // จำกัดข้อความไว้ 2 บรรทัด
  //                                       overflow: TextOverflow
  //                                           .ellipsis, // ตัดข้อความที่เกิน
  //                                       style: TextStyle(fontSize: 13),
  //                                     ),
  //                                   ),
  //                               ],
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     );
  //                   } else {
  //                     return Center(
  //                       child: Text(
  //                         'ไม่พบข้อมูล',
  //                         style: TextStyle(
  //                           fontFamily: 'Kanit',
  //                           fontSize: 15,
  //                         ),
  //                       ),
  //                     );
  //                   }
  //                 } else {
  //                   return loadProduct == true
  //                       ? ListView.builder(
  //                           scrollDirection: Axis.horizontal,
  //                           itemCount: 6,
  //                           itemBuilder: (context, index) => Padding(
  //                             padding:
  //                                 const EdgeInsets.symmetric(horizontal: 8.0),
  //                             child: Column(
  //                               children: [
  //                                 SizedBox(height: 10),
  //                                 LoadingTween(height: 165, width: 120),
  //                                 SizedBox(height: 5),
  //                                 LoadingTween(height: 40, width: 120),
  //                                 SizedBox(height: 5),
  //                                 LoadingTween(height: 17, width: 80),
  //                               ],
  //                             ),
  //                           ),
  //                         )
  //                       : Container(
  //                           child: Center(
  //                             child: Text('รอสักครู่'),
  //                           ),
  //                         );
  //                 }
  //               },
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
    // พรรณพืช
    {
      'id': 1,
      'name': 'เมล็ดพันธุ์ข้าวหอมมะลิ 105',
      'type': '1',
      'price': 120.0,
      'description':
          'เมล็ดพันธุ์ข้าวหอมมะลิคุณภาพดี ให้ผลผลิตสูง เหมาะกับการปลูกในทุกภาคของประเทศไทย',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_251458731.png',
      'stock': 10,
    },
    {
      'id': 6,
      'name': 'เมล็ดพันธุ์ผักบุ้งจีน',
      'type': '1',
      'price': 35.0,
      'description':
          'เมล็ดพันธุ์ผักบุ้งจีน ปลูกง่าย โตเร็ว เหมาะสำหรับปลูกในฤดูฝน',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_251522694.png',
      'stock': 50,
    },
    {
      'id': 7,
      'name': 'เมล็ดพันธุ์ถั่วฝักยาว',
      'type': '1',
      'price': 40.0,
      'description': 'เมล็ดถั่วฝักยาวพันธุ์ดี ให้ผลผลิตสูง ทนโรคและแมลง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_251548725.png',
      'stock': 30,
    },
    {
      'id': 8,
      'name': 'เมล็ดพันธุ์มะเขือเทศ',
      'type': '1',
      'price': 50.0,
      'description': 'มะเขือเทศพันธุ์คุณภาพ ให้ผลผลิตลูกใหญ่ สีแดงสด',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_251619462.png',
      'stock': 25,
    },
    {
      'id': 9,
      'name': 'เมล็ดพันธุ์ข้าวโพดหวาน',
      'type': '1',
      'price': 60.0,
      'description': 'ข้าวโพดหวานพันธุ์ดี รสหวาน ปลูกง่าย ผลผลิตสูง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_251637998.png',
      'stock': 40,
    },

    // เครื่องมือ
    {
      'id': 2,
      'name': 'เครื่องพ่นยาแบตเตอรี่ 20 ลิตร',
      'type': '2',
      'price': 890.0,
      'description':
          'เครื่องพ่นยาคุณภาพสูง ทำงานด้วยระบบไฟฟ้าแบตเตอรี่ ใช้งานต่อเนื่องได้ยาวนาน เหมาะกับการฉีดพ่นปุ๋ยหรือยาฆ่าแมลง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254704897.png',
      'stock': 10,
    },
    {
      'id': 10,
      'name': 'กรรไกรตัดแต่งกิ่ง',
      'type': '2',
      'price': 150.0,
      'description': 'กรรไกรคุณภาพสูง ตัดแต่งกิ่งไม้และพืชสวนได้สะดวก',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255345172.png',
      'stock': 20,
    },
    // {
    //   'id': 11,
    //   'name': 'จอบขุดดิน',
    //   'type': '2',
    //   'price': 200.0,
    //   'description': 'จอบขุดดินคุณภาพ แข็งแรง ใช้งานได้นาน',
    //   'image':
    //       'https://www.sprayerthai.com/wp-content/uploads/2021/07/shovel.jpg',
    //   'stock': 15,
    // },
    // {
    //   'id': 12,
    //   'name': 'สายยางรดน้ำ 20 ม.',
    //   'type': '2',
    //   'price': 350.0,
    //   'description': 'สายยางคุณภาพสูง ยาว 20 เมตร เหมาะสำหรับรดน้ำสวน',
    //   'image':
    //       'https://www.sprayerthai.com/wp-content/uploads/2021/07/hose.jpg',
    //   'stock': 30,
    // },
    {
      'id': 13,
      'name': 'เครื่องตัดหญ้าไฟฟ้า',
      'type': '2',
      'price': 2500.0,
      'description': 'เครื่องตัดหญ้าไฟฟ้า ประสิทธิภาพสูง ใช้งานง่าย',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255345172.png',
      'stock': 5,
    },

    // อาหารสัตว์
    {
      'id': 3,
      'name': 'อาหารไก่เนื้อเบอร์ 910',
      'type': '3',
      'price': 250.0,
      'description':
          'อาหารชนิดเม็ด สำหรับไก่เล็กถึงอายุ 3 สัปดาห์ มีโปรตีนคุณภาพสูง เหมาะสำหรับฟาร์มไก่เนื้อ',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_253341284.png',
      'stock': 10,
    },
    {
      'id': 14,
      'name': 'อาหารหมูลูกพันธุ์ 101',
      'type': '3',
      'price': 300.0,
      'description': 'อาหารหมูลูกพันธุ์ สำหรับลูกหมูอายุ 0-8 สัปดาห์ โปรตีนสูง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_253126489.png',
      'stock': 20,
    },
    {
      'id': 15,
      'name': 'อาหารปลานิล',
      'type': '3',
      'price': 220.0,
      'description': 'อาหารปลานิลเม็ดคุณภาพดี ช่วยเร่งการเจริญเติบโตของปลา',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_254041307.png',
      'stock': 25,
    },
    {
      'id': 16,
      'name': 'อาหารวัวกระทิง',
      'type': '3',
      'price': 400.0,
      'description': 'อาหารวัวชนิดเม็ด เสริมโปรตีนและแร่ธาตุสำหรับวัวเนื้อ',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_253600030.png',
      'stock': 15,
    },
    {
      'id': 17,
      'name': 'อาหารไก่ไข่เบอร์ 926',
      'type': '3',
      'price': 280.0,
      'description': 'อาหารไก่ไข่ เสริมโปรตีนและแคลเซียม ให้ไข่มีคุณภาพ',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_253540696.jpg',
      'stock': 20,
    },

    // เคมีภัณฑ์
    {
      'id': 4,
      'name': 'ปุ๋ยเคมีสูตร 15-15-15',
      'type': '4',
      'price': 450.0,
      'description':
          'ปุ๋ยเคมีสูตรมาตรฐาน เหมาะสำหรับพืชสวนและพืชไร่ ให้ธาตุอาหารครบถ้วนสำหรับการเจริญเติบโต',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_254613292.jpg',
      'stock': 10,
    },
    {
      'id': 5,
      'name': 'ยาฆ่าแมลงตราช้างแดง',
      'type': '4',
      'price': 195.0,
      'description':
          'ยาฆ่าแมลงประสิทธิภาพสูง ปลอดภัยเมื่อใช้ตามคำแนะนำ เหมาะสำหรับพืชสวน พืชไร่ และไม้ดอก',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_254638003.png',
      'stock': 0,
    },
    {
      'id': 18,
      'name': 'ปุ๋ยยูเรียเม็ด',
      'type': '4',
      'price': 220.0,
      'description': 'ปุ๋ยยูเรียเสริมไนโตรเจน สำหรับพืชผลผลิตสูง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_254711304.png',
      'stock': 30,
    },
    {
      'id': 19,
      'name': 'ยาฆ่าแมลงกำจัดเพลี้ย',
      'type': '4',
      'price': 180.0,
      'description': 'ยาฆ่าแมลงสูตรเข้มข้น กำจัดเพลี้ยและแมลงศัตรูพืชได้ดี',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_254735649.png',
      'stock': 20,
    },
    {
      'id': 20,
      'name': 'ปุ๋ยสูตรฟอสฟอรัสสูง',
      'type': '4',
      'price': 350.0,
      'description': 'ปุ๋ยฟอสฟอรัสสูง เพิ่มการเจริญเติบโตของรากพืช',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_254801234.png',
      'stock': 25,
    },
    {
      'id': 21,
      'name': 'สารปรับสภาพดิน',
      'type': '4',
      'price': 300.0,
      'description':
          'สารปรับสภาพดิน ช่วยให้ดินร่วนซุย เพิ่มประสิทธิภาพการใช้ปุ๋ย',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_254834628.png',
      'stock': 15,
    },

    // ========= 🚜 สินค้าใหม่ที่เด่น ๆ =========
    {
      'id': 22,
      'name': 'โดรนพ่นยาเกษตร DJI Agras T40',
      'type': '2', // จัดเป็นอุปกรณ์เครื่องมือ
      'price': 580000.0,
      'description':
          'โดรนพ่นยา/ปุ๋ย รุ่นล่าสุด DJI Agras T40 ความจุถัง 40 ลิตร พ่นได้รวดเร็ว ประหยัดแรงงาน เหมาะกับไร่ข้าวโพด นาข้าว และพืชเศรษฐกิจ',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_252119760.png',
      'stock': 2,
    },
    {
      'id': 23,
      'name': 'รถไถเดินตาม Kubota รุ่น RT140',
      'type': '2',
      'price': 120000.0,
      'description':
          'รถไถเดินตามขนาดกลาง ใช้งานง่าย เหมาะกับเกษตรกรรายย่อย สามารถติดตั้งอุปกรณ์เสริมได้หลายชนิด',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_255759883.png',
      'stock': 3,
    },
    {
      'id': 24,
      'name': 'รถแทรกเตอร์ Kubota MU5501',
      'type': '2',
      'price': 750000.0,
      'description':
          'แทรกเตอร์ขนาดใหญ่ 55 แรงม้า เหมาะสำหรับการเพาะปลูกขนาดกลางถึงใหญ่ รองรับงานไถ พรวน ยกร่อง และลากพ่วง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_250611616.png',
      'stock': 5,
    },
    {
      'id': 25,
      'name': 'ปุ๋ยอินทรีย์ชีวภาพ Premium',
      'type': '4',
      'price': 500.0,
      'description':
          'ปุ๋ยอินทรีย์ผสมจุลินทรีย์ธรรมชาติ เพิ่มความสมบูรณ์ของดิน กระตุ้นการเจริญเติบโตของพืชแบบยั่งยืน',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/rotation/rotation_254921133.png',
      'stock': 50,
    },
    {
      'id': 26,
      'name': 'ระบบ Smart Sensor เกษตร IoT',
      'type': '2',
      'price': 25000.0,
      'description':
          'เซ็นเซอร์ IoT ตรวจวัดความชื้นในดิน อุณหภูมิ และค่า pH ส่งข้อมูลผ่านแอปมือถือ ช่วยเกษตรกรวิเคราะห์และจัดการแปลงเพาะปลูก',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_250621859.png',
      'stock': 10,
    },
    // {
    //   'id': 27,
    //   'name': 'เครื่องเก็บเกี่ยวข้าว Combine Harvester',
    //   'type': '2',
    //   'price': 950000.0,
    //   'description':
    //       'เครื่องเก็บเกี่ยวข้าวอัตโนมัติ ทำงานได้รวดเร็ว ลดแรงงาน ประหยัดเวลา เหมาะกับไร่นาขนาดใหญ่',
    //   'image': 'https://www.agriculture.com/images/harvester.png',
    //   'stock': 2,
    // },
    {
      'id': 28,
      'name': 'ระบบน้ำหยดอัตโนมัติ Smart Drip',
      'type': '2',
      'price': 18000.0,
      'description':
          'ระบบน้ำหยดควบคุมด้วยมือถือ ตั้งเวลาอัตโนมัติ ประหยัดน้ำ เหมาะสำหรับสวนผลไม้และแปลงผัก',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_251239328.png',
      'stock': 8,
    },
    {
      'id': 29,
      'name': 'โรงเรือนอัจฉริยะ Smart Greenhouse',
      'type': '2',
      'price': 350000.0,
      'description':
          'โรงเรือนสำเร็จรูปพร้อมระบบควบคุมอุณหภูมิ ความชื้น และการให้น้ำอัตโนมัติ ผ่านแอปมือถือ',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_253545227.png',
      'stock': 1,
    },
    {
      'id': 30,
      'name': 'โดรนสำรวจพื้นที่การเกษตร Mavic Agro',
      'type': '2',
      'price': 250000.0,
      'description':
          'โดรนสำรวจไร่นา พร้อมกล้องความละเอียดสูงและเซ็นเซอร์ NDVI สำหรับวิเคราะห์สุขภาพพืช',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_252540513.png',
      'stock': 3,
    },
    // {
    //   'id': 31,
    //   'name': 'ปุ๋ยชีวภาพเสริมจุลินทรีย์',
    //   'type': '4',
    //   'price': 380.0,
    //   'description':
    //       'ปุ๋ยชีวภาพพิเศษเสริมจุลินทรีย์ละลายฟอสเฟต เพิ่มธาตุอาหารให้ดินและลดการใช้สารเคมี',
    //   'image': 'https://www.organicfertilizer.com/images/biofert.png',
    //   'stock': 40,
    // },
    {
      'id': 32,
      'name': 'รถไถเล็กอเนกประสงค์ Mini Tractor',
      'type': '2',
      'price': 185000.0,
      'description':
          'รถไถเล็กสำหรับสวนผลไม้ ใช้งานคล่องตัว ประหยัดน้ำมัน เหมาะกับพื้นที่ขนาดเล็กถึงกลาง',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_250611616.png',
      'stock': 6,
    },
    {
      'id': 33,
      'name': 'เครื่องเพาะกล้าอัตโนมัติ',
      'type': '2',
      'price': 45000.0,
      'description':
          'เครื่องเพาะกล้ารุ่นใหม่ สามารถหยอดเมล็ด รดน้ำ และควบคุมสภาพแวดล้อมได้อัตโนมัติ',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_253640982.png',
      'stock': 4,
    },
    // {
    //   'id': 34,
    //   'name': 'สารชีวภัณฑ์กำจัดหนอนกอข้าว',
    //   'type': '4',
    //   'price': 250.0,
    //   'description':
    //       'สารชีวภัณฑ์จากแบคทีเรีย Bacillus thuringiensis (BT) ใช้กำจัดหนอนศัตรูพืชโดยไม่กระทบสิ่งแวดล้อม',
    //   'image': 'https://www.bioagro.com/images/bt-bio.png',
    //   'stock': 25,
    // },
    {
      'id': 35,
      'name': 'เครื่องคัดแยกเมล็ดพันธุ์อัตโนมัติ',
      'type': '2',
      'price': 65000.0,
      'description':
          'เครื่องคัดแยกเมล็ดพันธุ์ตามขนาดและน้ำหนัก ลดแรงงาน เพิ่มคุณภาพเมล็ดพันธุ์',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_254142264.png',
      'stock': 7,
    },
    {
      'id': 36,
      'name': 'เครื่องอบข้าวโพดพลังงานแสงอาทิตย์',
      'type': '2',
      'price': 98000.0,
      'description':
          'เครื่องอบเมล็ดข้าวโพดด้วยพลังงานแสงอาทิตย์ ลดต้นทุนค่าไฟฟ้าและเป็นมิตรต่อสิ่งแวดล้อม',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_253640982.png',
      'stock': 3,
    },
    {
      'id': 37,
      'name': 'เครื่องบรรจุเมล็ดพืชอัตโนมัติ',
      'type': '2',
      'price': 120000.0,
      'description':
          'เครื่องบรรจุเมล็ดหรือธัญพืชลงถุงแบบอัตโนมัติ ปรับขนาดบรรจุได้ ประหยัดแรงงานและเวลา',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_253229765.png',
      'stock': 4,
    },
    {
      'id': 38,
      'name': 'ระบบพลังงานแสงอาทิตย์สำหรับเกษตร',
      'type': '2',
      'price': 150000.0,
      'description':
          'แผงโซลาร์เซ็ตพร้อมระบบแบตเตอรี่ สำหรับปั๊มน้ำและระบบชลประทานในไร่นา',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_252146409.png',
      'stock': 5,
    },
    {
      'id': 39,
      'name': 'เครื่องย่อยเศษพืช',
      'type': '2',
      'price': 32000.0,
      'description':
          'เครื่องย่อยเศษพืชหลังการเก็บเกี่ยว เปลี่ยนเป็นปุ๋ยหมักหรือนำกลับใช้ในไร่นา',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_252653005.png',
      'stock': 10,
    },
    {
      'id': 40,
      'name': 'หุ่นยนต์เก็บผลไม้ Smart Picker',
      'type': '2',
      'price': 480000.0,
      'description':
          'หุ่นยนต์เก็บผลไม้ เช่น มะม่วง ทุเรียน มะเขือเทศ ลดแรงงานและความเสียหายของผลผลิต',
      'image':
          'https://khubdeedlt.we-builds.com/khubdeedlt-document/images/aboutUs/aboutUs_251733990.png',
      'stock': 2,
    },
  ];

}
