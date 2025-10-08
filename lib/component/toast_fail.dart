import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

toastFail(BuildContext context,
    {String text = 'เกิดข้อผิดพลาดกรุณาลองใหม่อีกครั้ง',
    Color color = Colors.grey,
    Color fontColor = Colors.white,
    int duration = 3}) {
  return Toast.show(
    text,
    backgroundColor: color,
    duration: duration,
    gravity: Toast.bottom,
    textStyle: TextStyle(color: fontColor),
  );
}
