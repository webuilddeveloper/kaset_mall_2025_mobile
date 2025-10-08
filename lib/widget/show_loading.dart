import 'package:flutter/material.dart';

class ShowLoadingWidget extends StatelessWidget {
  ShowLoadingWidget({Key? key, required this.children, required this.loading})
      : super(key: key);

  final List<Widget> children;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...children,
        if (loading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.4),
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          )
      ],
    );
  }
}
