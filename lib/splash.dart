import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaset_mall/menu.dart';
import 'package:kaset_mall/shared/api_provider.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late Future<dynamic> futureModel;

  @override
  void initState() {
    _callRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildSplash();
  }

  _callRead() async {
    futureModel = postDio('${server_we_build}m/splash/read', {});
  }

  _callTimer(time) async {
    var _duration = new Duration(seconds: time);
    return new Timer(_duration, _callNavigatorPage);
  }

  _callNavigatorPage() async {
    final storage = new FlutterSecureStorage();
    String? value = await storage.read(key: 'profileCode10');

    if (value != null && value != '') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MenuCentralPage(),
          // builder: (context) => HomeMartPage(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MenuCentralPage(),
          // builder: (context) => HomeMartPage(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  _buildSplash() {
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
              //if no splash from service is return array length 0
              _callTimer((snapshot.data.length > 0
                      ? int.parse(snapshot.data[0]['timeOut']) / 1000
                      : 0)
                  .round());

              return snapshot.data.length > 0
                  ? Center(
                      child: Image.network(
                        snapshot.data[0]['imageUrl'],
                        fit: BoxFit.fill,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    )
                  : Container();
            } else if (snapshot.hasError) {
              _callTimer(0);
              return Container();
              // return Center(
              //   child: Container(
              //     color: Colors.white,
              //     child: dialogFail(context, reloadApp: true),
              //   ),
              // );
            } else {
              return Center(
                child: Container(),
              );
            }
          },
        ),
      ),
    );
  }
}
