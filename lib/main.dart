import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:cho_nun_btk/app/modules/Auth/views/auth_view_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

void setEasyLoading(bool isDarkMode) {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    // ..progressColor =
    //     isDarkMode ? AppColors.primaryDark : AppColors.primaryLight
    ..indicatorColor =
        isDarkMode ? AppColors.primaryDark : AppColors.onPrimaryDark
    ..backgroundColor = Colors.transparent
    ..textColor = AppColors.onPrimaryLight
    ..maskType = EasyLoadingMaskType.custom
    ..maskColor = isDarkMode
        ? AppColors.surfaceDark.withOpacity(0.1)
        : AppColors.surfaceDark.withOpacity(0.2)
    ..userInteractions = true
    ..boxShadow = <BoxShadow>[]
    ..errorWidget = const Icon(Icons.error, color: Colors.red, size: 50);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Sizer(builder: (context, orientation, deviceType) {
      setEasyLoading(themeProvider.isDarkMode);
      return GetMaterialApp(
          defaultTransition: Transition.rightToLeftWithFade,
          transitionDuration: const Duration(milliseconds: 300),
          debugShowCheckedModeBanner: true,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: AuthView(),
          builder: EasyLoading.init());
    });
  }
}
