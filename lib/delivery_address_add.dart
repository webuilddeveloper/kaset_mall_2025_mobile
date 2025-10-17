// ignore_for_file: must_be_immutable, unnecessary_null_comparison, duplicate_ignore, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/widget/data_error.dart';
import 'package:kasetmall/widget/loading_page.dart';
import 'package:kasetmall/widget/stack_tap.dart';
import 'package:toast/toast.dart';
import '../shared/api_provider.dart';
import '../widget/header.dart';

class DeliveryAddressAddCentralPage extends StatefulWidget {
  DeliveryAddressAddCentralPage({Key? key, this.code = ''}) : super(key: key);

  final String code;
  dynamic modelProvince;
  @override
  _DeliveryAddressAddCentralPageState createState() =>
      _DeliveryAddressAddCentralPageState();
}

class _DeliveryAddressAddCentralPageState
    extends State<DeliveryAddressAddCentralPage> {
  late List<dynamic> model;
  dynamic categoryModel = {'provinceTitle': ''};
  TextEditingController titleController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController buildingController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  int selectedType = 0;
  var _formKey = new GlobalKey<FormState>();

  bool loading = false;

  final storage = new FlutterSecureStorage();

  late PageController pageController;
  int currentPage = 0;
  late Future<dynamic> _futureShopLv1;
  late Future<dynamic> _futureShopLv2;
  late Future<dynamic> _futureShopLv3;
  dynamic lv1 = [];
  bool main = false;

  String selectedCodeLv1 = '';
  String selectedCodeLv2 = '';
  String selectedCodeLv3 = '';
  String selectedCodeLv4 = '';

  String titleCategoryLv1 = '';
  String titleCategoryLv2 = '';
  String titleCategoryLv3 = '';
  String titleCategoryLv4 = '';

  @override
  void initState() {
    pageController = new PageController(initialPage: currentPage);
    if (widget.code != '') _callRead();
    _callReadProvince(categoryModel);
    ToastContext().init(context);
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    phoneController.dispose();
    titleController.dispose();
    addressController.dispose();
    buildingController.dispose();
    fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerCentral(
        context,
        title: 'สร้างที่อยู่จัดส่ง',
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: loading
            ? LoadingPage()
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      children: _buildList(),
                    ),
                  ),
                  Container(
                    // bottom: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 45,
                        child: Material(
                          elevation: 0,
                          borderRadius: BorderRadius.circular(25.0),
                          color: Color(0xFFDF0B24),
                          child: MaterialButton(
                            onPressed: () async {
                              // final form = _formKey.currentState;
                              // if (form.validate()) {}
                              print('---------${phoneController.text.length}');
                              if (phoneController.text.length != 10) {
                                Toast.show('กรุณากรอกเบอร์มือถือให้ครบ 10 หลัก',
                                    backgroundColor: Colors.grey,
                                    duration: 3,
                                    gravity: Toast.bottom,
                                    textStyle: TextStyle(color: Colors.white));
                              } else
                                save();
                            },
                            child: new Text(
                              'บันทึก',
                              style: new TextStyle(
                                fontSize: 25.0,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
      ),
    );
  }

  _buildList() {
    return <Widget>[
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleName('จังหวัด / อำเภอ/เขต / ตำบล/แขวง / รหัสไปรษณีย์'),
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _sheetBottom();
                    // setState(() {

                    // });
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0),
                    constraints: BoxConstraints(
                      minHeight: 40,
                    ),
                    // height: 40,
                    decoration: new BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        width: 1,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          titleCategoryLv1 != ""
                              ? (titleCategoryLv1) +
                                  " / " +
                                  (titleCategoryLv2) +
                                  " / " +
                                  (titleCategoryLv3) +
                                  " / " +
                                  (selectedCodeLv4)
                              : 'จังหวัด / อำเภอ/เขต / ตำบล/แขวง / รหัสไปรษณีย์',
                          style: TextStyle(
                            color: Color(0xFF000000).withOpacity(0.9),
                            fontFamily: 'Kanit',
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            // letterSpacing: 0.23,
                          ),
                        )),
                  ),
                ),
              ],
            ),

            // _titleName('จังหวัด / เขต / รหัสไปรษณีย์'),
            // _textData('จังหวัด / เขต / รหัสไปรษณีย์', titleController),
            _titleName('ที่อยู่ บ้านเลขที่ ซอย หมู่ ถนน'),
            _textData('ที่อยู่ บ้านเลขที่ ซอย หมู่ ถนน', addressController),
            // _titleName('เลขที่อาคาร ชั้น'),
            // _textData('เลขที่อาคาร ชั้น', buildingController),
            _titleName('ชื่อผู้รับ'),
            _textData('ชื่อผู้รับ', fullNameController),
            _titleName('เบอร์มือถือ'),
            _textData('เบอร์มือถือ', phoneController,
                textI: TextInputType.number),
            SizedBox(height: 10),
            Text(
              'ประเภทที่อยู่',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            _selectTypeAddrdss(),
          ],
        ),
      ),
      SizedBox(height: 40),
    ];
  }

  _titleName(title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 15,
          // fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _textData(title, TextEditingController textC,
      {TextInputType textI = TextInputType.text}) {
    return SizedBox(
      height: 40,
      child: new TextFormField(
        keyboardType: textI,
        textInputAction: TextInputAction.next,
        controller: textC,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w300,
          color: Colors.black,
        ),
        cursorColor: Color(0xFF09665a),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Color(0xFF09665a)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Color(0xFF09665a)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          errorStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 10.0,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
          // labelText: "กรุณากรอกหมายเลขบัตร",
          hintText: title,
        ),
        // onSaved: (String value) {},
      ),
    );
  }

  _selectTypeAddrdss() {
    return Row(
      children: [
        _typeAddrdssName('ที่อยู่หลัก', 0, selectedType == 0 ? true : false),
        _typeAddrdssName('ที่อยู่สำรอง', 1, selectedType == 1 ? true : false),
      ],
    );
  }

  _typeAddrdssName(title, typeNumber, type) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedType = typeNumber;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: type ? Color(0XFFE3E6FE) : Color(0XFFFFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: type ? Color(0XFFE3E6FE) : Color(0XFFE4E4E4),
            ),
          ),
          child: Row(
            children: [
              type
                  ? Icon(
                      Icons.check_circle,
                      color: type ? Color(0xFF09665a) : Colors.black,
                      size: 15,
                    )
                  : Container(),
              SizedBox(width: 2),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: type ? Color(0xFF09665a) : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _sheetBottom() {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context,
            StateSetter setStateModal /*You can rename this!*/) {
          return Container(
            // height: 300,
            color: Color(0xFFFFFFFF),
            child: Column(
              children: [
                Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          'เลือกที่อยู่',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _titleCategory(1, setStateModal),
                      if (selectedCodeLv1 != '')
                        _titleCategory(2, setStateModal),
                      if (selectedCodeLv2 != '')
                        _titleCategory(3, setStateModal),
                      if (selectedCodeLv3 != '')
                        _titleCategory(4, setStateModal),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Expanded(
                  child: PageView(
                    controller: pageController,
                    physics: new NeverScrollableScrollPhysics(),
                    children: [
                      _buildPageLv(_futureShopLv1, 1, setStateModal),
                      if (selectedCodeLv1 != '')
                        _buildPageLv(_futureShopLv2, 2, setStateModal),
                      if (selectedCodeLv2 != '')
                        _buildPageLv(_futureShopLv3, 3, setStateModal),
                      // if (selectedCodeLv3 != '')
                      //   _buildPageLv(_futureShopLv4, 4, setStateModal),
                    ],
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  _titleCategory(lv, StateSetter setStateModal) {
    return GestureDetector(
      onTap: () => setStateModal(() {
        currentPage = lv - 1;
        pageController.animateToPage(lv - 1,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2,
              color: currentPage == lv - 1 ? Colors.red : Colors.white,
            ),
          ),
        ),
        child: Text(
          textCategory(lv),
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  textCategory(page) {
    String text = '';
    if (page == 1) {
      if (titleCategoryLv1 != "" && titleCategoryLv1 != "กรุงเทพมหานคร") {
        text = "จังหวัด" + titleCategoryLv1;
      } else if (titleCategoryLv1 == "กรุงเทพมหานคร") {
        text = titleCategoryLv1;
      } else {
        text = 'เลือกจังหวัด';
      }
    }
    if (page == 2) {
      if (titleCategoryLv2 != "") {
        text = titleCategoryLv2;
      } else {
        text = 'เลือกอำเภอ/เขต';
      }
    }
    if (page == 3) {
      if (titleCategoryLv3 != "" && titleCategoryLv1 != "กรุงเทพมหานคร") {
        text = "ตำบล" + titleCategoryLv3;
      } else if (titleCategoryLv1 == "กรุงเทพมหานคร") {
        text = titleCategoryLv3;
      } else {
        text = 'เลือกตำบล/แขวง';
      }
    }
    if (page == 4) {
      if (selectedCodeLv4 != "") {
        text = selectedCodeLv4;
      } else {
        text = 'เลือกรหัสไปรษณีย์';
      }
      // text = titleCategoryLv4;
    }

    return text;
  }

  _buildPageLv(_future, lv, StateSetter setStateModal) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data as List<dynamic>;
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (context, index) => Container(
              height: 1,
              color: Theme.of(context).colorScheme.surfaceBright,
            ),
            itemBuilder: (context, index) =>
                _buildItem(data[index], lv, setStateModal),
          );
        } else if (snapshot.hasError) {
          return DataError(onTap: () => _callReadProvince(''));
        } else {
          return ListView.separated(
            itemCount: 10,
            separatorBuilder: (context, index) => Container(
              height: 1,
              color: Theme.of(context).colorScheme.surfaceBright,
            ),
            itemBuilder: (context, index) => Container(
              height: 50,
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(left: 10),
              alignment: Alignment.centerLeft,
            ),
          );
        }
      },
    );
  }

  StackTap _buildItem(item, page, StateSetter setStateModal) {
    Color colorItem = Colors.black;
    if (page == 1 && selectedCodeLv1 == item['id']) colorItem = Colors.red;
    if (page == 2 && selectedCodeLv2 == item['id']) colorItem = Colors.red;
    if (page == 3 && selectedCodeLv3 == item['id']) colorItem = Colors.red;
    // if (page == 4 && selectedCodeLv4 == item['zip']) colorItem = Colors.red;
    return StackTap(
      onTap: () async => {
        setStateModal(() {
          currentPage = page;
        }),
        if (page == 1)
          {
            setStateModal(() {
              selectedCodeLv1 = item['id'].toString();
              selectedCodeLv2 = '';
              selectedCodeLv3 = '';
              selectedCodeLv4 = '';
              titleCategoryLv1 = item['name_th'];
              titleCategoryLv2 = '';
              titleCategoryLv3 = '';
              titleCategoryLv4 = '';
              getCategory(page, setStateModal);
              pageController.animateToPage(page,
                  duration: Duration(milliseconds: 500), curve: Curves.ease);
            })
          },
        if (page == 2)
          {
            setStateModal(() {
                  selectedCodeLv2 = item['id'].toString();
                  selectedCodeLv3 = '';
                  selectedCodeLv4 = '';
                  titleCategoryLv2 = item['name_th'];
                  getCategory(page, setStateModal);
                  pageController.animateToPage(page,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease);
                })
          },
        if (page == 3)
          {
            setStateModal(() {
                  selectedCodeLv3 = item['id'].toString();
                  titleCategoryLv3 = item['name_th'];
                  selectedCodeLv4 = item['zip'];
                  titleCategoryLv4 = item['zip'];
                  getCategory(page, setStateModal);
                  // pageController.animateToPage(page,
                  //     duration: Duration(milliseconds: 500), curve: Curves.ease)
                }),
            Navigator.pop(context, 'success')
          },
        // if (page == 4)
        //   {
        //     setStateModal(() => {
        //           selectedCodeLv4 = item['zip'],
        //           titleCategoryLv4 = item['zip'],
        //           getCategory(page, setStateModal),
        //           // pageController.animateToPage(page,
        //           //     duration: Duration(milliseconds: 500), curve: Curves.ease)
        //         }),
        //     Navigator.pop(context, 'success')
        //   },
        setState(() {}),
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item['name_th'] != null ? item['name_th'] : item['name_th'],
              style: TextStyle(
                  fontFamily: 'Kanit', fontSize: 14, color: colorItem),
            ),
            Icon(
              colorItem == Colors.red
                  ? Icons.check
                  : page != 4
                      ? Icons.arrow_forward_ios_rounded
                      : null,
              size: colorItem == Colors.red ? 20 : 15,
              color: colorItem,
            ),
          ],
        ),
      ),
    );
  }

  getCategory(lv, StateSetter setStateModal) async {
    // var model = await get(server + 'provinces/' );
    setStateModal(
      () {
        if (lv == 1) {
          _futureShopLv2 =
              get(server + "provinces/" + selectedCodeLv1 + "/districts");
        }
        if (lv == 2) {
          _futureShopLv3 = get(server +
              "provinces/" +
              selectedCodeLv1 +
              "/districts/" +
              selectedCodeLv2 +
              "/sub-districts");
        }
        // if (lv == 3)
        //   _futureShopLv4 = _futureShopLv3;
      },
    );
  }

  _callReadProvince(param) async {
    setState(
      () {
        _futureShopLv1 = get(server + 'provinces');

        if (param['provinceTitle'] != "") {
          selectedCodeLv1 = param['provinceCode:'];
          titleCategoryLv1 = param['provinceTitle'];
          _futureShopLv2 = get(server + 'provinces/' + selectedCodeLv1);
          selectedCodeLv2 = param['districtCode'];
          titleCategoryLv2 = param['districtTitle'];

          _futureShopLv3 = get(server +
              "provinces/" +
              selectedCodeLv1 +
              "/districts/" +
              selectedCodeLv2 +
              "/sub-districts");
          selectedCodeLv3 = param['subDistrictCode'];
          titleCategoryLv3 = param['subDistrictTitle'];
          selectedCodeLv4 = param['postCode'];
          titleCategoryLv4 = param['postCode'];
        } //
      },
    );
  }

  _callRead() async {
    var model = await get(server + 'shipping-addresses/' + widget.code);

    var data = model;
    fullNameController.text = data['name'];
    phoneController.text = data['phone'];
    addressController.text = data['address'];
    // buildingController.text = data['building'];
    categoryModel = {
      'provinceTitle': data['province']['data']['name_th'],
      'provinceCode': data['province']['data']['id'],
      'districtTitle': data['amphoe']['data']['name_th'],
      'districtCode': data['amphoe']['data']['id'],
      'subDistrictTitle': data['tambon']['data']['name_th'],
      'subDistrictCode': data['tambon']['data']['id'],
      'postCode': data['tambon']['data']['zip'],
    };

    setState(() {
      selectedType = data['main'] == true ? 0 : 1;
      categoryModel = {
        'provinceTitle': data['province']['data']['name_th'],
        'provinceCode': data['province']['data']['id'],
        'districtTitle': data['amphoe']['data']['name_th'],
        'districtCode': data['amphoe']['data']['id'],
        'subDistrictTitle': data['tambon']['data']['name_th'],
        'subDistrictCode': data['tambon']['data']['id'],
        'postCode': data['tambon']['data']['zip']
      };

      selectedCodeLv1 = data['province']['data']['id'].toString();
      selectedCodeLv2 = data['amphoe']['data']['id'].toString();
      selectedCodeLv3 = data['tambon']['data']['id'].toString();
      selectedCodeLv4 = data['tambon']['data']['zip'];
      titleCategoryLv1 = data['province']['data']['name_th'];
      titleCategoryLv2 = data['amphoe']['data']['name_th'];
      titleCategoryLv3 = data['tambon']['data']['name_th'];
      selectedCodeLv4 = data['tambon']['data']['zip'];
      // selectedType = data['addressType'];
    });
    this._callReadProvince(this.categoryModel);
  }

  save() async {
    String path = widget.code != '' ? 'update' : 'create';
    if (path == 'create') {
      await postObjectData(server + 'shipping-addresses', {
        'name': fullNameController.text,
        'address': addressController.text,
        'building': buildingController.text,
        'phone': phoneController.text,
        'province_id': selectedCodeLv1,
        'amphoe_id': selectedCodeLv2,
        'tambon_id': selectedCodeLv3,
        'zip': selectedCodeLv4,
        // 'addressType': selectedType,
        'main': selectedType == 0 ? true : false
        // 'isDefault': isDefault,
      }).then((value) => {Navigator.pop(context, 'success')});
    } else if (path == 'update') {
      await put(server + 'shipping-addresses/' + widget.code, {
        'main': selectedType == 0 ? true : false,
        'name': fullNameController.text,
        'address': addressController.text,
        'building': buildingController.text,
        'phone': phoneController.text,
        // ignore: unnecessary_null_comparison
        'province_id': selectedCodeLv1 == null
            ? categoryModel["provinceCode"]
            : selectedCodeLv1,
        'amphoe_id': selectedCodeLv2 == null
            ? categoryModel["districtCode"]
            : selectedCodeLv2,
        'tambon_id': selectedCodeLv3 == null
            ? categoryModel["subDistrictCode"]
            : selectedCodeLv3,
        'zip': selectedCodeLv4 == null
            ? categoryModel["postCode"]
            : selectedCodeLv4,
        'addressType': selectedType,
        // 'isDefault': isDefault,
      }).then((value) => {Navigator.pop(context, 'success')});
    }
  }
}
