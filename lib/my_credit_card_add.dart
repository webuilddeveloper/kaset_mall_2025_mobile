import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/component/toast_fail.dart';
import 'package:kasetmall/credit_card_form_field.dart';
import 'package:kasetmall/shared/api_payment.dart';
import 'package:kasetmall/widget/expiration_form_field.dart';
import 'package:kasetmall/widget/loading_page.dart';

import '../shared/api_provider.dart';
import '../widget/header.dart';

class MyCreditCardAddCentralPage extends StatefulWidget {
  MyCreditCardAddCentralPage({Key? key, this.code = ''}) : super(key: key);

  final String code;
  @override
  _MyCreditCardAddCentralPageState createState() =>
      _MyCreditCardAddCentralPageState();
}

class _MyCreditCardAddCentralPageState
    extends State<MyCreditCardAddCentralPage> {
  late List<dynamic> model;
  TextEditingController titleController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController expirationController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  bool isActive = false;

  ScrollController scrollController = new ScrollController();

  String keySearch = '';
  String category = '';
  int selectedIndexCategory = 0;
  // ignore: deprecated_member_use
  var _formKey = new GlobalKey<FormState>();
  var _paymentCard = PaymentCard();

  bool loading = false;

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
    if (widget.code != '') _callRead();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    titleController.dispose();
    expirationController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        appBar: headerCentral(
          context,
          title: 'เพิ่มบัตร',
        ),
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: loading
              ? LoadingPage()
              : Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      children: _buildList(),
                    ),
                    Positioned(
                      bottom: 50,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 45,
                          child: Material(
                            elevation: 0,
                            borderRadius: BorderRadius.circular(10.0),
                            color: Color(0xFFDF0B24),
                            child: MaterialButton(
                              onPressed: () async {
                                final form = _formKey.currentState;
                                if (form!.validate()) {
                                  save();
                                }
                              },
                              child: new Text(
                                'ส่ง',
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
                  ],
                ),
        ),
      ),
    );
  }

  _buildList() {
    return <Widget>[
      SizedBox(height: 10),
      Text(
        'ข้อมูลบัตร',
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 20),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleName('หมายเลขบัตร'),
            SizedBox(
              height: 40,
              child: new TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                controller: numberController,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                    borderSide: BorderSide(color: Color(0xFF0B24FB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                    borderSide: BorderSide(color: Color(0xFF0B24FB)),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  // labelText: "กรุณากรอกหมายเลขบัตร",
                  hintText: "กรุณากรอกหมายเลขบัตร",
                ),
                // onSaved: (String value) {},
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleName('วันหมดอายุ'),
                    SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 2.2,
                      child: ExpirationFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: BorderSide(color: Color(0xFF0B24FB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: BorderSide(color: Color(0xFF0B24FB)),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          hintText: "ดด/ปป",
                          hintStyle: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w300),
                        ),
                        controller: expirationController,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleName('CVV'),
                    SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 2.2,
                      child: new TextFormField(
                        controller: cvvController,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          new LengthLimitingTextInputFormatter(3),
                        ],
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w300),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: BorderSide(color: Color(0xFF0B24FB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: BorderSide(color: Color(0xFF0B24FB)),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          hintText: "- - -",
                        ),
                        // validator: CardUtils.validateCVV,
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          _paymentCard.cvv = int.parse(value ?? "");
                        },
                        onChanged: (String value) {
                          if (value.length >= 3)
                            FocusScope.of(context).nextFocus();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _titleName('ชื่อเจ้าของบัตร'),
            SizedBox(
              height: 40,
              child: new TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                controller: titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                    borderSide: BorderSide(color: Color(0xFF0B24FB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                    borderSide: BorderSide(color: Color(0xFF0B24FB)),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  // labelText: "กรุณากรอกหมายเลขบัตร",
                  hintText: "กรุณากรอกชื่อเจ้าของบัตร",
                ),
                // onSaved: (String value) {},
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 40),
      // Padding(
      //   padding: EdgeInsets.symmetric(horizontal: 20),
      //   child: Container(
      //     height: 45,
      //     child: Material(
      //       elevation: 0,
      //       borderRadius: BorderRadius.circular(7.0),
      //       color: Color(0xFFED5643),
      //       child: MaterialButton(
      //         onPressed: () async {
      //           final form = _formKey.currentState;
      //           if (form.validate()) {
      //             save();
      //           }
      //         },
      //         child: new Text(
      //           'ยืนยัน',
      //           style: new TextStyle(
      //             fontSize: 13.0,
      //             color: Colors.white,
      //             fontWeight: FontWeight.normal,
      //             fontFamily: 'Kanit',
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      // SizedBox(height: 40),
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

  save() async {
    setState(() => loading = true);
    dynamic response;
    dynamic resToken = {};
    dynamic resCustomer = {};
    Map<String, dynamic> cardJson = {};

    Map<String, String> token = {
      'card[name]': titleController.text,
      'card[number]': numberController.text,
      'card[security_code]': cvvController.text,
      'card[expiration_month]':
          int.tryParse(expirationController.text.substring(0, 2)).toString(),
      'card[expiration_year]': '20' +
          int.tryParse(expirationController.text.substring(3, 5)).toString()
    };

    final profileCode = await storage.read(key: 'profileCode10');
    final profileCategory = await storage.read(key: 'profileCategory');
    var user = await postDio(server + "m/v2/register/read",
        {"category": profileCategory, 'code': profileCode});
    String customerID = user['customerID'];

    // ?? step 1 create customer in omise server.
    resToken = await postOmise(endpoint_omise_v + 'tokens', token, pkey: true);

    if (customerID == '' || customerID == null || customerID == 'null') {
      resCustomer = await postOmise(endpoint_omise_m + 'customers', {
        'description': profileCode.toString(),
        'card': resToken['id'].toString()
      });

      await storage.write(
        key: 'customerID',
        value: resCustomer['id'].toString(),
      );

      customerID = resCustomer['id'].toString();
    }

    setState(() => loading = false);

    if (resToken['object'] == 'error') {
      setState(() => loading = false);
      return toastFail(context, text: resToken['message']);
    }

    cardJson = {
      // 'number': int.tryParse(numberController.text.substring(0, 4)).toString(),
      'number': resToken['card']['last_digits'],
      'tokenID': resToken['id'],
      'cardID': resToken['card']['id'],
      'title': resToken['card']['name'],
      'type': resToken['card']['brand'] ?? '',
      'customerID': customerID,
    };

    // ?? step 2 update our database.
    response = await postDio('${server}m/manageCreditCard/create', cardJson);
    setState(() => loading = false);
    if (response['status'] != 'E') {
      Navigator.pop(context, 'success');
    } else {
      return toastFail(context, text: 'เกิดข่้อผิดพลาด');
    }
  }

  _callRead() async {
    var model = await postDio('${server}m/manageCreditCard/read', {
      "code": widget.code,
    });

    var data = model[0];
    titleController.text = data['title'];
    cvvController.text = data['phone'];
    expirationController.text = data['address'];

    setState(() {
      isActive = data['isActive'];
    });
  }

  delete() async {
    await postDio('${server}m/manageCreditCard/delete', {
      "code": widget.code,
    }).then((value) {
      Navigator.pop(context);
      Navigator.pop(context, 'success');
    });
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }
}
