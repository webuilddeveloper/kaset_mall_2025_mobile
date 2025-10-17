import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DecorationRegister {
  static InputDecoration register(context, {String hintText = ''}) =>
      InputDecoration(
        // label: Text(hintText),
        hintStyle: TextStyle(
          color: Color(0xFF707070),
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        hintText: hintText,
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(color: Color(0xFF09665a)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(color: Color(0xFF09665a)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.2),
          ),
        ),
        errorStyle: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 10.0,
        ),
      );

  static InputDecoration password(
    context, {
    String hintText = '',
    bool visibility = false,
    Function? suffixTap,
  }) =>
      InputDecoration(
        // label: Text(hintText),
        // labelStyle: const TextStyle(
        //   color: Color(0xFF707070),
        // ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Color(0xFF707070),
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            suffixTap!();
          },
          child: visibility
              ? const Icon(Icons.visibility, size: 18)
              : const Icon(Icons.visibility_off, size: 18),
        ),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 5.0, 5.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(color: Color(0xFF09665a)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(color: Color(0xFF09665a)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.2),
          ),
        ),
        errorStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 10.0,
        ),
      );
}

class InputFormatTemple {
  static username() => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z.]')),
      ];
  static password() => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z@!_.]')),
        LengthLimitingTextInputFormatter(10),
      ];
  static phone() => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        LengthLimitingTextInputFormatter(10),
      ];

  static otp() => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        LengthLimitingTextInputFormatter(1),
      ];
}

const emptyText = '**ช่องนี้ไม่สามารถเว้นว่างได้';

class ValidateRegister {
  static firstName(String value) {
    if (value.isEmpty) {
      return emptyText;
    }
    return null;
  }

  static lastName(String value) {
    if (value.isEmpty) {
      return emptyText;
    }
    return null;
  }

  static phone(String value) {
    if (value.isEmpty) {
      return emptyText;
    }
    return null;
  }

  static email(String value) {
    if (value.isEmpty) {
      return emptyText;
    }
    if (!value.isValidEmail()) {
      return '**ตรวจสอบรูปแบบอีเมล';
    }
    return null;
  }

  static password(String value) {
    if (value.isEmpty) {
      return emptyText;
    }
    if (value.length < 8) {
      return '**รหัสผ่านต้องเป็นตัวอักษร a-z, A-Z และ 0-9 ความยาวขั้นต่ำ 8 ตัวอักษร';
    }
    return null;
  }

  static confirmPassword(String value, String password) {
    if (value.isEmpty) {
      return emptyText;
    }
    if (value != password) {
      return '**รหัสผ่านไม่ตรงกัน';
    }
    return null;
  }

  static occupation(int value) {
    if (value == 0) {
      return '**กรุณาเลือกอาชีพ';
    }
    return null;
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
