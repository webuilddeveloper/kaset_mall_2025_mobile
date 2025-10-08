import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_mart_v3/purchase_shipping.dart';
import 'package:mobile_mart_v3/widget/dialog.dart';

import 'package:month_picker_dialog/month_picker_dialog.dart';

class purchaseOrderListDraft extends StatefulWidget {
  purchaseOrderListDraft({
    super.key,
    required this.result,
    required this.addressesList,
  });
  final dynamic result;
  final dynamic addressesList;

  @override
  State<purchaseOrderListDraft> createState() => _purchaseOrderListDraftState();
}

class _purchaseOrderListDraftState extends State<purchaseOrderListDraft>
    with WidgetsBindingObserver {
  Map<String, dynamic> getpurchaseorderdraft = {};
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getpurchaseord();
    });

    final now = DateTime.now();

    selectedStartDate = now;
    selectedEndDate = now;

    final thaiMonth = thaiMonths[now.month];
    txtStartDate.text = thaiMonth;
    txtEndDate.text = thaiMonth;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getpurchaseord();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      if (_focusNode.canRequestFocus) {
        getpurchaseord();
      }
    }
  }

  final TextEditingController txtStartDate = TextEditingController();
  final TextEditingController txtEndDate = TextEditingController();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  Future<void> getpurchaseord() async {
    final startMonthFormatted =
        DateFormat('yyyy-MM').format(selectedStartDate!);
    final endMonthFormatted = DateFormat('yyyy-MM').format(selectedEndDate!);

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({
      "uid": widget.result['uid'],
      "orderstatus": "D",
      "month1": startMonthFormatted,
      "month2": endMonthFormatted,
    });
    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/getpurchaseorder.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print('🟢 สำเร็จ 🟢');
      print('success draft');

      setState(() {
        getpurchaseorderdraft = response.data;
      });
      print(
        getpurchaseorderdraft['result'].length,
      );
    } else {
      print(response.statusMessage);
    }
  }

  Future<void> remove({required String? transactionid}) async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({"transactionid": transactionid});
    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/purchaseorderdelete.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print('🟢 สำเร็จ 🟢');
      print(json.encode(response.data));
    } else {
      print(response.statusMessage);
    }
    getpurchaseord();
  }

  final List<String> thaiMonths = [
    '',
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม'
  ];

  void _pickMonth({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showMonthPicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
      initialDate:
          isStart ? (selectedStartDate ?? now) : (selectedEndDate ?? now),
      monthPickerDialogSettings: MonthPickerDialogSettings(
        headerSettings: PickerHeaderSettings(
          headerBackgroundColor: Color(0xFF012A6C),
        ),
        dateButtonsSettings: PickerDateButtonsSettings(
          selectedMonthBackgroundColor: Color(0xFF012A6C),
          selectedMonthTextColor: Colors.white,
          unselectedMonthsTextColor: Colors.black87,
          currentMonthTextColor: Colors.red,
        ),
        actionBarSettings: PickerActionBarSettings(
          confirmWidget: Text(
            'ตกลง',
            style: TextStyle(
              color: Color(0xFF012A6C),
              fontWeight: FontWeight.bold,
            ),
          ),
          cancelWidget: Text(
            'ยกเลิก',
            style: TextStyle(
              color: Color(0xFF012A6C),
              fontWeight: FontWeight.bold,
            ),
          ),
          buttonSpacing: 16,
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        final thaiMonth = thaiMonths[picked.month];
        final valueToDisplay = '$thaiMonth';

        if (isStart) {
          selectedStartDate = picked;
          txtStartDate.text = valueToDisplay;
          print('selectedStartDate: $selectedStartDate');
        } else {
          selectedEndDate = picked;
          txtEndDate.text = valueToDisplay;
          print('selectedEndDate: $selectedEndDate');
        }

        // ✅ ถ้ามีทั้ง Start และ End แล้วค่อยเรียก getpurchaseord()
        if (selectedStartDate != null && selectedEndDate != null) {
          getpurchaseord(); // ไม่ต้องใส่ setState ซ้อนอีกแล้ว
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // เพิ่ม WillPopScope เพื่อตรวจจับเมื่อกลับมาจากหน้าอื่น
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
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
              '(ร่าง) ใบขอสั่งซื้อของฉัน',
              style: TextStyle(color: Colors.white),
            ),
          ),
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
        body: Focus(
          focusNode: _focusNode,
          // ใช้ Focus เพื่อตรวจจับเมื่อกลับมาที่หน้านี้
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              // เรียก API เมื่อหน้านี้ได้รับ focus กลับมา
              getpurchaseord();
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.only(right: 15, left: 15, top: 20, bottom: 40),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ตั้งแต่',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    child: GestureDetector(
                      onTap: () {
                        _pickMonth(isStart: true);
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: txtStartDate,
                          decoration: InputDecoration(
                            hintText: 'เลือกเดือนเริ่มต้น',
                            hintStyle: TextStyle(
                                fontSize: 12, color: Color(0xFF707070)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF707070)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF707070)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF707070)),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            suffixIcon:
                                Icon(Icons.calendar_today_outlined, size: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'จนถึง',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _pickMonth(isStart: false);
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: txtEndDate,
                        decoration: InputDecoration(
                          hintText: 'เลือกเดือนสิ้นสุด',
                          hintStyle:
                              TextStyle(fontSize: 12, color: Color(0xFF707070)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF707070)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF707070)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF707070)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          suffixIcon:
                              Icon(Icons.calendar_today_outlined, size: 15),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 1,
                    color: Colors.black.withOpacity(0.2),
                  ),
                  SizedBox(height: 20),
                  getpurchaseorderdraft['result'] == null
                      ? Center(
                          child: Text(
                          'ไม่พบข้อมูลการสั่งชื้อ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF949596),
                          ),
                        ))
                      : Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF707070).withOpacity(0.2),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(
                              color: Color(0xFFDCE0E5),
                              height: 30,
                            ),
                            itemCount: getpurchaseorderdraft['result'].length,
                            itemBuilder: (context, index) {
                              final order =
                                  getpurchaseorderdraft['result'][index];

                              return GestureDetector(
                                // onTap: () {
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => PurchaseShipping(
                                //         result: widget.result,
                                //         allItems:
                                //             getpurchaseorderdraft['result']
                                //                 [index]['listdata'],
                                //         orderid: order['orderid'],
                                //       ),
                                //     ),
                                //   ).then((_) {
                                //     // เรียก API เมื่อกลับมาจากหน้า PurchaseShipping
                                //     getpurchaseord();
                                //   });
                                //   print(
                                //       '---------> draftorderid :  ${order['orderid']}');
                                // },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PurchaseShipping(
                                        result: widget.result,
                                        allItems:
                                            getpurchaseorderdraft['result']
                                                [index]['listdata'],
                                        orderid: order['orderid'],
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "เลขใบขอสั่งซื้อ\n${order['orderid']}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFD9D9D9),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ImageIcon(
                                                AssetImage(
                                                    'assets/icon_itme.png'),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'ร่างใบขอสั่งซื้อ',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ปุ่มลบ
                                        IconButton(
                                          onPressed: () {
                                            // await remove(
                                            //     transactionid:
                                            //         order['orderid']);
                                            // setState(() {
                                            //   getpurchaseorderdraft['result']
                                            //       .removeAt(index);
                                            // });
                                            showDeleteDialog(
                                                context: context,
                                                onTapD: () {
                                                  Navigator.pop(context);
                                                },
                                                onTapS: () async {
                                                  await remove(
                                                      transactionid:
                                                          order['orderid']);
                                                  setState(() {
                                                    getpurchaseorderdraft[
                                                            'result']
                                                        .removeAt(index);
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                title: 'ยกเลิกร่างใบขอสั่งซื้อ',
                                                subtitle:
                                                    'คุณต้องการที่จะลบร่างคำสั่งซื้อใบปพ. นี้หรือไม่หากยืนยันจะเป็นอันเสร็จสิ้นการยกเลิกร่างใบคำสั่งซื้อ',
                                                txtbtnD: 'ยกเลิก',
                                                txtbtnS: 'ยืนยัน');
                                          },
                                          icon: Image.asset(
                                            'assets/delete-bin.png',
                                            fit: BoxFit.contain,
                                            height: 25,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "วันที่สั่งซื้อ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          formatDateThai(order['createdate']),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: order['listdata'].length,
                                      itemBuilder: (context, itemIndex) {
                                        final item =
                                            order['listdata'][itemIndex];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: item['typeprint'] ==
                                                              'ปพ.1:ป'
                                                          ? Color(0xFFFBD5E6)
                                                          : item['typeprint'] ==
                                                                  'ปพ.1:บ'
                                                              ? Color(
                                                                  0xFFD5F7FB)
                                                              : Color(
                                                                  0xFFFDE86C),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                          color: Colors.black),
                                                    ),
                                                    child: Text(
                                                      item['typeprint'],
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      item['name'],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatDateThai(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);

      return DateFormat("d MMMM yyyy", "th").format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
