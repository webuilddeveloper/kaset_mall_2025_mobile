import 'package:flutter/material.dart';

buttonCloseBack(BuildContext context) {
  return Column(
    children: [
      Container(
        // width: 60,
        // color: Colors.red,
        // alignment: Alignment.centerRight,
        child: MaterialButton(
          minWidth: 29,
          onPressed: () {
            Navigator.pop(context);
          },
          color: Color(0xFFE84C10),
          textColor: Colors.white,
          child: Icon(
            Icons.close,
            size: 29,
          ),
          shape: CircleBorder(),
        ),
      ),
    ],
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.end,
  );
}
