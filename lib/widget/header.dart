import 'package:flutter/material.dart';
import 'package:kasetmall/shared/app_bar.dart';

headerCustom(BuildContext context,
    {String title = '',
    bool customBack = false,
    Function? func,
    List<Widget>? menuRight}) {
  return KasetAppBar(
    title: title,
    onBack: customBack && func != null
        ? () => func()
        : () => Navigator.pop(context),
    actions: menuRight ?? const <Widget>[],
  );
}

headerCentral(BuildContext context,
    {String title = '', bool customBack = false, Function? func}) {
  return KasetAppBar(
    title: title,
    onBack: customBack && func != null
        ? () => func()
        : () => Navigator.pop(context),
  );
}
