import 'dart:convert';
import 'dart:math';

// import 'package:cool_alert/cool_alert.dart' as cool_alert;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_mart_v3/delete_user.dart';
import 'package:mobile_mart_v3/delivery_address.dart';
import 'package:mobile_mart_v3/my_credit_card.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/user_profile_form.dart';
import 'package:mobile_mart_v3/widget/header.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingMain extends StatefulWidget {
  SettingMain({Key? key, this.code, this.title, this.callback})
      : super(key: key);

  final String? code;
  final String? title;
  final Function? callback;

  @override
  _SettingMain createState() => _SettingMain();
}

final storage = new FlutterSecureStorage();

class _SettingMain extends State<SettingMain> {
  Future<dynamic>? _futureModel;
  int _selectedDay = 0;
  int _selectedMonth = 0;
  int _selectedYear = 0;
  int year = 0;
  int month = 0;
  int day = 0;
  DateTime selectedDate = DateTime.now();
  TextEditingController txtDate = TextEditingController();
  TextEditingController? txtName;
  TextEditingController? txtEmail;
  TextEditingController? txtPhone;
  TextEditingController txtBirthday = TextEditingController();
  String? txtAffiliation;
  String? verifyPhonePage;
  String? profileCode;

  ScrollController scrollController = new ScrollController();
  dynamic _futureAffiliationModel = [
    {'code': '1', 'title': 'สมาชิก ศึกษาภัณฑ์ มอลล์.', 'Affiliation': '1'},
    {'code': '2', 'title': 'บุคคลทั่วไป', 'Affiliation': '2'},
  ];
  int selectedIndex = 0;
  @override
  void initState() {
    _getUserData();
    // _futureModel = postDio(comingSoonApi, {'codeShort': widget.code});
    scrollController = ScrollController();
    var now = new DateTime.now();
    setState(() {
      year = now.year;
      month = now.month;
      day = now.day;
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
    });
    super.initState();
  }

  void goBack() async {
    Navigator.pop(context);
  }

