// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/cart.dart';
import 'package:kasetmall/component/carousel_banner.dart';
import 'package:kasetmall/component/loading_image_network.dart';
import 'package:kasetmall/component/material/loading_tween.dart';
import 'package:kasetmall/component/toast_fail.dart';
import 'package:kasetmall/event_calendar_form.dart';
import 'package:kasetmall/event_calendar_main.dart';
import 'package:kasetmall/news_all.dart';
import 'package:kasetmall/news_form.dart';
import 'package:kasetmall/privilege_all.dart';
import 'package:kasetmall/privilege_form.dart';
import 'package:kasetmall/product_all.dart';
import 'package:kasetmall/product_from.dart';
import 'package:kasetmall/data/mock_kaset_data.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/shared/login_guard.dart';
import 'package:kasetmall/shared/notification_service.dart';
import 'package:kasetmall/shared/mock_store.dart';

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
  late final VoidCallback _authListener;
  bool _isLoggedIn = false;
  String _displayName = '';
  String _profileImageUrl = '';
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
  late final VoidCallback _cartListener;

  String? emailProfile;
  int total_page = 0;
  int page = 1;
  bool loadProduct = true;

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _refreshController = RefreshController();
    _authListener = () {
      if (mounted) {
        _loadUserProfile();
      }
    };
    _cartListener = () {
      if (mounted) {
        _getCountItemInCart();
      }
    };
    MockStore.authVersion.addListener(_authListener);
    MockStore.cartVersion.addListener(_cartListener);
    _getCategory();
    _callRead();
    // _getUserData();
    _getCountItemInCart();
    _loadUserProfile();
    // _callReadVideoShort();
    _callReadAll();
    _onLoading();

    super.initState();
  }

  @override
  void dispose() {
    MockStore.authVersion.removeListener(_authListener);
    MockStore.cartVersion.removeListener(_cartListener);
    _scrollController?.dispose();
    _refreshController?.dispose();
    super.dispose();
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
    final items = await CartStore.getCart();
    if (!mounted) return;
    setState(() {
      amountItemInCart = items.length;
    });
  }

  Future<void> _loadUserProfile() async {
    final isLoggedIn = await MockStore.isLoggedIn();
    final data = await MockStore.loadUserProfile();
    final firstName = data['firstName']?.toString() ?? '';
    final lastName = data['lastName']?.toString() ?? '';
    if (!mounted) return;
    setState(() {
      _isLoggedIn = isLoggedIn;
      _displayName = '$firstName $lastName'.trim();
      _profileImageUrl = data['imageUrl']?.toString() ?? '';
    });
  }

  ImageProvider _profileImageProvider(String path) {
    if (path.isEmpty) {
      return const AssetImage('assets/images/kaset/logo_kaset.png');
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return const AssetImage('assets/images/kaset/logo_kaset.png');
  }

  _getCategory() async {
    setState(() {
      _futureCategory = Future.value(mockCategories);
    });
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
      // extendBody: true,
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 42,
                  width: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE1EBE0)),
                  ),
                  child: _isLoggedIn
                      ? ClipOval(
                          child: Image(
                            image: _profileImageProvider(_profileImageUrl),
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/kaset/user.png',
                              width: 26,
                              height: 26,
                            ),
                          ),
                        )
                      : Image.asset(
                          'assets/images/kaset/logo_kaset.png',
                          width: 28,
                          height: 28,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เกษตร Mall',
                        style: const TextStyle(
                          color: Color(0xFF1B5E20),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        textScaleFactor: ScaleSize.textScaleFactor(context),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isLoggedIn
                            ? (_displayName.isNotEmpty
                                ? _displayName
                                : 'บัญชีของคุณ')
                            : 'เข้าสู่ระบบเพื่อเริ่มใช้งาน',
                        style: const TextStyle(
                          color: Color(0xFF6E6C61),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: ScaleSize.textScaleFactor(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (_isLoggedIn)
                  _buildAppBarAction(
                    icon: Icons.shopping_cart_outlined,
                    onTap: () async {
                      final allowed = await requireLogin(
                        context,
                        title: 'ตะกร้า',
                        description: 'ต้องเข้าสู่ระบบก่อนเพื่อดูตะกร้าสินค้า',
                      );
                      if (!allowed) return;
                      if (widget.changePage != null) {
                        widget.changePage!(1);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CartCentralPage(),
                          ),
                        ).then((value) => _getCountItemInCart());
                      }
                    },
                    badge: amountItemInCart > 0
                        ? amountItemInCart > 99
                            ? '99+'
                            : amountItemInCart.toString()
                        : null,
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
                  const SizedBox(height: 6),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CarouselBanner(
                        model: _futureBanner,
                        url: 'main/',
                        height: MediaQuery.of(context).size.height * 0.145,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () {},
                    child: _buildTitle(
                      title: 'หมวดหมู่',
                      showAll: false,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildCategory(),
                  const SizedBox(height: 6),
                  _buildCouponTodaySection(),

                  const SizedBox(height: 8),
                  _buildForYou(),
                  const SizedBox(height: 10),
                  _buildBestSellerSection(),
                  // _buildTitle(
                  //   code: 'product',
                  //   title: 'สินค้า',
                  //   showAll: true,
                  // ),
                  // SizedBox(height: 5),
                  // _buildTrending(),
                  const SizedBox(height: 85),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF7EE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE1EBE0)),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2E7D32),
              size: 22,
            ),
          ),
          if (badge != null)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8992B),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
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
                  } else if (code == 'coupon') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrivilegeAllPage(
                          title: 'คูปอง',
                        ),
                      ),
                    );
                  } else if (code == 'benefit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivilegeAllPage(
                          title: 'สิทธิประโยชน์',
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

        final categories = snapshot.data as List<dynamic>;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 100,
            ),
            itemBuilder: (context, i) {
              final item = categories[i];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductAllCentralPage(
                        title: 'สินค้า',
                        mode: true,
                        typeelect: item['id'],
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5EEE4)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF143D16).withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                height: 65,
                                width: 65,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF7EE),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: item['img'] == null
                                    ? Image.asset(
                                        "assets/images/kaset/no-img.png",
                                        width: 55,
                                        height: 55,
                                      )
                                    : Image.asset(
                                        item['img'],
                                        width: 55,
                                        height: 55,
                                      ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              item['name'] ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1A),
                                height: 1.08,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ignore: unused_element
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

  // ignore: unused_element
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
      child: Column(
        children: [
          _buildTitle(
            title: 'สิทธิประโยชน์',
            code: 'benefit',
            showAll: true,
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 220,
            child: FutureBuilder<dynamic>(
              future: _futureModelForYou,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        snapshot.data.length > 10 ? 10 : snapshot.data.length,
                    separatorBuilder: (_, __) => SizedBox(width: 12),
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
                            width: 152,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE1EBE0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF143D16).withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 116,
                                  width: 152,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F7F3),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                    ),
                                  ),
                                  child: snapshot
                                              .data[index]['imageUrl'].length >
                                          0
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(18),
                                          ),
                                          child: loadingImageNetwork(
                                            snapshot.data[index]['imageUrl'],
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Image.asset(
                                            'assets/images/kaset/no-img.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 8, 12, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFBE7C9),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          'สิทธิประโยชน์',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFC77A1F),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        snapshot.data[index]['title'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1C1C1A),
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

  Widget _buildCouponTodaySection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: CouponStore.getAllCoupons(),
      builder: (context, snapshot) {
        final hasCoupons = (snapshot.data ?? const []).isNotEmpty;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 86,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivilegeAllPage(title: 'คูปอง'),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE1EBE0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF143D16).withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE7C9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Color(0xFFC77A1F),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'คูปองวันนี้',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasCoupons
                              ? 'กดรับคูปองไว้ใช้กับสินค้าที่ร่วมรายการ'
                              : 'ยังไม่มีคูปองให้แสดง',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.8,
                            color: Color(0xFF6E6C61),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFFE8992B),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBestSellerSection() {
    final items = _futureProductHot.isNotEmpty
        ? _futureProductHot.take(6).toList()
        : mockProductList.take(6).toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'สินค้าขายดี',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C1C1A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 175,
              ),
              itemBuilder: (context, index) {
                return _buildMiniProductCard(items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniProductCard(dynamic product) {
    final image = (product['image'] ?? '').toString();
    final hasImage = image.isNotEmpty;
    final price = product['price'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductFormCentralPage(model: product),
          ),
        ).then((_) => _getCountItemInCart());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE1EBE0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF143D16).withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: SizedBox(
              height: 104,
              width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasImage)
                      AdaptiveProductImage(
                        url: image,
                        fit: BoxFit.contain,
                        blurThreshold: 0.45,
                        padding: const EdgeInsets.all(10),
                      )
                    else
                      Image.asset(
                        'assets/images/kaset/no-img.png',
                        fit: BoxFit.contain,
                      ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8992B),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'ขายดี',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1A),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '฿${price ?? '-'}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  late bool isBestSeller;
  String _filterSelected = '0';

  // ignore: unused_element
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
}
