import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as datetimePicker;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/widget/header.dart';
import 'package:kasetmall/widget/image_picker.dart';

class UserProfileForm extends StatefulWidget {
  UserProfileForm(
      {Key? key,
      this.code,
      this.title,
      this.callback,
      this.phoneFocus,
      this.nameFocus,
      this.emailFocus,
      this.birthFocus,
      this.mode = ""})
      : super(key: key);

  final String? code;
  final String? title;
  final Function? callback;
  final FocusNode? phoneFocus;
  final FocusNode? nameFocus;
  final FocusNode? emailFocus;
  final FocusNode? birthFocus;
  String mode;

  @override
  _UserProfileForm createState() => _UserProfileForm();
}

final storage = new FlutterSecureStorage();

class _UserProfileForm extends State<UserProfileForm> {
  // final storage = new FlutterSecureStorage();
  late Future<dynamic> _futureModel;
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
  int? selectOccupation;
  int? txtSex;
  String image = '';
  String name = '';
  String date = '';
  bool loadingImage = false;
  late XFile imageProfile;
  dynamic model;
  String profilePhone = "";

  ScrollController scrollController = new ScrollController();
  dynamic _futureAffiliationModel = [
    {'code': '1', 'title': 'สมาชิก ศึกษาภัณฑ์ มอลล์.', 'Affiliation': '1'},
    {'code': '2', 'title': 'บุคคลทั่วไป', 'Affiliation': '2'},
  ];
  dynamic _futureSexModel = [
    {'code': 1, 'title': 'ชาย', 'icon': Icons.male},
    {'code': 2, 'title': 'หญิง', 'icon': Icons.female},
    {'code': 3, 'title': 'เพศทางเลือก', 'icon': Icons.transgender},
  ];

  final _futureOccupationModel = [
    {'code': 10, 'title': 'ครู'},
    {'code': 20, 'title': 'นักเรียน'},
    {'code': 30, 'title': 'ผู้ปกครอง'},
    {'code': 40, 'title': 'เจ้าหน้าที่รัฐ'},
    {'code': 50, 'title': 'โรงเรียน/หน่วยงานรัฐ'},
    {'code': 60, 'title': 'ร้านค้า/บริษัท'},
    {'code': 70, 'title': 'อื่นๆ'},
  ];

  int selectedIndex = 0;
  int? selectedSexIndex;
  FocusNode phoneFocus = FocusNode();
  FocusNode? nameFocus;
  FocusNode? emailFocus;
  FocusNode? birthFocus;
  String get mode => widget.mode;

  @override
  void initState() {
    _readUser();
    scrollController = ScrollController();
    var now = new DateTime.now();
    year = now.year;
    month = now.month;
    day = now.day;
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedDay = now.day;
    // _callRead();

    super.initState();
  }

  @override
  dispose() {
    scrollController.dispose();
    super.dispose();
  }

  _readUser() async {
    // final code = await storage.read(key: 'profileCode10');
    // final result = await postDio(server + "m/Register/read", {'code': code});
    var a = await storage.read(key: 'profilePhone');
    final result = await get(server + 'users/me');

    if (result != null) {
      await storage.write(
        key: 'dataUserLoginDDPM',
        value: jsonEncode(result[0]),
      );

      setState(() {
        // image = result['imageUrl'] ?? '';
        // name = '${result[0]['firstName']} ${result[0]['lastName']}';
        // if (widget.mode == "addPhone") {
        //   phoneFocus.requestFocus();
        // }

        profilePhone = a ?? "";
        name = '${result['name']}';
        txtName = TextEditingController(text: result['name'] ?? '');
        txtEmail = TextEditingController(text: result['email'] ?? '');
        txtPhone = TextEditingController(text: result['phone'] ?? '');
        selectOccupation = result['occupation'];
        selectedSexIndex = (result['gender'] ?? 1) - 1;
        image = result['profile_picture_url'] ?? '';
        model = result;
        if (result['birthday'] != null) {
          txtBirthday.value = TextEditingValue(
            text: DateFormat("dd / MM / yyyy")
                .format(DateTime.parse(result['birthday'])),
          );
          date = result['birthday'];
          // _selectedYear = int.parse(date.substring(0,4));
          // _selectedMonth = int.parse(date.substring(4, 6));
          // _selectedDay = int.parse(date.substring(6, 8));
        } else {
          // txtBirthday.value = TextEditingValue(
          //   text: DateFormat("dd / MM / yyyy").format(DateTime.now()),
          // );

          txtBirthday.text = '';
        }
        if (result['phone'] == null) {
          setState(() {
            phoneFocus.requestFocus();
          });
        }
      });
    }
  }

