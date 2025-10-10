import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_mart_v3/home.dart';
import 'package:mobile_mart_v3/menu.dart';
import 'package:mobile_mart_v3/purchase_order.dart';
import 'package:mobile_mart_v3/purchase_orderlist.dart';
import 'package:mobile_mart_v3/purchase_orderlist_draft.dart';
import 'package:mobile_mart_v3/purchase_orderlist_success.dart';

class PurchaseMenuPage extends StatefulWidget {
  final String? cardid;

  const PurchaseMenuPage({
    Key? key,
    this.cardid,
  }) : super(key: key);

  @override
  State<PurchaseMenuPage> createState() => _PurchaseMenuPageState();
}

class _PurchaseMenuPageState extends State<PurchaseMenuPage>
    with WidgetsBindingObserver {
  Map<String, dynamic> addressesList = {};
  Map<String, dynamic> result = {};
  Map<String, dynamic> getpurchaseorderdraft = {};

  Map getpurchaseorder = {};
  Map getorderlist = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await loginWithIdCard();
      if (result.isNotEmpty && result['uid'] != null) {
        await getAddress();
        await GetpurchaseOrder();
        await GetpurchaseDraft();
        await GetOrderList();
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> GetOrderList() async {
    if (result['uid'] == null) return;
    final startMonthFormatted = DateFormat('yyyy-MM').format(DateTime.now());
    final endMonthFormatted = DateFormat('yyyy-MM').format(DateTime.now());

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };

    var data = json.encode({
      "uid": result['uid'],
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

          responseData['result'] = filteredResult;
        }

        setState(() {
          getorderlist = responseData;
          print('🟢🟢🟢 ได้ข้อมูล  :  ${getorderlist['result'].length} รายการ');
        });
      } else {
        print('❌ ผิดพลาด: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ เกิดข้อผิดพลาด: $e');
    }
  }

  Future<void> GetpurchaseOrder() async {
    if (result['uid'] == null) return;
    final startMonthFormatted = DateFormat('yyyy-MM').format(DateTime.now());
    final endMonthFormatted = DateFormat('yyyy-MM').format(DateTime.now());

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };

    var data = json.encode({
      "uid": result['uid'],
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
        Map responseData = response.data;

        if (responseData.containsKey('result') &&
            responseData['result'] is List) {
          List filteredResult = responseData['result'];

          final excludedStatuses = ['D', 'A2', 'A1'];
          filteredResult = filteredResult
              .where((item) => !excludedStatuses.contains(item['orderstatus']))
              .toList();

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

  Future<void> GetpurchaseDraft() async {
    if (result['uid'] == null) return;
    final startMonthFormatted = DateFormat('yyyy-MM').format(DateTime.now());
    final endMonthFormatted = DateFormat('yyyy-MM').format(DateTime.now());

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };

    var data = json.encode({
      "uid": result['uid'],
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
      getpurchaseorderdraft = response.data;
      // print('🟢 สำเร็จ 🟢');
      // print('success draft');
      // print(
      //     '-------getpurchaseorderdraft---- : ${getpurchaseorderdraft['result'].length} ');
    } else {
      print('ErrordraftMenu');
      print(response.statusMessage);
    }
  }

  Future<dynamic> loginWithIdCard() async {
    if (widget.cardid == null) return null;

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({"idCard": widget.cardid});
    var dio = Dio();
    try {
      var response = await dio.request(
        'https://etranscript.suksapan.or.th/otepmobileapi/login.php',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        setState(() {
          result = response.data;
        });

        return response.data;
      } else {
        print('Error: ${response.statusMessage}');
        throw Exception('Failed to login: ${response.statusMessage}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }

  Future<void> getAddress() async {
    if (result['uid'] == null) return;

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({
      "uid": "${result['uid']}",
    });
    var dio = Dio();
    try {
      var response = await dio.request(
        'https://etranscript.suksapan.or.th/otepmobileapi/userdatashipping.php',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        setState(() {
          addressesList = response.data;
        });
      } else {
        print(response.statusMessage);
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF012A6C),
        leading: Padding(
          padding: EdgeInsets.only(left: 8),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MenuCentralPage(),
              ));
            },
          ),
        ),
        title: Text(
          'ใบขอสั่งซื้อ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF5F9FF), Colors.white],
                  stops: [0.3, 1.0],
                ),
              ),
              child: SafeArea(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ID Card Display
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFE8F1FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFFBBD6FF)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: Color(0xFF012A6C),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'เลขบัตรประชาชน',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      widget.cardid ?? '',
                                      style: TextStyle(
                                        color: Color(0xFF012A6C),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.verified_user,
                                  color: Color(0xFF012A6C),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 32),

                          // Menu Title
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F1FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.grid_view_rounded,
                                  color: Color(0xFF012A6C),
                                  size: 22,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'เมนูหลัก',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF012A6C),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Menu Cards
                          GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            childAspectRatio: 0.9,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: [
                              _buildMenuCard(
                                context,
                                title: 'ออกใบขอสั่งซื้อ',
                                icon: Icons.shopping_cart_checkout,
                                description: 'สร้างใบสั่งซื้อใหม่',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => purchaseOrder(
                                        result: result,
                                      ),
                                    ),
                                  );
                                  _loadData();
                                },
                                count: '',
                              ),
                              _buildMenuCard(
                                context,
                                title: 'ร่างใบสั่งซื้อ',
                                icon: Icons.edit_document,
                                description: 'แก้ไขร่างใบสั่งซื้อที่บันทึกไว้',
                                count: getpurchaseorderdraft['result'] != null
                                    ? getpurchaseorderdraft['result']
                                        .length
                                        .toString()
                                    : '0',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          purchaseOrderListDraft(
                                        result: result,
                                        addressesList: addressesList,
                                      ),
                                    ),
                                  );

                                  _loadData();
                                },
                              ),
                              _buildMenuCard(
                                context,
                                title: 'รายการขอใบสั่งซื้อ',
                                icon: Icons.assignment_outlined,
                                description: 'ตรวจสอบรายการคำขอใบสั่งซื้อ',
                                count: getpurchaseorder['result'] != null
                                    ? getpurchaseorder['result']
                                        .length
                                        .toString()
                                    : '0',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => purchaseOrderList(
                                        result: result,
                                        addressesList: addressesList,
                                      ),
                                    ),
                                  );

                                  _loadData();
                                },
                              ),
                              _buildMenuCard(
                                context,
                                title: 'คำสั่งซื้อ',
                                icon: Icons.receipt_long,
                                description: 'ดูรายการคำสั่งซื้อทั้งหมด',
                                count: getorderlist['result'] != null
                                    ? getorderlist['result'].length.toString()
                                    : '0',
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderList(
                                        result: result,
                                        addressesList: addressesList,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFFE8F1FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFFBBD6FF)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFF012A6C),
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'กรุณาเลือกเมนูที่ต้องการเพื่อดำเนินการเกี่ยวกับใบสั่งซื้อ',
                                    style: TextStyle(
                                      color: Color(0xFF012A6C),
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required Function onTap,
    required String count,
  }) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Color(0xFFDCE4F3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFE8F1FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          size: 24,
                          color: Color(0xFF012A6C),
                        ),
                      ),
                      count.isNotEmpty
                          ? Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.red,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    count ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF012A6C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
