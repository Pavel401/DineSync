class FcmNotificationPayload {
  FcmNotificationType? type;
  String? bookingId;
  String? notificationId;

  // String? turfName;
  // String? turfImage;
  // String? userName;
  // String? userImage;

  FcmNotificationPayload({
    this.type,
    this.bookingId,
    this.notificationId,
  });

  factory FcmNotificationPayload.fromJson(Map<String, dynamic> json) {
    return FcmNotificationPayload(
      type: json['type'] != null
          ? FcmNotificationType.values.firstWhere((e) => e.name == json['type'])
          : null,
      notificationId: json['notificationId'] ?? '',
      bookingId: json['bookingId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type!.name,
      'notificationId': notificationId,
      'bookingId': bookingId,
    };
  }
}

enum FcmNotificationType {
  MARKEETING,
  BOOKING_REMINDER,
  REVIEW_REMINDER,
}
