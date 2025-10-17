import 'dart:math';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
// import 'package:logger/logger.dart';

unfocus(context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}


moneyFormat(String price) {
  // price = (int.parse(price)/100).toInt().toString();
  price = NumberFormat.currency(locale: 'th_TH', name: '', decimalDigits: 2)
      .format((int.parse(price) / 100));
  return price;
}

dateStringToDate(String date) {
  var year = date.substring(0, 4);
  var month = date.substring(4, 6);
  var day = date.substring(6, 8);
  DateTime.parse(year + '-' + month + '-' + day);
  // fixflutter2 var onlyBuddhistYear = todayDate.yearInBuddhistCalendar;
  // var formatter = DateFormat.yMMMMd();
  // var dateInBuddhistCalendarFormat =
  //     formatter.formatInBuddhistCalendarThai(todayDate);
  // return (dateInBuddhistCalendarFormat);
  return day + '-' + month + '-' + year;
}

dateStringToDateBirthDay(String date) {
  //20201010 to 2020-10-10T00:00:00
  var year = date.substring(0, 4);
  var month = date.substring(4, 6);
  var day = date.substring(6, 8);
  DateTime todayDate = DateTime.parse(year + '-' + month + '-' + day);

  return (todayDate);
}

dateStringToMonthTH(String date) {
  //20201010 to 2020-10-10T00:00:00
  date.substring(0, 4);
  String month = date.substring(4, 6);
  String day = date.substring(6, 8);

  List<dynamic> monthList = [
    {'code': '01', 'value': 'ม.ค.'},
    {'code': '02', 'value': 'ก.พ.'},
    {'code': '03', 'value': 'มี.ค.'},
    {'code': '04', 'value': 'เม.ย.'},
    {'code': '05', 'value': 'พ.ค.'},
    {'code': '06', 'value': 'มิ.ย.'},
    {'code': '07', 'value': 'ก.ค.'},
    {'code': '08', 'value': 'ส.ค.'},
    {'code': '09', 'value': 'ก.ย.'},
    {'code': '10', 'value': 'ต.ค.'},
    {'code': '11', 'value': 'พ.ย.'},
    {'code': '12', 'value': 'ธ.ค.'}
  ];

  dynamic monthTH = monthList.where((o) => month == o['code']).toList();

  return day + ' ' + monthTH[0]['value'];
}

dateStringToTime(String date) {
  //20201010123409 to 12.34
  var h = date.substring(8, 10);
  var m = date.substring(10, 12);
  return h + '.' + m;
}

dateToDateString(String date) {
//10-10-2020 to 10102020
  var day = date.substring(0, 2);
  var month = date.substring(3, 5);
  var year = date.substring(6, 10);
  String todayDate = year + month + day;

  return (todayDate);
}

dateStringToDateStringFormat(String date, {String type = '/'}) {
  String result = '';
  if (date != '') {
    String yearString = date.substring(0, 4);
    var yearInt = int.parse(yearString);
    var year = yearInt + 543;
    var month = date.substring(4, 6);
    var day = date.substring(6, 8);
    result = day + type + month + type + year.toString();
  }

  return result;
}

// convert html to string
String parseHtmlString(String htmlString) {
  final document = parse(htmlString);
  final String parsedString = parse(document.body?.text).documentElement!.text;

  return parsedString;
}

chatFormatDate(String date, String time) {
  String result = '';
  if (date != '') {
    int year = int.parse(date.substring(0, 4));
    int month = int.parse(date.substring(4, 6));
    int day = int.parse(date.substring(6, 8));
    final birthday = DateTime(year, month, day);
    final currentDate = DateTime.now();
    final difDate = currentDate.difference(birthday).inDays;

    ;

    if (difDate == 0) {
      result = 'วันนี้';
    } else if (difDate == 1) {
      result = 'เมื่อวาน';
    } else {
      result = day.toString() + '-' + month.toString() + '-' + year.toString();
    }
  }
  return result + ' : ' + time.toString().substring(0, 5);
}

