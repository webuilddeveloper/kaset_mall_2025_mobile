import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kasetmall/menu.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/shared/extension.dart';

import '../component/link_url_in.dart';

class PaymentStatusCentralPage extends StatefulWidget {
  const PaymentStatusCentralPage({Key? key, this.model}) : super(key: key);

  final dynamic model;
  @override
  State<PaymentStatusCentralPage> createState() =>
      _PaymentStatusCentralPageState();
}

class _PaymentStatusCentralPageState extends State<PaymentStatusCentralPage>
    with TickerProviderStateMixin {
  double currentOpacity = 0;
  late AnimationController animationController;

  late String qrCode;
  bool loadingSuccess = false;
  late Timer myTimerCheck;
  bool success = false;
  bool a1 = false;
  dynamic _questionnaire;

  @override
  void initState() {
    print('=======initState=========');
    print(widget.model);
    print(widget.model['payment_type']);
    print(widget.model['order_id']);
    print('=======initState=========');
    if (widget.model['payment_type'] == '3') {
      _getQRCode();
    }
    _checkOrder();
    animationController = AnimationController(
      value: 0.25,
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    animationController.addListener(() {
      setState(() {});
    });
    super.initState();
    animationController.forward();
    _callReadQuestionnaire();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  _callReadQuestionnaire() async {
    _questionnaire = await postDio('${server_we_build}questionnaire/read', {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFromDialog();
    });
  }

  _checkOrder() {
    postLineNoti(widget.model['order_id']);

    setState(() {
      myTimerCheck = Timer.periodic(Duration(seconds: 5), (timer) {
        get(server + 'orders/' + widget.model['order_id'])
            .then((value) async => {
                  if (value['status'] != 0)
                    {
                      setState(() {
                        success = true;
                        myTimerCheck.cancel();
                      }),
                    },
                });
      });
    });
  }

  _getQRCode() async {
    try {
      var value = await getQRCode(
          server + 'orders/' + widget.model['order_id'] + '/payments/qr.svg');
      print('QR Code Data123: $value');

      if (value != null && value.isNotEmpty) {
        setState(() {
          loadingSuccess = true;
          qrCode = value;
          // debugPrint("QR Code Data: $qrCode");
        });
      } else {
        print('QR code is empty or null');
      }
    } catch (e) {
      print("Error fetching QR code: $e");
    }
  }

  // _getQRCode() {
  //   getQRCode(
  //           server + 'orders/' + widget.model['order_id'] + '/payments/qr.svg')
  //       .then((value) => {
  //             Timer(
  //               Duration(seconds: 1),
  //               () => {
  //                 setState(
  //                   () {
  //                     loadingSuccess = true;
  //                     qrCode = value;
  //                   },
  //                 ),
  //               },
  //             ),
  //           });
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   elevation: 0,
        //   backgroundColor: Colors.white,
        //   automaticallyImplyLeading: false,
        //   toolbarHeight: 50,
        //   flexibleSpace: Container(
        //     color: Colors.transparent,
        //     child: Container(
        //       margin:
        //           EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
        //       padding: EdgeInsets.symmetric(horizontal: 15),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           GestureDetector(
        //             onTap: () {
        //               Navigator.pop(context);
        //             },
        //             child: Row(
        //               children: [
        //                 Icon(Icons.arrow_back_ios),
        //                 Text(
        //                   'สำเร็จ',
        //                   style: TextStyle(
        //                     color: Colors.black,
        //                     fontSize: 20,
        //                     fontWeight: FontWeight.bold,
        //                   ),
        //                   textAlign: TextAlign.start,
        //                 )
        //               ],
        //             ),
        //           ),
        //           Expanded(child: SizedBox()),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        body: SafeArea(
          child: Center(
              child: widget.model['payment_type'] == '3'
                  ? _qrCodePage()
                  : _successToPayPage()),
        ),
      ),
      // ignore: missing_return
      onWillPop: () async {
        // return false;
        setState(() {
          myTimerCheck.cancel();
        });
        Navigator.pop(context);
        return false;
      },
    );
    // );
  }

  _successToPayPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Opacity(
          opacity: animationController.value,
          child: Icon(
            Icons.check_circle_rounded,
            size: animationController.value * 100,
            color: Color(0xFF09665a),
          ),
        ),
        SizedBox(height: 15),
        Opacity(
          opacity: animationController.value,
          child: Text(
            'การสั่งซื้อสำเร็จ',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Color(0xFF09665a),
            ),
          ),
        ),
        Text(
          'ขอบคุณที่ไว้วางใจซื้อสินค้ากับเรา',
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => MenuCentralPage(),
              ),
              (Route<dynamic> route) => false,
            );
            // myTimerCheck.cancel();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                width: 1,
                color: Color(0xFFDF0B24),
              ),
            ),
            child: Text(
              'กลับหน้าหลัก',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFFDF0B24),
              ),
            ),
          ),
        )
      ],
    );
  }

  _qrCodePage() {
    return success
        ? _successToPayPage()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: animationController.value,
                child: Icon(
                  Icons.payments_rounded,
                  size: animationController.value * 100,
                  color: Color(0xFF09665a),
                ),
              ),
              SizedBox(height: 5),
              Opacity(
                opacity: animationController.value,
                child: Text(
                  'ชำระเงิน',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF09665a),
                  ),
                ),
              ),
              Text(
                'กรุณาสแกน QR Code เพื่อทำการชำระเงิน',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 15),
              Container(
                child: Icon(
                  Icons.qr_code_2,
                  size: 400,
                ),
              ),
              // gen Qr Code
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     Container(
              //         width: 300,
              //         height: 350,
              //         // alignment: Alignment.center,
              //         // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              //         child: loadingSuccess == false
              //             ? Center(
              //                 child: CircularProgressIndicator(
              //                 strokeWidth: 2,
              //               ))
              //             :
              //             //       Text(
              //             //   qrCode,
              //             //   style: TextStyle(
              //             //     fontSize: 15,
              //             //     fontWeight: FontWeight.w500,
              //             //     color: Color(0xFFDF0B24),
              //             //   ),
              //             // ),
              //             SvgPicture.string(qrCode, width: 200, height: 200)
              //         // Html(
              //         //     data: qrCode ?? '',
              //         //     onLinkTap: (url, attributes, element) {
              //         //       if (url != null) {
              //         //         launchInWebViewWithJavaScript(url);
              //         //       }
              //         //     },
              //         //   ),
              //         ),
              //   ],
              // ),

              SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  // _getQRCode();
                  setState(() {
                    myTimerCheck.cancel();
                  });
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => MenuCentralPage(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      width: 1,
                      color: Color(0xFFDF0B24),
                    ),
                  ),
                  child: Text(
                    'กลับหน้าหลัก',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFDF0B24),
                    ),
                  ),
                ),
              )
            ],
          );
  }

  void _showFromDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // ไม่ให้ปิดโดยการแตะด้านนอก
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ปุ่มปิดที่มุมขวาบน
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Container()),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if ((_questionnaire?[0]?['imageUrl'] ?? '') == '')
                  Icon(Icons.quiz_outlined,
                      size: 60, color: Theme.of(context).primaryColor),
                if ((_questionnaire?[0]?['imageUrl'] ?? '') != '')
                  Image.network(
                    _questionnaire?[0]?['imageUrl'],
                    width: 100,
                    height: 100,
                  ),
                SizedBox(height: 15),

                Text(
                  '${_questionnaire?[0]?['title'] ?? 'แบบสอบถามความพึงพอใจ'}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  parseHtmlString(_questionnaire?[0]?['description'] ??
                      'ในการใช้บริการซื้อสินค้าศึกษาภัณฑ์\nพาณิชย์ออนไลน์'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '(เพื่อรับของรางวัลฟรี)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                      launchInWebViewWithJavaScript(_questionnaire?[0]
                              ?['linkUrl'] ??
                          'https://docs.google.com/forms/d/e/1FAIpQLSfPuJxz8ett0-6RpbXeiKa1cT2jNeAkCw2SRPpxL7bUh297Kg/viewform?pli=1&authuser=0');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '${_questionnaire?[0]?['textButton'] ?? 'เข้าร่วมแบบสอบถาม'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'ข้ามไป',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
