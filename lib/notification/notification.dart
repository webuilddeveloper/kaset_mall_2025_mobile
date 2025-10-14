import 'package:flutter/material.dart';
import 'package:kaset_mall/notification/notification_main.dart';

import '../cart.dart';

class NotificationCentralPage extends StatefulWidget {
  const NotificationCentralPage({Key? key}) : super(key: key);

  @override
  State<NotificationCentralPage> createState() => _NotificationCentralPage();
}

class _NotificationCentralPage extends State<NotificationCentralPage> {
  int _selectedIndex = 0;
  late TextEditingController searchController;
  List<Widget> _widgetOptions = <Widget>[];
  String profileCode = "";

  @override
  void initState() {
    searchController = TextEditingController(text: '');
    _widgetOptions = <Widget>[
      NotificationMainCentralPage(),
      // NotificationPromotionCentralPage(),
      const SizedBox(),
      const SizedBox(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: AdaptiveTextSize().getadaptiveTextSize(context, 50),
          flexibleSpace: Container(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top +
                    AdaptiveTextSize().getadaptiveTextSize(context, 10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'การแจ้งเตือน',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textScaleFactor: ScaleSize.textScaleFactor(context),
                    textAlign: TextAlign.start,
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Container(
              //   margin: EdgeInsets.only(top: 15.0, left: 20.0),
              //   child: Row(
              //     // scrollDirection: Axis.horizontal,
              //     children: [
              //       _buttonBottomBar('ทั้งหมด', 0),
              //       _buttonBottomBar('โปรโมชัน', 1),
              //     ],
              //   ),
              // ),
              Expanded(
                child: _widgetOptions[_selectedIndex],
              ),
            ],
          ),
        ));
  }
}
