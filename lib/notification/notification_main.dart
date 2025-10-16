import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/notification/notification_form.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../shared/api_provider.dart';
import '../../shared/extension.dart';

class NotificationMainCentralPage extends StatefulWidget {
  const NotificationMainCentralPage({Key? key}) : super(key: key);

  @override
  State<NotificationMainCentralPage> createState() =>
      _NotificationMainCentralPage();
}

class _NotificationMainCentralPage extends State<NotificationMainCentralPage> {
  dynamic profile = {'firstName': '', 'lastName': '', 'imageUrl': ''};
  late RefreshController _refreshController;
  int selectedIndex = 0;
  final storage = new FlutterSecureStorage();
  String _email = '';
  late Future<dynamic> futureNotification;
  String profileCode = "";

  List<dynamic> notiList = [
    {
      "code": "0",
      "title": "ลดทันที 30 บาท",
      "description":
          "พิเศษสำหรับลูกค้าใหม่!!! เมื่อสั่งซื้อครั้งแรก ลดทันที 30 บาท",
      "imageUrl": "assets/images/kaset/logo.png",
      "status": "A",
    },
    {
      "code": "1",
      "title": "ของแถมทุกออเดอร์",
      "description":
          "ฟรี!! ของแถมทุกออเดอร์ พร้อมส่วนลดลูกค้าใหม่ ด่วน!! ของมีจำนวนจำกัด",
      "imageUrl": "assets/images/kaset/logo.png",
      "status": "A",
    },
    {
      "code": "2",
      "title": "มาร่วมเป็นร้านค้ากับเราสิ",
      "description":
          "มาสมัครเป็นร้านค้าพันธมิตรกับเรา เพื่อการกระจายสินค้าสู่แอพช็อปปิ้งออนไลน์ และส่งตรงถึงมือลูกค้าทันที ตั้งแต่วันนี้เป็นต้นไป",
      "imageUrl": "assets/images/kaset/logo.png",
      "status": "A",
    }
  ];

  @override
  void initState() {
    _refreshController = new RefreshController();
    // _futureRotation = postDio('${mainRotationApi}read', {'limit': 10});
    // _getProfile();
    _getNotification();
    // _onLoading();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(
            complete: Container(
              child: Text(''),
            ),
            completeDuration: Duration(milliseconds: 0),
          ),
          footer: CustomFooter(
            builder: (context, mode) {
              Widget? body;
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: notiList.length,
            itemBuilder: (context, index) =>
                card(context, notiList[index], index),
          ),
          // FutureBuilder(
          //   future: futureNotification,
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       if (snapshot.data.length > 0) {
          //         return ListView.builder(
          //           shrinkWrap: true,
          //           physics: ScrollPhysics(),
          //           itemCount: snapshot.data.length,
          //           itemBuilder: (context, index) =>
          //               card(context, snapshot.data[index], index),
          //         );
          //       } else {
          //         return Center(
          //           child: Text('ไม่มีการแจ้งเตือน'),
          //         );
          //       }
          //     } else {
          //       return Center(
          //         child: Text('ไม่มีการแจ้งเตือน'),
          //       );
          //     }
          //   },
          // ),
        ));
  }

  Widget card(BuildContext context, dynamic model, int index) {
    double height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () async {
        // if (model['status'] != 'N') {
        //   postDio(
        //     server_we_build + 'notificationV2/m/readNoti',
        //     {
        //       'reference': model['code'],
        //       'profileCode': _email,
        //     },
        //   );
        //   futureNotification.then((value) => {
        //         setState(() {
        //           value[index]['status'] = 'N';
        //         })
        //       });
        // }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationFormPage(
                model: model,
                profileCode:
                    profileCode), //{'code': 'reference', 'id': model['reference']},
          ),
        ).then((value) => _onLoading());
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        // height: (height * 15) / 100,
        // width:isCheckSelect ? (width*20)/100,
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: model['status'] == 'A'
              ? Color.fromARGB(255, 168, 168, 168).withOpacity(0.4)
              : Color.fromARGB(255, 197, 197, 197).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(height * 1 / 100),
            //     color: model['status'] == 'A'
            //         ? Color(0xFFB7B7B7).withOpacity(0.1)
            //         : Colors.red,
            //   ),
            //   height: height * 1.5 / 100,
            //   width: height * 1.5 / 100,
            // ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                model['imageUrl'] != "" && model['imageUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          model['imageUrl'],
                          height: (height * 7) / 100,
                          width: (height * 7) / 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    // Container(
                    //     height: (height * 6) / 100,
                    //     width: (height * 6) / 100,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(5),
                    //       image: DecorationImage(
                    //         fit: BoxFit.fill,
                    //         // image: AssetImage(
                    //         //   'assets/images/bot_menu3.png',
                    //         // ),
                    //         image: NetworkImage(model['imageUrl']),
                    //       ),
                    //     ),
                    //   )
                    : Container(
                        height: (height * 12) / 100,
                        width: (height * 12) / 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage(
                              'assets/icon.png',
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 5),
                  Text(
                    parseHtmlString(model['description']),
                    style: TextStyle(
                      color: Colors.black,
                      // fontFamily: 'Arial',
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  // Container(
                  //   margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                  //   child: Text(
                  //     '${dateStringToDateStringFormatV2(model['createDate'])}',
                  //     style: TextStyle(
                  //       color: Color(0xFFB7B7B7),
                  //       fontFamily: 'Arial',
                  //       fontSize: 13,
                  //       fontWeight: FontWeight.normal,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  dateStringToDateStringFormatV2(String date, {String type = '/'}) {
    String result = '';
    if (date != '') {
      String yearString = date.substring(0, 4);
      var yearInt = int.parse(yearString);
      var year = yearInt + 543;
      var month = date.substring(4, 6);
      var day = date.substring(6, 8);
      var monthTH = "";
      if (month == "01")
        monthTH = "ม.ค.";
      else if (month == "02")
        monthTH = "ก.พ.";
      else if (month == "03")
        monthTH = "มี.ค.";
      else if (month == "04")
        monthTH = "เม.ย.";
      else if (month == "05")
        monthTH = "พ.ค.";
      else if (month == "06")
        monthTH = "มิ.ย.";
      else if (month == "07")
        monthTH = "ก.ค.";
      else if (month == "08")
        monthTH = "ส.ค.";
      else if (month == "09")
        monthTH = "ก.ย.";
      else if (month == "10")
        monthTH = "ต.ค.";
      else if (month == "11")
        monthTH = "พ.ย.";
      else if (month == "12") monthTH = "ธ.ค.";

      result = day + ' ' + monthTH + ' ' + year.toString();
    }

    return result;
  }

  // logic
  void _onRefresh() async {
    // setState(() {
    //   _limit = 30;
    // });
    _getNotification();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {});
    _getNotification();
    _refreshController.loadComplete();
  }

  _getNotification() async {
    futureNotification =
        postDio(server_we_build + 'notificationV2/m/getNoti', {});
    // dynamic valueStorage = await storage.read(key: 'dataUserLoginDDPM');
  }
}
