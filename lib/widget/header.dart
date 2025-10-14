import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasetmall/shared/api_provider.dart';

headerCustom(BuildContext context,
    {String title = '',
    bool customBack = false,
    Function? func,
    List<Widget>? menuRight}) {
  return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      elevation: 0,
      // toolbarHeight: MediaQuery.of(context).padding.top,
      flexibleSpace: Container(
        height: 57 + MediaQuery.of(context).padding.top,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Row(
          children: [
            IconButton(
              iconSize: 25,
              splashRadius: 20,
              alignment: Alignment.center,
              onPressed: () {
                if (customBack && func != null) {
                  func!();
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: menuRight);
}

headerCentral(BuildContext context,
    {String title = '', bool customBack = false, Function? func}) {
  return AppBar(
    backgroundColor: Colors.white,
    automaticallyImplyLeading: false,
    elevation: 0,
    // toolbarHeight: MediaQuery.of(context).padding.top,
    flexibleSpace: Container(
      height: 57 + MediaQuery.of(context).padding.top,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        children: [
          IconButton(
            iconSize: 25,
            splashRadius: 20,
            alignment: Alignment.center,
            onPressed: () {
              if (customBack && func != null) {
                func!();
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
