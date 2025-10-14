import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kaset_mall/home.dart';

import 'package:kaset_mall/widget/dialog.dart';

class PurchasePaymentInformation extends StatefulWidget {
  final Future<void> Function() onConfirmPayment;
  final dynamic result;
  final dynamic orderid;
  const PurchasePaymentInformation(
      {super.key,
      required this.result,
      required this.orderid,
      required this.onConfirmPayment});

  @override
  State<PurchasePaymentInformation> createState() =>
      _PurchasePaymentInformationState();
}

String DOCSLIP_Name = '';
String DOCSLIP_Encoded = '';
String DOCSLIP_FileType = '';

String DOCSLIPMORE_FileName = '';
String DOCSLIPMORE_Encoded = '';
String DOCSLIPMORE_FileType = '';

Map<String, dynamic> DOCAPPROVAL = {};

class _PurchasePaymentInformationState
    extends State<PurchasePaymentInformation> {
  @override
  void initState() {
    super.initState();
    // เรียกข้อมูลเอกสารที่มีอยู่แล้วเมื่อเปิดหน้า
    getFile();
  }

  Future<void> pickAndUploadFile(BuildContext context, String category) async {
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

        String fileType = result.files.single.extension != null
            ? 'application/${result.files.single.extension}'
            : 'application/octet-stream';
        String fileName = result.files.single.name;
        String base64Raw = base64Encode(fileBytes);
        String dataUrl = 'data:$fileType;base64,$base64Raw';
        String encoded = base64Encode(utf8.encode(dataUrl));

        // เก็บข้อมูลแยกตามหมวดหมู่และอัปเดตสถานะ UI ด้วย setState
        setState(() {
          if (category == 'DOC-SLIP') {
            DOCSLIP_Name = fileName;
            DOCSLIP_FileType = fileType;
            DOCSLIP_Encoded = encoded;
          } else if (category == 'DOC-SLIP-MORE') {
            DOCSLIPMORE_FileName = fileName;
            DOCSLIPMORE_FileType = fileType;
            DOCSLIPMORE_Encoded = encoded;
          }
        });

        await insertfilelist(category);
      }
    } catch (e) {
      print("🔴 Error during file picking: $e");
    }
  }

  Future<void> insertfilelist(String category) async {
    String? fileName;
    String? encoded;
    String? fileType;

    if (category == 'DOC-SLIP') {
      fileName = DOCSLIP_Name;
      encoded = DOCSLIP_Encoded;
      fileType = DOCSLIP_FileType;
    } else if (category == 'DOC-SLIP-MORE') {
      fileName = DOCSLIPMORE_FileName;
      encoded = DOCSLIPMORE_Encoded;
      fileType = DOCSLIPMORE_FileType;
    }

    if (fileName == null || encoded == null || fileType == null) {
      print('❌ Missing file info for category: $category');
      return;
    }

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };

    print('category: $category');
    var data = json.encode({
      "transactionid": widget.orderid,
      "fileupload": encoded,
      "filetype": fileType,
      "filename": fileName,
      "uid": widget.result['uid'],
      "page": category
    });

    var dio = Dio();

    try {
      var response = await dio.request(
        'https://etranscript.suksapan.or.th/otepmobileapi/insertfilelist.php',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        print('🟢 อัปโหลดสำเร็จ($fileName)');
        print('📦 Response data: ${response.data}');

        // แสดง SnackBar เพื่อให้ผู้ใช้ทราบว่าอัปโหลดสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อัปโหลดไฟล์สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print(
            '🟡 อัปโหลดไม่สำเร็จ: ${response.statusCode} ${response.statusMessage}');

        // แสดง SnackBar กรณีมีปัญหา
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อัปโหลดไม่สำเร็จ โปรดลองอีกครั้ง'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('🔴 Dio error: $e');
      // แสดง SnackBar กรณีมีข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการอัปโหลด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> getFile() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json',
      'Cookie': 'PHPSESSID=70ig76ot83n5paa61d4davtu30'
    };
    var data =
        json.encode({"transactionid": widget.orderid, "page": "DOC-APPROVAL"});
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
        print(json.encode(response.data));
        setState(() {
          DOCAPPROVAL = response.data;
        });
      } else {
        print(response.statusMessage);
      }
    } catch (e) {
      print('🔴 Error getting files: $e');
    }
  }

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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.2)),
            ),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Kanit',
                        ),
                        children: [
                          TextSpan(text: 'หนังสืออนุมัติการสั่งซื้อจากเขตฯ '),
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'กรุณาอัพโหลดหนังสืออนุมัติการสั่งซื้อจากเขตฯ จำนวน 1 ไฟล์ โดยขนาดไฟล์ที่ อัพโหลดต้องไม่เกิน 1MB',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 45,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFDCE0E5),
                    ),
                    child: Center(
                      child: Text(
                        'เอกสาร.PDF',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Color(0xFFDCE0E5)),
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (DOCAPPROVAL['result'][index]
                                          ['filepath'] !=
                                      null) {}
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ImageIcon(
                                        AssetImage('assets/download-1.png'),
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
                  SizedBox(
                    height: 25,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Kanit',
                        ),
                        children: [
                          TextSpan(text: 'หลักฐานการชำระเงิน '),
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'กรุณาอัพโหลดหนังสืออนุมัติการสั่งซื้อจากเขตฯ จำนวน 1 ไฟล์ โดยขนาดไฟล์ที่ อัพโหลดต้องไม่เกิน 1MB',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      pickAndUploadFile(context, 'DOC-SLIP');
                    },
                    child: Container(
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
                  ),
                  SizedBox(height: 20),
                  DOCSLIP_Name == ''
                      ? SizedBox()
                      : Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFFFCA0A6),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  DOCSLIP_Name,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                  SizedBox(height: 20),
                  Container(
                    height: 1,
                    color: Colors.black.withOpacity(0.2),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Kanit',
                        ),
                        children: [
                          TextSpan(text: 'หลักฐานเอกสารเพิ่มเติม '),
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'กรุณาอัพโหลดหนังสืออนุมัติการสั่งซื้อจากเขตฯ จำนวน 1 ไฟล์ โดยขนาดไฟล์ที่ อัพโหลดต้องไม่เกิน 1MB',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      pickAndUploadFile(context, 'DOC-SLIP-MORE');
                    },
                    child: Container(
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
                  ),
                  SizedBox(height: 20),
                  DOCSLIPMORE_FileName == ''
                      ? SizedBox()
                      : Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFFFCA0A6),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  DOCSLIPMORE_FileName,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 60),
        child: GestureDetector(
          onTap: () {
            // ตรวจสอบว่ามีการอัปโหลดไฟล์หลักฐานการชำระเงินแล้วหรือไม่
            if (DOCSLIP_Name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('กรุณาอัปโหลดหลักฐานการชำระเงิน'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            showPinkDialog(
                context: context,
                onTap: () async {
                  Navigator.of(context).pop();
                  await widget.onConfirmPayment();

                  showSuccessDialog(
                    context: context,
                    onTapD: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HomeCentralPage(),
                      ));
                    },
                    onTapS: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    title: 'ส่งหลักฐานการชำระเงินสำเร็จ',
                    subtitle: '',
                    txtbtnD: 'กลับหน้าหลัก',
                    txtbtnS: 'รายการคำสั่งซื้อ',
                  );
                },
                title: 'ยืนยันการส่ง\nหลักฐานการชำระเงิน',
                subtitle:
                    'คุณต้องการที่จะยืนยันการส่งหลักฐานนี้หรือไม่หากยืนยันจะเป็นอันเสร็จสิ้นการยื่นหลักฐานการชำระเงิน');
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
                'ยืนยันการส่งหลักฐาน',
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
    );
  }
}
