import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:mobile_mart_v3/purchase_orderlist_shipping.dart';

class purchaseOrderList extends StatefulWidget {
  const purchaseOrderList(
      {super.key, required this.result, required this.addressesList});
  final dynamic result;
  final dynamic addressesList;
  @override
  State<purchaseOrderList> createState() => _purchaseOrderListState();
}

class _purchaseOrderListState extends State<purchaseOrderList>
    with WidgetsBindingObserver {
  String? selectedStatus = "ทั้งหมด";
  List<String> selectedStatusApi = ["All"];

  final Map<String, List<String>> statusMap = {
    "ทั้งหมด": ["All"],
    "ไม่ได้รับการอนุมัติ": ['F1', 'F2', 'F3', 'F4', 'F5'],
    "รายการที่รอการแก้ไข": ['W3', 'W4'],
    "รอรับการอนุมัติ": [
      'W1',
    ],
    "รอรับการชำระเงิน": ['W2'],
    "ได้รับการอนุมัติ": ['A1', 'A2'],
  };

  final List<String> itemsStatus = [
    "ทั้งหมด",
    "ไม่ได้รับการอนุมัติ",
    "รายการที่รอการแก้ไข",
    "รอรับการอนุมัติ",
    "รอรับการชำระเงิน",
    "ได้รับการอนุมัติ",
  ];

  Map getpurchaseorder = {};
  final TextEditingController txtStartDate = TextEditingController();
  final TextEditingController txtEndDate = TextEditingController();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initializeData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      getpurchaseord();
    }

    if (_isFirstLoad) {
      _isFirstLoad = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getpurchaseord();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

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
      "orderstatus": "All",
      "month1": startMonthFormatted,
      "month2": endMonthFormatted,
    });

    var dio = Dio();
    try {
      var response = await dio.request(
        'https://etranscript.suksapan.or.th/otepmobileapi/getpurchaseorder.php',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print('🟢 สําเร็จ 🟢');
        print('Loadding.... Success getpurchaseord');
        Map responseData = response.data;

        if (responseData.containsKey('result') &&
            responseData['result'] is List) {
          List filteredResult = responseData['result'];

          final excludedStatuses = ['D', 'A2', 'A1'];
          filteredResult = filteredResult
              .where((item) => !excludedStatuses.contains(item['orderstatus']))
              .toList();

          // กรองตามสถานะที่เลือก (ถ้าไม่ใช่ "ทั้งหมด")
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
          getpurchaseorder = responseData;
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
            'ใบขอสั่งซื้อของฉัน',
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
                  'สถานะใบขอซื้อ',
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
              getpurchaseorder['result'] == null ||
                      getpurchaseorder['result'].isEmpty
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
                        itemCount: getpurchaseorder['result'].length,
                        itemBuilder: (context, index) {
                          final order = getpurchaseorder['result'][index];
                          return GestureDetector(
                            onTap: () {
                              // order['orderstatus'] != 'W3' &&
                              //         order['orderstatus'] != 'W4'
                              //     ?
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PurchaseOrderShippingSum(
                                    order: getpurchaseorder['result'][index],
                                    result: widget.result,
                                    addressesList: widget.addressesList,
                                  ),
                                ),
                              ).then((_) {
                                getpurchaseord();
                              });
                              // : Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           PurchaseOrderShippingSumEdit(
                              //               order:
                              //                   getpurchaseorder['result']
                              //                       [index]),
                              //     ),
                              //   ).then((_) {
                              //     getpurchaseord();
                              //   });
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
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await remove(
                                            transactionid: order['orderid']);
                                        setState(() {
                                          getpurchaseorder['result']
                                              .removeAt(index);
                                        });
                                      },
                                      icon: Image.asset(
                                        'assets/delete-bin.png',
                                        fit: BoxFit.contain,
                                        height: 25,
                                      ),
                                    ),
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
