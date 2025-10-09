import 'package:flutter/material.dart';
import 'package:mobile_mart_v3/blank_page/blank_loading.dart';

blankListData(BuildContext context, {double height = 100}) {
  return Container(
    color: Colors.transparent,
    alignment: Alignment.center,
    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
    child: ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          child: BlankLoading(height: height),
        );
      },
    ),
  );
}

blankGridData(BuildContext context, {double height = 100}) {
  return Container(
    color: Colors.transparent,
    alignment: Alignment.center,
    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
    child: GridView.count(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      crossAxisCount: 2,
      children: List<Widget>.generate(
        10,
        (index) {
          return Container(
            margin: index % 2 == 0
                ? const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 5.0)
                : const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0),
            child: BlankLoading(height: height),
          );
        },
      ),
    ),
  );
}
