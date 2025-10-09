import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget loadingImageNetwork(
  String url, {
  BoxFit? fit,
  double? height,
  double? width,
  Color? color,
  bool isProfile = false,
}) {
  if (url == null) url = '';
  if (url == '' && isProfile)
    return Container(
      height: 30,
      width: 30,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Image.asset(
        'assets/images/user_not_found.png',
        color: Colors.white,
      ),
    );
  if (url == '')
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image),
    );
  return CachedNetworkImage(
    imageUrl: url,
    fit: fit,
    height: height,
    width: width,
    color: color,
    placeholder: (_, __) => TweenAnimationBuilder(
      duration: Duration(seconds: 1),
      tween: Tween<double>(begin: 0.5, end: 1.0),
      builder: (_, double opacity, __) {
        return Opacity(
          opacity: opacity,
          child: Container(
            height: height ?? 30,
            width: width ?? 30,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/kaset/no-img.png',
            ),
          ),
        );
      },
      onEnd: () {
        // Loop animation
        Future.delayed(Duration(milliseconds: 500), () {
          // Trigger rebuild to repeat animation
        });
      },
    ),
    errorWidget: (_, __, ___) => Container(
      height: 30,
      width: 30,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Image.asset(
        'assets/images/kaset/no-img.png',
      ),
    ),
  );
}
