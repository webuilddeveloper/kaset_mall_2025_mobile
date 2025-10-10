import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_mart_v3/menu.dart';
import 'package:mobile_mart_v3/register_shop.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';
import 'package:mobile_mart_v3/verify_phone.dart';
import 'package:mobile_mart_v3/widget/header.dart';
import 'package:mobile_mart_v3/widget/input.dart';

import 'home.dart';

class RegisterCentralPage extends StatefulWidget {
  RegisterCentralPage({Key? key}) : super(key: key);

  @override
  _RegisterCentralPageState createState() => _RegisterCentralPageState();
}

class _RegisterCentralPageState extends State<RegisterCentralPage> {
  final storage = new FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();
  final txtPassword = TextEditingController();
  final txtConPassword = TextEditingController();
  final txtFirstName = TextEditingController();
  final txtLastName = TextEditingController();
  final txtPhone = TextEditingController();
  final txtEmail = TextEditingController();

  dynamic _futureSexModel = [
    {'code': 0, 'title': 'ชาย', 'icon': Icons.male},
    {'code': 1, 'title': 'หญิง', 'icon': Icons.female},
    {'code': 2, 'title': 'เพศทางเลือก', 'icon': Icons.transgender},
  ];

  final _futureOccupationModel = [
    {'code': 0, 'title': 'กรุณาเลือกอาชีพ'},
    {'code': 10, 'title': 'ครู'},
    {'code': 20, 'title': 'นักเรียน'},
    {'code': 30, 'title': 'ผู้ปกครอง'},
    {'code': 40, 'title': 'เจ้าหน้าที่รัฐ'},
    {'code': 50, 'title': 'โรงเรียน/หน่วยงานรัฐ'},
    {'code': 60, 'title': 'ร้านค้า/บริษัท'},
    {'code': 70, 'title': 'อื่นๆ'},
  ];

  late int selectedSexIndex = 0;
  late int selectOccupation = 0;
  bool showConfirmPassword = true;
  bool showPassword = true;

