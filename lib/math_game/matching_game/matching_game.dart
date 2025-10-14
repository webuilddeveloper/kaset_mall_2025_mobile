import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:kaset_mall/math_game/setting_main.dart';

class MatchingGameScreen extends StatefulWidget {
  @override
  _MatchingGameScreenState createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  List<dynamic> pairs = [];
  late Map<String, String> matchedPairs; // Track matched pairs
  String? _cachedProfileFirstName;
  int pairsMatched = 0;
  int elapsedSeconds = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    // fetchPairs();
    initializeProfileFirstName();
    startTimer();
    startNewGame(); // เริ่มเกมทันที
  }

  Future<void> resetUserId({bool forceReset = false}) async {
    if (_cachedProfileFirstName != null && !forceReset) {
      // ใช้ userId เดิม ถ้าไม่ต้องการสุ่มใหม่
      return;
    }
    var random = Random();
    var randomNumber = random.nextInt(9000) + 1000;
    var newProfileFirstName = 'guest_$randomNumber';

    await storage.write(key: 'profileFirstName', value: newProfileFirstName);

    setState(() {
      _cachedProfileFirstName = newProfileFirstName;
    });
  }

  void startNewGame() async {
    await resetUserId(forceReset: true); // สุ่ม userId ใหม่เฉพาะตอนเริ่มเกมใหม่
    startTime = DateTime.now();
    await fetchPairs();
  }

  Future<void> initializeProfileFirstName() async {
    // ตรวจสอบว่ามีค่าใน storage หรือยัง
    var profileFirstName = await storage.read(key: 'profileFirstName');

    if (profileFirstName == null) {
      // สุ่มค่าใหม่
      var random = Random();
      var randomNumber = random.nextInt(9000) + 1000;
      profileFirstName = 'guest_$randomNumber';

      // บันทึกค่าใหม่ใน storage
      await storage.write(key: 'profileFirstName', value: profileFirstName);
    }

    // เก็บค่าใน memory (session cache)
    setState(() {
      _cachedProfileFirstName = profileFirstName;
    });
  }

  Future<String?> getProfileFirstName() async {
    // ใช้ cache ถ้ามีอยู่แล้ว
    if (_cachedProfileFirstName != null) {
      return _cachedProfileFirstName;
    }

    // ดึงค่าจาก storage ถ้ามี
    _cachedProfileFirstName = await storage.read(key: 'profileFirstName');

    // ถ้าไม่มีใน storage ให้ใช้ค่า 'guest' พร้อม random id
    if (_cachedProfileFirstName == null) {
      _cachedProfileFirstName =
          'guest_${DateTime.now().millisecondsSinceEpoch}';
      // เก็บค่าลง storage
      await storage.write(
          key: 'profileFirstName', value: _cachedProfileFirstName);
    }

    return _cachedProfileFirstName;
  }

  Future<List<dynamic>> fetchRandomPairs() async {
    var profileFirstName = await getProfileFirstName();
    print('-------profileFirstName---11---->>>  ${profileFirstName}');

    final response = await Dio().get(
        'https://gateway.we-builds.com/sspmall-py-extended/matching/random-pairs/${profileFirstName}');

    if (response.statusCode == 200) {
      return response.data['pairs'];
    } else {
      throw Exception('Failed to fetch pairs');
    }
  }

  void submitAnswer() async {
    try {
      var profileFirstName = await getProfileFirstName();
      print('-------profileFirstName---22---->>>  ${profileFirstName}');

      List<Map<String, dynamic>> pairsMatchedData =
          matchedPairs.entries.map((entry) {
        return {
          'pair_id': entry.key,
          'word':
              pairs.firstWhere((pair) => pair['pair_id'] == entry.key)['word'],
          'image_url': entry.value,
        };
      }).toList();

      final Map<String, dynamic> requestData = {
        'user_id': profileFirstName,
        'user_name': profileFirstName,
        'pairs_matched': pairsMatchedData,
        'time_taken': pairsMatchedData.isNotEmpty ? _getTimeTaken() : "N/A",
      };
      print('------------>  Request Data    <------------');
      print(JsonEncoder.withIndent('  ').convert(requestData));

      final response = await Dio().post(
        'https://gateway.we-builds.com/sspmall-py-extended/matching/submit-pairs',
        data: requestData,
      );
      if (response.statusCode == 200) {
        _showCustomDialog(
          context: context,
          title: 'จบเกมส์!!',
          message: 'ใช้เวลาไปทั้งหมด : ${timeTaken} นาที',
          icon: Icons.check_circle,
          iconColor: Colors.green,
          onConfirm: () {
            startNewGame(); // เริ่มเกมใหม่
            Navigator.pop(context); // ปิดหน้า
          },
        );
      } else {
        // throw Exception('ส่งคำตอบล้มเหลว: ${response.statusCode}');
        _showCustomDialog(
          context: context,
          title: 'Failed!',
          message:
              'Failed to send answer.\n( ส่งคำตอบล้มเหลว: ${response.statusCode} )',
          icon: Icons.error_outline,
          iconColor: Colors.orange, // ใช้สีส้มแสดงสถานะผิดปกติ
        );
      }
    } catch (e) {
      _showCustomDialog(
        context: context,
        title: 'An error occurred.!',
        message: 'Please answer all questions.\n( กรุณาตอบให้ครบทุกข้อ )',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );

      print('Error in submitAnswer: $e');
    }
  }

  DateTime startTime = DateTime.now(); // เวลาเริ่มต้น
  String timeTaken = '';
  String _getTimeTaken() {
    DateTime endTime = DateTime.now(); // เวลาเมื่อกดปุ่มส่งคำตอบ
    Duration duration = endTime.difference(startTime); // คำนวณเวลาที่ใช้

    // แปลงเป็นรูปแบบที่ต้องการ (00:00)
    timeTaken =
        '${_twoDigits(duration.inMinutes)}:${_twoDigits(duration.inSeconds.remainder(60))}';
    print('===============> ${timeTaken}');
    return timeTaken;
  }

  String _twoDigits(int n) =>
      n.toString().padLeft(2, '0'); // แปลงเวลาเป็น 2 หลัก

  Future<void> fetchPairs() async {
    try {
      final data = await fetchRandomPairs();
      setState(() {
        pairs = data;
        matchedPairs = {
          for (var pair in data) pair['pair_id']: "",
        };
      });
    } catch (e) {
      print(e);
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/MatchingGame.gif',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.22,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        spreadRadius: 0,
                        // blurRadius: 8,
                        offset: Offset(0, 6),
                      ),
                    ]),
                height: MediaQuery.of(context).size.height * 0.76,
                width: MediaQuery.of(context).size.width * 0.9,
                child: pairs.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 20),
                              child: Text(
                                'Time spent: ${elapsedSeconds ~/ 60}:${elapsedSeconds % 60}',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'TitanOne',
                                    color: Color(0xFFf05151)
                                    // fontWeight: FontWeight.
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  // ด้านซ้าย: คำ
                                  Expanded(
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: pairs.length,
                                      itemBuilder: (context, index) {
                                        final word = pairs[index]['word'];
                                        final pairId = pairs[index]['pair_id'];
                                        return DragTarget<String>(
                                          onWillAccept: (data) => true,
                                          onAccept: (data) {
                                            setState(() {
                                              matchedPairs[pairId] =
                                                  data; // เก็บรูปที่จับคู่
                                            });
                                            print(
                                                '------345------$matchedPairs');
                                          },
                                          builder: (context, candidateData,
                                              rejectedData) {
                                            return Container(
                                              margin: EdgeInsets.all(3.0),
                                              padding: EdgeInsets.all(3.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: matchedPairs[pairId] ==
                                                          null
                                                      ? Color(0xFFF2d021)
                                                      : Color(0xFFf05151),
                                                  style: BorderStyle.solid,
                                                  width: 5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      // แสดงคำ
                                                      Text(
                                                        word,
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      // SizedBox(height: 8),
                                                      // แสดงรูปที่เลือกหรือข้อความว่าง
                                                      matchedPairs[pairId] != ""
                                                          ? Image.network(
                                                              matchedPairs[
                                                                  pairId]!,
                                                              height: 50,
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  Icon(
                                                                      Icons
                                                                          .image_not_supported,
                                                                      size: 50),
                                                            )
                                                          : Text(
                                                              'วางรูปที่นี่',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                    ],
                                                  ),
                                                  // ปุ่ม X เพื่อลบรูป
                                                  if (matchedPairs[pairId] !=
                                                      null)
                                                    Positioned(
                                                      top: 2,
                                                      right: 4,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            matchedPairs[
                                                                    pairId] =
                                                                ""; // ลบรูปที่เลือก
                                                          });
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.red,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  // VerticalDivider(),
                                  // ด้านขวา: รูปภาพ
                                  Expanded(
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: pairs.length,
                                      itemBuilder: (context, index) {
                                        final image = pairs[index]['image_url'];
                                        return Draggable(
                                          data: image,
                                          feedback: Material(
                                            child: Image.network(
                                              image,
                                              height: 60,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Icon(
                                                      Icons.image_not_supported,
                                                      size: 60),
                                            ),
                                          ),
                                          child: Container(
                                            margin: EdgeInsets.all(8.0),
                                            padding: EdgeInsets.all(8.0),
                                            child: Image.network(
                                              image,
                                              height: 60,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Icon(
                                                      Icons.image_not_supported,
                                                      size: 60),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Center(
                                      child: Text(
                                        'Back',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'TitanOne',
                                        ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      // primary: Color(0xFFf05151),
                                      backgroundColor: Color(0xFFF2d021),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      timer?.cancel();
                                      submitAnswer();
                                      // Navigator.pop(context);
                                    },
                                    child: Center(
                                      child: Text(
                                        'confirm',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'TitanOne',
                                        ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFf05151),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showCustomDialog({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onConfirm,
  }) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // มุมโค้ง
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white, // พื้นหลัง Dialog
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ไอคอน
                Icon(
                  icon,
                  size: 60,
                  color: iconColor,
                ),
                SizedBox(height: 15),
                // หัวข้อ
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                SizedBox(height: 10),
                // ข้อความ
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 20),
                // ปุ่มยืนยัน
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // ปิด Dialog
                      if (onConfirm != null) onConfirm(); // ถ้ามีฟังก์ชันยืนยัน
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor, // สีตามไอคอน
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'TitanOne',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
