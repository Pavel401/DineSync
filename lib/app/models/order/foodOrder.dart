import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/models/table/table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodOrder {
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
  OrderType? orderType;
  PaymentMode? paymentMode;
  PaymentStatus? paymentStatus;
  TableModel? tableData;

  FoodOrder({
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
    this.discountData,
    this.orderType,
    this.tableData,
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
        'orderTime': Timestamp.fromDate(orderTime), // Store as Timestamp
        'cookingStartTime': cookingStartTime != null
            ? Timestamp.fromDate(cookingStartTime!)
            : null, // Store as Timestamp
        'cookingEndTime': cookingEndTime != null
            ? Timestamp.fromDate(cookingEndTime!)
            : null, // Store as Timestamp
        'orderStatus': orderStatus.name,
        'customerData': customerData.toJson(),
        'totalAmount': totalAmount,
        'kitchenData': kitchenData?.toJson(),
        'specialInstructions': specialInstructions,
        'kitchenComment': kitchenComment,
        'customerFeedback': customerFeedback,
        'queuePosition': queuePosition,
        'discountData': discountData?.toJson(),

        'orderType': orderType?.name,
        'tableData': tableData?.toJson(),
      };

  // JSON deserialization
  FoodOrder.fromJson(Map<String, dynamic> json)
      : orderId = json['orderId'],
        orderItems = Map.fromEntries(
          (json['foodItems'] as List).map((entry) => MapEntry(
                FoodItem.fromJson(entry['foodItem']),
                entry['quantity'],
              )),
        ),
        waiterData = WaiterData.fromJson(json['waiterData']),
        orderTime = (json['orderTime'] as Timestamp)
            .toDate(), // Convert Timestamp to DateTime
        cookingStartTime = json['cookingStartTime'] != null
            ? (json['cookingStartTime'] as Timestamp).toDate()
            : null,
        cookingEndTime = json['cookingEndTime'] != null
            ? (json['cookingEndTime'] as Timestamp).toDate()
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
        discountData = json['discountData'] != null
            ? DiscountData.fromJson(json['discountData'])
            : null,
        orderType = json['orderType'] != null
            ? OrderType.values.firstWhere((e) => e.name == json['orderType'])
            : null,
        tableData = json['tableData'] != null
            ? TableModel.fromJson(json['tableData'])
            : null,
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
  String? customerName;
  Gender? customerGender;
  String? customerPhoneNumber;
  String? customerSeatingPlace;

  CustomerData({
    required this.customerName,
    this.customerGender,
    this.customerPhoneNumber,
    this.customerSeatingPlace,
  });

  Map<String, dynamic> toJson() => {
        'customerName': customerName,
        'customerGender': customerGender?.name,
        'customerPhoneNumber': customerPhoneNumber,
        'customerSeatingPlace': customerSeatingPlace,
      };

  CustomerData.fromJson(Map<String, dynamic> json)
      : customerName = json['customerName'],
        customerGender = json['customerGender'] != null
            ? Gender.values.firstWhere((e) => e.name == json['customerGender'])
            : null,
        customerPhoneNumber = json['customerPhoneNumber'],
        customerSeatingPlace = json['customerSeatingPlace'];
}

class KitchenData {
  String kitchenStaffId;
  String kitchenStaffName;

  KitchenData({
    required this.kitchenStaffId,
    required this.kitchenStaffName,
  });

  Map<String, dynamic> toJson() => {
        'kitchenStaffId': kitchenStaffId,
        'kitchenStaffName': kitchenStaffName,
      };

  KitchenData.fromJson(Map<String, dynamic> json)
      : kitchenStaffId = json['kitchenStaffId'],
        kitchenStaffName = json['kitchenStaffName'];
}

enum FoodOrderStatus {
  PENDING,
  PREPARING,
  CANCELLED,
  READY,
  COMPLETED,
}

enum Gender {
  MALE,
  FEMALE,
  OTHER,
}

enum OrderType {
  DINE_IN,
  TAKE_AWAY,
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
