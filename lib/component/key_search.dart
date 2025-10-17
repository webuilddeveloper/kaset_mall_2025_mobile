// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class KeySearch extends StatefulWidget {
  KeySearch({super.key, this.show, this.onKeySearchChange});

  final bool? show;
  final Function(String)? onKeySearchChange;

  @override
  _SearchBox createState() =>
      _SearchBox(show: show!, onKeySearchChange: onKeySearchChange!);
}

class _SearchBox extends State<KeySearch> {
  final txtDescription = TextEditingController();
  bool? show;
  Function(String)? onKeySearchChange;

  _SearchBox({@required this.show, this.onKeySearchChange});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    txtDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: new BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: new BorderRadius.circular(10.0),
      ),
      child: TextField(
        controller: txtDescription,
        onChanged: (text) {
          onKeySearchChange!(txtDescription.text);
        },
        keyboardType: TextInputType.multiline,
        maxLines: 1,
        style: TextStyle(
          fontSize: 13,
          fontFamily: 'Kanit',
          color: Theme.of(context).primaryColor,
        ),
        decoration: InputDecoration(
          hintText: 'ค้นหาสิทธิประโยชน์...',
          hintStyle: TextStyle(
            fontFamily: 'Kanit',
            color: Colors.grey,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).primaryColor,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}
