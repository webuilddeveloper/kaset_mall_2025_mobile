import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/forgot_password.dart';
import 'package:kasetmall/menu.dart';
import 'package:kasetmall/register.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/shared/apple.dart';
import 'package:kasetmall/shared/facebook_firebase.dart';
import 'package:kasetmall/shared/google.dart';
import 'package:kasetmall/shared/line.dart';
import 'package:kasetmall/verify_phone.dart';
import 'package:kasetmall/widget/text_field.dart';

DateTime now = new DateTime.now();
void main() {
  // Intl.defaultLocale = 'th';
  runApp(LoginCentralPage());
}

class LoginCentralPage extends StatefulWidget {
  LoginCentralPage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _LoginCentralPageState createState() => _LoginCentralPageState();
}

class _LoginCentralPageState extends State<LoginCentralPage> {
  final storage = new FlutterSecureStorage();

  late String _username;
  late String _password;
  late String _category;

  final txtUsername = TextEditingController();
  final txtPassword = TextEditingController();
  bool showVisibility = false;
  bool statusVisibility = true;

  @override
  void initState() {
    setState(() {
      _username = "";
      _password = "";
      _category = "";
    });
    super.initState();
  }

  @override
  void dispose() {
    txtUsername.dispose();
    txtPassword.dispose();

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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
            decoration: BoxDecoration(
                // image: DecorationImage(
                //   image: AssetImage("assets/bg_login.png"),
                //   fit: BoxFit.cover,
                // ),
                // color: Colors.white
                ),
            child: SafeArea(
              child: Center(
                child: ListView(
                  padding: EdgeInsets.only(
                    top: 70,
                    left: 15,
                    right: 15,
                    bottom: 20 + MediaQuery.of(context).padding.bottom,
                  ),
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/logo.png",
                        // fit: BoxFit.contain,
                        // height: 150,
                        width: 150,
                      ),
                    ),
                    Container(
                      // width: 100,
                      margin: EdgeInsets.only(top: 40),
                      padding: EdgeInsets.all(30),
                      // constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width + 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        // color: Colors.white.withOpacity(0.63),
                        color: Theme.of(context)
                            .primaryColorLight
                            .withOpacity(0.3),
                        // border: Border.all(
                        //   // width: 1,
                        //   // color: Theme.of(context).accentColor,
                        // ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'เข้าสู่ระบบ',
                            style: TextStyle(
                              fontSize: 27,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          labelTextField(
                            'อีเมล',
                            Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 20.00,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          textFieldCentral(
                            txtUsername,
                            null,
                            'อีเมล',
                            'อีเมล',
                            true,
                            false,
                          ),
                          SizedBox(height: 15.0),
                          labelTextField(
                            'รหัสผ่าน',
                            Icon(
                              Icons.lock,
                              color: Colors.black,
                              size: 20.00,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          textFieldCentral(
                            txtPassword,
                            null,
                            'รหัสผ่าน',
                            'รหัสผ่าน',
                            true,
                            true,
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          _buildLoginButton(),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: _rowLongLine(
                              '  หรือท่านอาจจะ  ',
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                // InkWell(
                                //   onTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) =>
                                //             ForgotPasswordCentralPage(),
                                //       ),
                                //     );
                                //   },
                                //   child: Container(
                                //     padding: const EdgeInsets.symmetric(
                                //       horizontal: 15.0,
                                //       vertical: 3,
                                //     ),
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(30.0),
                                //       border: Border.all(
                                //         color: Color(0xFFC0BFBF),
                                //       ),
                                //       color: Colors.white,
                                //     ),
                                //     child: Text(
                                //       "ลืมรหัสผ่าน",
                                //       style: TextStyle(
                                //         fontSize: 15,
                                //         fontFamily: 'Kanit',
                                //         color: Color(0xFFC0BFBF),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            RegisterCentralPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    child: Text(
                                      "สมัครสมาชิก",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Kanit',
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            RegisterCentralPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 13.0,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      "เข้าร่วมเป็นร้านค้า",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Kanit',
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: _rowLongLine(
                        '  เข้าสู่ระบบผ่าน  ',
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          alignment: new FractionalOffset(0.5, 0.5),
                          height: 50.0,
                          width: 50.0,
                          child: new IconButton(
                            onPressed: () async {
                              _callLoginFacebook();
                            },
                            icon: new Image.asset(
                              "assets/logo/login_facebook.png",
                            ),
                            padding: new EdgeInsets.all(5.0),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          alignment: FractionalOffset(0.5, 0.5),
                          height: 50.0,
                          width: 50.0,
                          child: IconButton(
                            onPressed: () async {
                              // var obj = await loginGoogle();
                              var accessToken = await getAccessTokenG();
                              loginWithSsp(accessToken, "google");

                              // var obj = await signInWithGoogle();

                              // loginWithSsp(accessToken.value, "google");
                              // if (obj != null) {
                              //   var model = {
                              //     "username": obj.user.email,
                              //     "email": obj.user.email,
                              //     "imageUrl": obj.user.photoURL != null
                              //         ? obj.user.photoURL
                              //         : '',
                              //     "firstName": obj.user.displayName,
                              //     "lastName": '',
                              //     "googleID": obj.user.uid
                              //   };

                              //   Dio dio = new Dio();
                              //   var response = await dio.post(
                              //     '${server}m/v2/register/google/login',
                              //     data: model,
                              //   );

                              //   await storage.write(
                              //     key: 'categorySocial',
                              //     value: 'Google',
                              //   );

                              //   await storage.write(
                              //     key: 'imageUrlSocial',
                              //     value: obj.user.photoURL != null
                              //         ? obj.user.photoURL
                              //         : '',
                              //   );

                              //   createStorageApp(
                              //     model: response.data['objectData'],
                              //     category: 'google',
                              //   );

                              //   Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => MenuCentralPage(),
                              //     ),
                              //   );
                              // }
                            },
                            icon: new Image.asset(
                              "assets/logo/login_google.png",
                            ),
                            padding: new EdgeInsets.all(5.0),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          alignment: new FractionalOffset(0.5, 0.5),
                          height: 50.0,
                          width: 50.0,
                          child: IconButton(
                            onPressed: () async {
                              await loginLine();
                              var accessToken = await getAccessTokenL();
                              loginWithSsp(accessToken?.value, "line");

                              // final idToken = obj.accessToken.idToken;
                              // final userEmail = (idToken != null)
                              //     ? idToken['email'] != null
                              //         ? idToken['email']
                              //         : ''
                              //     : '';
                              // if (obj != null) {
                              //   var model = {
                              //     "username":
                              //         (userEmail != '' && userEmail != null)
                              //             ? userEmail
                              //             : obj.userProfile.userId,
                              //     "email": userEmail,
                              //     "imageUrl": (obj.userProfile.pictureUrl != '' &&
                              //             obj.userProfile.pictureUrl != null)
                              //         ? obj.userProfile.pictureUrl
                              //         : '',
                              //     "firstName": obj.userProfile.displayName,
                              //     "lastName": '',
                              //     "lineID": obj.userProfile.userId
                              //   };
                              //   Dio dio = new Dio();
                              //   var response = await dio.post(
                              //     '${server}m/v2/register/line/login',
                              //     data: model,
                              //   );
                              //   await storage.write(
                              //     key: 'categorySocial',
                              //     value: 'Line',
                              //   );
                              //   await storage.write(
                              //     key: 'imageUrlSocial',
                              //     value: (obj.userProfile.pictureUrl != '' &&
                              //             obj.userProfile.pictureUrl != null)
                              //         ? obj.userProfile.pictureUrl
                              //         : '',
                              //   );
                              //   createStorageApp(
                              //     model: response.data['objectData'],
                              //     category: 'line',
                              //   );
                              //   Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => MenuCentralPage(),
                              //     ),
                              //   );
                              // }
                            },
                            icon: new Image.asset(
                              "assets/logo/login_line.png",
                            ),
                            padding: new EdgeInsets.all(5.0),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        if (Platform.isIOS)
                          Container(
                            alignment: new FractionalOffset(0.5, 0.5),
                            height: 50.0,
                            width: 50.0,
                            child: new IconButton(
                              onPressed: () async {
                                String? accessToken = await signInWithApple();
                                if (accessToken != null) {
                                  loginWithSsp(accessToken, "apple");
                                } else {
                                  print(
                                      "Apple sign-in failed: No access token received.");
                                }
                              },
                              icon: new Image.asset(
                                "assets/images/apple_circle.png",
                              ),
                              padding: new EdgeInsets.all(5.0),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  _rowLongLine(String title, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: Container(
            height: 1,
            color: color,
          ),
        ),
        Text(
          ' ${title} ',
          style: TextStyle(
            fontSize: 13.00,
            fontFamily: 'Kanit',
            color: color,
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: color,
          ),
        ),
      ],
    );
  }

  _buildLoginButton() {
    return Material(
      // elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Theme.of(context).primaryColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        height: 40,
        onPressed: () async {
          // loginWithGuest();
          await new FlutterSecureStorage()
              .write(key: 'firstName', value: 'สมศักดิ์');
          await new FlutterSecureStorage()
              .write(key: 'lastName', value: 'ศักดิ์สม');
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MenuCentralPage()),
              (route) => false);
        },
        child: new Text(
          'เข้าสู่ระบบ',
          style: new TextStyle(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Kanit',
          ),
        ),
      ),
    );
  }

  //login username / password
  Future<dynamic> login() async {
    if ((_username == null || _username == '') && _category == 'guest') {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => new CupertinoAlertDialog(
          title: new Text(
            'กรุณากรอกอีเมล',
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
    } else if ((_password == null || _password == '') && _category == 'guest') {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => new CupertinoAlertDialog(
          title: new Text(
            'กรุณากรอกรหัสผ่าน',
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
    } else {
      // Dio dio = new Dio();
      // var response = await dio.post(
      //   '${server}token',
      //   data: {
      //     'email': _username.toString(),
      //     'password': _password.toString(),
      //     'device_name': "mobile"
      //   },
      // );

      final response = await postLogin(server + 'token', {
        'email': _username.toString(),
        'password': _password.toString(),
        'device_name': "mobile"
      });

      if (response['token'] != null) {
        FocusScope.of(context).unfocus();
        new TextEditingController().clear();
        // await new FlutterSecureStorage()
        //     .write(key: 'token', value: response['token']);
        final result = await getUser(server + 'users/me');
        // await new FlutterSecureStorage()
        //     .write(key: 'phoneVerified', value: result['phone_verified'].toString());
        // await new FlutterSecureStorage()
        //     .write(key: 'profileCode', value: result['id'].toString());
        createStorageApp(
            model: result, category: 'guest', token: response['token']);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => MenuCentralPage(),
        //   ),
        // );

        if (result['phone_verified'] == false) {
          showDialog(
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
              });
        } else {
          _updateToken('${result['id']}');
          // print(result['id']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MenuCentralPage(),
            ),
          );
        }
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => new CupertinoAlertDialog(
            title: new Text(
              'อีเมล/รหัสผ่าน ไม่ถูกต้อง',
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
                  FocusScope.of(context).unfocus();
                  new TextEditingController().clear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }

      // if (result.status == 'S' || result.status == 's') {
      //   createStorageApp(
      //     model: result.objectData.code,
      //     category: 'guest',
      //   );

      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => MenuCentralPage(),
      //     ),
      //   );

      //   // await storage.write(
      //   //   key: 'dataUserLoginDDPM',
      //   //   value: jsonEncode(result.objectData),
      //   // );

      //   // Navigator.of(context).pushAndRemoveUntil(
      //   //   MaterialPageRoute(
      //   //     builder: (context) => MenuCentralPage(),
      //   //   ),
      //   //   (Route<dynamic> route) => false,
      //   // );
      // }

      // else {
      //   if (_category == 'guest') {
      //     return showDialog(
      //       barrierDismissible: false,
      //       context: context,
      //       builder: (BuildContext context) => new CupertinoAlertDialog(
      //         title: new Text(
      //           result.message,
      //           style: TextStyle(
      //             fontSize: 16,
      //             fontFamily: 'Kanit',
      //             color: Colors.black,
      //             fontWeight: FontWeight.normal,
      //           ),
      //         ),
      //         content: Text(" "),
      //         actions: [
      //           CupertinoDialogAction(
      //             isDefaultAction: true,
      //             child: new Text(
      //               "ตกลง",
      //               style: TextStyle(
      //                 fontSize: 13,
      //                 fontFamily: 'Kanit',
      //                 color: Color(0xFF000070),
      //                 fontWeight: FontWeight.normal,
      //               ),
      //             ),
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //             },
      //           ),
      //         ],
      //       ),
      //     );
      //   } else {
      //     register();
      //   }
      // }
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

  Future<dynamic> loginWithSsp(accessToken, String type) async {
    // final accessToken = obj.accessToken.idToken;

    final response = await postLoginSocial(server + 'auth/token/' + type,
        {'access_token': accessToken.toString(), 'device_name': "mobile"});
    if (response['token'] != null) {
      final result = await getUser(server + 'users/me');
      createStorageApp(
        model: result,
        category: type,
        token: response['token'],
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MenuCentralPage(),
        ),
      );
      // if (result['phone_verified'] == false) {
      //   showDialog(
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
      //                     color: Color(0xFFFF7514),
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
      //             ],
      //           ),
      //         );
      //       });
      // } else {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => MenuCentralPage(),
      //     ),
      //   );
      // }
    }
  }

  //login guest
  void loginWithGuest() async {
    setState(() {
      _category = 'guest';
      _username = txtUsername.text;
      _password = txtPassword.text;
    });
    login();
  }

  TextStyle style = TextStyle(
    fontFamily: 'Kanit',
    fontSize: 18.0,
  );

  _callLoginFacebook() async {
    // String obj = await facebookSignIn();
    var accessToken = await getAccessTokenF();
    loginWithSsp(accessToken, "facebook");
    // var obj = await signInWithFacebook();
    // if (obj != null) {
    //   var model = {
    //     "username": obj.user.email,
    //     "email": obj.user.email,
    //     "imageUrl":
    //         obj.user.photoURL != null ? obj.user.photoURL + "?width=9999" : '',
    //     "firstName": obj.user.displayName,
    //     "lastName": '',
    //     "facebookID": obj.user.uid
    //   };

    //   Dio dio = new Dio();
    //   var response = await dio.post(
    //     '${server}m/v2/register/facebook/login',
    //     data: model,
    //   );

    //   await storage.write(
    //     key: 'categorySocial',
    //     value: 'Facebook',
    //   );
    //   await storage.write(
    //     key: 'imageUrlSocial',
    //     value:
    //         obj.user.photoURL != null ? obj.user.photoURL + "?width=9999" : '',
    //   );

    //   createStorageApp(
    //     model: response.data['objectData'],
    //     category: 'facebook',
    //   );

    //   if (obj != null) {
    //     // Navigator.pushReplacement(
    //     //   context,
    //     //   MaterialPageRoute(
    //     //     builder: (context) => MenuCentralPage(),
    //     //   ),
    //     // );
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => PdpaPage(),
    //       ),
    //     );
    //   }
    // }
  }
}
