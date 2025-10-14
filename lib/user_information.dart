import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaset_mall/game_selection_page.dart';
import 'package:kaset_mall/math_game/setting_main.dart';
import 'package:kaset_mall/phonics_game.dart';
import 'package:kaset_mall/product_favorite.dart';
import 'package:kaset_mall/read_book_list.dart';
import 'package:kaset_mall/register.dart';
import 'package:kaset_mall/register_shop.dart';
import 'package:kaset_mall/review_success.dart';
import 'package:kaset_mall/to_pay.dart';
import 'package:kaset_mall/to_rate.dart';
import 'package:kaset_mall/to_receive.dart';
import 'package:kaset_mall/to_ship.dart';
import 'package:kaset_mall/to_success.dart';
import 'package:kaset_mall/user_profile_form.dart';
import 'package:kaset_mall/verify_phone.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'chats_staff.dart';
import '../component/link_url_in.dart';
import '../component/loading_image_network.dart';
import '../dark_mode.dart';
import '../read_book.dart';
import '../shared/api_provider.dart';
import '../shared/extension.dart';
import 'cart.dart';
import 'coupons_pickup.dart';
import 'delivery_address.dart';
import 'login.dart';

class UserInformationCentralPage extends StatefulWidget {
  @override
  _UserInformationCentralPageState createState() =>
      _UserInformationCentralPageState();
}

