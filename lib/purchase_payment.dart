import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:mobile_mart_v3/purchase_payment_information.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchasePayment extends StatefulWidget {
  final dynamic totalAmount;
  final dynamic orderid;
  final dynamic result;

  const PurchasePayment(
      {super.key, required this.totalAmount, this.orderid, this.result});

  @override
  State<PurchasePayment> createState() => _PurchasePaymentState();
}

late final String totalAmount;

class _PurchasePaymentState extends State<PurchasePayment> {
  void initState() {
    getqrcodescb();
    super.initState();
  }

  String _selectedRadioValue = "1";
  Map<String, dynamic> qrcode = {};

  Timer? _paymentStatusTimer;

  void _launchFileUrl() async {
    final url = Uri.parse(
        'https://etranscript.suksapan.or.th/otep/printPayinslipscb.php?transactionid=${widget.orderid}');

    print('=======>>  URL: ${url} ');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'ไม่สามารถเปิดลิงก์: $url';
    }
  }

  Future<void> getqrcodescb() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json',
      'Cookie': 'PHPSESSID=70ig76ot83n5paa61d4davtu30'
    };
    print('widget.orderid : ${widget.orderid}');
    var data = json.encode({"transactionid": widget.orderid});
    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/getqrcodescb.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      setState(() {
        qrcode = response.data;
      });

      _paymentStatusTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
        await getpaymentstatus();
      });
    } else {
      print(response.statusMessage);
    }
  }

  Future<void> getpaymentstatus() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json',
      'Cookie': 'PHPSESSID=70ig76ot83n5paa61d4davtu30'
    };
    var data = json.encode({"transactionid": widget.orderid});
    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/getpaymentstatus.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      var result = response.data;
      if (result["return"] == "00") {
        paymentconfirm();
        _paymentStatusTimer?.cancel();
        showSuccessDialog(context);
      }
    } else {
      print(response.statusMessage);
    }
  }

  Future<void> paymentconfirm() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json',
      'Cookie': 'PHPSESSID=70ig76ot83n5paa61d4davtu30'
    };
    var data = json.encode({
      "transactionid": widget.orderid,
      "paymenttype": _selectedRadioValue,
      "uid": widget.result['uid']
    });
    print('=============paymentconfirm===============');
    print(data);
    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/paymentconfirm.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print(json.encode(response.data));
    } else {
      print(response.statusMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFF012A6C),
          leading: Padding(
            padding: EdgeInsets.only(left: 12),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Center(
              child: Text(
            'ชำระเงิน',
            style: TextStyle(color: Colors.white),
          )),
          actions: [
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.transparent,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'วิธีชำระเงิน',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Radio<String>(
                              activeColor: Color(0xFF012A6C),
                              value: "1",
                              groupValue: _selectedRadioValue,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRadioValue = value!;
                                });
                              },
                            ),
                            Text(
                              "สแกน QR Code",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _selectedRadioValue == "1"
                                    ? FontWeight
                                        .w600 // ตัวอักษรหนาเมื่อถูกเลือก
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                              height: 1, color: Colors.black.withOpacity(0.2)),
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              activeColor: Color(0xFF012A6C),
                              value: "2",
                              groupValue: _selectedRadioValue,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRadioValue = value!;
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ใบแจ้งชำระเงินผ่านธนาคาร",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: _selectedRadioValue == "2"
                                          ? FontWeight
                                              .w600 // ตัวอักษรหนาเมื่อถูกเลือก
                                          : FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  _selectedRadioValue == "2"
                                      ? GestureDetector(
                                          onTap: () => _launchFileUrl(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Color(0xFFDCE0E5),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                      'assets/download-1.png',
                                                      width: 20,
                                                      height: 20),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    'เอกสารใบแจ้งชำระเงิน',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox()
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        textDetail(
                          title: 'รวมเงิน ',
                          detail: '${widget.totalAmount['totalamount']} บาท',
                          fontWeightTitle: FontWeight.w400,
                          colorTitle: Colors.black.withOpacity(0.6),
                          fontSizeTitle: 13,
                          fontSizeDetail: 13,
                        ),
                        SizedBox(height: 10),
                        textDetail(
                          title: 'ค่าขนส่ง ',
                          detail: '${widget.totalAmount['shippingprice']} บาท',
                          fontWeightTitle: FontWeight.w400,
                          colorTitle: Colors.black.withOpacity(0.6),
                          fontSizeTitle: 13,
                          fontSizeDetail: 13,
                        ),
                        SizedBox(height: 10),
                        textDetail(
                          title: 'มูลค่าสินค้าและค่าขนส่งก่อนภาษี',
                          detail:
                              '${widget.totalAmount['totalamountbeforetax']} บาท',
                          fontWeightTitle: FontWeight.w400,
                          colorTitle: Colors.black.withOpacity(0.6),
                          fontSizeTitle: 13,
                          fontSizeDetail: 13,
                        ),
                        SizedBox(height: 10),
                        textDetail(
                          title: 'ภาษีมูลค่าเพิ่ม ',
                          detail: '${widget.totalAmount['totalvat']} บาท',
                          fontWeightTitle: FontWeight.w400,
                          colorTitle: Colors.black.withOpacity(0.6),
                          fontSizeTitle: 13,
                          fontSizeDetail: 13,
                        ),
                        SizedBox(height: 10),
                        textDetail(
                          title: 'ยอดสุทธิ ',
                          detail: '${widget.totalAmount['totalsum']} บาท',
                          fontWeightTitle: FontWeight.w400,
                          colorTitle: Colors.black.withOpacity(0.6),
                          fontSizeTitle: 13,
                          fontSizeDetail: 13,
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            height: 1,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${widget.totalAmount['totalsum']} บาท',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 60),
          child: GestureDetector(
            onTap: () {
              _selectedRadioValue == "1"
                  ? showQrDialog(context)
                  : showPaymentDialog(context);
            },
            child: Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF012A6C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'ชำระเงิน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Widget textDetail({
    required String title,
    required String detail,
    required FontWeight fontWeightTitle,
    required Color colorTitle,
    required double fontSizeTitle,
    required double fontSizeDetail,
    FontWeight fontWeightDetail = FontWeight.w700,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSizeTitle,
              fontWeight: fontWeightTitle,
              color: colorTitle,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            detail,
            style: TextStyle(
              fontSize: fontSizeDetail,
              fontWeight: fontWeightDetail,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  showQrDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // ปิด dialog โดยกดพื้นที่รอบๆ ไม่ได้
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3E6FE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFF0B24FB), width: 1),
                      ),
                      child: QrImageView(
                        data: qrcode['qrcode'],
                        version: QrVersions.auto,
                        size: 250.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ชำระผ่าน QR Code',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF012A6C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'บัญชีธนาคาร ธนาคารไทยพาณิชย์ (SCB)\nชื่อบัญชี องค์การค้าของ สกสค.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Positioned(
                right: 15,
                top: 30,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // ปิด dialog โดยกดพื้นที่รอบๆ ไม่ได้
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ยืนยันการชำระเงิน',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Color(0xFFFCA0A6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'คุณต้องการที่จะชำระเงินหรือไม่ \nหากยืนยันจะเข้าสู่กระบวนการการชำระเงิน',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Color(0xFF012A6C), width: 1),
                                ),
                                child: const Center(
                                  child: Text(
                                    'ยกเลิก',
                                    style: TextStyle(
                                      color: Color(0xFF012A6C),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PurchasePaymentInformation(
                                      result: widget.result,
                                      orderid: widget.orderid,
                                      onConfirmPayment: paymentconfirm,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0xFF012A6C),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'ยืนยัน',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 20,
                top: 30,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/check-one.png',
                        width: 80,
                        height: 80,
                      ),
                      Text(
                        'ชำระเงินสำเร็จ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Color(0xFF039855),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 15,
                top: 30,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //       builder: (context) => PurchasePaymentInformation()),
                      // );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icon_error.png',
                        width: 80,
                        height: 80,
                      ),
                      Text(
                        'ชำระเงินไม่สำเร็จ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Color(0xFFFF3333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 15,
                top: 30,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //       builder: (context) => PurchasePaymentInformation()),
                      // );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showMissingFileDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icon_error.png', // เปลี่ยนเป็นไอคอนอื่นถ้าอยากให้ดูเบากว่า
                        width: 80,
                        height: 80,
                      ),
                      Text(
                        'กรุณาอัปโหลดไฟล์\nเอกสารประกอบการสั่งซื้อ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color(0xFFFF3333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 15,
                top: 30,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
