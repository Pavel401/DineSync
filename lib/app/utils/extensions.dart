import 'package:flutter/material.dart';

extension HexColor on String {
  Color toColor() {
    var hexColor = this.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // Add alpha value if not provided
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    } else {
      throw FormatException("Invalid hexadecimal color format");
    }
  }
}
