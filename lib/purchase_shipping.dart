// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kasetmall/home.dart';
import 'package:kasetmall/purchase_order.dart';
import 'package:kasetmall/purchase_orderlist.dart';
import 'package:kasetmall/purchase_orderlist_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasetmall/widget/dialog.dart';

class PurchaseShipping extends StatefulWidget {
  final dynamic allItems;
  final dynamic result;
  final dynamic orderid;

  const PurchaseShipping({
    Key? key,
    required this.allItems,
    required this.result,
    this.orderid,
  }) : super(key: key);

  @override
  State<PurchaseShipping> createState() => _PurchaseShippingState();
}

class _PurchaseShippingState extends State<PurchaseShipping> {
  String _selectedAddress = "2";
  String _selectedDelivery = "1";
  String _selectedBuyerid = "1";
  File? selectedFile;
  Map<String, dynamic> getpurchaseorderdetail = {};
  Map<String, dynamic> addressesList = {};
  List<dynamic> branchList = [];
  Map<String, dynamic> totalAmount = {};
  String _selectedBranch = "กรุณาเลือกสาขา";
  List<dynamic> getfile = [];

  String? finalEncoded;
  String? fileType;
  String? fileName;

  @override
  void initState() {
    getAddress();
    getBranch();
    getTotalAmount();
    getLoadFile();
    GetpurchaseorderDetail();
    _checkAndLoadAddressSelection();
    print('============>>>> ${widget.result['transactionid']}');

    super.initState();
  }

  void _checkAndLoadAddressSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTransactionId = prefs.getString('saved_transaction_id');
    String currentTransactionId =
        widget.result['transactionid']?.toString() ?? '';

