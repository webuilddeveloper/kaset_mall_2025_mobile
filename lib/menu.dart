import 'dart:convert';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:mobile_mart_v3/commercial_organization.dart';
import 'package:mobile_mart_v3/component/loading_image_network.dart';
import 'package:mobile_mart_v3/component/toast_fail.dart';
import 'package:mobile_mart_v3/coupon.dart';
import 'package:mobile_mart_v3/game_selection_page.dart';
import 'package:mobile_mart_v3/home.dart';
import 'package:mobile_mart_v3/main_popup/dialog_main_popup.dart';
import 'package:mobile_mart_v3/notification/notification.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/user_information.dart';
import 'cart.dart';

class MenuCentralPage extends StatefulWidget {
  const MenuCentralPage({
    Key? key,
    this.pageIndex = 0,
    this.commercialOrganization = '0',
  }) : super(key: key);
  final int pageIndex;
  final String commercialOrganization;

  @override
  State<MenuCentralPage> createState() => _MenuCentralPageState();
}

class _MenuCentralPageState extends State<MenuCentralPage> {
  final storage = new FlutterSecureStorage();
  late Future<dynamic> _futureMainPopUp;
  int _currentPage = 0;
  late TextEditingController searchController;
  List<Widget> _widgetOptions = <Widget>[];
  dynamic profile = {'firstName': '', 'lastName': '', 'imageUrl': ''};
  String? profileCode = '';
  late PageController pageController;
  var home;
  bool hiddenMainPopUp = false;
  late DateTime currentBackPressTime;

  @override
  void initState() {
    // _callReadPolicy();
    onSetPage();
    home = HomeCentralPage(changePage: _changePage);
    _futureMainPopUp = postDio('${mainPopupHomeApi}read', {'limit': 10});
    _getProfile();
    searchController = TextEditingController(text: '');
    _widgetOptions = <Widget>[
      home,
      //// HomeMartPage(),
      NotificationCentralPage(),
      CommercialOrganizationPage(
        commercialOrganization: widget.commercialOrganization,
      ),
      GameSelectionPage(),
      CouponCentralPage(),
      UserInformationCentralPage(),
    ];
    pageController = new PageController(
      initialPage: _currentPage,
    );
    _buildMainPopUp();
    _setupInteractedMessage();
    super.initState();
  }