  _getUserData() async {
    profileCode = await storage.read(key: 'profileCode10');
    var a = await storage.read(key: 'phoneVerified');
    setState(() {
      verifyPhonePage = a ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerCentral(context, title: 'ตั้งค่า'),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset('assets/images/bg_setting.png'),
            ),
            Container(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  profileCode != null
                      ? Container(
                          padding: EdgeInsets.only(bottom: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 5),
                                child: Text('บัญชีของฉัน',
                                    style: TextStyle(
                                      color: Color(0xFF000000),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 5),
                                child: GestureDetector(
                                  onTap: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UserProfileForm(),
                                      ),
                                    ),
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text('ข้อมูลเกี่ยวกับบัญชี',
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                            )),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Color(0xFF000000),
                                        size: 17,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              verifyPhonePage == 'true'
                                  ? Container(
                                      margin: EdgeInsets.only(bottom: 5),
                                      child: GestureDetector(
                                        onTap: () => {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  DeliveryAddressCentralPage(),
                                            ),
                                          ),
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Text('ที่อยู่ของฉัน',
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  )),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: Color(0xFF000000),
                                              size: 17,
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              verifyPhonePage == 'true'
                                  ? Container(
                                      margin: EdgeInsets.only(bottom: 5),
                                      child: GestureDetector(
                                        onTap: () => {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  MyCreditCardCentralPage(),
                                            ),
                                          ),
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Text(
                                                  'ข้อมูลบัญชีธนาคาร / บัตร',
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  )),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: Color(0xFF000000),
                                              size: 17,
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        )
                      : Container(),
                  // Container(
                  //   padding: EdgeInsets.only(bottom: 28),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Container(
                  //         margin: EdgeInsets.only(bottom: 5),
                  //         child: Text('การตั้งค่า',
                  //             style: TextStyle(
                  //               color: Color(0xFF000000),
                  //               fontSize: 20,
                  //               fontWeight: FontWeight.w500,
                  //             )),
                  //       ),
                  //       Container(
                  //         margin: EdgeInsets.only(bottom: 5),
                  //         child: GestureDetector(
                  //           onTap: () => {
                  //             // Navigator.push(
                  //             //   context,
                  //             //   MaterialPageRoute(
                  //             //     builder: (_) => SettingMain(),
                  //             //   ),
                  //             // ),
                  //           },
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Container(
                  //                 child: Text('ตั้งค่าการแจ้งเตือน',
                  //                     style: TextStyle(
                  //                       color: Color(0xFF000000),
                  //                       fontSize: 18,
                  //                       fontWeight: FontWeight.normal,
                  //                     )),
                  //               ),
                  //               Icon(
                  //                 Icons.arrow_forward_ios_rounded,
                  //                 color: Color(0xFF000000),
                  //                 size: 17,
                  //               )
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       Container(
                  //         margin: EdgeInsets.only(bottom: 5),
                  //         child: GestureDetector(
                  //           onTap: () => {
                  //             // Navigator.push(
                  //             //   context,
                  //             //   MaterialPageRoute(
                  //             //     builder: (_) => SettingMain(),
                  //             //   ),
                  //             // ),
                  //           },
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Container(
                  //                 child: Text('ตั้งค่าภาษา',
                  //                     style: TextStyle(
                  //                       color: Color(0xFF000000),
                  //                       fontSize: 18,
                  //                       fontWeight: FontWeight.normal,
                  //                     )),
                  //               ),
                  //               Icon(
                  //                 Icons.arrow_forward_ios_rounded,
                  //                 color: Color(0xFF000000),
                  //                 size: 17,
                  //               )
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       Container(
                  //         margin: EdgeInsets.only(bottom: 5),
                  //         child: GestureDetector(
                  //           onTap: () => {
                  //             // Navigator.push(
                  //             //   context,
                  //             //   MaterialPageRoute(
                  //             //     builder: (_) => SettingMain(),
                  //             //   ),
                  //             // ),
                  //           },
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Container(
                  //                 child: Text('ตั้งค่าความเป็นส่วนตัว',
                  //                     style: TextStyle(
                  //                       color: Color(0xFF000000),
                  //                       fontSize: 18,
                  //                       fontWeight: FontWeight.normal,
                  //                     )),
                  //               ),
                  //               Icon(
                  //                 Icons.arrow_forward_ios_rounded,
                  //                 color: Color(0xFF000000),
                  //                 size: 17,
                  //               )
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Container(
                    padding: EdgeInsets.only(bottom: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Text('ช่วยเหลือ',
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                        // Container(
                        //   margin: EdgeInsets.only(bottom: 5),
                        //   child: GestureDetector(
                        //     onTap: () => {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (_) => CommercialOrganizationPage(),
                        //         ),
                        //       ),
                        //     },
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Container(
                        //           child: Text('เกี่ยวกับ',
                        //               style: TextStyle(
                        //                 color: Color(0xFF000000),
                        //                 fontSize: 18,
                        //                 fontWeight: FontWeight.normal,
                        //               )),
                        //         ),
                        //         Icon(
                        //           Icons.arrow_forward_ios_rounded,
                        //           color: Color(0xFF000000),
                        //           size: 17,
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // Container(
                        //   margin: EdgeInsets.only(bottom: 5),
                        //   child: GestureDetector(
                        //     onTap: () => {
                        //       // Navigator.push(
                        //       //   context,
                        //       //   MaterialPageRoute(
                        //       //     builder: (_) => SettingMain(),
                        //       //   ),
                        //       // ),
                        //     },
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Container(
                        //           child: Text('เกี่ยวกับ',
                        //               style: TextStyle(
                        //                 color: Color(0xFF000000),
                        //                 fontSize: 18,
                        //                 fontWeight: FontWeight.normal,
                        //               )),
                        //         ),
                        //         Icon(
                        //           Icons.arrow_forward_ios_rounded,
                        //           color: Color(0xFF000000),
                        //           size: 17,
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: GestureDetector(
                            onTap: () => {
                              launchUrl(
                                Uri.parse('https://policy.we-builds.com/ssp/'),
                              )
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => SettingMain(),
                              //   ),
                              // ),
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text('นโยบายความเป็นส่วนตัว',
                                      style: TextStyle(
                                        color: Color(0xFF000000),
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      )),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF000000),
                                  size: 17,
                                )
                              ],
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: GestureDetector(
                            onTap: () => {
                              // launchUrl(
                              //   Uri.parse(
                              //       'https://suksapanmall.com/#/accout-deletion'),
                              // )
                              _dialogConfirm(),
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text('การยกเลิกการปิดบัญชี',
                                      style: TextStyle(
                                        color: Color(0xFF000000),
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      )),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF000000),
                                  size: 17,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'v.$versionName',
                    ),
                  ),

                  profileCode != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MaterialButton(
                              height: 33,
                              // minWidth: 168,
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(25)),
                              onPressed: () {
                                logout(context);
                                // launchInWebViewWithJavaScript(model['fileUrl']);
                              },
                              child: Text(
                                "ออกจากระบบ",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF0B24FB),
                                  fontWeight: FontWeight.w400,
                                  // letterSpacing: 0.1
                                ),
                              ),
                              color: Color(0xFFE3E6FE),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _dialogConfirm() {
  //   return cool_alert.CoolAlert.show(
  //     context: context,
  //     type: cool_alert.CoolAlertType.confirm,
  //     animType: cool_alert.CoolAlertAnimType.scale,
  //     // barrierDismissible: false,
  //     title: 'การยกเลิกบัญชี',
  //     text: 'คุณต้องการยกเลิกบัญชีใช่หรือไม่',
  //     loopAnimation: false,
  //     cancelBtnText: 'ย้อนกลับ',
  //     onCancelBtnTap: () => {
  //       Navigator.pop(context),
  //     },
  //     confirmBtnColor: Color(0xFF1CBC51),
  //     confirmBtnText: 'ยืนยัน',
  //     onConfirmBtnTap: () => {
  //       // Navigator.pop(context),
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => DeleteUser(),
  //         ),
  //       ),
  //     },
  //   );
  // }
  _dialogConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'การยกเลิกบัญชี',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'คุณต้องการยกเลิกบัญชีใช่หรือไม่',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            child: Text(
              'ย้อนกลับ',
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'ยืนยัน',
              style: TextStyle(color: Color(0xFF1CBC51)),
            ),
            onPressed: () {
              Navigator.pop(context); // ปิด dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeleteUser(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
