import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_mart_v3/game_selection_page.dart';
import 'package:mobile_mart_v3/math_game/setting_main.dart';
import 'package:mobile_mart_v3/phonics_game.dart';
import 'package:mobile_mart_v3/product_favorite.dart';
import 'package:mobile_mart_v3/read_book_list.dart';
import 'package:mobile_mart_v3/register.dart';
import 'package:mobile_mart_v3/review_success.dart';
import 'package:mobile_mart_v3/to_pay.dart';
import 'package:mobile_mart_v3/to_rate.dart';
import 'package:mobile_mart_v3/to_receive.dart';
import 'package:mobile_mart_v3/to_ship.dart';
import 'package:mobile_mart_v3/to_success.dart';
import 'package:mobile_mart_v3/user_profile_form.dart';
import 'package:mobile_mart_v3/verify_phone.dart';
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
  late Future<dynamic> _futureDeliveryAddress;

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

  late Future<dynamic> _countRedeemAll;
  late Future<dynamic> _countRedeem;
  late Future<dynamic> futureModel;
  late Future<dynamic> _futureManageShop;
  late Future<dynamic> _futureOrders;
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
  late String _password;
  late String _facebookID;
  late String _appleID;
  late String _googleID;
  late String _lineID;
  late String _email;
  late String _imageUrl;
  late String _category;
  late String _prefixName;
  late String _firstName;
  late String _lastName;

  final txtUsername = TextEditingController();
  final txtPassword = TextEditingController();
  bool loadingSuccess = false;

  List<dynamic> paid = [];
  List<dynamic> ship = [];
  List<dynamic> delivery = [];
  List<dynamic> success = [];
  int review = 0;

  @override
  void initState() {
    profileFirstName = '';
    profileLastName = '';
    _read();
    _readUser();

    super.initState();
  }

  void _onRefresh() async {
    _read();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  _getUserData() async {
    var a = await storage.read(key: 'phoneVerified');
    setState(() {
      verifyPhonePage = a ?? "";
    });
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
      _futureOrders = get('${server}orders').then((value) => {
            [...value].forEach((e) => {
                  if (e['order_details']['data'].length > 0)
                    {
                      if (e['status'] == 0 || e['status'] == 1)
                        {paid.add(e)}
                      else if (e['status'] == 10 || e['status'] == 11)
                        {ship.add(e)}
                      else if (e['status'] == 20)
                        {delivery.add(e)}
                      else if (e['status'] == 30)
                        {success.add(e)}
                      // else if (e['status'] == 40)
                      //   {review.add(e)}
                    }
                }),
          });
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
          image: DecorationImage(
            image: AssetImage("assets/bg_profile.png"),
            fit: BoxFit.cover,
          ),
        ),
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
    return Stack(
      children: [
        (profileCode == '' || profileCode == null)
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
                  color: Color(0XFF0B24FB),
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
                child: (profileImageUrl != null)
                    ? loadingImageNetwork(
                        profileImageUrl,
                        fit: BoxFit.cover,
                        isProfile: true,
                      )
                    : Container(
                        height: 70,
                        width: 70,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0XFF0B24FB),
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
                  fontSize: 15,
                  color: Color(0XFF0B24FB),
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
                      color:
                          (profilePhone == null || verifyPhonePage == 'false')
                              ? Color(0xFFDF0B24)
                              : Color(0XFF0B24FB),
                    ),
                  ),
                  child: Text(
                    profilePhone == null
                        ? 'ยังไม่ได้เพิ่มเบอร์โทรศัพท์'
                        : verifyPhonePage == 'false'
                            ? 'ยังไม่ได้ยืนยันเบอร์โทรศัพท์'
                            : 'สมาชิก ศึกษาภัณฑ์ มอลล์.',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15,
                      color:
                          (profilePhone == null || verifyPhonePage == 'false')
                              ? Color(0xFFDF0B24)
                              : Color(0XFF0B24FB),
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
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(15),
      physics: ClampingScrollPhysics(),
      children: <Widget>[
        Row(
          children: [
            Container(
              // width: 10,
              child: Icon(
                Icons.assignment_outlined,
                color: Color(0xFFDF0B24),
              ),
            ),
            SizedBox(width: 5),
            Text(
              'รายการสั่งซื้อของฉัน',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textScaleFactor: ScaleSize.textScaleFactor(context),
            ),
          ],
        ),

        SizedBox(height: 10),
        _orderList(),
        SizedBox(height: 10),
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
        SizedBox(height: 10),
        _deliveryAddress(),

        SizedBox(height: 10),
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
                : {}),
        SizedBox(height: 10),
        _coupon(),
        SizedBox(
          height: 10,
        ),
        _rowTitle(
          Icons.games,
          'เกม',
          callback: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => GameSelectionPage(),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        _rowTitle(
          Icons.book,
          'อ่านนิยาย',
          callback: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReadBookList(),
              //   builder: (context) => PdfViewerScreen(
              //       pdfUrl:
              //           'http://vet.we-builds.com/vet-document/images/knowledge/knowledge_212438263.pdf'),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        _rowTitle(
          Icons.headset_mic,
          'ติดต่อ',
          callback: () {
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
          },
        ),
        SizedBox(height: 10),
        _rowTitle(Icons.reviews_outlined, 'สินค้าที่รีวิวแล้ว',
            callback: () => verifyPhonePage == 'true'
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ReviewSuccessPage(),
                    ),
                  )
                : {}),
        SizedBox(height: 10),
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
        SizedBox(height: 10),
        _rowTitle(Icons.airplay, 'Suksapan Teaching',
            callback: () => launchInWebViewWithJavaScript(
                'https://teaching.suksapanpanit.com/th')),
        SizedBox(height: 10),
        _rowTitle2(
            Icons.shopping_bag_outlined, 'ใบสั่งซื้อ', 'ร้านศึกษาภัณฑ์พาณิชย์',
            callback: () => launchInWebViewWithJavaScript(
                'https://crm.suksapanpanit.com/th/filesharing/viewer/ba25414e0ba3486b8d1b48940ec2e81a')),

        // SizedBox(height: 10),
        // _rowTitle('ตัวเลือกชำระเงิน',
        //     callback: () => verifyPhonePage == 'true'
        //         ? Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (BuildContext context) =>
        //                   MyCreditCardCentralPage(),
        //             ),
        //           )
        //         : {}),
        // SizedBox(height: 10),
        // _paymentOptions(),
        // SizedBox(height: 10),
        // InkWell(
        //   onTap: () {
        //     // toastFail(context);
        //     logout(context);
        //   },
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       Icon(
        //         Icons.power_settings_new,
        //         color: themeChange.darkTheme ? Colors.white : Colors.red,
        //       ),
        //       Text(
        //         " ออกจากระบบ",
        //         style: new TextStyle(
        //           fontSize: 12.0,
        //           color: themeChange.darkTheme ? Colors.white : Colors.red,
        //           fontWeight: FontWeight.normal,
        //           fontFamily: 'Kanit',
        //         ),
        //       ),
        //     ],
        //   ),
        // )
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
            if (profileCode == null || profileCode == '')
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginCentralPage(),
                  ),
                )
              }
            else if (profilePhone == null || profilePhone == '')
              {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          UserProfileForm(mode: "addPhone"),
                    )).then((value) => {_onRefresh()}),
              }
            else if (verifyPhonePage == 'false')
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => VerifyPhonePage(),
                  ),
                )
              }
            else
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ToPayCentralPage(),
                  ),
                ).then((value) => _onRefresh())
              }
          },
        ),
        _boxOrderList(
          'กำลัง\nจัดเตรียม',
          'assets/logo/delivery.png',
          ship.length > 0 ? ship.length : null,
          callback: () => {
            if (profileCode == null || profileCode == '')
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginCentralPage(),
                  ),
                )
              }
            else if (profilePhone == null || profilePhone == '')
              {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          UserProfileForm(mode: "addPhone"),
                    )).then((value) => {_onRefresh()}),
              }
            else if (verifyPhonePage == 'false')
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => VerifyPhonePage(),
                  ),
                )
              }
            else
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ToShipCentralPage(),
                  ),
                ).then((value) => _onRefresh())
              }
          },
        ),
        _boxOrderList(
          'ระหว่าง\nขนส่ง',
          'assets/logo/car.png',
          delivery.length > 0 ? delivery.length : null,
          callback: () => {
            if (profileCode == null || profileCode == '')
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginCentralPage(),
                  ),
                )
              }
            else if (profilePhone == null || profilePhone == '')
              {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          UserProfileForm(mode: "addPhone"),
                    )).then((value) => {_onRefresh()}),
              }
            else if (verifyPhonePage == 'false')
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => VerifyPhonePage(),
                  ),
                )
              }
            else
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ToReceiveCentralPage(),
                  ),
                ).then((value) => _onRefresh())
              }
          },
        ),
        InkWell(
          onTap: () => {
            if (profileCode == null || profileCode == '')
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginCentralPage(),
                  ),
                )
              }
            else if (profilePhone == null || profilePhone == '')
              {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          UserProfileForm(mode: "addPhone"),
                    )).then((value) => {_onRefresh()}),
              }
            else if (verifyPhonePage == 'false')
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => VerifyPhonePage(),
                  ),
                )
              }
            else
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ToSuccessPage(),
                  ),
                ).then((value) => _onRefresh())
              }
          },
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
                        color: Color(0xFFDF0B24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.check,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                  (profileCode != null &&
                          success.length != null &&
                          success.length > 0 &&
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
                              success.length > 99
                                  ? '99+'
                                  : success.length.toString(),
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: success.length.toString().length <= 1
                                    ? 13
                                    : success.length.toString().length == 2
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
                  'เสร็จสิ้น',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        _boxOrderList(
          'ที่ต้องรีวิว',
          'assets/logo/paper.png',
          review > 0 ? review : null,
          callback: () => {
            if (profileCode == null || profileCode == '')
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginCentralPage(),
                  ),
                )
              }
            else if (profilePhone == null || profilePhone == '')
              {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          UserProfileForm(mode: "addPhone"),
                    )).then((value) => {_onRefresh()}),
              }
            else if (verifyPhonePage == 'false')
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => VerifyPhonePage(),
                  ),
                )
              }
            else
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ToRateCentralPage(),
                  ),
                ).then((value) => _onRefresh())
              }
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
                    color: Color(0xFFDF0B24),
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

  _rowTitle(icon, title, {Function? callback}) {
    return InkWell(
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
                            color: Color(0xFFDF0B24),
                            size: (ScaleSize.textScaleFactor(context) +
                                    (MediaQuery.of(context).size.aspectRatio)) +
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
                  ),
                  textScaleFactor: ScaleSize.textScaleFactor(context),
                ),
              ],
            ),
            // Container(
            //   alignment: Alignment.center,
            //   width: (ScaleSize.textScaleFactor(context) +
            //           (MediaQuery.of(context).size.aspectRatio)) +
            //       20,
            //   height: (ScaleSize.textScaleFactor(context) +
            //           (MediaQuery.of(context).size.aspectRatio)) +
            //       20,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(9),
            //     color: Color(0XFFF7F7F7),
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(5.0),
            //     child: Image.asset(
            //       'assets/logo/right_arrow.png',
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  _rowTitle2(icon, title, title2, {Function? callback}) {
    return InkWell(
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
                            color: Color(0xFFDF0B24),
                            size: (ScaleSize.textScaleFactor(context) +
                                    (MediaQuery.of(context).size.aspectRatio)) +
                                27),
                      )
                    : SizedBox(width: 0),
                SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textScaleFactor: ScaleSize.textScaleFactor(context),
                    ),
                    Text(
                      title2,
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textScaleFactor: ScaleSize.textScaleFactor(context),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _coupon() {
    if ((profileCode == null ||
        profileCode == '' ||
        verifyPhonePage == 'false')) {
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
    } else {
      return FutureBuilder<dynamic>(
        future: _futureCoupon,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              var row = <Widget>[];
              for (var d in snapshot.data) {
                row.add(_boxCoupon(
                    'ส่วนลด ' + moneyFormat(d['discount'].toString()) + ' บาท',
                    'เมื่อซื้อครบ ' +
                        moneyFormat(d['minimum_order_total'].toString()) +
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
            } else
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
        },
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
    return FutureBuilder<dynamic>(
      future: _futureDeliveryAddress,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            var row = <Widget>[];
            // var isSelect = true;
            for (var d in snapshot.data) {
              row.add(
                _boxDeliveryAndPayment(
                  d['name'],
                  d['address'],
                  // d['building'],
                  d['tambon']['data']['name_th'],
                  d['amphoe']['data']['name_th'],
                  d['province']['data']['name_th'],
                  d['zip'],
                  isSelect: d['main'],
                  callback: () => changeDefault(d['id'], d['main']),
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
                  builder: (BuildContext context) =>
                      DeliveryAddressCentralPage(),
                ),
              ),
            );
          }
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
      },
    );
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
    return InkWell(
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
              Image.asset(
                "assets/logo/logo_ssp.png",
                // fit: BoxFit.contain,
                height: 30,
                width: 60,
              ),
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
    _futureDeliveryAddress.then((value) => {});
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
