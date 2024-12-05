import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Home/views/home_view.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/fcm_controller.dart';
import 'package:cho_nun_btk/app/modules/Auth/views/auth_view_home.dart';
import 'package:cho_nun_btk/app/modules/Chef%20App/views/chef_home.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/Home/views/waiter_view.dart';
import 'package:cho_nun_btk/app/services/registry.dart';
import 'package:cho_nun_btk/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  setupRegistry();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AuthController authController = Get.put(AuthController());
  authController.loadUserModel();
  await FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    debugPrint('FirebaseMessaging: Token refreshed');
    debugPrint('FirebaseMessaging: New Token: $newToken');
    if (FirebaseAuth.instance.currentUser != null) {
      FcmProvider()
          .saveFCMToken(FirebaseAuth.instance.currentUser!.uid, newToken);
    }
  });
  // Future.delayed(const Duration(seconds: 1), () {});

  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // await FirebaseMessaging.instance.setAutoInitEnabled(true);
  // debugPrint('FirebaseMessaging: FCM Token: $fcmToken');
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
          home: SplashScreen(), // Set SplashScreen as the initial view
          builder: EasyLoading.init());
    });
  }
}

class SplashScreen extends StatelessWidget {
  final AuthController auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserType>(
      future: auth.checkUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Handle error state
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.hasData) {
          UserType userType = snapshot.data!;
          Widget view;

          switch (userType) {
            case UserType.ADMIN:
              view = AdminHomeView();
              break;
            case UserType.CHEF:
              view = ChefHomeView();
              break;
            case UserType.WAITER:
              view = WaiterHomeView();
              break;
            default:
              view = AuthView();
              break;
          }

          return view;
        } else {
          return const Scaffold(
            body: Center(
              child: Text('No user data available'),
            ),
          );
        }
      },
    );
  }
}
