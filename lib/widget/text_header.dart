// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kasetmall/cart.dart';

Container textHeader(
  BuildContext context, {
  String title = '',
  double fontSize = 15.0,
  FontWeight fontWeight = FontWeight.w500,
  Color color = Colors.black,
}) {
  return Container(
    padding: EdgeInsets.only(top: 5.0),
    child: Row(
      children: [
        Container(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
            textScaleFactor: ScaleSize.textScaleFactor(context),
          ),
        ),
      ],
    ),
  );
}