class _UserInformationCentralPageState
    extends State<UserInformationCentralPage> {
  final storage = new FlutterSecureStorage();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late Future<dynamic> _futureProfile;
  late Future<dynamic> _countLike;
  Future<dynamic> _futureCoupon = Future.value([
    {
      'title': 'ส่วนลด 100 บาท',
      'description': 'เมื่อสั่งซื้อสินค้าครั้งแรกกับแอพ'
    },
    {
      'title': 'ส่วนลด 200 บาท',
      'description': 'เมื่อสั่งซื้อสินค้าครั้งแรกกับแอพ'
    },
    {
      'title': 'ส่วนลด 200 บาท',
      'description': 'เมื่อสั่งซื้อสินค้าครั้งแรกกับแอพ'
    },
    {
      'title': 'ส่วนลด 200 บาท',
      'description': 'เมื่อสั่งซื้อสินค้าครั้งแรกกับแอพ'
    },
  ]);
  Future<dynamic>? _futureDeliveryAddress;

  Future<dynamic> _futurePaymentOptions = Future.value([
    {
      'title': 'ชำระเงินปลายทาง',
      'description': 'ชำระเงินเมื่อได้รับสินค้า',
    },
    {'title': 'บัตรเครดิต / เดบิต', 'description': 'บัตร visa xxx-123'},
    {
      'title': 'ชำระเงินปลายทาง2',
      'description': 'ชำระเงินเมื่อได้รับสินค้า',
    },
    {'title': 'บัตรเครดิต / เดบิต2', 'description': 'บัตร visa xxx-123'},
  ]);

  List<dynamic> addressList = [
    {
      "name": "สมศักดิ์ ศักดิ์สม",
      "no": "19/1-2 ชั้น8 ห้อง8บี ซ.ยาสูบ1 ถ.วิภาวดีรังสิต",
      "subDistrict": "จอมพล",
      "district": "จตุจักร",
      "province": "กรุงเทพมหานครฯ",
      "postNo": "10900",
      "main": true
    },
    {
      "name": "สมศักดิ์2 ศักดิ์สม",
      "no": "19/1-2 ชั้น8 ห้อง8บี ซ.ยาสูบ1 ถ.วิภาวดีรังสิต",
      "subDistrict": "จอมพล",
      "district": "จตุจักร",
      "province": "กรุงเทพมหานครฯ",
      "postNo": "10900",
      "main": false
    },
  ];

  List<dynamic> discountList = [
    {
      "discount": 5000,
      "minimumOrderTotal": 30000,
    },
  ];

  String profileCode = '';
  String profileImageUrl = '';
  String referenceShopCode = '';
  String referenceShopName = '';
  String profilePhone = '';
  var profileFirstName;
  var profileLastName;

  bool isShop = false;
  String verifyPhonePage = 'false';
  int follower = 0;
  int following = 0;

  late String _userId;
  late String _username;

  final txtUsername = TextEditingController();
  final txtPassword = TextEditingController();
  bool loadingSuccess = false;

  List<dynamic> paid = [];
  List<dynamic> ship = [];
  List<dynamic> delivery = [];
  List<dynamic> success = [];
  int review = 0;

  String memberType = '1';
  var isShopRegis;

  @override
  void initState() {
    // _read();
    // _readUser();
    _getUserData();

    super.initState();
  }

  void _onRefresh() async {
    // _read();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  _getUserData() async {
    // var a = await storage.read(key: 'phoneVerified');
    // setState(() {
    //   verifyPhonePage = a ?? "";
    // });
    final fistName =
        await new FlutterSecureStorage().read(key: 'firstName') ?? "";
    final lastName =
        await new FlutterSecureStorage().read(key: 'lastName') ?? "";
    final isShop =
        await new FlutterSecureStorage().read(key: 'isShop') ?? "false";
    setState(() {
      profileFirstName = fistName;
      profileLastName = lastName;
      isShopRegis = isShop;
    });
    Timer(
      Duration(seconds: 1),
      () => {
        setState(
          () {
            loadingSuccess = true;
          },
        ),
      },
    );
  }

  _getCredit() async {
    try {
      var res = await postDio('${server}m/manageCreditCard/read', {});
      var mapData = res.map((e) {
        return {
          'title': 'บัตรเครดิต / เดบิต',
          'description': 'บัตร ${e['type']} xxx-${e['number']}'
        };
      }).toList();
      setState(() {
        _futurePaymentOptions = Future.value([
          // {
          //   'title': 'ชำระเงินปลายทาง',
          //   'description': 'ชำระเงินเมื่อได้รับสินค้า',
          // },
          ...mapData
        ]);
      });
    } catch (e) {}
  }

  _readWaiteReview() async {
    try {
      await get('${server}users/me/order-details/review-pending')
          .then((value) => {
                setState(() {
                  review = value.length;
                })
              });
    } catch (e) {
      setState(() {
        review = 0;
      });
    }
  }

  _readCoupon() {
    _futureCoupon = get('${server}users/me/coupons');
  }

  _readOrder() async {
    setState(() {
      // Timer(
      //   Duration(seconds: 1),
      //   () => {
      //     setState(
      //       () {
      //       },
      //     ),
      //   },
      // );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBackground();
  }

  _buildBackground() {
    return Container(
        decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage("assets/bg_profile.png"),
            //   fit: BoxFit.cover,
            // ),
            color: Colors.white),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: EdgeInsets.only(
                top: 0,
                // bottom: MediaQuery.of(context).padding.bottom
              ),
              child: loadingSuccess == false
                  ? Center(
                      child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ))
                  : Column(
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: _screen(),
                        )
                      ],
                    ),
            ),
          ),
        ));
  }

  _buildHeader() {
    print('----====----- ${profileFirstName}');
    return Stack(
      children: [
        (profileFirstName == '' || profileFirstName == null)
            ? _isNotProfileCode()
            : _isProfileCode(),
        Positioned(
          top: 25,
          // bottom: -30,
          right: 20,
          child: GestureDetector(
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingMain(),
                ),
              ),
            },
            child: Image.asset(
              'assets/images/settings.png',
              width: (ScaleSize.textScaleFactor(context) /
                      (MediaQuery.of(context).size.aspectRatio)) +
                  AdaptiveTextSize().getadaptiveTextSize(context, 35),
              height: (ScaleSize.textScaleFactor(context) /
                      (MediaQuery.of(context).size.aspectRatio)) +
                  AdaptiveTextSize().getadaptiveTextSize(context, 35),
            ),
          ),
        ),
      ],
    );
  }

  _isNotProfileCode() {
    return Padding(
      padding: const EdgeInsets.only(top: 45, left: 15, right: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 70,
            width: 70,
            padding: EdgeInsets.all(profileImageUrl != '' ? 0.0 : 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
            ),
            child: GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => UserProfileForm(),
                //   ),
                // );
              },
              child: Container(
                height: 70,
                width: 70,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Image.asset(
                  'assets/images/central/profile.png',
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginCentralPage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(
                      color: Color(0XFFDF0B24),
                    ),
                  ),
                  child: Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 13,
                      color: Color(0XFFDF0B24),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => RegisterCentralPage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(
                      color: Color(0XFF0B24FB),
                    ),
                  ),
                  child: Text(
                    'ลงทะเบียน',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 13,
                      color: Color(0XFF0B24FB),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );

    // return Container(
    //   padding: const EdgeInsets.only(top: 70, left: 15, right: 15, bottom: 0),
    // );
  }

  _isProfileCode() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 15),
          Container(
            height: (ScaleSize.textScaleFactor(context) +
                    (MediaQuery.of(context).size.aspectRatio)) +
                AdaptiveTextSize().getadaptiveTextSize(context, 70),
            width: (ScaleSize.textScaleFactor(context) +
                    (MediaQuery.of(context).size.aspectRatio)) +
                AdaptiveTextSize().getadaptiveTextSize(context, 70),
            padding: EdgeInsets.all(profileImageUrl != '' ? 0.0 : 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileForm(),
                  ),
                ).then((value) async {
                  _onRefresh();
                  var image = await storage.read(key: 'profileImageUrl');
                  var phone = await storage.read(key: 'profilePhone');
                  var firstname = await storage.read(key: 'profileFirstName');
                  var lastname = await storage.read(key: 'profileLastName');
                  setState(() {
                    profileImageUrl = image ?? "";
                    profilePhone = phone ?? "";
                    profileFirstName = firstname;
                    profileLastName = lastname;
                  });
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child:
                    // loadingImageNetwork(
                    //         profileImageUrl,
                    //         fit: BoxFit.cover,
                    //         isProfile: true,
                    //       )
                    (isShopRegis == 'true' && memberType == '2')
                        ? Container(
                            height: 70,
                            width: 70,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: Image.asset(
                              'assets/images/central/store.png',
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                              color: Colors.white,
                            ),
                          )
                        : Container(
                            height: 70,
                            width: 70,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: Image.asset(
                              'assets/images/central/profile.png',
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                              color: Colors.white,
                            ),
                          ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (profileFirstName ?? "") + ' ' + (profileLastName ?? ""),
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
                textScaleFactor: ScaleSize.textScaleFactor(context),
              ),
              SizedBox(height: 5),
              InkWell(
                onTap: () {
                  profilePhone == null
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                UserProfileForm(mode: "addPhone"),
                          ),
                        )
                      : verifyPhonePage == 'false'
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    VerifyPhonePage(),
                              ),
                            )
                          : null;
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Text(
                    memberType == '1' ? 'สมาชิกเกษตรกร' : 'สมาชิกร้านค้า',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15,
                      color: Theme.of(context).primaryColor,
                    ),
                    textScaleFactor: ScaleSize.textScaleFactor(context),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _screen() {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return memberType == '2'
        ? Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  childAspectRatio: 1.2,
                  // 9/15,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              children: [
                // /////////////////// ร้านค้า //////////////////////
                _colTitle(Icons.integration_instructions, 'จัดการสินค้า',
                    callback: () => {}, isShowMenu: memberType == '2'),
                _colTitle(Icons.assignment_outlined, 'คำสั่งซื้อ',
                    callback: () => {}, isShowMenu: memberType == '2'),
                _colTitle(Icons.inventory, 'คลังสินค้า',
                    callback: () => {}, isShowMenu: memberType == '2'),
                _colTitle(Icons.local_shipping, 'จัดส่งสินค้า',
                    callback: () => {}, isShowMenu: memberType == '2'),
                _colTitle(Icons.account_circle, 'กลับไประบบผู้ซื้อ',
                    callback: () => {
                          setState(() {
                            memberType = '1';
                          }),
                        },
                    isShowMenu: memberType == '2'),
              ],
            ),
          )
        : ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(15),
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              // /////////////////// สมาชิก //////////////////////
              _rowTitle(Icons.assignment_outlined, 'รายการสั่งซื้อของฉัน',
                  callback: () => {}),
              _orderList(),
              _rowTitle(Icons.local_shipping_outlined, 'ที่อยู่จัดส่ง',
                  callback: () => verifyPhonePage == 'true'
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                DeliveryAddressCentralPage(),
                          ),
                        )
                      : {}),
              _deliveryAddress(),
              _rowTitle(Icons.confirmation_num_outlined, 'คูปองของฉัน',
                  callback: () => verifyPhonePage == 'true'
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                CouponPickUpCentralPage(
                              readMode: true,
                            ),
                          ),
                        )
                      : {},
                  isShowMenu: memberType == '1'),
              _coupon(),
              _rowTitle(Icons.headset_mic, 'ติดต่อ', callback: () {
                if (profileCode != '' && profileCode != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => chatstaff(
                        userId: _userId,
                        userName: _username,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => LoginCentralPage(),
                    ),
                  );
                }
              }),
              _rowTitle(Icons.reviews_outlined, 'สินค้าที่รีวิวแล้ว',
                  callback: () => verifyPhonePage == 'true'
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ReviewSuccessPage(),
                          ),
                        )
                      : {}),
              _rowTitle(Icons.favorite_border, 'สินค้าที่ฉันถูกใจ',
                  callback: () => verifyPhonePage == 'true'
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ProductFavoriteCentralPage(),
                          ),
                        )
                      : {}),
              _rowTitle(
                  Icons.add_business,
                  isShopRegis == 'true'
                      ? 'ร้านค้าของฉัน'
                      : 'สมัครสมาชิกเป็นร้านค้า',
                  callback: () => {
                        print('======== : ${isShopRegis}'),
                        isShopRegis == 'true'
                            ? setState(() {
                                memberType = '2';
                              })
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      RegisterShopPage(),
                                ),
                              )
                      },
                  isShowMenu: (profileFirstName ?? '') != ''),
            ],
          );
  }

  _orderList() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _boxOrderList(
          'ที่ต้อง\nชำระเงิน',
          'assets/logo/pay.png',
          paid.length,
          callback: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ToPayCentralPage(),
              ),
            ).then((value) => _onRefresh())
          },
        ),
        _boxOrderList(
          'กำลัง\nจัดเตรียม',
          'assets/logo/delivery.png',
          ship.length > 0 ? ship.length : null,
          callback: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ToShipCentralPage(),
              ),
            ).then((value) => _onRefresh())
          },
        ),
        _boxOrderList(
          'ระหว่าง\nขนส่ง',
          'assets/logo/car.png',
          delivery.length > 0 ? delivery.length : null,
          callback: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ToReceiveCentralPage(),
              ),
            ).then((value) => _onRefresh())
          },
        ),
        _boxOrderList(
          'เสร็จสิ้น',
          'assets/logo/check.png',
          delivery.length > 0 ? delivery.length : null,
          callback: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ToSuccessPage(),
              ),
            ).then((value) => _onRefresh())
          },
        ),
        _boxOrderList(
          'ที่ต้องรีวิว',
          'assets/logo/paper.png',
          review > 0 ? review : null,
          callback: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ToRateCentralPage(),
              ),
            ).then((value) => _onRefresh())
          },
        ),
      ],
    );
  }

  _boxOrderList(title, imageurl, countItem, {Function? callback}) {
    return InkWell(
      onTap: () => callback!(),
      child: Container(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  // alignment: Alignment.center,
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      imageurl,
                      // color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
              (profileCode != null &&
                      countItem != null &&
                      verifyPhonePage == 'true')
                  ? Positioned(
                      right: 0,
                      top: 0,
                      // bottom: 5,
                      child: Container(
                        height: 23,
                        width: 23,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0XFF0B24FB),
                        ),
                        child: Text(
                          countItem > 99 ? '99+' : countItem.toString(),
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: countItem.toString().length <= 1
                                ? 13
                                : countItem.toString().length == 2
                                    ? 12
                                    : 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
            ]),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  _rowTitle(icon, title, {Function? callback, bool isShowMenu = true}) {
    return isShowMenu
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              onTap: () => callback!(),
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (icon ?? '') != ''
                            ? Container(
                                // width: 10,
                                child: Icon(icon,
                                    color: Theme.of(context).primaryColor,
                                    size: (ScaleSize.textScaleFactor(context) +
                                            (MediaQuery.of(context)
                                                .size
                                                .aspectRatio)) +
                                        27),
                              )
                            : SizedBox(width: 0),
                        SizedBox(width: 5),
                        Text(
                          title,
                          style: TextStyle(
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).primaryColor),
                          textScaleFactor: ScaleSize.textScaleFactor(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        : SizedBox();
  }

  _colTitle(icon, title, {Function? callback, bool isShowMenu = true}) {
    return isShowMenu
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // ✅ สีของเงา
                  spreadRadius: 2, // ✅ การกระจายของเงา
                  blurRadius: 8, // ✅ ความเบลอของเงา
                  offset: const Offset(2, 4), // ✅ ทิศทางของเงา (x, y)
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: GestureDetector(
              onTap: () => callback!(),
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (icon ?? '') != ''
                        ? Container(
                            // width: 10,

                            child: Icon(icon,
                                color: Colors.white,
                                size: (ScaleSize.textScaleFactor(context) +
                                        (MediaQuery.of(context)
                                            .size
                                            .aspectRatio)) +
                                    55),
                          )
                        : SizedBox(width: 0),
                    // SizedBox(width: 5),
                    Text(
                      title,
                      style: TextStyle(
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white),
                      textScaleFactor: ScaleSize.textScaleFactor(context),
                    ),
                  ],
                ),
              ),
            ),
          )
        : SizedBox();
  }

  _coupon() {
    if (discountList.length > 0 && (profileFirstName ?? '') != '') {
      var row = <Widget>[];
      for (var d in discountList) {
        row.add(_boxCoupon(
            'ส่วนลด ' + moneyFormat(d['discount'].toString()) + ' บาท',
            'เมื่อซื้อครบ ' +
                moneyFormat(d['minimumOrderTotal'].toString()) +
                ' บาท'));
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: row,
            ),
          ),
        ],
      );
    } else {
      return _boxNotData(
        callback: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => CouponPickUpCentralPage(
              readMode: true,
            ),
          ),
        ),
      );
    }
  }

  _boxCoupon(title, description) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8, right: 8),
      child: Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.centerLeft,
        // width: (MediaQuery.of(context).size.aspectRatio) + 175,
        // AdaptiveTextSize().getadaptiveTextSize(context, 165),
        // height: AdaptiveTextSize().getadaptiveTextSize(context, 60),
        // width: AdaptiveTextSize().getadaptiveTextSize(context, 165),
        // height: (MediaQuery.of(context).size.aspectRatio) + 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: Color(0XFFE3E6FE),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: ScaleSize.textScaleFactor(context),
            ),
            Text(
              description,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 11,
                color: Color(0XFF707070),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: ScaleSize.textScaleFactor(context),
            ),
          ],
        ),
      ),
    );
  }

  _deliveryAddress() {
    if (addressList.length > 0 && (profileFirstName ?? '') != '') {
      var row = <Widget>[];
      // var isSelect = true;
      for (var d in addressList) {
        row.add(
          _boxDeliveryAndPayment(
            d['name'],
            d['address'],
            // d['building'],
            d['subDistrict'],
            d['district'],
            d['province'],
            d['postNo'],
            isSelect: d['main'],
            // callback: () => changeDefault(d['id'], d['main']),
          ),
        );
        // isSelect = false;
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: row,
        ),
      );
    } else {
      return _boxNotData(
        callback: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => DeliveryAddressCentralPage(),
          ),
        ),
      );
    }
    // FutureBuilder<dynamic>(
    //   future: _futureDeliveryAddress,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       if (snapshot.data.length > 0) {
    //         var row = <Widget>[];
    //         // var isSelect = true;
    //         for (var d in snapshot.data) {
    //           row.add(
    //             _boxDeliveryAndPayment(
    //               d['name'],
    //               d['address'],
    //               // d['building'],
    //               d['tambon']['data']['name_th'],
    //               d['amphoe']['data']['name_th'],
    //               d['province']['data']['name_th'],
    //               d['zip'],
    //               isSelect: d['main'],
    //               callback: () => changeDefault(d['id'], d['main']),
    //             ),
    //           );
    //           // isSelect = false;
    //         }

    //         return SingleChildScrollView(
    //           scrollDirection: Axis.horizontal,
    //           child: Row(
    //             children: row,
    //           ),
    //         );
    //       } else {
    //         return _boxNotData(
    //           callback: () => Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (BuildContext context) =>
    //                   DeliveryAddressCentralPage(),
    //             ),
    //           ),
    //         );
    //       }
    //     } else {
    //       return _boxNotData(
    //         callback: () => Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (BuildContext context) => DeliveryAddressCentralPage(),
    //           ),
    //         ),
    //       );
    //     }
    //   },
    // );
  }

  _paymentOptions() {
    if ((profileCode == null ||
        profileCode == '' ||
        verifyPhonePage == 'false')) {
      return _boxNotData();
    } else {
      return FutureBuilder<dynamic>(
        future: _futurePaymentOptions,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              List<Widget> row = [];
              var isSelect = false;
              for (var d in snapshot.data) {
                row.add(
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(8),
                        alignment: Alignment.centerLeft,
                        width: 165,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: isSelect
                                ? Color(0xFF1434F7)
                                : Color(0xFFE4E4E4),
                            width: 1,
                          ),
                          color: Color(0XFFFFFFFF),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d['title'],
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              d['description'],
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 11,
                                color: Color(0XFF707070),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                isSelect = false;
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: row,
                ),
              );
            } else
              return _boxNotData();
          } else {
            return _boxNotData();
          }
        },
      );
    }
  }

  _boxDeliveryAndPayment(title, address, subDistrictTitle, districtTitle,
      provinceTitle, postalCode,
      {isSelect, Function? callback}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => callback!(),
        child: Container(
          padding: EdgeInsets.all(
              AdaptiveTextSize().getadaptiveTextSize(context, 8)),
          alignment: Alignment.centerLeft,
          width: AdaptiveTextSize().getadaptiveTextSize(context, 165),
          // height: AdaptiveTextSize().getadaptiveTextSize(context, 70),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isSelect ? Color(0xFF1434F7) : Color(0xFFE4E4E4),
              width: 1,
            ),
            color: Color(0XFFFFFFFF),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaleFactor: ScaleSize.textScaleFactor(context),
              ),
              Text(
                (address ?? "") +
                    " " +
                    // (building ?? "") +
                    // " " +
                    (subDistrictTitle ?? "") +
                    " " +
                    (districtTitle ?? "") +
                    " " +
                    (provinceTitle ?? "") +
                    " " +
                    (postalCode ?? ""),
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 11,
                  color: Color(0XFF707070),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textScaleFactor: ScaleSize.textScaleFactor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _boxNotData({Function? callback}) {
    return GestureDetector(
      onTap: () => {
        (profileCode == '' || profileCode == null)
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => LoginCentralPage(),
                ),
              )
            : ((profilePhone == '' || profilePhone == null) &&
                    profileCode != null)
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          UserProfileForm(mode: "addPhone"),
                    )).then((value) => {_onRefresh()})
                : (verifyPhonePage == 'false' && profileCode != '')
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => VerifyPhonePage(),
                        ),
                      )
                    : callback!(),
      },
      // (profilePhone == '' || profilePhone == null)
      //     ? Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (BuildContext context) => LoginCentralPage(),
      //         ),
      //       )
      //     : (verifyPhonePage == 'false' && profileCode != '')
      //         ? Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (BuildContext context) => VerifyPhonePage(),
      //             ))
      //         : (profileCode == '' || profileCode == null)
      //             ? Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (BuildContext context) => LoginCentralPage(),
      //                 ),
      //               )
      //             : null,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(bottom: 8, right: 8),
        child: Container(
          alignment: Alignment.center,
          width: 165,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: Color(0xFF1434F7),
              width: 1,
            ),
            // color: Color(0XFFE3E6FE),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image.asset(
              //   "assets/logo/logo_ssp.png",
              //   // fit: BoxFit.contain,
              //   height: 30,
              //   width: 60,
              // ),
              Text(
                (profileCode == '' || profileCode == null)
                    ? 'กรุณาเข้าสู่ระบบเพื่อใช้งาน'
                    : ((profilePhone == '' || profilePhone == null) &&
                            profileCode != null)
                        ? 'กรุณาเพิ่มหมายเลขโทรศัพท์'
                        : (verifyPhonePage == 'false' && profileCode != '')
                            ? 'กรุณายืนยันเบอร์โทรศัพท์'
                            : 'ไม่มีรายการ',

                // (profilePhone == '' || profilePhone == null)
                //     ? 'กรุณาเพิ่มหมายเลขโทรศัพท์'
                //     : (verifyPhonePage == 'false' && profileCode != '')
                //         ? 'กรุณายืนยันเบอร์โทรศัพท์'
                //         : (profileCode == '' || profileCode == null)
                //             ? 'กรุณาเข้าสู่ระบบเพื่อใช้งาน'
                //             : 'ไม่มีรายการ',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 11,
                  color: Color(0XFF707070),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _readUser() async {
    try {
      final result = await get(server + 'users/me');
      print('Result: $result');
      // print(result['id']);
      if (result != null) {
        _userId = result['id'];
        _username = result['name'];
        print('------userId--------${_userId}');
        print('------username--------${_username}');
      } else {
        print('No result from API');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  _read() async {
    setState(() {
      loadingSuccess = false;
    });
    profileImageUrl = (await storage.read(key: 'profileImageUrl')) ?? "";
    profilePhone = (await storage.read(key: 'profilePhone')) ?? "";
    profileFirstName = await storage.read(key: 'profileFirstName');
    profileLastName = await storage.read(key: 'profileLastName');
    referenceShopCode = (await storage.read(key: 'referenceShopCode')) ?? "";
    referenceShopName = (await storage.read(key: 'referenceShopName')) ?? "";

    //read profile
    profileCode = (await storage.read(key: 'profileCode10')) ?? "";
    // if (profileCode != '' && profileCode != null)

    if (profilePhone != "") {
      _getUserData();
    }
    _readOrder();
    _readAddress();
    _getCredit();
    _readCoupon();
    _readWaiteReview();
    Timer(
      Duration(seconds: 1),
      () => {
        setState(
          () {
            loadingSuccess = true;
          },
        ),
      },
    );
  }

  _readAddress() {
    _futureDeliveryAddress = get('${server}shipping-addresses');
    _futureDeliveryAddress?.then((value) => {});
  }

  changeDefault(param, isSelect) async {
    if (!isSelect) {
      await put('${server}shipping-addresses/' + param, {
        "main": true,
      });
      setState(() {
        _readAddress();
      });
    }
  }
}
