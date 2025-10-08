import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_mart_v3/menu.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/widget/text_field.dart';

DateTime now = new DateTime.now();
void main() {
  // Intl.defaultLocale = 'th';
}

class VerifyPhonePage extends StatefulWidget {
  VerifyPhonePage({Key? key, this.title , this.sendOtp}) : super(key: key);
  final String? title;
  bool? sendOtp;
  @override
  _VerifyPhonePageState createState() => _VerifyPhonePageState();
}

class _VerifyPhonePageState extends State<VerifyPhonePage> {
  final storage = new FlutterSecureStorage();
  late int num;
  late int countDownNumber;
  bool buttonIsActive = false;
  late bool sendOTP;
  final verification_code = TextEditingController();
  bool showVisibility = false;
  bool statusVisibility = true;

  @override
  void initState() {
    setState(() {
      sendOTP = (widget.sendOtp) ?? true;
    });
    if (sendOTP) {
      _reSendOTP();
    }
    
    super.initState();
    
  }

  @override
  void dispose() {
    verification_code.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBackground();
  }

  _buildBackground() {
    return Container(
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage("assets/bg_login.png"),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: _buildScaffold(),
    );
  }

  _buildScaffold() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg_login.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.only(
                  top: 70,
                  left: 15,
                  right: 15,
                  // bottom: 20 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  Center(
                    child: Image.asset(
                      "assets/logo/logo_ssp.png",
                      // fit: BoxFit.contain,
                      // height: 150,
                      width: 200,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Card(
                  //   margin: EdgeInsets.only(top: 20),
                  //   color: Colors.white,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(19.0),
                  //   ),
                  //   elevation: 10,
                  //   child: 
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          color: Colors.white.withOpacity(0.63),
                          // border: Border.all(
                          //   // width: 1,
                          //   // color: Theme.of(context).accentColor,
                          // ),
                        ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              'ยืนยัน OTP',
                              style: TextStyle(
                                  fontSize: 27,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0XFF0B24FB)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            'กรุณาตรวจสอบรหัส OTP ที่ได้รับทาง SMS ของเบอร์โทรศัพท์ที่ลงทะเบียน',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                // fontWeight: FontWeight.bold,
                                color: Color(0xFF707070)),
                          ),
                          Text(
                            '** หากไม่ได้รับรหัส OTP ทาง SMS กรุณากดขอรหัส OTP อีกครั้ง **',
                            style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Kanit',
                                // fontWeight: FontWeight.bold,
                                color: Color(0xFFDF0B24)),
                          ),
                          SizedBox(height: 15.0),
                          textFieldCentral(
                            verification_code,
                            null,
                            'กรุณากรอกรหัส OTP ที่ได้รับ',
                            'กรุณากรอกรหัส OTP ที่ได้รับ',
                            true,
                            false,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                TextButton(
                                  child: Text(
                                      buttonIsActive == false
                                          ? 'ขอรหัส OTP อีกครั้ง'
                                          : 'ขอรหัสใหม่ได้ในอีก ${countDownNumber.toString()} วินาที',
                                      style: TextStyle(fontSize: 14)),
                                  style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            buttonIsActive == false
                                                ? Colors.black
                                                : Colors.grey),
                                  ),
                                  onPressed: () {
                                    // _reSendOTP();
                                    buttonIsActive == false
                                        ? _countDown()
                                        : null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    if (verification_code.text == null || verification_code.text == '') { 
                                    } else {
                                      _sendOTP();
                                    }
                                  },
                                  child: Text(
                                    "ยืนยัน OTP",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFDF0B24),
                                    // shadowColor: Color(0xFFDF0B24),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          30), // <-- Radius
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  // ),
                ],
              ),
            )),
      ),
    );
  }

  _buildDialog(String param) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(
          param,
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
                color: Color(0xFF000070),
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  _reSendOTP() async {
    get('${server}users/verify/otp/resend');
    // a.then((value) => {
      
    // });
   
  }

  _countDown() {
    _reSendOTP();
    this.num = 60;
    this.countDownNumber = 60;
    // Timer timer = new Timer(new Duration(seconds: 1), () {
    // });
    Timer.periodic(new Duration(seconds: 1), (timer) {
      if (this.countDownNumber >= 1) {
        this.buttonIsActive = true;
        this.countDownNumber = this.num--;
      } else if (this.countDownNumber <= 0) {
        this.buttonIsActive = false;
        timer.cancel();
        // clearInterval(aa);
      }
      setState(() {
        this.countDownNumber = this.countDownNumber;
      });
    });
  }

  Future<dynamic> _sendOTP() async {
    final result = await postObjectData(server + 'users/verify/otp', {
      // 'username': txtEmail.text,
      'verification_code': verification_code.text,
    });

    // showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (BuildContext context) {
    //       return WillPopScope(
    //         onWillPop: () {
    //           return Future.value(false);
    //         },
    //         child: CupertinoAlertDialog(
    //           title: new Text(
    //             'ยืนยันเบอร์โทรศัพท์เรียบร้อยแล้ว',
    //             style: TextStyle(
    //               fontSize: 16,
    //               fontFamily: 'Kanit',
    //               color: Colors.black,
    //               fontWeight: FontWeight.normal,
    //             ),
    //           ),
    //           content: Text(" "),
    //           actions: [
    //             CupertinoDialogAction(
    //               isDefaultAction: true,
    //               child: new Text(
    //                 "ตกลง",
    //                 style: TextStyle(
    //                   fontSize: 13,
    //                   fontFamily: 'Kanit',
    //                   color: Color(0xFFFF7514),
    //                   fontWeight: FontWeight.normal,
    //                 ),
    //               ),
    //               onPressed: () {
    //                 Navigator.push(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (_) => LoginCentralPage(),
    //                   ),
    //                 );
    //               },
    //             ),
    //           ],
    //         ),
    //       );
    //     });

    if (result['phone_verified'] == true) {
      await new FlutterSecureStorage()
            .write(key: 'phoneVerified', value: result['phone_verified'].toString());
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
                  'ยืนยันเบอร์โทรศัพท์เรียบร้อยแล้ว',
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MenuCentralPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          });
    } else {
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
                  result.message,
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
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          });
    }
  }
}
