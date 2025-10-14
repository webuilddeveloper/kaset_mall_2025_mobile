import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaset_mall/widget/header.dart';

class MyBankAddCentralPage extends StatefulWidget {
  MyBankAddCentralPage({Key? key, this.code, this.title, this.callback})
      : super(key: key);

  final String? code;
  final String? title;
  final Function? callback;

  @override
  _MyBankAddCentralPage createState() => _MyBankAddCentralPage();
}

final storage = new FlutterSecureStorage();

class _MyBankAddCentralPage extends State<MyBankAddCentralPage> {
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
  TextEditingController? txtBirthday = TextEditingController();
  String? txtAffiliation;
  String? selectBankValue;
  bool SelectBandDefault = false;

  ScrollController scrollController = new ScrollController();
  List<dynamic> _futureBankModel = [
    {'code': '1', 'title': 'ธนาคารกสิกรไทย'},
    {'code': '2', 'title': 'ธนาคารกรุงไทย'},
    {'code': '3', 'title': 'ธนาคารกรุงเทพ'},
    {'code': '4', 'title': 'ธนาคารไทยพาณิชย์'},
    {'code': '5', 'title': 'ธนาคารออมสิน'},
    {'code': '6', 'title': 'ธนาคารกรุงศรี'},
  ];
  int selectedIndex = 0;
  @override
  void initState() {
    // print('oo $reporterCategoryList');
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: headerCentral(context, title: 'เพิ่มธนาคาร'),
          body: SafeArea(
            child: FutureBuilder<dynamic>(
              future: _futureModel,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                return Container(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ListView(
                      //   physics: ScrollPhysics(),
                      //   shrinkWrap: true,
                      //   // crossAxisAlignment: CrossAxisAlignment.end,
                      //   // mainAxisAlignment: MainAxisAlignment.start,
                      //   children: <Widget>[

                      //     SizedBox(height: 50)
                      //   ],
                      // ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ข้อมูลบัญชี',
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
                                    padding:
                                        EdgeInsets.only(left: 15.0, bottom: 5),
                                    child: Text(
                                      'ชื่อนามสกุล',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF000000),
                                        // fontWeight: FontWeight.w300,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  TextField(
                                    // controller: txtDescription,
                                    // keyboardType: TextInputType.multiline,
                                    // maxLines: 4,
                                    // maxLength: 100,
                                    cursorColor: Color(0xFF0B24FB),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Kanit',
                                    ),
                                    decoration: InputDecoration(
                                      fillColor: Color(0xFFFFFFFF),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                            color: Color(0xFF0B24FB)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                            color: Color(0xFF0B24FB)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.black.withOpacity(0.2),
                                        ),
                                      ),
                                      errorStyle: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 10.0,
                                      ),
                                      hintText: 'กรุณาใส่ชื่อสมาชิก',
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
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
                                    padding:
                                        EdgeInsets.only(left: 15.0, bottom: 5),
                                    child: Text(
                                      'หมายเลขประชาชน',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF000000),
                                        // fontWeight: FontWeight.w300,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  TextField(
                                    // controller: txtDescription,
                                    // keyboardType: TextInputType.multiline,
                                    // maxLines: 4,
                                    // maxLength: 100,
                                    cursorColor: Color(0xFF0B24FB),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Kanit',
                                    ),
                                    decoration: InputDecoration(
                                      fillColor: Color(0xFFFFFFFF),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                            color: Color(0xFF0B24FB)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                            color: Color(0xFF0B24FB)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.black.withOpacity(0.2),
                                        ),
                                      ),
                                      errorStyle: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 10.0,
                                      ),
                                      hintText: '_-____-_____-__-_',
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
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
                                  padding:
                                      EdgeInsets.only(left: 15.0, bottom: 5),
                                  child: Text(
                                    'หมายเลขบัญชี',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF000000),
                                      // fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                TextFormField(
                                  // controller: txtDescription,
                                  // keyboardType: TextInputType.multiline,
                                  // maxLines: 4,
                                  // maxLength: 100,
                                  // keyboardType: TextInputType.number,
                                  // inputFormatters: <TextInputFormatter>[
                                  //   FilteringTextInputFormatter.digitsOnly,
                                  //   LengthLimitingTextInputFormatter(10),
                                  // ],
                                  cursorColor: Color(0xFF0B24FB),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Kanit',
                                  ),
                                  decoration: InputDecoration(
                                    fillColor: Color(0xFFFFFFFF),
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide:
                                          BorderSide(color: Color(0xFF0B24FB)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide:
                                          BorderSide(color: Color(0xFF0B24FB)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(
                                        color: Colors.black.withOpacity(0.2),
                                      ),
                                    ),
                                    errorStyle: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 10.0,
                                    ),
                                    hintText: '___-_-_____-_',
                                    contentPadding: const EdgeInsets.all(10.0),
                                  ),
                                  controller: txtPhone,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 23.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                      EdgeInsets.only(left: 15.0, bottom: 5),
                                  child: Text(
                                    'เลือกธนาคาร',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF000000),
                                      // fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                DropdownButtonFormField<dynamic>(
                                  value: selectBankValue,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  elevation: 16,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFF0B24FB), width: 1.0),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFFE4E4E4),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    hintText: 'กรุณาเลือก ธนาคาร',
                                    contentPadding: const EdgeInsets.all(10.0),
                                  ),
                                  validator: (value) =>
                                      value == '' || value == null
                                          ? 'กรุณาเลือกหัวข้อ'
                                          : null,
                                  onChanged: (d) {
                                    // This is called when the user selects an item.
                                    setState(() {
                                      selectBankValue = d;
                                    });
                                  },
                                  items: _futureBankModel.map((item) {
                                    // print(item);
                                    return DropdownMenuItem(
                                      child: new Text(
                                        item['title'],
                                        style: TextStyle(
                                          fontSize: 15.00,
                                          fontFamily: 'Kanit',
                                          color: Color(
                                            0xFF000070,
                                          ),
                                        ),
                                      ),
                                      value: item['code'],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          // SizedBox(
                          //   height: 10,
                          // ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ตั้งเป็นบัญชีเริ่มต้น',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF000000),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              CupertinoSwitch(
                                value: SelectBandDefault,
                                activeColor: Colors.red,
                                onChanged: (value) {
                                  setState(() {
                                    SelectBandDefault = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              height: 50,
                              // minWidth: 168,
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(25)),
                              onPressed: () {
                                // launchInWebViewWithJavaScript(model['fileUrl']);
                              },
                              child: Text(
                                "ส่ง",
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.w400),
                              ),
                              color: Color(0xFFDF0B24),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          )),
    );
  }
}