dateThai(int? date) {
  if (date == null) {
    return '-';
  } else {
    String newDate = date.toString();
    if (newDate.length <= 10) {
      newDate += '000';
    }
    var dateForm = (DateFormat("dd/MM/yyyy ", "th").format(
            DateTime.fromMillisecondsSinceEpoch(int.parse(newDate),
                isUtc: false)))
        .toString();
    var d = (int.tryParse(
                dateForm.substring(dateForm.length - 5, dateForm.length))! + 543)
        .toString();
    var dateResult = dateForm.substring(0, 6) + d;
    return dateResult;
  }
}

dateTimeThai(int date) {
  String newDate = date.toString();
  if (newDate.length <= 10) {
    newDate += '000';
  }
  var dateForm = (DateFormat("ddMMyyyyHHmmss", "th").format(
          DateTime.fromMillisecondsSinceEpoch(int.parse(newDate),
              isUtc: false)))
      .toString();

  var y = (int.tryParse(
              dateForm.substring(dateForm.length - 10, dateForm.length - 6))! +
          543)
      .toString();
  var m = dateForm.substring(dateForm.length - 12, dateForm.length - 10);
  var d = dateForm.substring(dateForm.length - 14, dateForm.length - 12);

  var hh = dateForm.substring(dateForm.length - 6, dateForm.length - 4);
  var mm = dateForm.substring(dateForm.length - 4, dateForm.length - 2);
  var ss = dateForm.substring(dateForm.length - 2, dateForm.length);

  var dateResult = '$d/$m/$y $hh:$mm:$ss';
  return dateResult;
}

dateUnixTimeThaiShort(int date) {
  var dateMilliseconds = date * 1000;
  var dateForm = (DateFormat("dd/MM/yyyy", "th").format(
          DateTime.fromMillisecondsSinceEpoch(dateMilliseconds, isUtc: false)))
      .toString();
  var d =
      (int.tryParse(dateForm.substring(dateForm.length - 4, dateForm.length))! +
              543)
          .toString();
  var dShort = d.substring(2, 4);
  var dateResult = dateForm.substring(0, 6) + dShort;
  return dateResult;
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

final priceFormat = NumberFormat("#,###.##", "en_US");

// List<Identity> toListModel(List<dynamic> model) {
//   var list = new List<Identity>();
//   model.forEach((element) {
//     var m = new Identity();
//     m.code = element['code'] != null ? element['code'] : '';
//     m.title = element['title'] != null ? element['title'] : '';
//     m.description =
//         element['description'] != null ? element['description'] : '';
//     m.imageUrl = element['imageUrl'] != null ? element['imageUrl'] : '';
//     m.createBy = element['createBy'] != null ? element['createBy'] : '';
//     m.createDate = element['createDate'] != null ? element['createDate'] : '';
//     m.imageUrlCreateBy = element['imageUrlCreateBy'] != null ? element['imageUrlCreateBy'] : '';
//     list.add(m);
//   });

//   return list;
// }

// Identity toModel(dynamic model) {
//   var m = new Identity();
//   m.code = model['code'] != null ? model['code'] : '';
//   m.title = model['title'] != null ? model['title'] : '';
//   m.description = model['description'] != null ? model['description'] : '';
//   m.imageUrl = model['imageUrl'] != null ? model['imageUrl'] : '';
//   m.createBy = model['createBy'] != null ? model['createBy'] : '';
//   m.createDate = model['createDate'] != null ? model['createDate'] : '';
//   m.imageUrlCreateBy = model['imageUrlCreateBy'] != null ? model['imageUrlCreateBy'] : '';

//   return m;
// }

// logWTF(dynamic model) {
//   var logger = Logger(
//     printer: PrettyPrinter(),
//   );
//   return logger.wtf(model);
// }

// logD(dynamic model) {
//   var logger = Logger(
//     printer: PrettyPrinter(),
//   );
//   return logger.d(model);
// }

// logE(dynamic model) {
//   var logger = Logger(
//     printer: PrettyPrinter(),
//   );
//   return logger.e(model);
// }