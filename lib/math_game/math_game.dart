import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/shared/api_provider.dart';

import '../../shared/extension.dart';

class MathGame extends StatefulWidget {
  @override
  _MathGameState createState() => _MathGameState();
}

class _MathGameState extends State<MathGame>
    with SingleTickerProviderStateMixin {
  TextEditingController answerController = TextEditingController();
  final FocusNode answerFocusNode = FocusNode();
  final storage = new FlutterSecureStorage();

  double numberPositionOffset = 0;

  late Timer timer = Timer(Duration.zero, () {});
  int elapsedTime = 0;
  late Future<dynamic> _futureModel;
  List<dynamic> model = [];

  List<dynamic> modelAnswer = [];
  List<dynamic> userRanking = [];
  String validateText = '';
  int totalAnswer = 1;
  String? profileCode = '';
  String? firstName = '';
  // ควบคุมการเคลื่อนไหวของพื้นหลัง
  late AnimationController _animationController;
  double boxOffset = 0;
  Color boxColor = Color(0xFF40E0D0);
  dynamic selectedQuestion = {};
  Set<int> usedIndexes = {};

  final tempModel = [
    {"id": 1, "question": "8 + 4 * 3 - 6 / 2", "answer": 17},
    {"id": 2, "question": "15 - 3 * 4 + 18 / 6", "answer": 6},
    {"id": 3, "question": "24 / 3 + 5 * 2 - 7", "answer": 11},
    {"id": 4, "question": "10 * 2 - 8 / 4 + 3", "answer": 21},
    {"id": 5, "question": "9 + 12 / 3 * 4 - 7", "answer": 18},
    {"id": 6, "question": "14 - 6 * 2 + 8 / 4", "answer": 4},
    {"id": 7, "question": "20 / 5 + 6 * 3 - 4", "answer": 18},
    {"id": 8, "question": "7 * 4 - 16 / 2 + 5", "answer": 25},
    {"id": 9, "question": "18 + 6 / 2 * 3 - 9", "answer": 18},
    {"id": 10, "question": "25 - 5 * 3 + 20 / 4", "answer": 15}
  ];

  @override
  void initState() {
    readQuestion();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(answerFocusNode);
    });
    super.initState();
  }

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        elapsedTime++;
      });
    });
  }

  readQuestion() async {
    profileCode = await storage.read(key: 'profileCode10');
    firstName = await storage.read(key: 'profileFirstName');

    _futureModel = postDio(server_we_build + 'm/mathGame/question/read', {});

    model = await _futureModel;

    selectedQuestion = getRandomQuestion();
    startTimer();
  }

  void resetGame() {
    setState(() {
      elapsedTime = 0;
      answerController.clear();
      numberPositionOffset = 0;
      boxColor = Color(0xFF40E0D0);
      boxOffset = 0;
      modelAnswer.clear();
      usedIndexes = {};
      selectedQuestion = {};
      totalAnswer = 1;
      timer?.cancel();
      readQuestion();
    });
    Navigator.pop(context);
  }

  String get formattedTime {
    int minutes = elapsedTime ~/ 60;
    int seconds = elapsedTime % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController?.dispose();
    answerFocusNode.dispose();

    super.dispose();
  }

  void checkAnswer() async {
    int userAnswer = int.tryParse(answerController.text) ?? 0;
    int questionAnswer = int.tryParse(selectedQuestion["answer"]) ?? 0;
    if (userAnswer == questionAnswer) {
      setState(() {
        boxColor = Color(0xFF40E0D0);
        boxOffset = 0;
      });
      modelAnswer.add(selectedQuestion);
      if (modelAnswer.length < 3) {
        selectedQuestion = getRandomQuestion();
        totalAnswer += 1;
        answerController.text = '';
      } else {
        timer?.cancel();
        checkCreate();
      }
    } else {
      setState(() {
        boxColor = Colors.red;
        boxOffset = 10;
        validateText = '';
      });

      // กลับไปที่ตำแหน่งเดิมหลังจาก 300ms
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          boxOffset = 0;
        });
      });
    }
  }

  getRandomQuestion() {
    final random = Random();
    int index;
    var code;
    var questionLevel = modelAnswer.length == 0
        ? "1"
        : modelAnswer.length == 1
            ? "2"
            : "3";
    var modelLevel =
        model.where((x) => x['questionLevel'] == questionLevel).toList();
    for (int i = 0; i < modelLevel.length; i++) {
      index = random.nextInt(modelLevel.length);

      code = modelLevel[index]["code"];
      bool isUsed = modelAnswer.any((element) => element["code"] == code);
      if (!isUsed) {
        return modelLevel[index];
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    String question = selectedQuestion["question"] ?? '';

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/quickMath_.gif',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      'เวลา: $formattedTime',
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontFamily: 'Layiji'),
                    ),
                  ),
                  Container(
                    child: IconButton(
                      color: Colors.black,
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => dialogOptions(context),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 30),
              width: MediaQuery.of(context).size.width,
              child: Text(
                '${totalAnswer}/3',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontFamily: 'Layiji',
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        padding: const EdgeInsets.all(10.0),
                        width: 290,
                        duration: Duration(milliseconds: 300),
                        transform: Matrix4.translationValues(0, boxOffset, 0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: boxColor, width: 3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          question,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 32,
                              color: Colors.black,
                              fontFamily: 'Layiji'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    width: 320,
                    height: 90,
                    child: TextField(
                      focusNode: answerFocusNode,
                      controller: answerController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 24, fontFamily: 'Layiji'),
                      onChanged: (value) {
                        setState(() {
                          numberPositionOffset = (value.isNotEmpty) ? 10 : 0;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'กรอกคำตอบ',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: boxColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: boxColor, width: 3.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: boxColor, width: 3.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF40E0D0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8.0), // Change the radius here
                      ),
                    ),
                    onPressed: () {
                      checkAnswer();
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'ตรวจสอบคำตอบ',
                        style: TextStyle(fontSize: 24, fontFamily: 'Layiji'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  DateTime parseCreateDate(String createDate) {
    return DateTime.parse(createDate.substring(0, 8));
  }

  checkCreate() async {
    if (profileCode == null || profileCode == '') {
      dialogSuccess(context);
      return;
    }
    userRanking = await postDio(server_we_build + 'm/mathGame/ranking/read',
        {'reference': profileCode});

    if (userRanking.length > 0) {
      DateTime currentTime = _parseTime(userRanking[0]["timer"]);
      DateTime newTime = _parseTime(formattedTime);

      DateTime lastUpdate = parseCreateDate(userRanking[0]['updateDate']);
      DateTime now = DateTime.now();

      print(lastUpdate);

      bool isCurrentMonth =
          (lastUpdate.year == now.year && lastUpdate.month == now.month);

      if (!isCurrentMonth) {
        // อัปเดตเมื่อเป็นเดือนใหม่
        print('--update to new month');
        var update =
            await postDio(server_we_build + 'm/mathGame/ranking/update', {
          "code": userRanking[0]['code'],
          "reference": profileCode ?? "",
          "name": firstName ?? "",
          "timer": formattedTime,
        });
        dialogSuccess(context);
      } else if (newTime.isAfter(currentTime)) {
        // อัปเดตถ้าเวลาใหม่ดีกว่าเวลาเดิมในเดือนปัจจุบัน
        print('--update to better time');
        var update =
            await postDio(server_we_build + 'm/mathGame/ranking/update', {
          "code": userRanking[0]['code'],
          "reference": profileCode ?? "",
          "name": firstName ?? "",
          "timer": formattedTime,
        });
        dialogSuccess(context);
      } else {
        // ไม่ต้องอัปเดต
        print('--time not better, no update');
        dialogSuccess(context);
      }
    } else {
      print('--create');
      var create =
          await postDio(server_we_build + 'm/mathGame/ranking/create', {
        "reference": profileCode ?? "",
        "name": firstName ?? "",
        "timer": formattedTime,
      });
      dialogSuccess(context);
    }
  }

  dialogOptions(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.height * 0.4,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_options.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('เล่นต่อ',
                    style: TextStyle(fontSize: 24, fontFamily: 'Layiji')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Colors.yellow.shade200,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  resetGame();
                },
                child: Text('เริ่มใหม่',
                    style: TextStyle(fontSize: 24, fontFamily: 'Layiji')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Colors.yellow.shade200,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('กลับสู่หน้าหลัก',
                    style: TextStyle(fontSize: 24, fontFamily: 'Layiji')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Colors.red.shade200,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  dialogSuccess(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.5,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_victory.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 90),
                  Container(
                    child: Text('คุณใช้เวลาไป  $formattedTime',
                        style: TextStyle(
                            fontSize: 28,
                            fontFamily: 'Layiji',
                            color: Colors.amber.shade900)),
                  ),
                  SizedBox(height: 10),
                  if (profileCode == null || profileCode == '')
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                          '*สถิติจะไม่ถูกบันทึก เนื่องจากท่านยังไม่ได้ทำการเข้าสู่ระบบ',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Layiji',
                              color: Colors.red)),
                    ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: 180,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        resetGame();
                      },
                      child: Text('เริ่มใหม่',
                          style: TextStyle(fontSize: 24, fontFamily: 'Layiji')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            color: Colors.yellow.shade200,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 180,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text('กลับสู่หน้าหลัก',
                          style: TextStyle(fontSize: 24, fontFamily: 'Layiji')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            color: Colors.red.shade200,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
