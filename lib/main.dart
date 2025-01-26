import 'dart:convert';

import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:cho_nun_btk/app/models/FCM/fcm_model.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Home/views/home_view.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/fcm_controller.dart';
import 'package:cho_nun_btk/app/modules/Auth/views/auth_view_home.dart';
import 'package:cho_nun_btk/app/modules/Chef%20App/Home/views/chef_home.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/Home/views/waiter_view.dart';
import 'package:cho_nun_btk/app/provider/fcm_helper.dart';
import 'package:cho_nun_btk/app/services/analytics.dart';
import 'package:cho_nun_btk/app/services/local_notification_service.dart';
import 'package:cho_nun_btk/app/services/registry.dart';
import 'package:cho_nun_btk/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  await LocalNotificationService().init();

  AuthController authController = Get.put(AuthController());
  authController.loadUserModel();

  final fcmToken = await FirebaseMessaging.instance.getToken();

  debugPrint('FirebaseMessaging: Token $fcmToken');
  await FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    debugPrint('FirebaseMessaging: Token refreshed');
    debugPrint('FirebaseMessaging: New Token: $newToken');
    if (FirebaseAuth.instance.currentUser != null) {
      FcmProvider()
          .saveFCMToken(FirebaseAuth.instance.currentUser!.uid, newToken);
    }
  });

  await FirebaseMessaging.onMessage
      .listen(handleBackgroundMessageWhenAppIsOpen);

  // When user taps on the notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    LocalNotificationService().handleNotificationClick(message.data);
  });

  // Check if the app was opened by tapping a notification while terminated
  // This is only for notifcations from Firebase Cloud Messaging
  // Notifications from Local Notification Service will not be handled here (need to test)
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    LocalNotificationService().handleNotificationClick(initialMessage
        .data); // Handle notification click when app was terminated
  }

  print("Received the initial message: $initialMessage");

  await FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    debugPrint('FirebaseMessaging: Token refreshed');
    debugPrint('FirebaseMessaging: New Token: $newToken');
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseHelper()
          .saveFCMToken(FirebaseAuth.instance.currentUser!.uid, newToken);
    }
  });

  initializeCrashAnalytics();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

// Define an async function to initialize FlutterFire
void initializeCrashAnalytics() async {
  try {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    // Set `_error` state to true if Firebase initialization fails
    debugPrint('Error: $e');
  }
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
    ..userInteractions = false
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
          navigatorObservers: <NavigatorObserver>[
            AnalyticsService().getAnalyticsObserver()
          ],
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

Future<void> handleBackgroundMessageWhenAppIsOpen(RemoteMessage message) async {
  debugPrint('FirebaseMessaging: Message received when app is open');
  debugPrint('FirebaseMessaging: Title: ${message.notification!.title}');
  debugPrint('FirebaseMessaging: Body: ${message.notification!.body}');

  FcmNotificationPayload payload =
      FcmNotificationPayload.fromJson(message.data);

  debugPrint('FirebaseMessaging: Type: ${payload.type}');
  if (message.notification != null &&
      message.notification!.title != null &&
      message.notification!.body != null) {
    String imageUrl = message.notification?.apple?.imageUrl ??
        message.notification?.android?.imageUrl ??
        '';

    if (imageUrl.isNotEmpty) {
      debugPrint('FirebaseMessaging: Image URL: $imageUrl');
      LocalNotificationService().showBigPictureNotification(
          id: message.messageId.hashCode,
          title: message.notification!.title!,
          imageUrl: imageUrl,
          body: message.notification!.body!,
          payload: jsonEncode(message.data));
    } else {
      LocalNotificationService().showBasicNotification(
          id: message.messageId.hashCode,
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: jsonEncode(message.data));
    }
  }
  return;
}
