import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  AnalyticsService() {}

  FirebaseAnalyticsObserver getAnalyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // User properties tells us what the user is
  Future setUserProperties(
      {required String userId, required String userRole}) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'user_role', value: userRole);
  }

  Future logLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      print("OK");
    } catch (error) {
      print("The error is $error");
    }
  }

  Future logEvent(
      {required String eventName,
      required Map<String, Object> parameters}) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (error) {
      print("Analytics error logging $eventName:$error");
    }
  }

  Future logScreenView(
      {required String screenName,
      required Map<String, dynamic> parameters}) async {
    // await _analytics.
  }
}

class Analytics {
  static const String TAP_SKILL_CARD = 'created_new_order';
  static const String CANCEllED_ORDER = 'cancelled_order';
}
