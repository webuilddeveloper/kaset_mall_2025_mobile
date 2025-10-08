import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'matching_game.dart';

class Maching_Main extends StatefulWidget {
  const Maching_Main({Key? key}) : super(key: key);

  @override
  State<Maching_Main> createState() => _Maching_MainState();
}

class _Maching_MainState extends State<Maching_Main> {
  @override
  void initState() {
    super.initState();
    readRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Matching.gif',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55,
            child: Container(
              width: 300,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.transparent,
                //       color: Colors.transparent,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MatchingGameScreen()),
                  ).then((value) => readRanking());
                },
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.64,
            child: Container(
              width: 300,
              height: 65,
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
                    builder: (context) => Container(
                      child: dialogRanking(context),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.87,
            left: MediaQuery.of(context).size.height * 0.01,
            child: Container(
              width: 150,
              height: 70,
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
    model.sort((a, b) => parseTime(a['pairs_matched'].toString())
        .compareTo(parseTime(b['pairs_matched'].toString())));
    return Dialog(
      insetPadding: EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/scoreboard.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              height: 450,
              width: 300,
              // color: Colors.deepOrange,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return Divider(color: Colors.grey);
                      },
                      itemCount: model.length,
                      itemBuilder: (context, index) {
                        var score = model[index];

                        int rank = index + 1;
                        TextStyle textStyle;

                        if (rank == 1) {
                          textStyle = TextStyle(
                              color: Color(0xFFf2d021), // สีทอง
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'TitanOne');
                        } else if (rank == 2) {
                          textStyle = TextStyle(
                              color: Colors.blue.shade700, // สีน้ำเงิน
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'TitanOne');
                        } else if (rank == 3) {
                          textStyle = TextStyle(
                              color: Color(0xFFf05151), // สีแดง
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'TitanOne');
                        } else {
                          textStyle = TextStyle(
                              color: Color(0xFF41c2ab),
                              // สีทั่วไปสำหรับอันดับอื่น
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              fontFamily: 'TitanOne');
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10),
                          child: Container(
                            // decoration: boxDecoration,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '$rank',
                                      style: textStyle,
                                      // style: TextStyle(
                                      //     fontSize: 20,
                                      //     color: Colors.black,
                                      //     fontFamily: 'TitanOne'),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      score['user_name'],
                                      style: textStyle,
                                      // style: TextStyle(
                                      //     fontSize: 20,
                                      //     color: Colors.black,
                                      //     fontFamily: 'TitanOne'),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      score['pairs_matched'].toString(),
                                      style: textStyle,
                                      // style: TextStyle(
                                      //     fontSize: 20,
                                      //     color: Colors.black,
                                      //     fontFamily: 'TitanOne'),
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
                    child: Text(
                      'BACK',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'TitanOne',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFf05151),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                          color: Color(0xFF38373b),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
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

  List<dynamic> model = [];

  readRanking() async {
    // print('=========================00=========================');

    var dio = Dio();
    try {
      var response = await dio.request(
        'https://gateway.we-builds.com/sspmall-py-extended/matching/rankings',
        options: Options(
          method: 'GET',
        ),
      );
      // print('=======001================> ${response.data}');

      if (response.statusCode == 200) {
        setState(() {
          // Extract the 'rankings' key and assign it to model
          model = response
              .data['rankings']; // Ensure 'rankings' exists in the response

          // Sort the data by 'time_taken'
          model.sort((a, b) => parseTime(a['pairs_matched'].toString())
              .compareTo(parseTime(b['pairs_matched'].toString())));
        });
      } else {
        print('Error: ${response.statusMessage}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
}
