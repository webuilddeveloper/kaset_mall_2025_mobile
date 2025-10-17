import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

labelTextFormFieldPasswordOldNew(String lable, bool showSubtitle) {
  return new Padding(
    padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
    child: new Row(
      children: <Widget>[
        new Flexible(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                lable,
                style: TextStyle(
                  fontSize: 15.000, fontFamily: 'Kanit',
                  fontWeight: FontWeight.bold,
                  // color: Color(0xFFFF7514),
                ),
              ),
              if (showSubtitle)
                Text(
                  '( ใช้ 6 ตัวขึ้นไปสำหรับรหัสผ่าน )',
                  style: TextStyle(
                    fontSize: 10.00,
                    fontFamily: 'Kanit',
                    color: Color(0xFFFF0000),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

textFormFieldPasswordOldNew(
  TextEditingController model,
  String modelMatch,
  String hintText,
  String validator,
  bool enabled,
  bool isPassword,
) {
  return TextFormField(
    obscureText: isPassword,
    style: TextStyle(
      color: enabled ? Color(0xFF000070) : Color(0xFFFFFFFF),
      fontWeight: FontWeight.normal,
      fontFamily: 'Kanit',
      fontSize: 15.00,
    ),
    decoration: InputDecoration(
      filled: true,
      fillColor: enabled ? Color(0xFFC5DAFC) : Color(0xFF707070),
      contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      errorStyle: TextStyle(
        fontWeight: FontWeight.normal,
        fontFamily: 'Kanit',
        fontSize: 10.0,
      ),
    ),
    validator: (model) {
      if (model!.isEmpty) {
        return 'กรุณากรอก' + validator + '.';
      }
      if (isPassword && model != modelMatch) {
        return 'กรุณากรอกรหัสผ่านให้ตรงกัน.';
      }

      if (isPassword) {
       String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{6,}$';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(model)) {
          return 'กรุณากรอกรูปแบบรหัสผ่านให้ถูกต้อง.';
        }
      }
      return null;
    },
    controller: model,
    enabled: enabled,
  );
}

labelTextFormFieldPassword(String lable) {
  return new Padding(
    padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
    child: new Row(
      children: <Widget>[
        new Flexible(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                lable,
                style: TextStyle(
                  fontSize: 15.000,
                  fontFamily: 'Kanit',
                ),
              ),
              Text(
                '(รหัสผ่านต้องเป็นตัวอักษร a-z, A-Z และ 0-9 ความยาวขั้นต่ำ 6 ตัวอักษร)',
                style: TextStyle(
                  fontSize: 10.00,
                  fontFamily: 'Kanit',
                  color: Color(0xFFFF0000),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

labelTextFormField(String label) {
  return Padding(
    padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 15.000, fontFamily: 'Kanit', fontWeight: FontWeight.bold,
        // color: Color(0xFFFF7514),
      ),
    ),
  );
}

textFormField(
  TextEditingController model,
  String modelMatch,
  String hintText,
  String validator,
  bool enabled,
  bool isPassword,
  bool isEmail, {
  bool isPattern = false,
  TextInputType? textInputType,
}) {
  return TextFormField(
    keyboardType: textInputType,
    inputFormatters: isPattern
        ? [
            // fixflutter2 new WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9@_]")),
          ]
        : null,
    obscureText: isPassword,
    style: TextStyle(
      fontWeight: FontWeight.normal,
      fontFamily: 'Kanit',
      fontSize: 15.00,
    ),
    decoration: InputDecoration(
      // filled: true,
      // fillColor: enabled ? Color(0xFF373737) : Color(0xFF707070),
      contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      hintText: hintText,
      hintStyle: TextStyle(
        // color: Colors.white70,
        fontFamily: 'Kanit',
        fontSize: 13,
        fontWeight: FontWeight.w300,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF707070)),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1794D2)),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1794D2)),
      ),
    ),
    validator: (model) {
      if (model!.isEmpty) {
        return 'กรุณากรอก${validator}.';
      }
      // if (isPassword && model != modelMatch && modelMatch != null) {
      //   return 'กรุณากรอกรหัสผ่านให้ตรงกัน.';
      // }

      if (isPassword) {
        // if (!regex.hasMatch(model)) {
        if (model.length < 6) {
          return 'กรุณากรอกรูปแบบรหัสผ่านให้ถูกต้อง.';
        }
      }
      if (isEmail) {
        String pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(model)) {
          return 'กรุณากรอกรูปแบบอีเมลให้ถูกต้อง.';
        }
      }
      return null;
      // return true;
    },
    controller: model,
    enabled: enabled,
  );
}

textFormFieldNoValidator(
  TextEditingController model,
  String hintText,
  bool enabled,
  bool isEmail,
) {
  return Container(
    height: 30,
    child: TextFormField(
      style: TextStyle(
        color: enabled ? Color(0xFF000070) : Color(0xFFFFFFFF),
        fontWeight: FontWeight.normal,
        fontFamily: 'Kanit',
        fontSize: 13.00,
        // height: 1,
      ),
      decoration: InputDecoration(
        // filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 15.0),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        // border: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(10.0),
        //   borderSide: BorderSide.none,
        // ),
        errorStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
          fontSize: 10.0,
        ),
      ),
      // decoration: InputDecoration(
      //   filled: true,
      //   fillColor: enabled ? Color(0xFFC5DAFC) : Color(0xFF707070),
      //   contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      //   hintText: hintText,
      //   hintStyle: TextStyle(color: Colors.grey),
      //   border: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(10.0),
      //     borderSide: BorderSide.none,
      //   ),
      //   errorStyle: TextStyle(
      //     fontWeight: FontWeight.normal,
      //     fontFamily: 'Kanit',
      //     fontSize: 10.0,
      //   ),
      // ),
      validator: (model) {
        if (isEmail) {
          if (model != "" && model != null) {
            String pattern =
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp regex = new RegExp(pattern);
            if (!regex.hasMatch(model)) {
              return 'กรุณากรอกรูปแบบอีเมลให้ถูกต้อง.';
            }
          }
        }
        return null;
        // return true;
      },
      controller: model,
      enabled: enabled,
    ),
  );
}

textFormPhoneField(
  TextEditingController model,
  String hintText,
  String validator,
  bool enabled,
  bool isPhone,
) {
  return TextFormField(
    keyboardType: TextInputType.number,
    style: TextStyle(
      color: enabled ? Color(0xFF000070) : Color(0xFFFFFFFF),
      fontWeight: FontWeight.normal,
      fontFamily: 'Kanit',
      fontSize: 15.00,
    ),
    decoration: InputDecoration(
      filled: true,
      fillColor: enabled ? Color(0xFFC5DAFC) : Color(0xFF707070),
      contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      errorStyle: TextStyle(
        fontWeight: FontWeight.normal,
        fontFamily: 'Kanit',
        fontSize: 10.0,
      ),
    ),
    validator: (model) {
      if (model!.isEmpty) {
        return 'กรุณากรอก' + validator + '.';
      }
      if (isPhone) {
        String pattern = r'(^(?:[+0]9)?[0-9]{10,10}$)';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(model)) {
          return 'กรุณากรอกรูปแบบเบอร์ติดต่อให้ถูกต้อง.';
        }
      }
      return null;
    },
    controller: model,
    enabled: enabled,
  );
}

