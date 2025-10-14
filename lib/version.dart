import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kaset_mall/splash.dart';
import 'package:url_launcher/url_launcher.dart';

import 'shared/api_provider.dart';
import 'widget/dialog.dart';

class VersionPage extends StatefulWidget {
  @override
  _VersionPageState createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  late Future<dynamic> futureModel;

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<dynamic>(
          future: futureModel,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data['isActive']) {
                if (versionNumber < snapshot.data['version']) {
                  // print('update');

                  return Center(
                    child: Container(
                      color: Colors.white,
                      child: dialogVersion(
                        context,
                        title: snapshot.data['title'],
                        description: snapshot.data['description'],
                        isYesNo: !snapshot.data['isForce'],
                        callBack: (param) {
                          if (param) {
                            launch(snapshot.data['url']);
                          } else {
                            _callGoSplash();
                          }
                        },
                      ),
                    ),
                  );
                } else {
                  _callGoSplash();
                }
              } else {
                _callGoSplash();
              }
              return Container();
            } else if (snapshot.hasError) {
              _callGoSplash();
              return Container();
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  _callRead() {
    if (Platform.isAndroid) {
      futureModel = postDio(versionReadApi, {'platform': 'Android'});
    } else if (Platform.isIOS) {
      // print('version');
      futureModel = postDio(versionReadApi, {'platform': 'Ios'});
    }
  }

  _callGoSplash() {
    // print('go splash');

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Add Your Code here.
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(
    //       builder: (context) => SplashPage(),
    //     ),
    //   );
    // });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // add your code here.
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => SplashPage()));
    });
  }
}
