import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kaset_mall/purchase_payment.dart';

class PurchaseOrderShippingSum extends StatefulWidget {
  final dynamic order;

  final dynamic addressesList;
  final dynamic result;

  const PurchaseOrderShippingSum({
    Key? key,
    required this.order,
    this.addressesList,
    this.result,
  }) : super(key: key);

  @override
  State<PurchaseOrderShippingSum> createState() =>
      _PurchaseOrderShippingSumState();
}

class _PurchaseOrderShippingSumState extends State<PurchaseOrderShippingSum> {
  void initState() {
    getpurchaseorderdetail();
    getLoadFile();
    getTotalAmount();

    super.initState();
  }

  Map<String, dynamic> getorderdetail = {};
  List<dynamic> getfile = [];
  Map<String, dynamic> totalAmount = {};

  static const waitingForApproval = [
    //รอรับการอนุมัติ
    'W1',
  ]; // status 2
  static const approved = [
    //ได้รับการอนุมัติ
    'A1', 'A2'
  ]; // status 3
  static const notApproved = [
    //ไม่ได้รับการอนุมัติ
    'F1',
    'F2',
    'F3',
    'F4',
    'F5'
  ];
  // ignore: unused_field
  static const waitingPayment = [
    // รอการชำระเงิน
    'W2'
  ];

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

    print('-----------getTotalAmount-------------');
    print(data);

    if (response.statusCode == 200) {
      print(json.encode(response.data));
      setState(() {
        totalAmount = response.data;
      });
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
                                              widget.order['createdate'],
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400),
                                            )
                                          ],
                                        ),
                                        approved.contains(
                                                widget.order['orderstatus'])
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'วันที่อนุมัติใบขอสั่งซื้อ',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    widget.order['orderDate'],
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )
                                                ],
                                              )
                                            : SizedBox()
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
                                'สาเหตุการไม่อนุมัติ',
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
                              'คำสั่งซื้อไม่ตรงกับหนังสืออนุมัติการสั่งซื้อจากเขต',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
              // widget.order != null &&
              //         ['A1', 'A2'].contains(widget.order['orderstatus'])
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
                                              BorderRadius.circular(25),
                                          border: Border.all(
                                              color: Colors.black
                                                  .withOpacity(0.1)),
                                        ),
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
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
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
              approved.contains(widget.order['orderstatus'])
                  ? Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'หลักฐานการชำระเงิน',
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
                            border: Border.all(
                                color: Colors.black.withOpacity(0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    height: 50,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Color(0xFFDCE0E5))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  : SizedBox(),
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
              !notApproved.contains(widget.order['orderstatus']) &&
                      !approved.contains(widget.order['orderstatus']) &&
                      !waitingForApproval.contains(widget.order['orderstatus'])
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
                                  'ยกเลิก',
                                  style: TextStyle(
                                    color: Colors.black,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PurchasePayment(
                                  totalAmount: totalAmount,
                                  orderid: widget.order['orderid'],
                                  result: widget.result,
                                ),
                              ),
                            );
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
                              'กลับสู่หน้าใบขอสั่งซื้อ ',
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

  Color _getStatusColorByCode(String code) {
    switch (code) {
      case 'A1':
      case 'A2':
        return Color(0xFFBEFEC7); // ได้รับการอนุมัติ

      case 'F1':
      case 'F2':
      case 'F3':
      case 'F4':
      case 'F5':
        return Color(0xFFFFDEE0); // ไม่ได้รับการอนุมัติ

      case 'W3':
      case 'W4':
        return Color(0xFFD9D9D9); // รอการแก้ไข

      case 'W1':
      case 'W2':
        return Color(0xFFFFED9E); // รอรับการอนุมัติ

      default:
        return Colors.lightBlueAccent;
    }
  }

  Color _getStatusFontColorByCode(String code) {
    switch (code) {
      case 'A1':
      case 'A2':
        return Color(0xFF00A81C); // ได้รับการอนุมัติ

      case 'F1':
      case 'F2':
      case 'F3':
      case 'F4':
      case 'F5':
        return Color(0xFFDF0C3D); // ไม่ได้รับการอนุมัติ

      case 'W3':
      case 'W4':
        return Color(0xFF000000); // รอการแก้ไข

      case 'W1':
      case 'W2':
        return Color(0xFFDB6E00); // รอรับการอนุมัติ

      default:
        return Colors.white;
    }
  }

  ImageIcon _getStatusIconByCode(String code) {
    if (['A1', 'A2'].contains(code)) {
      return ImageIcon(AssetImage('assets/images/icon_check.png'),
          color: Color(0xFF00A81C));
    } else if (['F1', 'F2', 'F3', 'F4', 'F5'].contains(code)) {
      return ImageIcon(AssetImage('assets/images/icon_cancel.png'),
          color: Color(0xFFDF0C3D));
    } else if (['W3', 'W4'].contains(code)) {
      return ImageIcon(AssetImage('assets/icon_itme.png'),
          color: Color(0xFF000000));
    } else if (['W1', 'W2'].contains(code)) {
      return ImageIcon(AssetImage('assets/icon_itme.png'),
          color: Color(0xFFDB6E00));
    } else {
      return ImageIcon(AssetImage('assets/icon_itme.png'), color: Colors.white);
    }
  }

  String getStatusText(String code) {
    if (['A1', 'A2'].contains(code)) {
      return 'ได้รับการอนุมัติ';
    } else if (['F1', 'F2', 'F3', 'F4', 'F5'].contains(code)) {
      return 'ไม่ได้รับการอนุมัติ';
    } else if (['W3', 'W4'].contains(code)) {
      return 'รายการที่รอการแก้ไข';
    } else if (['W1'].contains(code)) {
      return 'รอรับการอนุมัติ';
    } else if (['W2'].contains(code)) {
      return 'รอรับการชำระเงิน';
    } else {
      return code;
    }
  }
}
