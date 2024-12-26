// ignore_for_file: unused_local_variable, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cho_nun_btk/app/models/FCM/fcm_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;

/// Local Notification Service Flow
///
/// We have three scenarios
/// 1. Notification clicked when the app is in the background (not terminated)
/// 2. Notification clicked when the app is in the foreground
/// 3. Notification clicked when the app is terminated
///
/// 1. Recieves Notification when the app is in the background
/// - This is pretty straight forward. We get the message via FirebaseMessaging.
/// onMessageOpenedApp.listen and then we call handleNotificationClick
/// to handle the notification.
/// Note: We are not scheduling any local notifications here. So, the payload
/// is directly from the FCM message.
///
/// 2. Recieves Notification when the app is in the foreground
/// - We get the message via FirebaseMessaging.onMessage.listen and then
/// we create a payload from the fcm notification data and schedule a local
/// notification using the showBasicNotification method
/// & showBigPictureNotification
///
/// - When the notification is clicked, the onLocalNotificationClicked method
/// is called. And then it calls the handleNotificationClick method to handle.
///
/// 3. Recieves Notification when the app is terminated
/// For FCM notification, in the main method we can check if the app was
/// opened by a notification click using
/// FirebaseMessaging.instance.getInitialMessage();
/// Have to check if the same is possible for local notifications. Or will it
/// work for both FCM and local notifications.

// Do not put this method in a class.
// The onLocalNotificationClicked needs to be either a static function
// or a top level function to be accessible as a Flutter entry point
void onLocalNotificationClicked(NotificationResponse? notifcationResponse) {
  String? payload = notifcationResponse?.payload;
  if (payload != null) {
    Map<String, dynamic> data = jsonDecode(payload);
    debugPrint("onLocalNotificationClicked: $data");
    LocalNotificationService().handleNotificationClick(data);
  }
}

class LocalNotificationService {
  static final LocalNotificationService _localNotificationService =
      LocalNotificationService._internal();

  factory LocalNotificationService() {
    return _localNotificationService;
  }

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

// Channel ID, Name, and Description
  static const String _channelId = 'turf_it_notifications';
  static const String _channelName = 'Turfit Notifications';
  static const String _channelDescription =
      'Notifications for Turfit activities and updates.';

  static int generateRandomId() {
    final Random random = Random();
    return random.nextInt(100000);
  }

  Future<void> requestPermissions() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions();
    }

    if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    }
  }

  Future<void> init() async {
    requestPermissions();

    late InitializationSettings initializationSettings;

    if (Platform.isAndroid) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
    }

    if (Platform.isIOS) {
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();
      initializationSettings = InitializationSettings(
        iOS: initializationSettingsIOS,
      );
    }

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // For notification clicks when the app is in foreground
      onDidReceiveNotificationResponse: onLocalNotificationClicked,
      // For notification clicks when the app is in background
      onDidReceiveBackgroundNotificationResponse: onLocalNotificationClicked,
    );

    tz.initializeTimeZones();
  }

  Future<void> showBigPictureNotification({
    required int id,
    required String title,
    required String body,
    required String imageUrl,
    String payload = "",
  }) async {
    // Step 1: Download the image
    final response = await http.get(Uri.parse(imageUrl));

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Step 2: Get the temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/notification_image.png'; // Save as PNG for compatibility

      // Step 3: Write the image file
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Step 4: Create Notification Details for both Android and iOS
      final NotificationDetails notificationDetails;

      if (Platform.isAndroid) {
        // Android-specific notification with BigPictureStyle
        final BigPictureStyleInformation bigPictureStyleInformation =
            BigPictureStyleInformation(
          FilePathAndroidBitmap(filePath), // Use local file path
          contentTitle: title,
          summaryText: body,
        );

        notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            styleInformation: bigPictureStyleInformation,
          ),
        );
      } else if (Platform.isIOS) {
        // iOS-specific notification with attachment
        final String iOSFilePath =
            filePath; // iOS accepts the same file path format
        final DarwinNotificationAttachment? attachment;

        try {
          // Step 4.1: Create attachment for iOS
          attachment = DarwinNotificationAttachment(iOSFilePath);
        } catch (e) {
          print("Failed to create iOS attachment: $e");
          return; // Don't proceed if attachment fails
        }

        notificationDetails = NotificationDetails(
          iOS: DarwinNotificationDetails(
            attachments: [attachment],
          ),
        );
      } else {
        return; // Unsupported platform
      }

      // Step 5: Show the notification
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } else {
      print('Failed to load image: ${response.statusCode}');
    }
  }

  Future<void> showBasicNotification(
      {required int id,
      required String title,
      required String body,
      String payload = ""}) async {
    final NotificationDetails notificationDetails;

    // Define notification details for Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );

    // Define notification details for iOS
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true, // Display alert on iOS
      presentBadge: true, // Show app badge
      presentSound: true, // Play notification sound
    );

    // Combine both platform-specific details into one notificationDetails
    notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    // Show the notification
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  void handleNotificationClick(Map<String, dynamic> data) {
    debugPrint("handleNotificationClick: $data");
    FcmNotificationPayload payload = FcmNotificationPayload.fromJson(data);
    if (data['type'] == 'BOOKING_REMINDER') {
      // ScaffoldMessenger.of(Get.context!).showSnackBar(
      //   SnackBar(
      //     content: Text("Booking Reminder Notification Clicked"),
      //   ),
      // );
    } else if (data['type'] == 'REVIEW_REMINDER') {
      // ScaffoldMessenger.of(Get.context!).showSnackBar(
      //   SnackBar(
      //     content: Text("Review Reminder Notification Clicked"),
      //   ),
      // );

      // Future.delayed(Duration(seconds: 1), () {
      //   Get.to(AddReviewPageByNotification(
      //     notificationPayload: payload,
      //   ));
      // });

      // recordOnClick(payload);
    } else {}
  }
}
