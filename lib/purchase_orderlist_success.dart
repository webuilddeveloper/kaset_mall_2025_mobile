import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_mart_v3/purchase_orderlist_shipping_success.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class OrderList extends StatefulWidget {
  const OrderList(
      {super.key, required this.result, required this.addressesList});
  final dynamic result;
  final dynamic addressesList;
  @override
  State<OrderList> createState() => _getOrderDetaiLlistState();
}

class _getOrderDetaiLlistState extends State<OrderList>
    with WidgetsBindingObserver {
  String? selectedStatus = "ทั้งหมด";
  List<String> selectedStatusApi = ["All"];

  final Map<String, List<String>> statusMap = {
    "ทั้งหมด": [
      'W4',
      'W1',
      'A1',
      'A2',
      'A2-1',
      'P1',
      'P1-1',
      'P2',
      'P3-1',
      'C2',
      'W2',
      'P3',
      'P4-1',
      'P4',
      'P5',
      'P6',
      'P7',
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
    ],
    "รอแนบเอกสาร": ['W4'],
    "รอรับการอนุมัติ": [
      'W1',
      'A1',
      'A2',
      'A2-1',
      'P1',
      'P1-1',
      'P2',
      'P3-1',
      'C2'
    ],
    "ได้รับการอนุมัติ": ['W2', 'P3', 'P4-1', 'P4', 'P5', 'P6', 'P7'],
    "ไม่ได้รับการอนุมัติ": [
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
    ],
  };

  final List<String> itemsStatus = [
    "ทั้งหมด",
    "รอแนบเอกสาร",
    "รอรับการอนุมัติ",
    "ได้รับการอนุมัติ",
    "ไม่ได้รับการอนุมัติ",
  ];

  Map getorderdetaillist = {};

  final TextEditingController txtStartDate = TextEditingController();
  final TextEditingController txtEndDate = TextEditingController();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // เพิ่ม observer เพื่อติดตาม lifecycle ของแอป
    WidgetsBinding.instance.addObserver(this);

    _initializeData();

    // สร้าง focus node เพื่อติดตามการกลับมาที่หน้านี้
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // เพิ่ม listener สำหรับการ navigate กลับมาที่หน้านี้
      Navigator.of(context).focusNode.addListener(_onFocusChange);
    });
  }

  void _initializeData() {
    final now = DateTime.now();

    selectedStartDate = now;
    selectedEndDate = now;

    final thaiMonth = thaiMonths[now.month];
    txtStartDate.text = thaiMonth;
    txtEndDate.text = thaiMonth;

    getpurchaseord();
  }

  void _onFocusChange() {
    if (Navigator.of(context).focusNode.hasFocus && !_isFirstLoad) {
      // เมื่อกลับมาหน้านี้ (เช่น กด back) ให้เรียก API ใหม่
      getpurchaseord();
    }

    if (_isFirstLoad) {
      _isFirstLoad = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ตรวจจับเมื่อแอปกลับมาทำงานในหน้าจอ (เช่น กลับมาจาก background)
    if (state == AppLifecycleState.resumed) {
      getpurchaseord();
    }
  }

  @override
  void dispose() {
    // ยกเลิกการเฝ้าดู lifecycle
    WidgetsBinding.instance.removeObserver(this);

    // ลบ listener เมื่อออกจากหน้านี้
    try {
      Navigator.of(context).focusNode.removeListener(_onFocusChange);
    } catch (e) {
      print('Error removing focus listener: $e');
    }

    super.dispose();
  }

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
      "status": "0",
      "month1": startMonthFormatted,
      "month2": endMonthFormatted,
    });

    var dio = Dio();
    try {
      var response = await dio.request(
        'https://etranscript.suksapan.or.th/otepmobileapi/getorderdetaillist.php',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        Map responseData = response.data;
        if (responseData.containsKey('result') &&
            responseData['result'] is List) {
          List filteredResult = responseData['result'];

          if (selectedStatus != "ทั้งหมด") {
            List<String> selectedStatusCodes = statusMap[selectedStatus] ?? [];
            filteredResult = filteredResult
                .where(
                    (item) => selectedStatusCodes.contains(item['orderstatus']))
                .toList();
          }

          responseData['result'] = filteredResult;
        }

        setState(() {
          getorderdetaillist = responseData;
        });
      } else {
        print('❌ ผิดพลาด: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ เกิดข้อผิดพลาด: $e');
    }
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
          currentMonthTextColor:
              Colors.red, // แสดงเดือนปัจจุบันเป็นสีแดง (เลือกได้)
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
        } else {
          selectedEndDate = picked;
          txtEndDate.text = valueToDisplay;
        }

        if (selectedStartDate != null && selectedEndDate != null) {
          getpurchaseord();
        }
      });
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
            'รายการคำสั่งซื้อ',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(right: 15, left: 15, top: 20, bottom: 40),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'สถานะคำสั่งซื้อ',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Container(
                    height: 45,
                    child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        isDense: true,
                        decoration: InputDecoration(
                          hintText: 'ทั้งหมด',
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
                        ),
                        items:
                            itemsStatus.map<DropdownMenuItem<String>>((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF707070)),
                              textAlign: TextAlign.start,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedStatus = newValue;
                            selectedStatusApi = statusMap[newValue!] ?? ["All"];

                            if (selectedStatus != null &&
                                selectedStartDate != null &&
                                selectedEndDate != null) {
                              getpurchaseord();
                            }
                          });
                        })),
              ),
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
                      suffixIcon: Icon(Icons.calendar_today_outlined, size: 15),
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
              getorderdetaillist['result'] == null ||
                      getorderdetaillist['result'].isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Color(0xFF012A6C),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'ไม่พบข้อมูลที่ตรงตามเงื่อนไข',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF707070),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'กรุณาเปลี่ยนเงื่อนไขการค้นหา',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF707070),
                            ),
                          ),
                        ],
                      ),
                    )
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
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          color: Color(0xFFDCE0E5),
                          height: 30,
                        ),
                        itemCount: getorderdetaillist['result'].length,
                        itemBuilder: (context, index) {
                          final order = getorderdetaillist['result'][index];
                          return GestureDetector(
                            onTap: () {
                              print(
                                  'orderid : ${getorderdetaillist['result'][index]['orderid']}');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PurchaseOrderDetailList(
                                    order: getorderdetaillist['result'][index],
                                    result: widget.result,
                                    addressesList: widget.addressesList,
                                  ),
                                ),
                              ).then((_) {
                                getpurchaseord();
                              });
                            },
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        color: _getStatusColorByCode(
                                            order['orderstatus']),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _getStatusIconByCode(
                                                  order['orderstatus']),
                                              const SizedBox(width: 6),
                                              Text(
                                                getStatusText(
                                                    order['orderstatus']),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color:
                                                      _getStatusFontColorByCode(
                                                          order['orderstatus']),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
                                    final item = order['listdata'][itemIndex];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
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