textFormIdCardField(
  TextEditingController model,
  String hintText,
  String validator,
  bool enabled,
) {
  return TextFormField(
    keyboardType: TextInputType.number,
    style: TextStyle(
      color: enabled ? Color(0xFF000070) : Color(0xFFFFFFFF),
      fontWeight: FontWeight.normal,
      fontFamily: 'Kanit',
      fontSize: 15.00,
    ),
    decoration: InputDecoration(
      filled: true,
      fillColor: enabled ? Color(0xFFC5DAFC) : Color(0xFF707070),
      contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      errorStyle: TextStyle(
        fontWeight: FontWeight.normal,
        fontFamily: 'Kanit',
        fontSize: 10.0,
      ),
    ),
    validator: (model) {
      if (model!.isEmpty) {
        return 'กรุณากรอก' + validator + '.';
      }

      String pattern = r'(^[0-9]\d{12}$)';
      RegExp regex = new RegExp(pattern);

      if (regex.hasMatch(model)) {
        if (model.length != 13) {
          return 'กรุณากรอกรูปแบบเลขบัตรประชาชนให้ถูกต้อง';
        } else {
          var sum = 0.0;
          for (var i = 0; i < 12; i++) {
            sum += double.parse(model[i]) * (13 - i);
          }
          if ((11 - (sum % 11)) % 10 != double.parse(model[12])) {
            return 'กรุณากรอกเลขบัตรประชาชนให้ถูกต้อง';
          } else {
            return null;
          }
        }
      } else {
        return 'กรุณากรอกรูปแบบเลขบัตรประชาชนให้ถูกต้อง';
      }
    },
    controller: model,
    enabled: enabled,
  );
}

textFormFieldAddress(
  TextEditingController model,
  String hintText,
  String validator,
  bool enabled,
  bool isPassword,
  bool isEmail, {
  bool isPattern = false,
  bool isPhone = false,
  TextInputType? textInputType,
}) {
  return TextFormField(
    keyboardType: textInputType,
    inputFormatters: textInputType == TextInputType.number
        ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
        : null,
    obscureText: isPassword,
    style: TextStyle(
      fontWeight: FontWeight.normal,
      fontFamily: 'Kanit',
      fontSize: 15.00,
    ),
    decoration: InputDecoration(
      filled: true,
      fillColor: Color(0xFFf7f7f7),
      contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      hintText: hintText,
      hintStyle: TextStyle(
        // color: Colors.white70,
        fontFamily: 'Kanit',
        fontSize: 13,
        fontWeight: FontWeight.w300,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFf7f7f7),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFf7f7f7),
        ),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFf7f7f7),
        ),
      ),
    ),
    validator: (model) {
      if (model!.isEmpty) {
        return 'กรุณากรอก' + validator + '.';
      }

      if (isPassword) {
        // if (!regex.hasMatch(model)) {
        if (model.length < 6) {
          return 'กรุณากรอกรูปแบบรหัสผ่านให้ถูกต้อง.';
        }
      }
      if (isEmail) {
        String pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(model)) {
          return 'กรุณากรอกรูปแบบอีเมลให้ถูกต้อง.';
        }
      }
      if (isPhone) {
        String pattern = r'(^(?:[+0]9)?[0-9]{10,10}$)';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(model)) {
          return 'กรุณากรอกรูปแบบเบอร์ติดต่อให้ถูกต้อง.';
        }
      }
      return null;
    },
    controller: model,
    enabled: enabled,
  );
}
