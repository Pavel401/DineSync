// import 'package:cho_nun_btk/app/utils/extensions.dart';
// import 'package:flutter/material.dart';

// class AppColors {
//   static Color primaryOrange = "#FF9E05".toColor();
//   static Color primaryBeige = "#E6E0CA".toColor();
//   static Color primaryBlue = "#14BCFF".toColor();
//   static Color primaryGrey = "#D9D9D9".toColor();
//   static Color primaryDark = "#212121".toColor();
//   static Color onPrimaryLight = Colors.white;
//   static Color onPrimaryDark = Colors.black;
//   static Color surfaceLight = Color(0xFFF7F7F7);
//   static Color surfaceDark = Color(0xFF303030);
//   static Color outlineLight = Color(0xFFDADADA);
//   static Color outlineDark = Color(0xFF505050);
//   static Color secondaryLight = primaryBeige;
//   static Color secondaryDark = Color(0xFF414141);
// }
import 'package:flutter/material.dart';

class AppColors {
  static const primaryLight = Color(0xFF406835);
  static const secondaryLight = Color(0xFF54634D);
  static const tertiaryLight = Color(0xFFD7E1CF);
  static const onPrimaryLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF8FBF0);
  static const onSurfaceLight = Color(0xFF2C3527);
  static const outlineLight = Color(0xFF73796E);
  //Custom light theme colors
  static const searchBarLight = Color(0xFFE6E9DF);
  static const errorLight = Color(0xFFB00020);

  static const primaryDark = Color(0xFFA6D395);
  static const secondaryDark = Color(0xFFBBCBB1);
  static const tertiaryDark = Color(0xFF2C3626);
  static const onPrimaryDark = Color(0xFF12380B);
  static const surfaceDark = Color(0xFF11140F);
  static const onSurfaceDark = Color(0xFFE1E4DA);
  static const outlineDark = Color(0xFF8D9387);
  //Custom dark theme colors
  static const searchBarDark = Color(0xFF272B25);
  static const errorDark = Color(0xFFCF6679);

  static Color hexToColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // Adds the opacity if not provided.
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