  String _categorySelected = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtPhone.dispose();
    txtEmail.dispose();
    txtPassword.dispose();
    txtConPassword.dispose();
    txtFirstName.dispose();
    txtLastName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: headerCentral(context, title: 'สมัครสมาชิก'),
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              15.0,
              15,
              15,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            children: [
              Text(
                'ข้อมูลส่วนตัว',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextRegisterWidget(
                controller: txtFirstName,
                title: 'ชื่อสมาชิก',
                decoration: DecorationRegister.register(
                  context,
                  hintText: 'กรุณากรอกชื่อสมาชิก',
                ),
                validator: (value) => ValidateRegister.firstName(value),
              ),
              TextRegisterWidget(
                controller: txtLastName,
                title: 'นามสกุลสมาชิก',
                decoration: DecorationRegister.register(
                  context,
                  hintText: 'กรุณากรอกนามสกุลสมาชิก',
                ),
                validator: (value) => ValidateRegister.lastName(value),
              ),
              TextRegisterWidget(
                controller: txtPhone,
                title: 'หมายเลขโทรศัพท์',
                decoration: DecorationRegister.register(
                  context,
                  hintText: '0__-___-____',
                ),
                inputFormatters: InputFormatTemple.phone(),
                validator: (value) => ValidateRegister.phone(value),
              ),
              Container(
                padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 15.0, bottom: 5),
                        child: Text(
                          'อาชีพ',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF000000),
                            // fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          fillColor: Color(0xFFFFFFFF),
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF0B5C9E), width: 1.0),
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFE4E4E4),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(7.0),
                            gapPadding: 1,
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFE4E4E4),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(7.0),
                            gapPadding: 1,
                          ),
                          hintText: 'กรุณาใส่ชื่อสมาชิก',
                          contentPadding: const EdgeInsets.all(10.0),
                        ),
                        validator: (value) =>
                            ValidateRegister.occupation(value as int? ?? 0),
                        // validator: (value) =>
                        //     value == 0 ? 'กรุณาเลือกอาชีพ' : 0,
                        hint: Text(
                          'อาชีพ',
                          style: TextStyle(
                            fontSize: 15.00,
                            fontFamily: 'Kanit',
                          ),
                        ),
                        value: selectOccupation,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          new TextEditingController().clear();
                        },
                        onChanged: (Object? newValue) {
                          setState(() {
                            selectOccupation = newValue as int;
                          });
                        },
                        items: _futureOccupationModel.map((item) {
                          return DropdownMenuItem(
                            child: new Text(
                              item['title'].toString(),
                              style: TextStyle(
                                fontSize: 15.00,
                                fontFamily: 'Kanit',
                                color: Color(0xFF1B6CA8),
                              ),
                            ),
                            value: item['code'],
                          );
                        }).toList(),
                      )
                    ]),
              ),

              Container(
                padding: EdgeInsets.only(left: 15.0, bottom: 5),
                child: Text(
                  'เพศ',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                // width: 50,
                height: 33,
                margin: EdgeInsets.only(
                  top: 5.0,
                  bottom: 30,
                ),
                padding: EdgeInsets.only(left: 2.0, bottom: 5),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _futureSexModel.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        // FocusScope.of(context).unfocus();
                        // widget.onChange(snapshot.data[index]['code']);
                        setState(() {
                          selectedSexIndex = index;
                          // txtSex = _futureSexModel[index]['code'];
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(
                          5.0,
                        ),
                        margin: EdgeInsets.only(
                          right: 12.0,
                        ),
                        decoration: new BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: index == selectedSexIndex
                                  ? Color(0xFFFBE3E6).withOpacity(0.49)
                                  : Color(0xFFFFFFFF),
                              spreadRadius: 0,
                            ),
                          ],
                          borderRadius: new BorderRadius.circular(10.0),
                          border: Border.all(
                            color: index == selectedSexIndex
                                ? Color(0xFFFBE3E6).withOpacity(0.49)
                                : Color(0xFF000000).withOpacity(0.50),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                right: 5.0,
                              ),
                              child: Icon(
                                _futureSexModel[index]['icon'],
                                color: index == selectedSexIndex
                                    ? Color(0xFFDF0B24)
                                    : Color(0xFF000000).withOpacity(0.5),
                                size: 15,
                              ),
                              // child: index == selectedSexIndex
                              //     ? Icon(
                              //         Icons.(_futureSexModel[index]['icon']),
                              //         // Icons.check_circle,
                              //         color: Color(0xFFDF0B24),
                              //         size: 15,
                              //       )
                              //     : SizedBox(
                              //         height: 0,
                              //       ),
                            ),
                            Text(
                              _futureSexModel[index]['title'],
                              style: TextStyle(
                                color: index == selectedSexIndex
                                    ? Color(0xFFDF0B24)
                                    : Color(0xFF000000).withOpacity(0.5),
                                fontSize: 13.0,
                                fontWeight: index == selectedSexIndex
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 25),
              Text(
                'การเข้าใช้',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextRegisterWidget(
                controller: txtEmail,
                title: 'อีเมล',
                decoration: DecorationRegister.register(
                  context,
                  hintText: 'กรุณากรอกอีเมล',
                ),
                validator: (value) => ValidateRegister.email(value),
              ),
              TextRegisterWidget(
                controller: txtPassword,
                title: 'รหัสผ่าน',
                subTitle:
                    'รหัสผ่านต้องเป็นตัวอักษร a-z, A-Z และ 0-9 ความยาวขั้นต่ำ 8 ตัวอักษร',
                decoration: DecorationRegister.password(
                  context,
                  hintText: 'กรุณากรอกรหัสผ่าน',
                  suffixTap: () => setState(() {
                    showPassword = !showPassword;
                  }),
                  visibility: showPassword,
                ),
                obscureText: showPassword,
                inputFormatters: InputFormatTemple.password(),
                validator: (value) => ValidateRegister.password(value),
              ),
              TextRegisterWidget(
                controller: txtConPassword,
                title: 'ยืนยันรหัสผ่าน',
                subTitle:
                    'รหัสผ่านต้องเป็นตัวอักษร a-z, A-Z และ 0-9 ความยาวขั้นต่ำ 8 ตัวอักษร',
                decoration: DecorationRegister.password(
                  context,
                  hintText: 'กรุณายืนยันรหัสผ่าน',
                  suffixTap: () => setState(() {
                    showConfirmPassword = !showConfirmPassword;
                  }),
                  visibility: showConfirmPassword,
                ),
                obscureText: showConfirmPassword,
                inputFormatters: InputFormatTemple.password(),
                validator: (value) =>
                    ValidateRegister.confirmPassword(value, txtPassword.text),
              ),
              SizedBox(height: 25),
              // Text(
              //   'สังกัด',
              //   style: TextStyle(
              //     fontSize: 15,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
              // SizedBox(height: 5),
              // Row(
              //   children: [
              //     _buildCategory('สมาชิก ศึกษาภัณฑ์ มอลล์'),
              //     SizedBox(width: 10),
              //     _buildCategory('บุคคลทั่วไป'),
              //   ],
              // ),
              // SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  // final form = _formKey.currentState;
                  // if (form!.validate()) {
                  //   submitRegister();
                  // }

                  _buildDialogSuccess();
                },
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFDF0B24),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    'สมัครสมาชิก',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildCategory(String title) {
    bool value = _categorySelected == title;
    Color bg = value ? Color(0xFFFBE3E6) : Colors.white;
    Color br = value ? Color(0xFFFBE3E6) : Color(0xFFE4E4E4);
    Color txt = value ? Color(0xFFDF0B24) : Colors.black;
    return GestureDetector(
      onTap: () {
        setState(() {
          _categorySelected = title;
        });
      },
      child: Container(
        height: 33,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(
            width: 1,
            color: br,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (value)
              Icon(
                Icons.check_circle,
                color: Color(0xFFDF0B24),
                size: 15,
              ),
            SizedBox(width: 3),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: txt,
                fontWeight: value ? FontWeight.w500 : FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  submitRegister() async {
    final result = await postRegister(server + 'register', {
      // 'username': txtEmail.text,
      'password': txtPassword.text,
      'password_confirmation': txtConPassword.text,
      // 'facebookID': "",
      // 'appleID': "",
      // 'googleID': "",
      // 'lineID': "",
      'email': txtEmail.text,
      // 'imageUrl': "",
      'name': txtFirstName.text + " " + txtLastName.text,
      'phone': txtPhone.text,
      'gender': selectedSexIndex + 1,
      'occupation': selectOccupation,

      // 'memberType': _categorySelected
    });

// showDialog(
//           barrierDismissible: false,
//           context: context,
//           builder: (BuildContext context) {
//             return WillPopScope(
//               onWillPop: () {
//                 return Future.value(false);
//               },
//               child: CupertinoAlertDialog(
//                 title: new Text(
//                   'ลงทะเบียนเรียบร้อยแล้ว\nกรุณาเข้าสู่ระบบ\nเพื่อยืนยันเบอร์โทรศัพท์',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontFamily: 'Kanit',
//                     color: Colors.black,
//                     fontWeight: FontWeight.normal,
//                   ),
//                 ),
//                 content: Text(" "),
//                 actions: [
//                   CupertinoDialogAction(
//                     isDefaultAction: true,
//                     child: new Text(
//                       "ตกลง",
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontFamily: 'Kanit',
//                         color: Color(0xFFFF7514),
//                         fontWeight: FontWeight.normal,
//                       ),
//                     ),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => LoginCentralPage(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             );
//           });

    if (result['statusCode'] == 200) {
      final response = await postLogin(server + 'token', {
        'email': txtEmail.text,
        'password': txtPassword.text,
        'device_name': "mobile"
      });
      await new FlutterSecureStorage()
          .write(key: 'token', value: response['token']);

      final result = await get(server + 'users/me');
      await new FlutterSecureStorage().write(
          key: 'phoneVerified', value: result['phone_verified'].toString());
      createStorageApp(
          model: result, category: 'guest', token: response['token']);
      _updateToken(result['id']);
      if (result['phone_verified'] == false) {
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
                  'ลงทะเบียนเรียบร้อยแล้ว\nกรุณายืนยันเบอร์โทรศัพท์',
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
                          builder: (_) => VerifyPhonePage(
                            sendOtp: false,
                          ),
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
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MenuCentralPage()),
                          (route) => false);
                    },
                  ),
                ],
              ),
            );
          },
        );
      }
    } else {
      print('return register >>>>>>>> $result');
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
                  result['message'],
                  // '',
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

  _updateToken(profileCode) async {
    FirebaseMessaging.instance.getToken().then(
      (token) {
        postDio(server_we_build + 'notificationV2/m/updateTokenDevice',
            {"token": token, "profileCode": profileCode});
      },
    );
  }

  _buildDialogSuccess() {
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
              'ลงทะเบียนเรียบร้อยแล้ว\nท่านสนใจเข้าร่วมเป็นร้านค้ากับเราหรือไม่',
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
                      builder: (_) => RegisterShopPage(
                      ),
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
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MenuCentralPage()),
                      (route) => false);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class TextRegisterWidget extends StatelessWidget {
  const TextRegisterWidget({
    Key? key,
    @required this.title,
    @required this.controller,
    this.inputFormatters,
    this.validator,
    this.subTitle = '',
    this.decoration,
    this.obscureText = false,
  }) : super(key: key);

  final String? title;
  final String? subTitle;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final String Function(String)? validator;
  final InputDecoration? decoration;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 14, top: 10, bottom: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (subTitle!.isNotEmpty)
                Text(
                  subTitle!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF707070),
                  ),
                ),
            ],
          ),
        ),
        TextFormField(
          controller: controller,
          inputFormatters: inputFormatters,
          decoration: decoration,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'กรุณากรอกข้อมูล';
            }
            return null;
          },
          obscureText: obscureText,
          cursorColor: Color(0xFF0B24FB),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