  Future<void> _setupInteractedMessage() async {
    // กรณีที่ 1: แอปถูกปิด (Terminated) และเปิดขึ้นมาจากการกด Notification
    // getInitialMessage จะคืนค่า RemoteMessage ที่ทำให้แอปเปิดขึ้นมา
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // กรณีที่ 2: แอปอยู่เบื้องหลัง (Background) และเปิดขึ้นมาจากการกด Notification
    // onMessageOpenedApp เป็น Stream ที่จะส่ง RemoteMessage มาเมื่อเกิด event
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  /// ฟังก์ชันจัดการข้อมูลจาก RemoteMessage และสั่งให้ Navigator วิ่งไปหน้าอื่น
  void _handleMessage(RemoteMessage message) {
    // ตรวจสอบข้อมูลจาก 'data' payload
    if (message.data['screen'] == 'NotificationCentralPage') {
      // ดึงค่า product_id ออกมา (ถ้ามี)
      // final productId = message.data['product_id'];

      // ใช้ Navigator วิ่งไปยังหน้าที่ต้องการ
      _onItemTapped(1);
    }
  }

  _changePage(index) {
    setState(() {
      _currentPage = index;
      pageController.jumpToPage(index);
    });
  }

  onSetPage() {
    setState(() {
      _currentPage = widget.pageIndex != null ? widget.pageIndex : 0;
      // currentTabIndex = pageIndex != 0 ? pageIndex : currentTabIndex;
    });
  }

  _getProfile() async {
    profileCode = (await storage.read(key: 'profileCode10'));
    String? imageUrl = await storage.read(key: 'profileImageUrl');
    String? firstName = await storage.read(key: 'profileFirstName');
    String? lastName = await storage.read(key: 'profileLastName');
    setState(() {
      profile = {
        'firstName': firstName,
        'lastName': lastName,
        'imageUrl': imageUrl
      };
      profileCode = profileCode;
    });
    await _insertToken();
  }

  _insertToken() async {
    FirebaseMessaging.instance.getToken().then(
      (token) {
        postDio(server_we_build + 'notificationV2/m/insertTokenDevice',
            {"token": token, "profileCode": profileCode});
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      pageController.jumpToPage(index);
      if (index == 0 && _currentPage == 0) {
        _getProfile();
        _buildMainPopUp();
        home.getState().onRefresh();
      }
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: confirmExit,
      child: Scaffold(
        extendBody: true,
        body: PageView(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          children: _widgetOptions,
        ),
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                ),
              ],
            ),
            height: AdaptiveTextSize().getadaptiveTextSize(
                context, 35 + MediaQuery.of(context).padding.top),
            width: double.infinity,
            child: Stack(
              children: [
                // Positioned.fill(
                //   child: Image.asset(
                //     'assets/buttom_novel_bg2.jpg',
                //     fit: BoxFit.cover,
                //     width: double.infinity,
                //     height: double.infinity,
                //   ),
                // ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buttonBottomBar(
                            'assets/images/kaset/home-menu.png', '', 0),

                        // _buttonBottomBar('assets/images/central/organize.png',
                        //     'องค์การค้า', 2),
                        // _buttonBottomBar(
                        //     'assets/images/central/game.png', 'เกมส์', 3),
                        // _buttonBottomBar(
                        //     'assets/images/central/coupon.png', 'คูปอง', 4),
                        _buttonBottomBar(
                            'assets/images/kaset/basket.png', '', 1),
                        _buttonBottomBar(
                            'assets/images/kaset/notification.png', '', 2),
                        _buttonBottomBar(
                            (profile['imageUrl'] ?? "") == ''
                                ? 'assets/images/kaset/user.png'
                                : profile['imageUrl'],
                            '',
                            5,
                            network: (profile['imageUrl'] ?? "") == ''
                                ? false
                                : true),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Future<bool> confirmExit() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
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

  _buttonBottomBar(String image, String title, int index,
      {bool network = false}) {
    bool hasSelected = _currentPage == index;
    return
        // Expanded(
        //   flex: 1,
        //   child:
        InkWell(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        // padding: EdgeInsets.symmetric(vertical: 25),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (network)
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: loadingImageNetwork(
                    image,
                    height: AdaptiveTextSize().getadaptiveTextSize(context, 20),
                    width: AdaptiveTextSize().getadaptiveTextSize(context, 20),
                  ),
                ),
              if (!network)
                Image.asset(
                  image,
                  height: AdaptiveTextSize().getadaptiveTextSize(context, 30),
                  width: AdaptiveTextSize().getadaptiveTextSize(context, 30),
                  color: hasSelected ? Color(0xFF09665a) : Color(0xFFA89F9D),
                ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: hasSelected ? Color(0xFF09665a) : Color(0xFFA89F9D),
                  fontWeight: hasSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textScaleFactor: ScaleSize.textScaleFactor(context),
              ),
            ],
          ),
        ),
      ),
    );
    // );
  }

  _buildMainPopUp() async {
    var result = await postDio('${mainPopupHomeApi}read', {'limit': 100});

    if (result.length > 0) {
      var valueStorage = await storage.read(key: 'mainPopupDDPM');
      var dataValue;
      if (valueStorage != null) {
        dataValue = json.decode(valueStorage);
      } else {
        dataValue = null;
      }

      var now = new DateTime.now();
      DateTime date = new DateTime(now.year, now.month, now.day);

      if (dataValue != null) {
        var index = dataValue.indexWhere(
          (c) =>
              // c['username'] == userData.username &&
              c['date'].toString() ==
                  DateFormat("ddMMyyyy").format(date).toString() &&
              c['boolean'] == "true",
        );

        if (index == -1) {
          setState(() {
            hiddenMainPopUp = false;
          });
          return showDialog(
            barrierDismissible: false, // close outside
            context: context,
            builder: (_) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: MainPopupDialog(
                  model: _futureMainPopUp,
                  type: 'mainPopup',
                ),
              );
            },
          );
        } else {
          setState(() {
            hiddenMainPopUp = true;
          });
        }
      } else {
        setState(() {
          hiddenMainPopUp = false;
        });
        return showDialog(
          barrierDismissible: false, // close outside
          context: context,
          builder: (_) {
            return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: MainPopupDialog(
                model: _futureMainPopUp,
                type: 'mainPopup',
              ),
            );
          },
        );
      }
    }
  }
}
