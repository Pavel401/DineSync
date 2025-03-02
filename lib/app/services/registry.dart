import 'package:cho_nun_btk/app/modules/Auth/controllers/fcm_controller.dart';
import 'package:cho_nun_btk/app/provider/analytics_provider.dart';
import 'package:cho_nun_btk/app/provider/firebase_imageProvider.dart';
import 'package:cho_nun_btk/app/provider/food_order_provider.dart';
import 'package:cho_nun_btk/app/provider/menuProvider.dart';
import 'package:cho_nun_btk/app/services/fcm_notification.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

Future<void> setupRegistry() async {
  // Create and register MyService with async initialization

  serviceLocator.registerLazySingleton<FcmProvider>(() => FcmProvider());
  serviceLocator.registerLazySingleton<Menuprovider>(() => Menuprovider());
  serviceLocator.registerLazySingleton<FirebaseImageprovider>(
      () => FirebaseImageprovider());

  serviceLocator
      .registerLazySingleton<FoodOrderProvider>(() => FoodOrderProvider());

  serviceLocator
      .registerLazySingleton<AnalyticsProvider>(() => AnalyticsProvider());

  serviceLocator.registerLazySingleton<FcmNotificationProvider>(
      () => FcmNotificationProvider());
}
