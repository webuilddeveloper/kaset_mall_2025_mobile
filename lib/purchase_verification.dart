import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasetmall/purchase_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:kasetmall/purchase_order.dart';

class IDVerificationScreen extends StatefulWidget {
  const IDVerificationScreen({Key? key}) : super(key: key);

  @override
  State<IDVerificationScreen> createState() => _IDVerificationScreenState();
}

class _IDVerificationScreenState extends State<IDVerificationScreen> {
  final TextEditingController _idController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;
  bool _obscureID = true;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void initState() {
    loginWithIdCard();
    super.initState();
  }

  Future<dynamic> loginWithIdCard() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic T1RFUE1PQklMRTpBZHVORGVxUklJVkI=',
      'Content-Type': 'application/json'
    };
    var data = json.encode({"idCard": _idController.text});
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
        print('*********** Login successful *************');

        print(json.encode(response.data));
        print('******************************************');

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

  void _verifyID() {
    final String id = _idController.text.trim();

    if (id.isEmpty || id.replaceAll('-', '').length < 13) {
      setState(() {
        _errorText = 'กรุณากรอกเลขบัตรประชาชน 13 หลักให้ครบถ้วน';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    loginWithIdCard().then((responseData) async {
      if (responseData != null && responseData['returnmessage'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_card_id', _idController.text.trim());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PurchaseMenuPage(
                    cardid: _idController.text.trim(),
                  )),
        );
        print('Login successful');
      } else {
        setState(
          () {
            _errorText = 'เลขบัตรประชาชนไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
            _isLoading = false;
          },
        );
      }
    }).catchError((e) {
      setState(() {
        _errorText = 'เกิดข้อผิดพลาดในการตรวจสอบข้อมูล';
        _isLoading = false;
      });
    });
  }

  Widget _buildFormattedIDField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _idController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(13),
        ],
        obscureText: _obscureID,
        style: TextStyle(
          fontSize: 16,
          letterSpacing: _obscureID ? 1.2 : 0.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'X-XXXX-XXXXX-XX-X',
          hintStyle: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
            letterSpacing: 1.2,
          ),
          errorText: _errorText,
          errorStyle: TextStyle(color: Colors.red[700]),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(
            Icons.badge_outlined,
            color: Color(0xFF012A6C),
            size: 22,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureID ? Icons.visibility_off : Icons.visibility,
              color: Color(0xFF012A6C),
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _obscureID = !_obscureID;
              });
            },
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF012A6C), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[700]!, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    if (_idController.text.isEmpty) {
      return SizedBox.shrink();
    }

    return TextButton.icon(
      onPressed: () {
        setState(() {
          _idController.clear();
          _errorText = null;
        });
      },
      icon: Icon(
        Icons.refresh_rounded,
        size: 16,
        color: Color(0xFF012A6C),
      ),
      label: Text(
        'ล้างข้อมูล',
        style: TextStyle(
          color: Color(0xFF012A6C),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      ),
    );
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
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          'ยืนยันตัวตน',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F9FF), Colors.white],
            stops: [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F1FF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF012A6C).withOpacity(0.12),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Color(0xFFD6E6FF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF012A6C),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(0xFF012A6C),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified_user,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'ยืนยันตัวตนด้วยเลขบัตรประชาชน',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF012A6C),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'กรุณากรอกเลขบัตรประชาชน 13 หลัก เพื่อยืนยันตัวตน\nและดำเนินการต่อไป',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildFormattedIDField(),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            'ข้อมูลของคุณจะถูกเก็บเป็นความลับ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      _buildClearButton(),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (_errorText != null)
                    Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red[700],
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorText!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyID,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF012A6C),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            Color(0xFF012A6C).withOpacity(0.6),
                        elevation: 4,
                        shadowColor: Color(0xFF012A6C).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ยืนยันตัวตน',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                    ),
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
                            'ระบบจะทำการตรวจสอบเลขบัตรประชาชนของคุณเพื่อยืนยันตัวตนก่อนดำเนินการต่อไป',
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
    );
  }
}
