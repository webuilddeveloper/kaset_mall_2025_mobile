import 'package:flutter/material.dart';

class KeySearch extends StatefulWidget {
  KeySearch({super.key, this.show, this.onKeySearchChange});

//  final VoidCallback onTabCategory;
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
    double width = MediaQuery.of(context).size.width;

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
          hintText: 'ค้นหาสถานที่ท่องเที่ยว...',
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
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: [
      //     Container(
      //       height: 45.0,
      //       width: width - 90.0,
      //       child: TextField(
      //         autofocus: false,
      //         cursorColor: Theme.of(context).primaryColor,
      //         controller: txtDescription,
      //         onChanged: (text) {
      //           onKeySearchChange!(txtDescription.text);
      //         },
      //         keyboardType: TextInputType.multiline,
      //         maxLines: 1,
      //         style: TextStyle(
      //           fontSize: 13,
      //           fontFamily: 'Kanit',
      //         ),
      //         textAlign: TextAlign.left,
      //         decoration: InputDecoration(
      //           filled: true,
      //           fillColor: Colors.transparent,
      //           hintText: 'ใส่คำที่ต้องการค้นหา',
      //           contentPadding: const EdgeInsets.only(left: 5.0, right: 5.0),
      //           enabledBorder: const OutlineInputBorder(
      //               borderSide: BorderSide(color: Colors.white)),
      //           focusedBorder: const OutlineInputBorder(
      //               borderSide: BorderSide(color: Colors.white)),
      //         ),
      //       ),
      //     ),
      //     InkWell(
      //       onTap: () {
      //         onKeySearchChange!(txtDescription.text);
      //         setState(() {
      //           show = !show!;
      //         });
      //       },
      //       child: Container(
      //         color: Colors.transparent,
      //         child: Image.asset(
      //           'assets/images/search.png',
      //           height: 20.0,
      //           width: 20.0,
      //         ),
      //       ),
      //     )
      //   ],
      // ),
    );
  }
}
