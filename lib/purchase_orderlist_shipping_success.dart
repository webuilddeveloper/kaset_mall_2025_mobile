import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';

class PurchaseOrderDetailList extends StatefulWidget {
  final dynamic order;

  final dynamic addressesList;
  final dynamic result;

  const PurchaseOrderDetailList({
    Key? key,
    required this.order,
    this.addressesList,
    this.result,
  }) : super(key: key);

  @override
  State<PurchaseOrderDetailList> createState() =>
      _PurchaseOrderDetailListState();
}

class _PurchaseOrderDetailListState extends State<PurchaseOrderDetailList> {
  void initState() {
    getpurchaseorderdetail();
    getLoadFile();
    getTotalAmount();
    getAllDocuments();

    super.initState();
  }

  Map<String, dynamic> getorderdetail = {};
  List<dynamic> getfile = [];
  Map<String, dynamic> totalAmount = {};
  bool _isExpanded = false;

  static const waitingDoc = ['W4']; //รอแนบเอกสาร
  static const approved = [
    'W2',
    'P3',
    'P4-1',
    'P4',
    'P5',
    'P6',
    'P7'
  ]; //ได้รับการอนุมัติ
  static const notApproved = [
    'W3',
    'C1',
    'C2-1',
    'C2-2',
    'C3',
    'F1',
    'F2',
    'F3',
    'F4',
    'F5'
  ]; //ไม่ได้รับการอนุมัติ
  static const verification = [
    'W1',
    'A1',
    'A2',
    'A2-1',
    'P1',
    'P1-1',
    'P2',
    'P3-1',
    'C2'
  ]; //รอการตรวจสอบ

  Future<void> getpurchaseorderdetail() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({
      "transactionid": widget.order['orderid'],
    });
    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/getpurchaseorderdetail.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      setState(() {
        getorderdetail = response.data;
      });
    } else {
      print(response.statusMessage);
    }
  }

  Future<void> getLoadFile() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({
      "transactionid": "${widget.order['orderid']}",
      "page": "DOC-SCHOOL",
    });
    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/getloadfilelist.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      setState(() {
        getfile = response.data['result'] ?? [];
      });
    } else {
      print(response.statusMessage);
    }
  }

  Future<void> getTotalAmount() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({
      "transactionid": widget.order['orderid'],
    });
    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/getordercartsummary.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print(json.encode(response.data));
      setState(() {
        totalAmount = response.data;
      });
    } else {
      print(response.statusMessage);
    }
  }

  // กำหนดตัวแปร Map สำหรับเก็บข้อมูลเอกสารต่างๆ
  Map<String, dynamic> DOCSCHOOL = {};
  Map<String, dynamic> DOCAPPROVAL = {};
  Map<String, dynamic> DOCSLIP = {};
  Map<String, dynamic> DOCSLIPMORE = {};

// ฟังก์ชันสำหรับดึงข้อมูลเอกสารต่างๆตามประเภท
  Future<Map<String, dynamic>> getDocumentsByType(String documentType) async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json',
      'Cookie': 'PHPSESSID=70ig76ot83n5paa61d4davtu30'
    };

    var data = json.encode({
      "transactionid": widget.order['orderid'],
      "page": documentType,
    });

    var dio = Dio();
    try {
      var response = await dio.request(
        'https://etranscript.suksapan.or.th/otepmobileapi/getloadfilelist.php',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print("ดึงข้อมูล $documentType สำเร็จ");
        print(json.encode(response.data));
        return response.data;
      } else {
        print("เกิดข้อผิดพลาด: ${response.statusMessage}");
        return {};
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการเชื่อมต่อ: $e");
      return {};
    }
  }