    // ถ้า transaction id เดิมกับที่บันทึกไว้ ให้โหลดข้อมูลที่เลือกไว้
    if (savedTransactionId == currentTransactionId &&
        currentTransactionId.isNotEmpty) {
      setState(() {
        _selectedAddress = prefs.getString('selected_address') ?? '';
        _selectedBranch = prefs.getString('selected_dropdown') ?? '';
      });
    } else {
      // ถ้าไม่ใช่ transaction เดิม ให้เคลียร์ข้อมูล
      await prefs.remove('selected_address');
      await prefs.remove('selected_dropdown');
      await prefs.setString('saved_transaction_id', currentTransactionId);
      setState(() {
        _selectedAddress = '';
        _selectedBranch = '';
      });
    }
  }

  void _saveAddressSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentTransactionId =
        widget.result['transactionid']?.toString() ?? '';

    await prefs.setString('selected_address', _selectedAddress);
    await prefs.setString('selected_dropdown', _selectedBranch);
    await prefs.setString('saved_transaction_id', currentTransactionId);
  }

  Future<void> getAddress() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({
      "uid": "${widget.result['uid']}",
    });
    var dio = Dio();
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
  }

  Future<void> getBranch() async {
    var headers = {'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI='};
    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/getbranch.php',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        branchList = List<dynamic>.from(response.data['result']);
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
      "transactionid": widget.orderid != null
          ? widget.orderid
          : "${widget.result['transactionid']}",
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
      setState(() {
        totalAmount = response.data;
        print(totalAmount);
      });
    } else {
      print(response.statusMessage);
    }
  }

  Future<void> removeItem({
    required String? orderCart,
  }) async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };

    var data = json.encode({
      "id": orderCart,
      "transactionid": widget.orderid ?? "${widget.result['transactionid']}",
    });

    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/orderdeletelist.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print(json.encode(response.data));

      setState(() {
        widget.allItems.removeWhere((item) => item['id'] == orderCart);
      });

      if (widget.allItems.isEmpty) {
        await purchaseorderdelete();
        Navigator.pop(context);
      }
    } else {
      print(response.statusMessage);
    }

    await getTotalAmount();
  }

  Future<void> purchaseorderdelete() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json',
      'Cookie': 'PHPSESSID=vn02hbuktgd8naoc4uutndup0r'
    };
    var data = json.encode({"transactionid": widget.orderid});
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
      print(json.encode(response.data));
    } else {
      print(response.statusMessage);
    }
  }

  Future<void> pickAndUploadFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        List<int> fileBytes = await file.readAsBytes();

        const maxFileSize = 1 * 1024 * 1024;
        if (fileBytes.length > maxFileSize) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ไฟล์มีขนาดเกิน 1MB กรุณาเลือกไฟล์ที่เล็กกว่า'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        fileType = result.files.single.extension != null
            ? 'application/${result.files.single.extension}'
            : 'application/octet-stream';
        fileName = result.files.single.name;

        final base64Raw = base64Encode(fileBytes);
        final dataUrl = 'data:$fileType;base64,$base64Raw';

        finalEncoded = base64Encode(utf8.encode(dataUrl));

        await uploadFileToApi();
      }
    } catch (e) {
      print("🔴 Error during file picking: $e");
    }
  }

  Future<void> uploadFileToApi() async {
    if (finalEncoded == null || fileType == null || fileName == null) {
      print('⚠️ ข้อมูลไม่ครบ ไม่สามารถอัปโหลดได้');
      return;
    }

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json',
    };

    var jsonData = {
      "transactionid": widget.orderid != null
          ? widget.orderid
          : "${widget.result['transactionid']}",
      "fileupload": finalEncoded,
      "filetype": fileType,
      "filename": fileName,
      "uid": widget.result['uid'],
      "page": "DOC-SCHOOL",
    };

    try {
      var dio = Dio();
      var data = json.encode(jsonData);

      var response = await dio.post(
        'https://etranscript.suksapan.or.th/otepmobileapi/insertfilelist.php',
        data: data,
        options: Options(
          headers: headers,
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode == 200) {
        print('🟢 อัปโหลดสำเร็จ');
        print(response.data);
        getLoadFile();
      } else {
        print('🔴 ล้มเหลว: ${response.statusCode}');
        print('Response: ${response.data}');
      }
    } catch (e) {
      print('🔴 ขณะอัปโหลดเกิดข้อผิดพลาด: $e');
    }
  }

  Future<void> getLoadFile() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({
      "transactionid": widget.orderid != null
          ? widget.orderid
          : "${widget.result['transactionid']}",
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

  Future<void> deleteFile(String fid) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
        'Content-Type': 'application/json'
      };

      var data = json.encode({
        "fid": fid,
        "transactionid": widget.orderid != null
            ? widget.orderid
            : "${widget.result['transactionid']}",
        "page": "DOC-SCHOOL"
      });

      var dio = Dio();
      var response = await dio.request(
        'https://etranscript.suksapan.or.th/otepmobileapi/deletefilelist.php',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      Navigator.pop(context);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบไฟล์สำเร็จ')),
        );
        await getLoadFile();
        setState(() {});

        if (getfile.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่มีไฟล์เหลือในรายการ')),
          );
        }
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${response.statusMessage}')),
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> GetpurchaseorderDetail() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json',
      'Cookie': 'PHPSESSID=vn02hbuktgd8naoc4uutndup0r'
    };

    var data = json.encode(
      {
        "transactionid": widget.orderid, // ได้จากบันทึกร่างส่งเข้ามา
      },
    );
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
      print(json.encode(response.data));
      getpurchaseorderdetail = response.data;

      widget.orderid != null
          ? setState(() {
              _selectedBuyerid = getpurchaseorderdetail['buyerId'];
              _selectedAddress = getpurchaseorderdetail['addressId'];
              _selectedBranch = getpurchaseorderdetail['branchId'];
            })
          : null;
    } else {
      print(response.statusMessage);
    }
  }

  Future<void> ordersavedraft() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({
      "transactionid": widget.result['transactionid'],
      "sendaddress": _selectedAddress,
      "sendtype": _selectedAddress,
      "branchid":
          _selectedBranch == 'กรุณาเลือกสาขา' ? 'null' : _selectedBranch,
      "buyerid": _selectedBuyerid,
      "uid": widget.result['uid'],
      "schoolid": "${widget.result['schoolid']}",
      "flagspecial": totalAmount['flagspecial'],
      "shippingprice": totalAmount['shippingprice'],
    });
    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/ordersavedraft.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print('--------- ordersavedraft ----------');
      print(json.encode(response.data));

      print('-----------------------------------');
    } else {
      print(response.statusMessage);
    }
  }

  Future<void> commitOrder() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({
      "transactionid": (widget.orderid?.isEmpty ?? true)
          ? widget.result['transactionid']
          : widget.orderid,
      "sendaddress": _selectedAddress,
      "sendtype": _selectedAddress,
      "branchid":
          _selectedBranch == 'กรุณาเลือกสาขา' ? 'null' : _selectedBranch,
      "buyerid": _selectedBuyerid,
      "uid": widget.result['uid'],
      "schoolid": "${widget.result['schoolid']}",
      "flagspecial": totalAmount['flagspecial'],
      "shippingprice": totalAmount['shippingprice'],
    });

    var dio = Dio();
    var response = await dio.request(
      'https://etranscript.suksapan.or.th/otepmobileapi/ordercommit.php',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print('============= commitOrder ==================');
      print('🟢 สำเร็จ 🟢');
      print(json.encode(response.data.toString()));
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
          'ออกใบขอสั่งซื้อ',
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
                                  ListTile(
                                    leading: Radio<String>(
                                      activeColor: Color(0xFF012A6C),
                                      value: "2",
                                      groupValue: _selectedAddress,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedAddress = value!;
                                        });
                                        _saveAddressSelection();
                                      },
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "${widget.result['fname']} ${widget.result['lname']}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  _selectedAddress == "2"
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                            )),
                                        Text(
                                          "| ${widget.result['tel']}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: _selectedAddress == "2"
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '${addressesList['address']}',
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Container(
                                  height: 1,
                                  color: Colors.black.withOpacity(0.2))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Radio<String>(
                                          activeColor: Color(0xFF012A6C),
                                          value: "1",
                                          groupValue: _selectedAddress,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedAddress = value!;
                                            });
                                            _saveAddressSelection();
                                          },
                                        ),
                                        Text(
                                          "รับที่องค์การค้า",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: _selectedAddress == "1"
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text('เลือกสาขาองค์การค้า'),
                                    SizedBox(height: 12),
                                    Center(
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              spreadRadius: 2,
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedBranch.isEmpty
                                              ? null
                                              : _selectedBranch,
                                          hint: Text('กรุณาเลือกสาขา'),
                                          isDense: true,
                                          isExpanded: true,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 12),
                                          ),
                                          items: branchList.map((branch) {
                                            return DropdownMenuItem<String>(
                                              value:
                                                  branch['branchId'].toString(),
                                              child: Text(branch['branchName']),
                                            );
                                          }).toList(),
                                          onChanged: _selectedAddress == "1"
                                              ? (String? newValue) {
                                                  setState(() {
                                                    _selectedBranch = newValue!;
                                                  });
                                                  _saveAddressSelection();
                                                }
                                              : null,
                                        ),
                                      ),
                                    )
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withOpacity(0.2)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            activeColor: Color(0xFF012A6C),
                            value: "1",
                            groupValue: _selectedDelivery,
                            onChanged: (value) {
                              setState(() {
                                _selectedDelivery = value!;
                              });
                            },
                          ),
                          Text(
                            "EMS",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: _selectedDelivery == "1"
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withOpacity(0.2)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            activeColor: Color(0xFF012A6C),
                            value: "1",
                            groupValue: _selectedBuyerid,
                            onChanged: (value) {
                              setState(() {
                                _selectedBuyerid = value!;
                              });
                            },
                          ),
                          Text(
                            "สั่งผ่านเขต",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: _selectedBuyerid == "1"
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                        onTap: () {
                          pickAndUploadFile(context);
                        },
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Color(0xFFFCA0A6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ImageIcon(
                                    AssetImage('assets/upload.png'),
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'เลือกไฟล์',
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
                        ),
                      ),
                      SizedBox(height: 12),
                      getfile.isNotEmpty
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
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.1)),
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
                                          IconButton(
                                            icon: Icon(Icons.close,
                                                color: Colors.red),
                                            onPressed: () {
                                              deleteFile(getfile[index]['fid']);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : SizedBox(),
                      Text(
                        'กรุณาเลือกไฟล์ .pdf, .jpg, .jpeg, .png ที่มีขนาดไม่เกิน 1MB',
                        style: TextStyle(
                          color: Color(0xFF707070),
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
              ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รายการสินค้า',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 12),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => purchaseOrder(
                                    result: widget.result,
                                    draftorder: widget.orderid,
                                  ),
                                ),
                              );
                              print(
                                  '>>>>>>>>>>>>>>>>> draftorder :  ${widget.orderid}');
                              await getTotalAmount();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Color(0xFF012A6C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  ImageIcon(
                                    AssetImage('assets/add_cart.png'),
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'เพิ่มรายการสินค้า',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ListView.separated(
                        padding: EdgeInsets.only(top: 10),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          color: Color(0xFFDCE0E5),
                          height: 30,
                        ),
                        itemCount: widget.allItems.length,
                        itemBuilder: (context, index) {
                          final item = widget.allItems[index];
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
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: IconButton(
                                                onPressed: () async {
                                                  await removeItem(
                                                      orderCart:
                                                          widget.allItems[index]
                                                              ['id']);
                                                  setState(() {
                                                    widget.allItems
                                                        .removeAt(index);
                                                  });
                                                },
                                                icon: Image.asset(
                                                  'assets/delete-bin.png',
                                                  fit: BoxFit.contain,
                                                  height: 35,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 25,
                                                      width: 35,
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
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          item['typeprint'],
                                                          style: TextStyle(
                                                              fontSize: 8),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    if (item['type'] == 'T')
                                                      Container(
                                                        height: 25,
                                                        width: 35,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFFC8D8F),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'อนุมัติ',
                                                            style: TextStyle(
                                                                fontSize: 8),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    Container(
                                                      height: 25,
                                                      width: 35,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFFC8D8F),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'อนุมัติ',
                                                          style: TextStyle(
                                                              fontSize: 8),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    if (item['type'] == 'P')
                                                      Container(
                                                        height: 25,
                                                        width: 35,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFBEFEC7),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'ออนไลน์',
                                                            style: TextStyle(
                                                                fontSize: 8),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    Text(
                                                      '${item['priceCart']} บาท / ${item['unit']} ',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      maxLines: 3,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center, // <<< ให้กลางด้วย
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.15,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                        color:
                                                            Color(0xFF707070),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${item['quantityCart']}',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Color(0xFF012A6C),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
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
                        detail: totalAmount['totalamount'] ?? '0.00',
                        fontWeightTitle: FontWeight.w400,
                        colorTitle: Colors.black.withOpacity(0.6),
                        fontSizeTitle: 13,
                        fontSizeDetail: 13,
                      ),
                      SizedBox(height: 10),
                      textDetail(
                        title: 'ค่าขนส่ง ',
                        detail: totalAmount['shippingprice'] ?? '0.00',
                        fontWeightTitle: FontWeight.w400,
                        colorTitle: Colors.black.withOpacity(0.6),
                        fontSizeTitle: 13,
                        fontSizeDetail: 13,
                      ),
                      SizedBox(height: 10),
                      textDetail(
                        title: 'มูลค่าสินค้าและค่าขนส่งก่อนภาษี',
                        detail: totalAmount['totalamountbeforetax'] ?? '0.00',
                        fontWeightTitle: FontWeight.w400,
                        colorTitle: Colors.black.withOpacity(0.6),
                        fontSizeTitle: 13,
                        fontSizeDetail: 13,
                      ),
                      SizedBox(height: 10),
                      textDetail(
                        title: 'ภาษีมูลค่าเพิ่ม ',
                        detail: totalAmount['totalvat'] ?? '0.00',
                        fontWeightTitle: FontWeight.w400,
                        colorTitle: Colors.black.withOpacity(0.6),
                        fontSizeTitle: 13,
                        fontSizeDetail: 13,
                      ),
                      SizedBox(height: 10),
                      textDetail(
                        title: 'ยอดสุทธิ ',
                        detail: totalAmount['totalsum'] ?? '0.00',
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
                            convertToThaiBahtText(
                                totalAmount['totalsum'].toString()),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              widget.orderid == null
                  ? GestureDetector(
                      onTap: () {
                        showPinkDialog_2(
                          context: context,
                          onTap1: () {
                            Navigator.of(context).pop();

                            showSuccessDialog1(
                              context: context,
                              onTap: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                              title: 'ยกเลิกใบขอสั่งซื้อสำเร็จ',
                              subtitle: '',
                              txtbtn: 'กลับหน้าหลัก',
                            );
                          },
                          onTap2: () {
                            ordersavedraft();
                            Navigator.of(context).pop();

                            showSuccessDialog(
                              context: context,
                              onTapD: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                              onTapS: () {
                                Navigator.of(context).pop();
                                Future.delayed(Duration(milliseconds: 300), () {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          purchaseOrderListDraft(
                                        result: widget.result,
                                        addressesList: addressesList,
                                      ),
                                    ),
                                  );
                                });
                              },
                              title: 'บันทึกร่างใบขอสั่งซื้อสำเร็จ',
                              subtitle: '',
                              txtbtnD: 'กลับหน้าหลัก',
                              txtbtnS: 'ร่างใบขอสั่งซื้อ',
                            );
                          },
                          title: 'ร่างใบขอสั่งซื้อ',
                          subtitle:
                              'คุณต้องการที่จะยืนยันที่จะบันทึกร่างใบสั่งซื้อหรือไม่หากยืนยันจะเป็นอันเสร็จสิ้นการร่างคำสั่งซื้อ',
                          txtbtn1: 'ไม่บันทึกร่าง',
                          txtbtn2: 'ยืนยัน',
                        );
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(0xFF012A6C)),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              'บันทึกร่าง',
                              style: TextStyle(
                                color: Color(0xFF012A6C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
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
                          padding: const EdgeInsets.symmetric(horizontal: 25),
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
                      if (getfile.isEmpty) {
                        showMissingFileDialog(
                          context: context,
                          title: 'กรุณาอัปโหลดไฟล์\nเอกสารประกอบการสั่งซื้อ',
                        );
                      } else if (_selectedAddress.isEmpty) {
                        showMissingFileDialog(
                          context: context,
                          title:
                              'กรุณาเลือกที่อยู่จัดส่งสินค้า\nโปรดเลือกหรือเพิ่มที่อยู่จัดส่งก่อนดำเนินการต่อ',
                        );
                      } else if (_selectedAddress == "1" &&
                          (_selectedBranch.isEmpty ||
                              _selectedBranch == 'กรุณาเลือกสาขา')) {
                        showMissingFileDialog(
                          context: context,
                          title:
                              'กรุณาเลือกสาขา องค์การค้า\nโปรดเลือกสาขาขององค์การค้าที่คุณต้องการทำรายการด้วย',
                        );
                      } else {
                        showPinkDialog(
                            context: context,
                            onTap: () {
                              commitOrder();
                              Navigator.of(context).pop();
                              showSuccessDialog(
                                context: context,
                                onTapD: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => HomeCentralPage(),
                                  ));
                                },
                                onTapS: () {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => purchaseOrderList(
                                      addressesList: addressesList,
                                      result: widget.result,
                                    ),
                                  ));
                                },
                                title: 'ยืนยันการออกใบขอสั่งซื้อ',
                                subtitle: '',
                                txtbtnD: 'กลับหน้าหลัก',
                                txtbtnS: 'ใบขอสั่งซื้อของฉัน',
                              );
                            },
                            title: 'สรุปรายการสินค้า',
                            subtitle:
                                'รายการของคุณมีสินค้าประเภทเอกสารควบคุม ต้องมีการขออนุญาตจากเขตพื้นที่การศึกษาก่อนดำเนินการต่อ');
                      }
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
                          padding: const EdgeInsets.symmetric(horizontal: 25),
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

  void showMissingFileDialog(
      {required BuildContext context, required String title}) {
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
                      SizedBox(height: 12),
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
