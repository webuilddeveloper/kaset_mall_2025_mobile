import 'package:flutter/material.dart';
import 'package:kaset_mall/calendar.dart';
import 'package:kaset_mall/component/header.dart';
import 'package:kaset_mall/event_calendar_list.dart';

class EventCalendarMain extends StatefulWidget {
  EventCalendarMain({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _EventCalendarMain createState() => _EventCalendarMain();
}

class _EventCalendarMain extends State<EventCalendarMain> {
  bool showCalendar = true;
  @override
  void initState() {
    super.initState();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  void changeTab() async {
    // Navigator.pop(context, false);
    setState(() {
      showCalendar = !showCalendar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Note: Sensitivity is integer used when you don't want to mess up vertical drag
        if (details.delta.dx > 10) {
          // Right Swipe
          Navigator.pop(context);
        } else if (details.delta.dx < -0) {
          //Left Swipe
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: headerCalendar(
        //   context,
        //   goBack,
        //   showCalendar,
        //   title: widget.title,
        //   rightButton: () => changeTab(),
        // ),
        appBar: header(
          context,
          () => {Navigator.pop(context)},
          // goBack,
          isShowLogo: false,
          isCenter: true,
          isShowButtonCalendar: true,
          isButtonCalendar: showCalendar,
          title: widget.title,
          callBackClickButtonCalendar: () => setState(
            () {
              showCalendar = !showCalendar;
            },
          ),
          // rightButton: () => changeTab(),
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overScroll) {
            overScroll.disallowIndicator();
            return false;
          },
          child: showCalendar
              ? CalendarPage()
              : EventCalendarList(title: widget.title),
        ),
      ),
    );
  }
}