// ฟังก์ชันสำหรับดึงข้อมูลเอกสารทั้งหมด
  Future<void> getAllDocuments() async {
    // ดึงข้อมูลเอกสารประกอบคำสั่งซื้อ
    DOCSCHOOL = await getDocumentsByType("DOC-SCHOOL");

    // ดึงข้อมูลไฟล์หนังสืออนุมัติจากทางเขต
    DOCAPPROVAL = await getDocumentsByType("DOC-APPROVAL");

    // ดึงข้อมูลใบแทนใบเสร็จ
    DOCSLIP = await getDocumentsByType("DOC-SLIP");

    // ดึงข้อมูลใบแทนใบเสร็จ (เพิ่มเติม)
    DOCSLIPMORE = await getDocumentsByType("DOC-SLIP-MORE");

    // แจ้งเตือนเมื่อดึงข้อมูลเสร็จสิ้น
    print("ดึงข้อมูลเอกสารทั้งหมดเสร็จสิ้น");

    // อัพเดต UI หรือทำอย่างอื่นต่อ
    setState(() {
      // อัพเดต UI ตามต้องการ
    });
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
          'ใบขอสั่งซื้อ',
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
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColorByCode(widget.order['orderstatus']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _getStatusIconByCode(widget.order['orderstatus']),
                          const SizedBox(width: 6),
                          Text(
                            getStatusText(widget.order['orderstatus']),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _getStatusFontColorByCode(
                                  widget.order['orderstatus']),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              //'ยกเลิก/คืนเงิน/คืนสินค้า'
              !notApproved.contains(widget.order['orderstatus'])
                  ? Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.black.withOpacity(0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Container(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'หมายเลขคำสั่งซื้อ',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              widget.order['orderid'],
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'วันที่ออกใบขอสั่งซื้อ',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              getorderdetail['createdate'] ??
                                                  '-- -- ----',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'วันที่อนุมัติใบขอสั่งซื้อ',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              getorderdetail['podate'] ??
                                                  '-- -- ----',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFFD92D20),
                              ),
                            ),
                            SizedBox(width: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'สาเหตุการขอคืนเงิน/คืนสินค้า',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'ได้รับสินค้าไม่ครบตามจำนวน',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 20),
              approved.contains(widget.order['orderstatus'])
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFF039855),
                              ),
                            ),
                            SizedBox(width: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ไฟล์หนังสืออนุมัติจากทางเขต',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Color(0xFFDCE0E5))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ImageIcon(
                                    AssetImage('assets/download-1.png'),
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'xxxxxxxxxxxxxx',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Color(0xFFDCE0E5))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ImageIcon(
                                    AssetImage('assets/download-1.png'),
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'xxxxxxxxxxxxxx',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  : SizedBox(),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ที่อยู่ในการจัดส่ง',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  getorderdetail['addressId'] == '2'
                                      ? ListTile(
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${widget.result['fname']} ${widget.result['lname'] ?? '-'}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Text(
                                                "| ${widget.result['tel']}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Text(
                                                '${widget.addressesList['address'] ?? '-'}',
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'รับที่องค์การค้า\n${getorderdetail['branchName']}',
                                            maxLines: 5,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ตัวเลือกการจัดส่ง',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Column(
                              children: [
                                Text(
                                  getorderdetail['typeName'] ?? '-',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                      child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ประเภทสั่งซื้อ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Column(
                            children: [
                              Text(
                                // "สั่งซื้อเอง",
                                getorderdetail['buyerName'] ?? '-',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ))
                ],
              ),

              SizedBox(height: 20),
              // 3. ใบแทนใบเสร็จ
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFF039855),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ใบแทนใบเสร็จ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        SizedBox(height: 12),

                        // ListView สำหรับ DOCSLIP
                        DOCSLIP['result'] != null &&
                                DOCSLIP['result'].length > 0
                            ? ListView.builder(
                                itemCount: DOCSLIP['result'].length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFCA0A6),
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          Border.all(color: Color(0xFFDCE0E5)),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (DOCSLIP['result'][index]
                                                ['filepath'] !=
                                            null) {
                                          // โค้ดสำหรับเปิดหรือดาวน์โหลดไฟล์
                                          // launchFile(DOCSLIP['result'][index]['filepath']);
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ImageIcon(
                                              AssetImage(
                                                  'assets/download-1.png'),
                                              color: Colors.black,
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                DOCSLIP['result'][index]
                                                        ['fname'] ??
                                                    'เอกสาร',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Color(0xFFDCE0E5)),
                                ),
                                child: Center(
                                  child: Text(
                                    'ไม่มีเอกสาร',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // 4. ใบแทนใบเสร็จ (เพิ่มเติม)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFF039855),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ใบแทนใบเสร็จ (เพิ่มเติม)',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        SizedBox(height: 12),

                        // ListView สำหรับ DOCSLIPMORE
                        DOCSLIPMORE['result'] != null &&
                                DOCSLIPMORE['result'].length > 0
                            ? ListView.builder(
                                itemCount: DOCSLIPMORE['result'].length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFCA0A6),
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          Border.all(color: Color(0xFFDCE0E5)),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (DOCSLIPMORE['result'][index]
                                                ['filepath'] !=
                                            null) {
                                          // โค้ดสำหรับเปิดหรือดาวน์โหลดไฟล์
                                          // launchFile(DOCSLIPMORE['result'][index]['filepath']);
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ImageIcon(
                                              AssetImage(
                                                  'assets/download-1.png'),
                                              color: Colors.black,
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                DOCSLIPMORE['result'][index]
                                                        ['fname'] ??
                                                    'เอกสาร',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Color(0xFFDCE0E5)),
                                ),
                                child: Center(
                                  child: Text(
                                    'ไม่มีเอกสาร',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. ไฟล์หนังสือขอสั่งซื้อแบบพิมพ์ทางการศึกษา
                        Text(
                          'ไฟล์หนังสือขอสั่งซื้อแบบพิมพ์ทางการศึกษา',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        SizedBox(height: 12),

                        // // ListView สำหรับ DOCSCHOOL
                        // DOCSCHOOL['result'] != null &&
                        //         DOCSCHOOL['result'].length > 0
                        //     ? ListView.builder(
                        //         itemCount: DOCSCHOOL['result'].length,
                        //         shrinkWrap: true,
                        //         physics: NeverScrollableScrollPhysics(),
                        //         itemBuilder: (context, index) {
                        //           return Container(
                        //             margin: EdgeInsets.only(bottom: 8),
                        //             height: 50,
                        //             width: double.infinity,
                        //             decoration: BoxDecoration(
                        //               color: Colors.white,
                        //               borderRadius: BorderRadius.circular(10),
                        //               border:
                        //                   Border.all(color: Color(0xFFDCE0E5)),
                        //             ),
                        //             child: InkWell(
                        //               onTap: () {
                        //                 if (DOCSCHOOL['result'][index]
                        //                         ['filepath'] !=
                        //                     null) {
                        //                   // โค้ดสำหรับเปิดหรือดาวน์โหลดไฟล์
                        //                   // launchFile(DOCSCHOOL['result'][index]['filepath']);
                        //                 }
                        //               },
                        //               child: Row(
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.center,
                        //                 children: [
                        //                   ImageIcon(
                        //                     AssetImage('assets/download-1.png'),
                        //                     color: Colors.black,
                        //                   ),
                        //                   SizedBox(width: 10),
                        //                   Expanded(
                        //                     child: Text(
                        //                       DOCSCHOOL['result'][index]
                        //                               ['fname'] ??
                        //                           'เอกสาร',
                        //                       style: TextStyle(
                        //                         color: Colors.black,
                        //                         fontSize: 16,
                        //                         fontWeight: FontWeight.bold,
                        //                       ),
                        //                       overflow: TextOverflow.ellipsis,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           );
                        //         },
                        //       )
                        //     :
                        Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Color(0xFFDCE0E5)),
                          ),
                          child: Center(
                            child: Text(
                              'ไม่มีเอกสาร',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // 2. ไฟล์หนังสืออนุมัติจากทางเขต
                        Text(
                          'ไฟล์หนังสืออนุมัติจากทางเขต',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        SizedBox(height: 12),
                        DOCAPPROVAL['result'] != null &&
                                DOCAPPROVAL['result'].length > 0
                            ? ListView.builder(
                                itemCount: DOCAPPROVAL['result'].length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFCA0A6),
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          Border.all(color: Color(0xFFDCE0E5)),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (DOCAPPROVAL['result'][index]
                                                ['filepath'] !=
                                            null) {}
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ImageIcon(
                                              AssetImage(
                                                  'assets/download-1.png'),
                                              color: Colors.black,
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                DOCAPPROVAL['result'][index]
                                                        ['fname'] ??
                                                    'เอกสาร',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Color(0xFFDCE0E5)),
                                ),
                                child: Center(
                                  child: Text(
                                    'ไม่มีเอกสาร',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'เอกสารประกอบการสั่งซื้อ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: getfile.isNotEmpty
                            ? Container(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: getfile.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFCA0A6),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.black
                                                  .withOpacity(0.1)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Row(
                                            children: [
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  getfile[index]['fname'] ??
                                                      'ไม่มีชื่อไฟล์',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : SizedBox(
                                height: 50,
                                child: Center(
                                  child: Text(
                                    'ยังไม่มีไฟล์แนบ',
                                    style: TextStyle(
                                      color: Color(0xFF707070),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'สถานะการจัดส่ง',
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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      // ส่วนหัว (header) ที่สามารถคลิกเพื่อย่อ/ขยาย
                      InkWell(
                        borderRadius: _isExpanded
                            ? BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8))
                            : BorderRadius.circular(8),
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'XXX Express : TH00000000000',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'พัสดุจัดส่งสำเร็จแล้ว',
                                style: TextStyle(
                                  color: _getStatusFontColorByCode(
                                      widget.order['orderstatus']),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '20-10-2024 11:11',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ส่วนเนื้อหา timeline จะแสดงเมื่อ expanded (อยู่ใน Container เดียวกัน)
                      if (_isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 16.0),
                          child: Column(
                            children: [
                              Divider(color: Colors.black.withOpacity(0.2)),
                              _buildTimeline(),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // SizedBox(height: 20),
              // approved.contains(widget.order['orderstatus']) ||
              //         waitingDoc.contains(widget.order['orderstatus'])
              //     ? Column(
              //         children: [
              //           Align(
              //             alignment: Alignment.centerLeft,
              //             child: Text(
              //               'หลักฐานการชำระเงิน',
              //               style: TextStyle(
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.w600,
              //                   color: Colors.black),
              //             ),
              //           ),
              //           SizedBox(height: 20),
              //           Container(
              //             width: double.infinity,
              //             decoration: BoxDecoration(
              //               color: Colors.white,
              //               borderRadius: BorderRadius.circular(20),
              //               border: Border.all(
              //                   color: Colors.black.withOpacity(0.2)),
              //             ),
              //             child: Padding(
              //               padding: const EdgeInsets.all(20),
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   GestureDetector(
              //                     onTap: () {},
              //                     child: Container(
              //                       height: 50,
              //                       width: 200,
              //                       decoration: BoxDecoration(
              //                           color: Colors.white,
              //                           borderRadius: BorderRadius.circular(10),
              //                           border: Border.all(
              //                               color: Color(0xFFDCE0E5))),
              //                       child: Row(
              //                         mainAxisAlignment:
              //                             MainAxisAlignment.center,
              //                         children: [
              //                           ImageIcon(
              //                             AssetImage('assets/download-1.png'),
              //                             color: Colors.black,
              //                           ),
              //                           SizedBox(width: 10),
              //                           Text(
              //                             'xxxxxxxxxxxxxx',
              //                             style: TextStyle(
              //                               color: Colors.black,
              //                               fontSize: 16,
              //                               fontWeight: FontWeight.bold,
              //                             ),
              //                           ),
              //                         ],
              //                       ),
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           )
              //         ],
              //       )
              //     : SizedBox(),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'รายการสินค้า',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          color: Color(0xFFDCE0E5),
                          height: 30,
                        ),
                        itemCount: widget.order['listdata'].length,
                        itemBuilder: (context, index) {
                          final item = widget.order['listdata'][index];

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: GestureDetector(
                                                child: Text(
                                                  item['name'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF0F0F0),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                      '${item['quantityCart']} / ${item['unit']}'),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: item['typeprint'] ==
                                                        'ปพ.1:ป'
                                                    ? Color(0xFFFBD5E6)
                                                    : item['typeprint'] ==
                                                            'ปพ.1:บ'
                                                        ? Color(0xFFD5F7FB)
                                                        : Color(0xFFFDE86C),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.black),
                                              ),
                                              child: Text(
                                                item['typeprint'],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Text(
                                              '  ${item['priceCart'] ?? '-'} บาท/ ${item['unit']}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
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
                        title: 'รวมเงิน',
                        detail: '${totalAmount['totalamount']} บาท',
                        fontWeightTitle: FontWeight.w400,
                        colorTitle: Colors.black.withOpacity(0.6),
                        fontSizeTitle: 13,
                        fontSizeDetail: 13,
                      ),
                      SizedBox(height: 10),
                      textDetail(
                        title: 'ค่าขนส่ง ',
                        detail: '${totalAmount['shippingprice']} บาท',
                        fontWeightTitle: FontWeight.w400,
                        colorTitle: Colors.black.withOpacity(0.6),
                        fontSizeTitle: 13,
                        fontSizeDetail: 13,
                      ),
                      SizedBox(height: 10),
                      textDetail(
                        title: 'มูลค่าสินค้าและค่าขนส่งก่อนภาษี',
                        detail: '${totalAmount['totalamountbeforetax']} บาท',
                        fontWeightTitle: FontWeight.w400,
                        colorTitle: Colors.black.withOpacity(0.6),
                        fontSizeTitle: 13,
                        fontSizeDetail: 13,
                      ),
                      SizedBox(height: 10),
                      textDetail(
                        title: 'ภาษีมูลค่าเพิ่ม ',
                        detail: '${totalAmount['totalvat']}บาท',
                        fontWeightTitle: FontWeight.w400,
                        colorTitle: Colors.black.withOpacity(0.6),
                        fontSizeTitle: 13,
                        fontSizeDetail: 13,
                      ),
                      SizedBox(height: 10),
                      textDetail(
                        title: 'ยอดสุทธิ ',
                        detail: '${totalAmount['totalsum']} บาท',
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
                            convertToThaiBahtText('${totalAmount['totalsum']}'),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // !notApproved.contains(widget.order['orderstatus']) &&
              //         !approved.contains(widget.order['orderstatus'])
              //     ? Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           GestureDetector(
              //             onTap: () {
              //               Navigator.of(context).pop();
              //             },
              //             child: Container(
              //               height: 50,
              //               width: MediaQuery.of(context).size.width * 0.45,
              //               decoration: BoxDecoration(
              //                 color: Color(0xFFD9D9D9),
              //                 borderRadius: BorderRadius.circular(10),
              //               ),
              //               child: Center(
              //                 child: Padding(
              //                   padding:
              //                       const EdgeInsets.symmetric(horizontal: 25),
              //                   child: Text(
              //                     'ยกเลิก',
              //                     style: TextStyle(
              //                       color: Colors.black,
              //                       fontSize: 16,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //           widget.order['status'] == 'รายการรอรับการแก้ไข'
              //               ? GestureDetector(
              //                   onTap: () {
              //                     showPinkDialog(
              //                         context: context,
              //                         onTap: () {
              //                           Navigator.of(context).pop();
              //                           showSuccessDialog(
              //                             context: context,
              //                             onTapD: () {
              //                               Navigator.of(context)
              //                                   .push(MaterialPageRoute(
              //                                 builder: (context) =>
              //                                     HomeCentralPage(),
              //                               ));
              //                             },
              //                             onTapS: () {
              //                               Navigator.of(context).pop();
              //                               Navigator.of(context).pop();
              //                               Navigator.of(context).pop();
              //                             },
              //                             title: 'ยืนยันการออกใบขอสั่งซื้อ',
              //                             subtitle: '',
              //                             txtbtnD: 'กลับหน้าหลัก',
              //                             txtbtnS: 'ใบขอสั่งซื้อของฉัน',
              //                           );
              //                         },
              //                         title: 'สรุปรายการสินค้า',
              //                         subtitle:
              //                             'รายการของคุณมีสินค้าประเภทเอกสารควบคุม ต้องมีการขออนุญาตจากเขตพื้นที่การศึกษาก่อนดำเนินการต่อ');
              //                   },
              //                   child: Container(
              //                     height: 50,
              //                     width:
              //                         MediaQuery.of(context).size.width * 0.45,
              //                     decoration: BoxDecoration(
              //                       color: Color(0xFF012A6C),
              //                       borderRadius: BorderRadius.circular(10),
              //                     ),
              //                     child: Center(
              //                       child: Padding(
              //                         padding: const EdgeInsets.symmetric(
              //                             horizontal: 25),
              //                         child: Text(
              //                           'ยืนยัน',
              //                           style: TextStyle(
              //                             color: Colors.white,
              //                             fontSize: 16,
              //                             fontWeight: FontWeight.bold,
              //                           ),
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                 )
              //               : GestureDetector(
              //                   onTap: () {
              //                     Navigator.push(
              //                       context,
              //                       MaterialPageRoute(
              //                         builder: (context) => PurchasePayment(
              //                           totalAmount: totalAmount,
              //                           orderid: widget.order['orderid'],
              //                           result: widget.result,
              //                         ),
              //                       ),
              //                     );
              //                   },
              //                   child: Container(
              //                     height: 50,
              //                     width:
              //                         MediaQuery.of(context).size.width * 0.45,
              //                     decoration: BoxDecoration(
              //                       color: Color(0xFF012A6C),
              //                       borderRadius: BorderRadius.circular(10),
              //                     ),
              //                     child: Center(
              //                       child: Padding(
              //                         padding: const EdgeInsets.symmetric(
              //                             horizontal: 25),
              //                         child: Text(
              //                           'ชำระเงิน',
              //                           style: TextStyle(
              //                             color: Colors.white,
              //                             fontSize: 16,
              //                             fontWeight: FontWeight.bold,
              //                           ),
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                 ),
              //         ],
              //       )
              //     : GestureDetector(
              //         onTap: () {
              //           Navigator.pop(context);
              //         },
              //         child: Container(
              //           height: 50,
              //           width: MediaQuery.of(context).size.width,
              //           decoration: BoxDecoration(
              //             color: Color(0xFF012A6C),
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: Center(
              //             child: Padding(
              //               padding: const EdgeInsets.symmetric(horizontal: 25),
              //               child: Text(
              //                 'กลับสู่หน้าใบขอสั่งซื้อ ',
              //                 style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold,
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              SizedBox(height: 20),
              widget.order['status'] == 'จัดส่งสำเร็จ'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.45,
                            decoration: BoxDecoration(
                              color: Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  'คืนเงิน / คืนสินค้า',
                                  style: TextStyle(
                                    color: Color(0xff012A6C),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.45,
                            decoration: BoxDecoration(
                              color: Color(0xFF012A6C),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  'กลับสู่หน้าใบขอสั่งซื้อ  ',
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
                  : GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Color(0xFF012A6C),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              'กลับสู่หน้าใบขอสั่งซื้อ  ',
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
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
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

  String convertToThaiBahtText(String numberString) {
    final number = double.tryParse(numberString.replaceAll(',', '')) ?? 0.0;
    if (number == 0) return 'ศูนย์บาทถ้วน';

    final bahtText = _readNumberInThai(number.floor()) + 'บาท';
    final satang = ((number - number.floor()) * 100).round();

    if (satang == 0) {
      return bahtText + 'ถ้วน';
    } else {
      return bahtText + _readNumberInThai(satang) + 'สตางค์';
    }
  }

  String _readNumberInThai(int number) {
    const numberText = [
      'ศูนย์',
      'หนึ่ง',
      'สอง',
      'สาม',
      'สี่',
      'ห้า',
      'หก',
      'เจ็ด',
      'แปด',
      'เก้า'
    ];
    const positionText = ['', 'สิบ', 'ร้อย', 'พัน', 'หมื่น', 'แสน', 'ล้าน'];

    if (number == 0) return '';

    String result = '';
    String numberStr = number.toString();
    int len = numberStr.length;

    for (int i = 0; i < len; i++) {
      int digit = int.parse(numberStr[i]);
      int position = len - i - 1;

      if (digit != 0) {
        if (position == 0 && digit == 1 && len > 1) {
          result += 'เอ็ด';
        } else if (position == 1 && digit == 2) {
          result += 'ยี่';
        } else if (position == 1 && digit == 1) {
          result += '';
        } else {
          result += numberText[digit];
        }

        result += positionText[position % 6];
      }
    }

    return result;
  }

  Widget _buildTimeline() {
    final trackingData = [
      {
        'date': 'วันนี้ 14:46',
        'status': 'พัสดุกำลังนำส่ง',
        'isActive': true,
      },
      {
        'date': '11 มี.ค. 19:59',
        'status': 'พัสดุออกจากศูนย์คัดแยกสินค้า',
        'isActive': false,
      },
      {
        'date': '08 มี.ค. 17:21',
        'status': 'ผู้ส่งกำลังเตรียมพัสดุ',
        'isActive': false,
      },
      {
        'date': '03 มี.ค. 00:02',
        'status': 'สั่งซื้อสินค้าสำเร็จ',
        'isActive': false,
        'isLast': true,
      },
    ];

    return FixedTimeline.tileBuilder(
      theme: TimelineThemeData(
        nodePosition: 0,
        color: const Color(0xff1C2F72),
        indicatorTheme: const IndicatorThemeData(
          position: 0,
          size: 20.0,
        ),
        connectorTheme: const ConnectorThemeData(
          thickness: 2.5,
        ),
      ),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        itemCount: trackingData.length,
        contentsBuilder: (_, index) {
          final item = trackingData[index];
          final bool isLast =
              item.containsKey('isLast') ? item['isLast'] as bool : false;

          return Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 20.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: isLast ? 16.0 : 0),
              decoration: BoxDecoration(
                color: isLast ? const Color(0xFFF5F5F5) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['date'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['status'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        indicatorBuilder: (_, index) {
          final isActive = trackingData[index]['isActive'] as bool;
          return DotIndicator(
            size: 20,
            color: isActive ? const Color(0xff1C2F72) : Colors.white,
            border: Border.all(
              color: const Color(0xff1C2F72),
              width: 2,
            ),
          );
        },
        connectorBuilder: (_, index, connectorType) {
          return SolidLineConnector(
            color: const Color(0xff1C2F72),
            thickness: 2,
          );
        },
      ),
    );
  }

  Color _getStatusColorByCode(String code) {
    if (['W4'].contains(code)) return Color(0xFFD9D9D9); // รอแนบเอกสาร
    if (['W1', 'A1', 'A2', 'A2-1', 'P1', 'P1-1', 'P2', 'P3-1', 'C2']
        .contains(code)) {
      return Color(0xFFFFED9E); // รอรับการอนุมัติ
    }
    if (['W2', 'P3', 'P4-1', 'P4', 'P5', 'P6', 'P7'].contains(code)) {
      return Color(0xFFBEFEC7); // ได้รับการอนุมัติ
    }
    if (['W3', 'C1', 'C2-1', 'C2-2', 'C3', 'F1', 'F2', 'F3', 'F4', 'F5']
        .contains(code)) {
      return Color(0xFFFFDEE0); // ไม่ได้รับการอนุมัติ
    }
    return Colors.lightBlueAccent;
  }

  Color _getStatusFontColorByCode(String code) {
    if (['W4'].contains(code)) return Color(0xFF000000); // รอแนบเอกสาร
    if (['W1', 'A1', 'A2', 'A2-1', 'P1', 'P1-1', 'P2', 'P3-1', 'C2']
        .contains(code)) {
      return Color(0xFFDB6E00); // รอรับการอนุมัติ
    }
    if (['W2', 'P3', 'P4-1', 'P4', 'P5', 'P6', 'P7'].contains(code)) {
      return Color(0xFF00A81C); // ได้รับการอนุมัติ
    }
    if (['W3', 'C1', 'C2-1', 'C2-2', 'C3', 'F1', 'F2', 'F3', 'F4', 'F5']
        .contains(code)) {
      return Color(0xFFDF0C3D); // ไม่ได้รับการอนุมัติ
    }
    return Colors.white;
  }

  ImageIcon _getStatusIconByCode(String code) {
    if (['W2', 'P3', 'P4-1', 'P4', 'P5', 'P6', 'P7'].contains(code)) {
      return ImageIcon(AssetImage('assets/images/icon_check.png'),
          color: Color(0xFF00A81C));
    } else if (['W3', 'C1', 'C2-1', 'C2-2', 'C3', 'F1', 'F2', 'F3', 'F4', 'F5']
        .contains(code)) {
      return ImageIcon(AssetImage('assets/images/icon_cancel.png'),
          color: Color(0xFFDF0C3D));
    } else if (['W4'].contains(code)) {
      return ImageIcon(AssetImage('assets/icon_itme.png'),
          color: Color(0xFF000000)); // เอกสาร
    } else if (['W1', 'A1', 'A2', 'A2-1', 'P1', 'P1-1', 'P2', 'P3-1', 'C2']
        .contains(code)) {
      return ImageIcon(AssetImage('assets/icon_itme.png'),
          color: Color(0xFFDB6E00)); // รออนุมัติ
    } else {
      return ImageIcon(AssetImage('assets/icon_itme.png'), color: Colors.white);
    }
  }

  String getStatusText(String code) {
    if (['W4'].contains(code)) return 'รอแนบเอกสาร';
    if (['W1', 'A1', 'A2', 'A2-1', 'P1', 'P1-1', 'P2', 'P3-1', 'C2']
        .contains(code)) {
      return 'รอการตรวจสอบ';
    }
    if (['W2', 'P3', 'P4-1', 'P4', 'P5', 'P6', 'P7'].contains(code)) {
      return 'ได้รับการอนุมัติ';
    }
    if (['W3', 'C1', 'C2-1', 'C2-2', 'C3', 'F1', 'F2', 'F3', 'F4', 'F5']
        .contains(code)) {
      return 'ไม่ได้รับการอนุมัติ';
    }
    return code;
  }
}
