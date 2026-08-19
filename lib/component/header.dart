import 'package:flutter/material.dart';
import 'package:kasetmall/shared/app_bar.dart';

header(
  BuildContext context,
  Function functionGoBack, {
  String title = '',
  bool isShowLogo = true,
  bool isCenter = false,
  bool isShowButtonCalendar = false,
  bool isButtonCalendar = false,
  bool isShowButtonPoi = false,
  bool isButtonPoi = false,
  Function? callBackClickButtonCalendar,
  bool? isButtonRight,
  Future<void> Function()? rightButton,
  String? menu,
  Color? color,
}) {
  return KasetAppBar(
    title: title,
    showBackButton: true,
    onBack: () => Navigator.pop(context),
    actions: [
      if (isShowButtonCalendar)
        KasetAppBarAction(
          icon: isButtonCalendar ? Icons.list_alt_rounded : Icons.event_note,
          onTap: () {
            callBackClickButtonCalendar!();
          },
        ),
      if (isShowButtonPoi)
        KasetAppBarAction(
          icon: isButtonPoi ? Icons.list_alt_rounded : Icons.location_on_rounded,
          onTap: () {
            callBackClickButtonCalendar!();
          },
          iconColor: const Color(0xFF2E7D32),
          backgroundColor: const Color(0xFFEEF7EE),
        ),
    ],
  );
}
