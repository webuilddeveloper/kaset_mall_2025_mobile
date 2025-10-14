// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaset_mall/shared/api_provider.dart';

class MatchGamePage extends StatefulWidget {
  MatchGamePage({Key? key, required this.profileCode}) : super(key: key);

  String profileCode;

  @override
  State<MatchGamePage> createState() => _MatchGamePageState();
}

class _MatchGamePageState extends State<MatchGamePage>
    with TickerProviderStateMixin {
  // List<dynamic> choice = [
  //   {"code": "1", "choiceA": "A", "choiceB": "A"},
  //   {"code": "2", "choiceA": "B", "choiceB": "B"},
  //   {"code": "3", "choiceA": "C", "choiceB": "C"},
  //   {"code": "4", "choiceA": "D", "choiceB": "D"},
  // ];

  List<dynamic> choice = [
    {"code": "1", "choice": "A", "codeResult": "AA", "choicePosition": "1"},
    {"code": "2", "choice": "A", "codeResult": "AA", "choicePosition": "2"},
    {"code": "3", "choice": "B", "codeResult": "BB", "choicePosition": "1"},
    {"code": "4", "choice": "B", "codeResult": "BB", "choicePosition": "2"},
    {"code": "5", "choice": "C", "codeResult": "CC", "choicePosition": "1"},
    {"code": "6", "choice": "C", "codeResult": "CC", "choicePosition": "2"},
    {"code": "7", "choice": "D", "codeResult": "DD", "choicePosition": "1"},
    {"code": "8", "choice": "D", "codeResult": "DD", "choicePosition": "2"},
  ];

  List<dynamic> question = [];
  List<dynamic> scoreRankings = [];

  int page = 1;
  int isWrong = 0;
  int isQuestion = 0;
  int isCorrect = 0;
  String answer = "";
  String choiceCorrect = "";
  int timeBeforeStart = 3;
  int timeCountDownGame = 60;
  int countDownBeforeStartGame = 3;
  Timer timer = Timer(Duration(), () {});
  final storage = new FlutterSecureStorage();
  Dio dio = new Dio();
  late AnimationController controller;
  late Animation<double> animation;

  late AnimationController controllerAminDialog;
  late Animation<double> animationDialog;

  late AnimationController controllerAminScore;
  late Animation<double> animationScore;

  late AnimationController controllerAminBtn;
  late Animation<double> animationBtn;

  late AnimationController controllerAminScaleIn;
  late Animation<double> animationScaleIn;

  late AnimationController controllerAminCountDown;
  late Animation<double> animationCountDown;

  double opacityLevel = 0.0;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  initState() {
    get_questions();
    get_rankings();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        opacityLevel = 1.0;
        timer.cancel();
        setState(() {
          Timer timer2 = Timer.periodic(
            const Duration(milliseconds: 300),
            (timer2) {
              setState(() {
                controllerAminBtn = AnimationController(
                    duration: const Duration(milliseconds: 1200),
                    reverseDuration: const Duration(milliseconds: 1000),
                    vsync: this);
                animationBtn = CurvedAnimation(
                    parent: controllerAminBtn,
                    curve: Curves.elasticOut,
                    reverseCurve: Curves.elasticOut);
                controllerAminBtn.forward();
              });
              timer2.cancel();
            },
          );
        });
      },
    );
    super.initState();
    controllerAminBtn = AnimationController(
        duration: const Duration(milliseconds: 1200),
        reverseDuration: const Duration(milliseconds: 1000),
        vsync: this);
    animationBtn = CurvedAnimation(
        parent: controllerAminBtn,
        curve: Curves.elasticOut,
        reverseCurve: Curves.elasticOut);

    controllerAminCountDown = AnimationController(
        duration: const Duration(milliseconds: 1200),
        reverseDuration: const Duration(milliseconds: 1000),
        vsync: this);
    animationCountDown = CurvedAnimation(
        parent: controllerAminCountDown,
        curve: Curves.linear,
        reverseCurve: Curves.linearToEaseOut);

    controllerAminDialog = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    animationDialog = CurvedAnimation(
        parent: controllerAminDialog, curve: Curves.easeInOutBack);
  }

  get_questions() async {
    // dynamic valueStorage = await storage.read(key: 'dataUserLoginDDPM');
    await getQuestion(server_gateway + 'random-questions/' + widget.profileCode)
        .then((value) async {
      question = value['questions'];
      question[Random().nextInt(question.length)];
    });
  }

  get_rankings() async {
    await getQuestion(server_gateway + 'rankings?' + 'limit=10')
        .then((value) async {
      scoreRankings = value['rankings'];
      print('>>>>>>--------->>>>> ${scoreRankings}');
    });
  }
  // https://gateway.we-builds.com/sspmall-py-extended/phonics/rankings?limit=10

  check_answer(phonics_id, choice) async {
    try {
      var response =
          await postQuestion('${server_gateway}check-answer/$phonics_id', {
        "choice": choice,
        "user_id": widget.profileCode,
        "user_name": widget.profileCode,
        "time_taken": "00:${timeCountDownGame}"
      });
      print('>>>>>>--------->>>>> ${response}');
      if (response['game_over']) {
        if (response['correct']) {
          setState(() {
            isCorrect++;
            choiceCorrect = response['answer'];
            answer = response['filled_question'];
          });
          Future.delayed(Duration(seconds: 2), () {
            timer.cancel();
            controllerAminDialog.forward();
            ScaleTransition(
              // opacity: animation,
              scale: animationDialog,
              child: dialog_game_over(),
            );
          });
        } else if (!response['correct']) {
          print('=================');
          dialogWarning(
            context,
            title: 'ผิดดด',
            autoClose: true,
            autoCloseDelay: 1500,
            subTitle: response['filled_question'],
            actionAfterAutoClose: () {
              setState(() {
                isWrong++;
              });
              timer.cancel();
              dialog_game_over();
            },
          );
        }
        ;
      } else {
        if (response['correct']) {
          setState(() {
            choiceCorrect = response['answer'];
            answer = response['filled_question'];
            Future.delayed(Duration(seconds: 2), () {
              setState(() {
                choiceCorrect = "";
                answer = "";
                isQuestion++;
                isCorrect++;
              });
              controller = AnimationController(
                  duration: const Duration(milliseconds: 1200), vsync: this);
              animation =
                  CurvedAnimation(parent: controller, curve: Curves.elasticOut);
              controller.forward();
            });
          });
        } else {
          dialogWarning(
            context,
            title: 'ผิดดด',
            autoClose: true,
            autoCloseDelay: 1500,
            subTitle: response['filled_question'],
            actionAfterAutoClose: () {
              setState(() {
                isWrong++;
                // return false;
              });
            },
          );
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: AnimatedOpacity(
        opacity: opacityLevel,
        curve: Curves.easeInOutBack,
        duration: const Duration(seconds: 1),
        onEnd: () {
          timer = Timer.periodic(
            const Duration(milliseconds: 300),
            (timer) {
              setState(() {
                timer.cancel();
              });
            },
          );
          print('==========');
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              opacity: 0.33,
              fit: BoxFit.fitHeight,
              image: AssetImage('assets/images/phonics_game_bg.jpeg'),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: page == 0
                  ? page_countdown_start_game()
                  : page == 1
                      ? page_main()
                      : page == 2
                          ? page_game()
                          : page_score(),
            ),
          ),
        ),
      ),
    );
  }

  page_main() {
    // controllerAminBtn.reverse();
    controllerAminBtn.forward();
    return Stack(
      // alignment: Alignment.center,
      children: [
        Positioned.fill(
          top: 100,
          left: 0,
          right: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'คำนี้เติม...อะไรดี?',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  ScaleTransition(
                    // opacity: animation,
                    scale: animationBtn,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(12),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.red, // background color
                        shadowColor: Colors.white, // text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        controllerAminBtn.reverse().then(
                              (value) => {
                                get_questions(),
                                setState(() {
                                  page = 0;
                                }),
                                countDown(
                                  countDownTime: countDownBeforeStartGame,
                                  mode: '1',
                                  actionAfterTimeOut: () {
                                    setState(() {
                                      page = 2;
                                    });
                                    countDown(
                                      countDownTime: timeCountDownGame,
                                      mode: '2',
                                    );
                                  },
                                ),
                              },
                            );
                      },
                      child: Text(
                        'เริ่มเกมส์เลย',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ScaleTransition(
                    // opacity: animation,
                    scale: animationBtn,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(12),
                        backgroundColor: Colors.orange,

                        shadowColor: Colors.white, // text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        await get_rankings();
                        setState(() {
                          page = 3;
                        });
                        controllerAminScore = AnimationController(
                            duration: const Duration(milliseconds: 1200),
                            vsync: this);
                        animationScore = CurvedAnimation(
                            parent: controllerAminScore,
                            curve: Curves.elasticOut);
                        controllerAminScore.forward();
                      },
                      child: Text(
                        'ดูอันดับคะแนนคนเก่ง',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
            bottom: MediaQuery.of(context).size.height * 0.05,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.red.withOpacity(0.85),

                shadowColor: Colors.white, // text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Center(
                  child: Text(
                '  ย้อนกลับ  ',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              )),
            )),
      ],
    );
  }

  page_countdown_start_game() {
    return Center(
      child: Text(
        timeBeforeStart.toString(),
        style: TextStyle(
          color: Colors.red.shade800,
          fontSize: 200,
          fontWeight: FontWeight.w500,
          // fontFamily: 'IBMPlex',
        ),
      ),
    );
  }

  countDown(
      {int countDownTime = 0,
      ControllerCallback? actionAfterTimeOut,
      String? mode}) {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (mode == '1') {
          setState(
            () {
              countDownTime--;
              timeBeforeStart--;
              if (countDownTime == 0 && actionAfterTimeOut != null) {
                timer.cancel();
                actionAfterTimeOut!();
              }
            },
          );
        } else if (mode == '2') {
          setState(
            () {
              countDownTime--;
              timeCountDownGame--;
              if (countDownTime == 0) {
                timer.cancel();
                controllerAminDialog.forward();
                dialog_game_over();
              }
            },
          );
        }
      },
    );
    controller = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.elasticOut);
    controller.forward();
  }

  page_game() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                'ข้อที่ ${isQuestion + 1}/${question.length}',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SizedBox(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.red,

                shadowColor: Colors.white, // text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                timer.cancel();
                controllerAminDialog.forward();
                dialog_confirm_endGame();
              },
              child: Text(
                'ออกจากเกมส์',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                  text: 'เหลืออีก : ',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: 'Kanit',
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: '${timeCountDownGame}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Kanit')),
                    TextSpan(
                        text: ' วินาที',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontFamily: 'Kanit')),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                  text: 'ตอบผิด : ',
                  style: TextStyle(
                      fontSize: 20, color: Colors.black, fontFamily: 'Kanit'),
                  children: <TextSpan>[
                    TextSpan(
                        text: '${isWrong}/3',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Kanit')),
                    TextSpan(
                        text: ' ครั้ง',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontFamily: 'Kanit')),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 3),
                        color: Colors.grey.withOpacity(0.7),
                        // color: Colors.white,
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        // top: 0,
                        // right: 0,
                        // left: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                play_sound(question[isQuestion]['voice_url']);
                              },
                              child: Icon(
                                Icons.volume_up,
                                size: 40,
                              ),
                            )
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            child: Image.network(
                              question[isQuestion]['image_url'],
                              fit: BoxFit.contain,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  answer.isEmpty
                                      ? question[isQuestion]['question']
                                          .toString()
                                      : answer,
                                  style: TextStyle(fontSize: 50),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: (2 / 2),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(10.0),
                    children: [
                      ...question[isQuestion]['choices'].asMap().entries.map(
                        (e) {
                          var index = e.key;
                          var value = e.value;
                          MaterialColor isColor = index == 0
                              ? Colors.amber
                              : index == 1
                                  ? Colors.blue
                                  : index == 2
                                      ? Colors.purple
                                      : Colors.orange;
                          return ScaleTransition(
                            // opacity: animation,
                            scale: animation,
                            child: InkWell(
                              onTap: () {
                                (choiceCorrect ?? "") == ""
                                    ? check_answer(
                                        question[isQuestion]['phonics_id'],
                                        value)
                                    : null;
                              },
                              child: Container(
                                padding: const EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: choiceCorrect == ""
                                      ? isColor
                                      : choiceCorrect == value
                                          ? isColor
                                          : isColor,
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(0, 3),
                                      color: Colors.grey.withOpacity(0.7),
                                      // color: Colors.white,
                                      blurRadius: 6,
                                    )
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    choiceCorrect == value
                                        ? Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Center(
                                              child: Icon(
                                                Icons.check,
                                                size: 120,
                                                color: Color.fromARGB(
                                                    255, 73, 181, 76),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    Center(
                                      child: Text(
                                        value.toString(),
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 70),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  page_score() {
    return Column(
      children: [
        SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                'จัดอันดับคะแนน',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.orange,

                shadowColor: Colors.white, // text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  page = 1;
                  controllerAminBtn.forward();
                });
              },
              child: Text(
                'กลับหน้าหลัก',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        ),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (_, __) => const Divider(
              height: 18,
            ),
            itemCount: scoreRankings.length,
            itemBuilder: (context, index) => ScaleTransition(
              // opacity: animation,
              scale: animationScore,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        // color: Colors.amber,
                        color: Color.fromARGB(
                          255,
                          Random().nextInt(256),
                          Random().nextInt(256),
                          Random().nextInt(256),
                        ).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text:
                                    'อันดับที่ ${scoreRankings[index]['rank'].toString()}. ',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: 'Kanit',
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: scoreRankings[index]['user_name']
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'Kanit'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                  text: 'จำนวน ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontFamily: 'Kanit',
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text:
                                            '${scoreRankings[index]['total_correct'].toString()}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: 'Kanit')),
                                    TextSpan(
                                        text: ' ข้อ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontFamily: 'Kanit')),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                  text:
                                      '${scoreRankings[index]['time_taken'].toString()}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Kanit'),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: ' นาที',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Kanit')),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ),
      ],
    );
  }

  dialogSuccessApply(BuildContext context,
      {bool pressBarrierToClose = true,
      String? title,
      String? subTitle,
      List<Widget>? content,
      bool showBackground = true,
      bool autoClose = false,
      required ControllerCallback actionAfterAutoClose,
      int autoCloseDelay = 3}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.5),
      barrierDismissible: pressBarrierToClose,
      builder: (BuildContext context) {
        autoClose
            ? Future.delayed(Duration(milliseconds: autoCloseDelay), () {
                Navigator.pop(context);
                actionAfterAutoClose();
              })
            : Container();
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          elevation: 15,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 15),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(36),
            ),
          ),
          content: Container(
            // width: 100,
            height: 200,
            color: Colors.transparent,
            // constraints:
            //     const BoxConstraints(minHeight: 70, maxHeight: double.infinity),
            child: Stack(
              children: [
                Container(
                  // padding: const EdgeInsets.all(20),
                  child: Column(
                    // alignment: WrapAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.asset(
                          'assets/images/icon check.png',
                          fit: BoxFit.contain,
                          // width: 50,
                          // height: 235,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title.toString(),
                            style: const TextStyle(
                              color: Color(0xFF0A5E4F),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              // fontFamily: 'IBMPlex',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            subTitle.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              // fontFamily: 'IBMPlex',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  dialogWarning(
    BuildContext context, {
    bool pressBarrierToClose = true,
    String? title,
    String? subTitle,
    List<Widget>? content,
    bool showBackground = true,
    int autoCloseDelay = 3,
    bool autoClose = false,
    required ControllerCallback actionAfterAutoClose,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.5),
      barrierDismissible: pressBarrierToClose,
      builder: (BuildContext context) {
        autoClose
            ? Future.delayed(Duration(milliseconds: autoCloseDelay), () {
                Navigator.pop(context);
                actionAfterAutoClose();
              })
            : Container();
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 15),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(36),
            ),
          ),
          content: SizedBox(
            width: 150,
            height: 150,
            child: Image.asset(
              'assets/images/icon_error.png',
              fit: BoxFit.contain,
              // width: 50,
              // height: 235,
            ),
          ),
        );
      },
    );
  }

  dialogEmpty(
    BuildContext context, {
    bool pressBarrierToClose = true,
    String? title,
    double titleFontSize = 20.0,
    String? subTitle,
    List<Widget>? content,
    bool showBackground = false,
  }) {
    return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.elasticOut.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0, curvedValue, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              elevation: 15,
              insetPadding: const EdgeInsets.symmetric(horizontal: 15),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(36),
                ),
              ),
              content: Container(
                // width: MediaQuery.of(context).size.width,
                // height: 180,
                constraints: const BoxConstraints(
                    minHeight: 180, maxHeight: double.infinity, maxWidth: 400),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          // alignment: WrapAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    title.toString(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            ...?content

                            // content!.isNotEmpty ? ...content!.map((e) => e).toList() : Container(),
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
      },
      transitionDuration: Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      // ignore: missing_return
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
    );
  }

  play_sound(path) async {
    final player = AudioPlayer();
    await player.play(UrlSource(path));
  }

  dialog_game_over() {
    return dialogEmpty(
      context,
      title: 'จบเกมส์',
      titleFontSize: 50,
      pressBarrierToClose: false,
      content: [
        Container(
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              text: 'เหลืออีก : ',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontFamily: 'Kanit',
              ),
              children: <TextSpan>[
                TextSpan(
                    text: '${timeCountDownGame}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Kanit')),
                TextSpan(
                    text: ' วินาที',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontFamily: 'Kanit')),
              ],
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              text: 'ทำได้ : ',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontFamily: 'Kanit',
              ),
              children: <TextSpan>[
                TextSpan(
                    text: '${isCorrect}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Kanit')),
                TextSpan(
                    text: ' ข้อ',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontFamily: 'Kanit')),
              ],
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              text: 'ตอบผิด : ',
              style: TextStyle(
                  fontSize: 20, color: Colors.black, fontFamily: 'Kanit'),
              children: <TextSpan>[
                TextSpan(
                    text: '${isWrong}/3',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Kanit')),
                TextSpan(
                    text: ' ครั้ง',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontFamily: 'Kanit')),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.purple,
                disabledBackgroundColor: Colors.purple, // background color
                shadowColor: Colors.white, // text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  setValueDefault();
                  Navigator.pop(context);
                  page = 3;
                  controllerAminScore.forward();
                });
              },
              child: Text(
                'ดูผลคะแนน',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.red,
                disabledBackgroundColor: Colors.red, // background color
                shadowColor: Colors.white, // text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                  page = 1;
                  setValueDefault();
                  controllerAminBtn.forward();
                });
              },
              child: Text(
                'กลับหน้ากลัก',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            )
          ],
        ),
      ],
    );
  }

  dialog_confirm_endGame() {
    return dialogEmpty(
      context,
      title: 'ต้องการออกจากเกมส์\nใช่ หรือไม่',
      titleFontSize: 30,
      pressBarrierToClose: false,
      content: [
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.blue, // background color
                shadowColor: Colors.white, // text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                  countDown(countDownTime: timeCountDownGame, mode: "2");
                });
              },
              child: Text(
                'เล่นต่อ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.red,
                disabledBackgroundColor: Colors.red, // background color
                shadowColor: Colors.white, // text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                  page = 1;
                  setValueDefault();
                  // controllerAminBtn.forward();
                });
              },
              child: Text(
                'ออก',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ],
    );
  }

  setValueDefault() {
    setState(() {
      isWrong = 0;
      isQuestion = 0;
      isCorrect = 0;
      answer = "";
      choiceCorrect = "";
      timeBeforeStart = 3;
      timeCountDownGame = 60;
      timer.cancel();
    });
  }
}
