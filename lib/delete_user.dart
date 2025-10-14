import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaset_mall/shared/api_provider.dart';

import '../component/link_url_in.dart';
import 'menu.dart';

class DeleteUser extends StatefulWidget {
  const DeleteUser({Key? key}) : super(key: key);

  @override
  State<DeleteUser> createState() => _DeleteUserState();
}

class _DeleteUserState extends State<DeleteUser> with TickerProviderStateMixin {
  double currentOpacity = 0;
  late AnimationController animationController;

  late String qrCode;
  bool loadingSuccess = false;
  // Timer myTimerCheck;
  bool success = false;
  bool a1 = false;

  @override
  void initState() {
    _callDeleteUser();
    animationController = AnimationController(
      value: 0.25,
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    animationController.addListener(() {
      setState(() {});
    });
    super.initState();
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  _callDeleteUser() {
    delete(server + 'users/me')
        .then((value) => {print('delete ===== >>>>>> ${value}')});
  }

  @override
  Widget build(BuildContext context) {
    var tween = Tween<double>(begin: 0, end: 100).animate(animationController);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   elevation: 0,
        //   backgroundColor: Colors.white,
        //   automaticallyImplyLeading: false,
        //   toolbarHeight: 50,
        //   flexibleSpace: Container(
        //     color: Colors.transparent,
        //     child: Container(
        //       margin:
        //           EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
        //       padding: EdgeInsets.symmetric(horizontal: 15),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           GestureDetector(
        //             onTap: () {
        //               Navigator.pop(context);
        //             },
        //             child: Row(
        //               children: [
        //                 Icon(Icons.arrow_back_ios),
        //                 Text(
        //                   'สำเร็จ',
        //                   style: TextStyle(
        //                     color: Colors.black,
        //                     fontSize: 20,
        //                     fontWeight: FontWeight.bold,
        //                   ),
        //                   textAlign: TextAlign.start,
        //                 )
        //               ],
        //             ),
        //           ),
        //           Expanded(child: SizedBox()),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        body: SafeArea(
          child: Center(child: _successToPayPage()),
        ),
      ),
      // ignore: missing_return
    );
    // );
  }

  _successToPayPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Opacity(
          opacity: animationController.value,
          child: Icon(
            Icons.check_circle_rounded,
            size: animationController.value * 100,
            color: Color(0xFF1CBC51),
          ),
        ),
        SizedBox(height: 15),
        Opacity(
          opacity: animationController.value,
          child: Text(
            'คุณได้ทำการยกเลิกบัญชีแล้ว',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1CBC51),
            ),
          ),
        ),
        SizedBox(height: 15),
        Text(
          'หากต้องการกู้คืนโปรดติดต่ออีเมล',
          style: TextStyle(
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        InkWell(
          onTap: () {
            launchInWebViewWithJavaScript('mailto:korn.th@mywawa.me');
          },
          child: Text(
            'korn.th@mywawa.me',
            style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 13, 150, 213),
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        // SizedBox(height: 15),
        Text(
          'ภายใน 30 วันหลังที่ได้คุณได้ทำการยกเลิกบัญชี',
          style: TextStyle(
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => MenuCentralPage(),
              ),
              (Route<dynamic> route) => false,
            );
            // myTimerCheck.cancel();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                width: 1,
                color: Color(0xFFDF0B24),
              ),
            ),
            child: Text(
              'กลับหน้าหลัก',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFFDF0B24),
              ),
            ),
          ),
        )
      ],
    );
  }
}
