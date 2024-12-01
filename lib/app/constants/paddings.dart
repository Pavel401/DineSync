import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppPading {
  static Padding paddingAll({required Widget child, double padding = 20.0}) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }

  static EdgeInsets containerPadding =
      EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h, bottom: 2.h);
}
