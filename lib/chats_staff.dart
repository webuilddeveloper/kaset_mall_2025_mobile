import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

import '../shared/api_provider.dart';

class chatstaff extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? reference; // เพิ่มพารามิเตอร์ใหม่
  final String? question;
  final String? imageUrl;
  final String? totalAmount;
  final String? totalPrice;
  final String? orderStatus;
  final String? type;

  const chatstaff({
    Key? key,
    this.userId,
    this.userName,
    this.question,
    this.imageUrl,
    this.orderStatus,
    this.reference,
    this.totalAmount,
    this.totalPrice,
    this.type,
  }) : super(key: key);
  @override
  _chatstaffState createState() => _chatstaffState();
}

class _chatstaffState extends State<chatstaff> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late XFile? _image;
  late String _imageUrl;
  List<dynamic> objectData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'orderStatus' || widget.type == 'product') {
      _startMessage();
    }
    _readDetail();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String message, {String? imageUrl}) async {
    if (message.isEmpty && imageUrl == null) return;

    // Optimistic update - add message immediately
    setState(() {
      objectData.insert(0, {
        "isQuestion": true,
        "question": imageUrl ?? message,
        "type": imageUrl != null ? "image" : "text",
      });
    });

    try {
      final dio = Dio();
      final response = await dio.post(
        'https://ssp.we-builds.com/ssp-api/m/chatstaff/create',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          "userId": widget.userId,
          "userName": widget.userName,
          "question": imageUrl ?? message,
          "type": imageUrl != null ? "image" : "text",
          "answer": "",
          "reference": ""
        },
      );

      if (response.statusCode == 200) {
        _controller.clear();
        await _readDetail();
      }
    } catch (e) {
      // Remove optimistic update if failed
      setState(() {
        objectData.removeAt(0);
      });
      print('Error sending message: $e');
    }
  }

  Future<void> _readDetail() async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://ssp.we-builds.com/ssp-api/m/chatstaff/readDetail',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          "userId": widget.userId,
          "userName": widget.userName,
        },
      );

      if (response.statusCode == 200) {
        final fetchedData = response.data;
        setState(() {
          // Reverse the list to show newest messages at the bottom
          objectData =
              (fetchedData['objectData'] as List ?? []).reversed.toList();
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _startMessage() async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://ssp.we-builds.com/ssp-api/m/chatstaff/create',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          "userId": widget.userId,
          "userName": widget.userName,
          "reference": widget.reference,
          "question": widget.question,
          "imageUrl": widget.imageUrl,
          "totalAmount": widget.totalAmount ?? '',
          "totalPrice": widget.totalPrice,
          "orderStatus": widget.orderStatus ?? '',
          "type": widget.type,
          "answer": "",
        },
      );

      if (response.statusCode == 200) {
        await _readDetail();
        _controller.clear();
      }
    } catch (e) {
      print('Error in startMessage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'แชทกับแอดมิน',
          style: TextStyle(
              fontFamily: 'Kanit', color: Theme.of(context).primaryColor),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: objectData.isEmpty
                ? const Center(child: Text("No data available"))
                : ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: objectData.length,
                    itemBuilder: (context, index) {
                      final item = objectData[index];
                      final bool isQuestion = item['isQuestion'] ?? false;
                      final String messageText = isQuestion
                          ? (item['question'] ?? '')
                          : (item['answer'] ?? '');
                      final String messageType = item['type'] ?? '';

                      return Align(
                        alignment: isQuestion
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isQuestion
                                ? Theme.of(context).primaryColor
                                : const Color(0xffFCF6F5),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isQuestion ? 20 : 0),
                              bottomRight: Radius.circular(isQuestion ? 0 : 20),
                            ),
                          ),
                          child: _getMessageWidget(context, messageType,
                              messageText, item, isQuestion),
                        ),
                      );
                    },
                  ),
          ),
          // ช่องกรอกข้อความและปุ่มส่ง
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: _controller,
                      cursorColor: Theme.of(context).primaryColor,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xffFCF6F5),
                        hintText: 'พิมพ์ข้อความ',
                        hintStyle: TextStyle(
                          color: Colors.black12,
                          fontFamily: 'Kanit',
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xffFCF6F5),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xffFCF6F5),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xffFCF6F5),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        prefixIcon: IconButton(
                          icon: Icon(Icons.photo_library),
                          color: Theme.of(context).primaryColor,
                          onPressed: _imgFromGallery,
                        ),
                        suffixIcon: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.send),
                            color: Colors.white,
                            onPressed: () {
                              final message = _controller.text.trim();
                              if (message.isNotEmpty) {
                                _sendMessage(message);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // เพิ่มฟังก์ชันสำหรับการอัพโหลดรูปภาพ
  _imgFromGallery() async {
    XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    setState(() {
      _image = image;
    });
    _upload();
  }

  void _upload() async {
    if (_image == null) return;

    uploadImage(_image!).then((res) {
      setState(() {
        _imageUrl = res;
      });
      _sendMessage('', imageUrl: _imageUrl);
    }).catchError((err) {
      print(err);
    });
  }

  Widget _getMessageWidget(BuildContext context, String type, String text,
      Map<String, dynamic> item, bool isQuestion) {
    // ข้อความธรรมดา
    if (type == 'text') {
      return Linkify(
        onOpen: (link) async {
          if (await canLaunch(link.url)) {
            await launch(link.url);
          } else {
            throw 'Could not launch $link';
          }
        },
        text: text,
        style: TextStyle(
          fontSize: 16,
          color: isQuestion ? Colors.white : Colors.black,
        ),
        // linkStyle: TextStyle(color: Colors.red),
      );
      // return SelectableText(
      //   text,
      //   style: TextStyle(
      //     fontSize: 16,
      //     color: isQuestion ? Colors.white : Colors.black,
      //   ),
      //   onTap: () {
      //     final regex = RegExp(r'https?://[^\s]+');
      //     final match = regex.firstMatch(text);
      //     match != null ? match.group(0) ?? '' : null;
      //     if (match != null) {}
      //   },
      // );
      // return GestureDetector(
      //   onTap: () {
      //     _launchURL();
      //   },
      //   child: Text(
      //     text,
      //     style: TextStyle(
      //       fontSize: 16,
      //       color: isQuestion ? Colors.white : Colors.black,
      //     ),
      //   ),
      // );
    }

// รูปภาพ พร้อม loading state
    if (type == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          text,
          width: 150,
          fit: BoxFit.contain,
          // เพิ่ม loading widget
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? (loadingProgress.cumulativeBytesLoaded ?? 0) /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
          // จัดการ error
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 150,
              height: 150,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.error_outline, size: 30),
              ),
            );
          },
        ),
      );
    }

    // สถานะสินค้า หรือ default
    return GestureDetector(
      onTap: () => _startMessage(),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // รูปสินค้า
              if (item['imageUrl'] != null)
                ClipRRect(
                  child: Image.network(
                    item['imageUrl'],
                    height: 80,
                  ),
                ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'คุณกำลังสอบถามข้อมูลเกี่ยวกับสินค้านี้ ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item['question'] != null) Text(item['question']),

                    // แสดงเฉพาะเมื่อเป็น orderStatus
                    if (type == 'orderStatus' && item['totalAmount'] != null)
                      Text(
                        'จำนวน: ${item['totalAmount']} ชิ้น',
                        style: const TextStyle(color: Colors.grey),
                      ),

                    if (item['totalPrice'] != null)
                      Text(
                        '${item['totalPrice']} บาท',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),

                    // แสดงเฉพาะเมื่อเป็น orderStatus
                    if (type == 'orderStatus' && item['orderStatus'] != null)
                      Text(
                        'สถานะ: ${item['orderStatus']}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
