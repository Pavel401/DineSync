import 'package:cho_nun_btk/app/models/menu/menu.dart';

class Foodorder {
  String orderId;
  Map<FoodItem, int> orderItems = {};

  WaiterData waiterData;
  DateTime orderTime;
  DateTime? cookingStartTime;
  DateTime? cookingEndTime;
  FoodOrderStatus orderStatus;
  CustomerData customerData;
  double totalAmount;
  KitchenData? kitchenData;
  String? specialInstructions;
  String? kitchenComment;
  String? customerFeedback;
  DiscountData? discountData;

  int? queuePosition;

  Foodorder({
    required this.orderId,
    required this.orderItems,
    required this.waiterData,
    required this.orderTime,
    this.cookingStartTime,
    this.cookingEndTime,
    required this.orderStatus,
    required this.customerData,
    required this.totalAmount,
    this.kitchenData,
    this.specialInstructions,
    this.kitchenComment,
    this.customerFeedback,
    this.queuePosition,
  });

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'foodItems': orderItems.entries
            .map((entry) => {
                  'foodItem': entry.key.toJson(),
                  'quantity': entry.value,
                })
            .toList(),
        'waiterData': waiterData.toJson(),
        'orderTime': orderTime.toIso8601String(),
        'cookingStartTime': cookingStartTime?.toIso8601String(),
        'cookingEndTime': cookingEndTime?.toIso8601String(),
        'orderStatus': orderStatus.name,
        'customerData': customerData.toJson(),
        'totalAmount': totalAmount,
        'kitchenData': kitchenData?.toJson(),
        'specialInstructions': specialInstructions,
        'kitchenComment': kitchenComment,
        'customerFeedback': customerFeedback,
        'queuePosition': queuePosition,
      };

  // JSON deserialization
  Foodorder.fromJson(Map<String, dynamic> json)
      : orderId = json['orderId'],
        orderItems = Map.fromEntries(
          (json['foodItems'] as List).map((entry) => MapEntry(
                FoodItem.fromJson(entry['foodItem']),
                entry['quantity'],
              )),
        ),
        waiterData = WaiterData.fromJson(json['waiterData']),
        orderTime = DateTime.parse(json['orderTime']),
        cookingStartTime = json['cookingStartTime'] != null
            ? DateTime.parse(json['cookingStartTime'])
            : null,
        cookingEndTime = json['cookingEndTime'] != null
            ? DateTime.parse(json['cookingEndTime'])
            : null,
        orderStatus = FoodOrderStatus.values
            .firstWhere((e) => e.name == json['orderStatus']),
        customerData = CustomerData.fromJson(json['customerData']),
        totalAmount = json['totalAmount'],
        kitchenData = json['kitchenData'] != null
            ? KitchenData.fromJson(json['kitchenData'])
            : null,
        specialInstructions = json['specialInstructions'] ?? "",
        kitchenComment = json['kitchenComment'] ?? "",
        queuePosition = json['queuePosition'] ?? 0,
        customerFeedback = json['customerFeedback'] ?? "";
}

class DiscountData {
  bool isDiscountApplied;
  String? discountName;
  String? discountCode;
  double? discountAmount;

  DiscountData({
    required this.isDiscountApplied,
    this.discountName,
    this.discountCode,
    this.discountAmount,
  });

  Map<String, dynamic> toJson() => {
        'isDiscountApplied': isDiscountApplied,
        'discountName': discountName,
        'discountCode': discountCode,
        'discountAmount': discountAmount,
      };

  DiscountData.fromJson(Map<String, dynamic> json)
      : isDiscountApplied = json['isDiscountApplied'],
        discountName = json['discountName'],
        discountCode = json['discountCode'],
        discountAmount = json['discountAmount'];
}

class WaiterData {
  String waiterId;
  String waiterName;
  String? waiterImage;

  WaiterData({
    required this.waiterId,
    required this.waiterName,
    this.waiterImage,
  });

  Map<String, dynamic> toJson() => {
        'waiterId': waiterId,
        'waiterName': waiterName,
        'waiterImage': waiterImage,
      };

  WaiterData.fromJson(Map<String, dynamic> json)
      : waiterId = json['waiterId'],
        waiterName = json['waiterName'],
        waiterImage = json['waiterImage'];
}

class CustomerData {
  String customerName;
  Gender? customerGender;
  String? customerPhoneNumber;

  CustomerData({
    required this.customerName,
    this.customerGender,
    this.customerPhoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'customerName': customerName,
        'customerGender': customerGender?.name,
        'customerPhoneNumber': customerPhoneNumber,
      };

  CustomerData.fromJson(Map<String, dynamic> json)
      : customerName = json['customerName'],
        customerGender = json['customerGender'] != null
            ? Gender.values.firstWhere((e) => e.name == json['customerGender'])
            : null,
        customerPhoneNumber = json['customerPhoneNumber'];
}

class KitchenData {
  String kitchenStaffId;
  String kitchenStaffName;
  DateTime? cookingStartTime;
  DateTime? cookingEndTime;

  KitchenData({
    required this.kitchenStaffId,
    required this.kitchenStaffName,
    this.cookingStartTime,
    this.cookingEndTime,
  });

  Map<String, dynamic> toJson() => {
        'kitchenStaffId': kitchenStaffId,
        'kitchenStaffName': kitchenStaffName,
        'cookingStartTime': cookingStartTime?.toIso8601String(),
        'cookingEndTime': cookingEndTime?.toIso8601String(),
      };

  KitchenData.fromJson(Map<String, dynamic> json)
      : kitchenStaffId = json['kitchenStaffId'],
        kitchenStaffName = json['kitchenStaffName'],
        cookingStartTime = json['cookingStartTime'] != null
            ? DateTime.parse(json['cookingStartTime'])
            : null,
        cookingEndTime = json['cookingEndTime'] != null
            ? DateTime.parse(json['cookingEndTime'])
            : null;
}

enum FoodOrderStatus {
  PENDING,
  CONFIRMED,
  PREPARING,
  CANCELLED,
  DELIVERED,
}

enum PreparationStatus {
  NOT_STARTED,
  IN_PROGRESS,
  READY,
}

enum Gender {
  MALE,
  FEMALE,
  OTHER,
}

enum OrderType {
  DINE_IN,
  TAKE_AWAY,
  DELIVERY,
}

enum PaymentMode {
  CASH,
  CARD,
  UPI,
  WALLET,
}

enum PaymentStatus {
  PENDING,
  PAID,
  FAILED,
}
