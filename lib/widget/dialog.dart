import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_mart_v3/shared/api_provider.dart';

dialog(BuildContext context,
    {String? title,
    String? description,
    bool isYesNo = false,
    String btnOk = 'ตกลง',
    String btnCancel = 'ยกเลิก',
    Function? callBack}) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: new Text(
            title!,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          content: Text(
            description!,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            Container(
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: CupertinoDialogAction(
                isDefaultAction: true,
                child: new Text(
                  btnOk,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Kanit',
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onPressed: () {
                  if (isYesNo) {
                    Navigator.pop(context, false);
                    callBack!();
                  } else {
                    Navigator.pop(context, false);
                  }
                },
              ),
            ),
            if (isYesNo)
              Container(
                color: Color(0xFF707070),
                child: CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    btnCancel,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Kanit',
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ),
          ],
        );
      });
}

dialogVersion(BuildContext context,
    {String? title,
    String? description,
    bool isYesNo = false,
    Function? callBack}) {
  return CupertinoAlertDialog(
    title: new Text(
      title!,
      style: TextStyle(
        fontSize: 20,
        fontFamily: 'Kanit',
        color: Colors.black,
        fontWeight: FontWeight.normal,
      ),
    ),
    content: Column(
      children: [
        Text(
          description!,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'เวอร์ชั่นปัจจุบัน ' + versionName,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Kanit',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    ),
    actions: [
      Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: CupertinoDialogAction(
          isDefaultAction: true,
          child: new Text(
            "อัพเดท",
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Kanit',
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.normal,
            ),
          ),
          onPressed: () {
            if (isYesNo) {
              callBack!(true);
              // Navigator.pop(context, false);
            } else {
              callBack!(true);
              // Navigator.pop(context, false);
            }
          },
        ),
      ),
      if (isYesNo)
        Container(
          color: Color(0xFF707070),
          child: CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text(
              "ภายหลัง",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              callBack!(false);
              Navigator.pop(context, false);
            },
          ),
        ),
    ],
  );
}

dialogBtn(BuildContext context,
    {String? title,
    String? description,
    bool isYesNo = false,
    String btnOk = 'ตกลง',
    String btnCancel = 'ยกเลิก',
    Function? callBack}) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: new Text(
            title!,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          content: Text(
            description!,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Kanit',
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            Container(
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: CupertinoDialogAction(
                isDefaultAction: true,
                child: new Text(
                  btnOk,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Kanit',
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                  callBack!(true);
                },
              ),
            ),
            if (isYesNo)
              Container(
                color: Color(0xFFE84C10),
                child: CupertinoDialogAction(
                  isDefaultAction: true,
                  child: new Text(
                    btnCancel,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Kanit',
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                    callBack!(false);
                  },
                ),
              ),
          ],
        );
      });
}

showPinkDialog({
  required BuildContext context,
  required VoidCallback onTap,
  required String title,
  required String subtitle,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Color(0xFFFCA0A6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF012A6C),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'ยืนยัน',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 30,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

showPinkDialog_2({
  required BuildContext context,
  required VoidCallback onTap1,
  required VoidCallback onTap2,
  required String title,
  required String subtitle,
  required String txtbtn1,
  required String txtbtn2,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        color: Color(0xFFFCA0A6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onTap1,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Color(0xFF012A6C)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  txtbtn1,
                                  style: TextStyle(
                                    color: Color(0xFF012A6C),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          // ใช้ Expanded เพื่อให้ขยายเต็มพื้นที่
                          child: GestureDetector(
                            onTap: onTap2,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFF012A6C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  txtbtn2,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 30,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

showSuccessDialog({
  required BuildContext context,
  required VoidCallback onTapD,
  required VoidCallback onTapS,
  required String title,
  required String subtitle,
  required String txtbtnD,
  required String txtbtnS,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/check-one.png',
                      width: 80,
                      height: 80,
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Color(0xFF039855),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onTapD,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Color(0xFF012A6C), width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  txtbtnD,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF012A6C),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: onTapS,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFF012A6C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Center(
                                  child: Text(
                                    txtbtnS,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 30,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

showSuccessDialog1({
  required BuildContext context,
  required VoidCallback onTap,
  required String title,
  required String subtitle,
  required String txtbtn,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/check-one.png',
                      width: 80,
                      height: 80,
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Color(0xFF039855),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF012A6C),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            txtbtn,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 30,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

showDeleteDialog({
  required BuildContext context,
  required VoidCallback onTapD,
  required VoidCallback onTapS,
  required String title,
  required String subtitle,
  required String txtbtnD,
  required String txtbtnS,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Color(0xFFFCA0A6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onTapD,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Color(0xFF012A6C), width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  txtbtnD,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF012A6C),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: onTapS,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFF012A6C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Center(
                                  child: Text(
                                    txtbtnS,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 30,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
