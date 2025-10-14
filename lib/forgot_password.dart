import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaset_mall/shared/api_provider.dart';
import 'package:kaset_mall/widget/text_form_field.dart';
import '../../login.dart';
import '../widget/header.dart';
import '../widget/text_field.dart';
import 'login.dart';

class ForgotPasswordCentralPage extends StatefulWidget {
  @override
  _ForgotPasswordCentralPageState createState() =>
      _ForgotPasswordCentralPageState();
}

class _ForgotPasswordCentralPageState extends State<ForgotPasswordCentralPage> {
  final _formKey = GlobalKey<FormState>();

  final txtEmail = TextEditingController();

  @override
  void dispose() {
    txtEmail.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> submitForgotPassword() async {
    postRegister(server + 'forgot-password', {
      'email': txtEmail.text,
    }).then((value) => {});

    // final result = await postObjectData('forgot-password', {
    //   'email': txtEmail.text,
    // });
    setState(() {
      txtEmail.text = '';
    });
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: new Text(
            'ส่งอีเมลการเปลี่บยรหัสผ่านใหม่แล้ว\nกรุณาตรวจสอบอีเมล',
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginCentralPage(),
                  ),
                );
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // if (result['status'] == 'S') {
    //   return showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         content: Text(result['message'].toString()),
    //       );
    //     },
    //   );
    // } else {
    //   return showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         content: Text(result['message'].toString()),
    //       );
    //     },
    //   );
    // }
  }

  void goBack() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        // image: DecorationImage(
        //   image: AssetImage("assets/images/background_login.png"),
        //   fit: BoxFit.cover,
        // ),
      ),
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          // Note: Sensitivity is integer used when you don't want to mess up vertical drag
          if (details.delta.dx > 10) {
            // Right Swipe
            Navigator.pop(context);
          } else if (details.delta.dx < -0) {
            //Left Swipe
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          // appBar: header(context, goBack, title: 'ลืมรหัสผ่าน'),
          appBar: headerCentral(context, title: 'ลืมรหัสผ่าน'),
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg_login.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              child: ListView(
                padding: EdgeInsets.only(
                  top: 40,
                  left: 15,
                  right: 15,
                  bottom: 20 + MediaQuery.of(context).padding.bottom,
                ),
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      "assets/logo/logo_ssp.png",
                      // fit: BoxFit.contain,
                      // height: 150,
                      width: 200,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                              child: Text(
                                'กรอกอีเมลเพื่อรับรหัสผ่านใหม่ ระบบจะส่งรหัสผ่านใหม่ไปยังอีเมลของคุณ',
                                style: TextStyle(
                                  fontSize: 18.00,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            labelTextFormField('อีเมล'),
                            textFieldCentral(
                              txtEmail,
                              null,
                              'อีเมล',
                              'อีเมล',
                              true,
                              false,
                            ),
                            Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                margin: EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 10.0,
                                ),
                                child: Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(30.0),
                                  // color: Theme.of(context).primaryColor,
                                  color: Color(0XFFFC0D1B),
                                  child: MaterialButton(
                                    height: 40,
                                    onPressed: () {
                                      final form = _formKey.currentState;
                                      if (form!.validate()) {
                                        form.save();
                                        submitForgotPassword();
                                      }
                                    },
                                    child: new Text(
                                      'ยืนยัน',
                                      style: new TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'Kanit',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // new Container(
                  //   child: Container(
                  //     padding: EdgeInsets.symmetric(
                  //       horizontal: 10.0,
                  //       vertical: 10.0,
                  //     ),

                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