  void goBack() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: headerCentral(context, title: 'บัญชี'),
        body: Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          child: ListView(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 30.0),
                        height: 148,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                "assets/images/profile_form_background.png"),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 5),
                            Stack(
                              children: [
                                ImageUploadPicker(
                                  callback: (file) => {
                                    setState(() {
                                      _uploadImage(file);
                                    })
                                  },
                                  // _uploadImage(file),
                                  child: image != ''
                                      ? Container(
                                          // margin: EdgeInsets.only(bottom: 20.0),
                                          height: 155,
                                          width: 155,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(image),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                          ),
                                        )
                                      : Container(
                                          height: 150,
                                          width: 150,
                                          padding: EdgeInsets.all(30),
                                          decoration: BoxDecoration(
                                            color: Color(0XFF0B24FB),
                                            borderRadius:
                                                BorderRadius.circular(75),
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
                                if (loadingImage)
                                  Positioned.fill(
                                    child: Container(
                                      height: 155,
                                      width: 155,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(90),
                                      ),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 25),
                              child: Text(name,
                                  style: TextStyle(
                                    color: Color(0xFF0B24FB),
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal,
                                  )),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  // width: 50,
                                  height: 25,
                                  margin: EdgeInsets.only(
                                    bottom: 15.0,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      left: 10.0,
                                      right: 10.0,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: new BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFFFFFFFF),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                      borderRadius:
                                          new BorderRadius.circular(25.0),
                                      border: Border.all(
                                        color: Color(0xFF0B24FB),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'สมาชิก ศึกษาภัณฑ์ มอลล์.',
                                      style: TextStyle(
                                        color: Color(0xFF0B24FB),
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.normal,
                                        letterSpacing: 0.33,
                                        fontFamily: 'Kanit',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'ข้อมูลส่วนตัว',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 15.0, bottom: 5),
                            child: Text(
                              'ชื่อสมาชิก',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF000000),
                                // fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          TextField(
                            // autofocus: widget.nameFocus,
                            focusNode: nameFocus,
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 4,
                            // maxLength: 100,
                            enabled: true,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Kanit',
                              color: Color(0xFF005C9E),
                            ),
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
                            controller: txtName,
                          ),
                        ],
                      )),
                  Container(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 15.0, bottom: 5),
                            child: Text(
                              'อีเมล',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF000000),
                                // fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          TextField(
                            focusNode: emailFocus,
                            // controller: txtDescription,
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 4,
                            // maxLength: 100,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Kanit',
                              color: Color(0xFF005C9E),
                            ),
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
                                // borderRadius: BorderRadius.only(
                                //     topLeft: Radius.circular(5.0),
                                //     topRight: Radius.circular(5.0)),
                                gapPadding: 1,
                              ),
                              hintText: 'กรุณาใส่อีเมล',
                              contentPadding: const EdgeInsets.all(10.0),
                            ),
                            controller: txtEmail,
                          ),
                        ],
                      )),
                  Container(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 15.0, bottom: 5),
                            child: Text(
                              'หมายเลขติดต่อ',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF000000),
                                // fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          TextFormField(
                            focusNode: phoneFocus,
                            // controller: txtDescription,
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 4,
                            // maxLength: 100,
                            // keyboardType: TextInputType.number,
                            // inputFormatters: <TextInputFormatter>[
                            //   FilteringTextInputFormatter.digitsOnly,
                            //   LengthLimitingTextInputFormatter(10),
                            // ],
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Kanit',
                              color: Color(0xFF005C9E),
                            ),
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
                                // borderRadius: BorderRadius.only(
                                //     topLeft: Radius.circular(5.0),
                                //     topRight: Radius.circular(5.0)),
                                gapPadding: 1,
                              ),
                              hintText: 'กรุณาใส่หมายเลขติดต่อ',
                              contentPadding: const EdgeInsets.all(10.0),
                            ),
                            controller: txtPhone,
                          ),
                        ],
                      )),
                  Container(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 15.0, bottom: 5),
                        child: Text(
                          'วันเกิด',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF000000),
                            // fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => dialogOpenPickerDate(),
                        child: AbsorbPointer(
                          child: TextFormField(
                            focusNode: birthFocus,
                            // controller: txtDescription,
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 4,
                            // maxLength: 100,
                            // textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Kanit',
                              color: Color(0xFF005C9E),
                              fontWeight: FontWeight.normal,
                            ),
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.calendar_today_outlined,
                                size: 15,
                              ),
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
                                // borderRadius: BorderRadius.only(
                                //     topLeft: Radius.circular(5.0),
                                //     topRight: Radius.circular(5.0)),
                                gapPadding: 1,
                              ),
                              hintText: 'กรุณาเลือก วัน/เดือน/ปีเกิด',
                              contentPadding: const EdgeInsets.all(10.0),
                            ),
                            controller: txtBirthday,
                          ),
                        ),
                      ),
                    ],
                  )),
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
                            validator: (value) {
                              int.parse(value.toString()) == 0
                                  ? 'กรุณาเลือกอาชีพ'
                                  : 0;
                            },
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
                            onChanged: (newValue) {
                              setState(() {
                                selectOccupation =
                                    int.parse(newValue.toString());
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
                  SizedBox(
                    height: 10,
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
                                    fontWeight: index == selectedIndex
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
                  Slidable(
                    key: const ValueKey(1),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (ctx) => {null},
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          icon: Icons.info_outline,
                        ),
                        SlidableAction(
                          onPressed: (ctx) => {
                            null,
                          },
                          backgroundColor: const Color.fromRGBO(219, 32, 32, 1),
                          foregroundColor: Colors.white,
                          icon: Icons.delete_outline,
                        ),
                      ],
                    ),
                    child: Container(),
                  ),
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Text(
              //       'สังกัด',
              //       style: TextStyle(
              //         fontSize: 15,
              //         color: Color(0xFF000000),
              //         fontWeight: FontWeight.w600,
              //       ),
              //       textAlign: TextAlign.left,
              //     ),
              //   ],
              // ),
              // Container(
              //   // width: 50,
              //   height: 33,
              //   margin: EdgeInsets.only(
              //     top: 5.0,
              //     bottom: 50,
              //   ),
              //   child: ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: _futureAffiliationModel.length,
              //     itemBuilder: (BuildContext context, int index) {
              //       return GestureDetector(
              //         onTap: () {
              //           // FocusScope.of(context).unfocus();
              //           // widget.onChange(snapshot.data[index]['code']);
              //           setState(() {
              //             selectedIndex = index;
              //             txtAffiliation =
              //                 _futureAffiliationModel[index]['Affiliation'];
              //           });
              //         },
              //         child: Container(
              //           alignment: Alignment.center,
              //           padding: EdgeInsets.all(
              //             5.0,
              //           ),
              //           margin: EdgeInsets.only(
              //             right: 12.0,
              //           ),
              //           decoration: new BoxDecoration(
              //             boxShadow: [
              //               BoxShadow(
              //                 color: index == selectedIndex
              //                     ? Color(0xFFFBE3E6).withOpacity(0.49)
              //                     : Color(0xFFFFFFFF),
              //                 spreadRadius: 0,
              //               ),
              //             ],
              //             borderRadius: new BorderRadius.circular(10.0),
              //             border: Border.all(
              //               color: index == selectedIndex
              //                   ? Color(0xFFFBE3E6).withOpacity(0.49)
              //                   : Color(0xFF000000).withOpacity(0.50),
              //               width: 1,
              //             ),
              //           ),
              //           child: Row(
              //             children: [
              //               Container(
              //                 margin: EdgeInsets.only(
              //                   right: 5.0,
              //                 ),
              //                 child: index == selectedIndex
              //                     ? Icon(
              //                         Icons.check_circle,
              //                         color: Color(0xFFDF0B24),
              //                         size: 15,
              //                       )
              //                     : SizedBox(
              //                         height: 0,
              //                       ),
              //               ),
              //               Text(
              //                 _futureAffiliationModel[index]['title'],
              //                 style: TextStyle(
              //                   color: index == selectedIndex
              //                       ? Color(0xFFDF0B24)
              //                       : Color(0xFF000000).withOpacity(0.5),
              //                   fontSize: 13.0,
              //                   fontWeight: index == selectedIndex
              //                       ? FontWeight.w500
              //                       : FontWeight.normal,
              //                   fontFamily: 'Kanit',
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),

              MaterialButton(
                height: 50,
                // minWidth: 168,
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(25)),
                onPressed: () {
                  _update();
                },
                child: Text(
                  "บันทึก",
                  style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w400),
                ),
                color: Color(0xFFDF0B24),
              ),
              SizedBox(height: 50)
            ],
          ),
        ));
  }

  _update() async {
    FocusScope.of(context).unfocus();
    String fileName;
    String fileType;
    var birthDate;
    // if (imageProfile != null) {
    //   fileName = imageProfile.path.split('/').last;
    //   fileType = fileName.split('.').last;
    // }
    if (txtBirthday.text != null) {
      birthDate = txtBirthday.text.split('/');
    }
    var map = {
      "name": txtName?.text ?? '',
      "email": txtEmail?.text ?? '',
      "phone": txtPhone?.text ?? '',
      "gender": (selectedSexIndex! + 1).toString(),
      "occupation": selectOccupation.toString(),
      "birthday": birthDate != null
          ? DateFormat("yyyy-MM-dd").format(
              DateTime(
                int.parse(birthDate[2]),
                int.parse(birthDate[1]),
                int.parse(birthDate[0]),
              ),
            )
          : '',

      // "profile_picture": imageProfile != null
      //     ? await MultipartFile.fromFile(imageProfile.path,
      //         filename: fileName, contentType: MediaType('image', fileType))
      //     : "",
      // imageProfile != null ? await MultipartFile.fromFile(imageProfile.path,
      //     filename: fileName, contentType: MediaType('image', fileType)) :
    };
    // var b = await storage.read(key: 'profilePhone');
    if (profilePhone == null) {
      await put(server + 'users/me', map).then((value) async => {
            await postReturnAll(server + 'users/me/phone-number', {
              'phone': (txtPhone?.text).toString() ?? ''
            }).then((value2) async => {
                  setState(() {
                    if (value2['status2'] == 'S') {
                      storage.write(
                          key: 'profilePhone',
                          value: txtPhone?.text.toString());
                      Navigator.pop(context, 'success');
                    } else {
                      // phoneFocus.requestFocus();
                      // toastFail(context, text: value2['message'], duration: 3);
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
                                  value2['message'],
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
                                      phoneFocus.requestFocus();
                                    },
                                  ),
                                ],
                              ),
                            );
                          });
                    }
                  }),
                }),
          });
    } else {
      await put(server + 'users/me', map).then((value) async => {
            Navigator.pop(context, 'success'),
          });
    }
    return null;
  }

  dialogOpenPickerDate() {
    var birthDate = txtBirthday.text != ''
        ? txtBirthday.text.split('/')
        : DateFormat("dd / MM / yyyy").format(DateTime.now()).split('/');
    datetimePicker.DatePicker.showDatePicker(context,
        theme: datetimePicker.DatePickerTheme(
          containerHeight: 210.0,
          itemStyle: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF0B24FB),
            fontWeight: FontWeight.normal,
            fontFamily: 'Kanit',
          ),
          doneStyle: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF0B24FB),
            fontWeight: FontWeight.normal,
            fontFamily: 'Kanit',
          ),
          cancelStyle: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF0B24FB),
            fontWeight: FontWeight.normal,
            fontFamily: 'Kanit',
          ),
        ),
        showTitleActions: true,
        minTime: DateTime(1800, 1, 1),
        maxTime: DateTime(year, month, day), onConfirm: (date) {
      setState(
        () {
          _selectedYear = int.parse(birthDate[2]);
          _selectedMonth = int.parse(birthDate[1]);
          _selectedDay = int.parse(birthDate[0]);
          txtBirthday.value = TextEditingValue(
            text: DateFormat("dd / MM / yyyy").format(date),
          );
        },
      );
    },
        currentTime: DateTime(
          int.parse(birthDate[2]),
          int.parse(birthDate[1]),
          int.parse(birthDate[0]),
        ),
        locale: datetimePicker.LocaleType.th);
  }

  _uploadImage(file) async {
    setState(() {
      loadingImage = true;
      imageProfile = file;
    });
    String? fileName;
    String? fileType;
    if (imageProfile != null) {
      fileName = imageProfile.path.split('/').last;
      fileType = fileName.split('.').last;
    }

    var map = FormData.fromMap({
      "name": model['name'] ?? '',
      "email": model['email'] ?? '',
      "phone": model['phone'] ?? '',
      "gender": (model['gender'] ?? 1),
      "occupation": (model['occupation'] ?? 70),
      "birthday": model['birthday'] ?? '',
      "profile_picture": imageProfile != null
          ? await MultipartFile.fromFile(imageProfile.path,
              filename: fileName,
              contentType: MediaType('image', (fileType ?? "")))
          : "",
    });
    await postFormData(server + 'users/me?_method=put', map)
        .then((value) async => {
              setState(() {
                image = value['profile_picture_url'].toString();
                loadingImage = false;
                storage.delete(key: 'profileImageUrl');
                storage.write(
                    key: 'profileImageUrl',
                    value: value['profile_picture_url'].toString());
              }),
            });
  }
}
