import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaset_mall/math_game/math_game.dart';
import 'package:kaset_mall/shared/api_provider.dart';
import 'package:video_player/video_player.dart';

import '../../home.dart';

class MathGameMain extends StatefulWidget {
  MathGameMain({Key? key}) : super(key: key);

  @override
  _MathGameMain createState() => _MathGameMain();
}

class _MathGameMain extends State<MathGameMain> {
  final storage = new FlutterSecureStorage();
  late VideoPlayerController _controller;
  late Future<dynamic> _futureModel;
  List<dynamic> model = [];

  @override
  void initState() {
    super.initState();
    readRanking();
  }

  Duration parseTime(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      return Duration(
          minutes: int.parse(parts[0]), seconds: int.parse(parts[1]));
    } else {
      return Duration.zero;
    }
  }

  DateTime parseCreateDate(String createDate) {
    return DateTime.parse(createDate.substring(0, 8)); // ตัดเอาเฉพาะ yyyyMMdd
  }

  DateTime findMonday(DateTime date) {
    int daysToMonday = date.weekday - DateTime.monday;
    return date.subtract(Duration(days: daysToMonday));
  }

  DateTime findSunday(DateTime date) {
    int daysToSunday = DateTime.sunday - date.weekday;
    return date.add(Duration(days: daysToSunday));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/last_quickmath.gif',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.38,
            child: Container(
              width: 300,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MathGame()),
                  ).then((value) => readRanking());
                },
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.52,
            child: Container(
              width: 300,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.transparent, // สีพื้นหลัง
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    readRanking();
                  });
                  showDialog(
                    context: context,
                    builder: (context) => dialogRanking(context),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.65,
            child: Container(
              width: 300,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.transparent, // สีพื้นหลัง
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  dialogRanking(BuildContext context) {
    model
        .sort((a, b) => parseTime(a['timer']).compareTo(parseTime(b['timer'])));

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_ranking2.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            Expanded(
              child: ListView.builder(
                itemCount: model.length,
                itemBuilder: (context, index) {
                  var score = model[index];
                  int rank = index + 1;
                  BoxDecoration boxDecoration;
                  if (rank == 1) {
                    boxDecoration = BoxDecoration(
                      color: Colors.amber.shade200,
                      border: Border.all(color: Colors.amber, width: 3),
                      borderRadius: BorderRadius.circular(15),
                    );
                  } else if (rank == 2) {
                    boxDecoration = BoxDecoration(
                      color: Colors.blue.shade200,
                      border: Border.all(color: Colors.blue, width: 3),
                      borderRadius: BorderRadius.circular(15),
                    );
                  } else if (rank == 3) {
                    boxDecoration = BoxDecoration(
                      color: Colors.red.shade200,
                      border: Border.all(color: Colors.red, width: 3),
                      borderRadius: BorderRadius.circular(15),
                    );
                  } else {
                    boxDecoration = BoxDecoration(
                      color: Colors.red.shade100,
                      border: Border.all(color: Colors.red.shade200, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10),
                    child: Container(
                      decoration: boxDecoration,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontFamily: 'Layiji'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                score['name'],
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontFamily: 'Layiji'),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                score['timer'],
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontFamily: 'Layiji'),
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
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('ย้อนกลับ',
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
          ],
        ),
      ),
    );
  }

  readRanking() async {
    _futureModel = postDio(server_we_build + 'm/mathGame/ranking/read', {});

    List<dynamic> filteredData = await _futureModel;

    DateTime now = DateTime.now();
    DateTime firstDayOfTwoMonthsAgo = DateTime(now.year, now.month, 1);
    DateTime lastDayOfCurrentMonth =
        DateTime(now.year, now.month + 2, 1).subtract(const Duration(days: 1));

    setState(() {
      model = filteredData;
      // model = filteredData.where((item) {
      //   DateTime updateDate = parseCreateDate(item['updateDate']);
      //   return updateDate.isAfter(
      //           firstDayOfTwoMonthsAgo.subtract(const Duration(days: 1))) &&
      //       updateDate
      //           .isBefore(lastDayOfCurrentMonth.add(const Duration(days: 1)));
      // }).toList();
    });
  }
}
