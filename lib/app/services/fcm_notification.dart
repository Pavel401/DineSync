import 'dart:convert';

import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/models/auth/authmodels.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/utils/order_parser.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../modules/Auth/controllers/auth_controller.dart';

class FcmNotificationProvider {
  String BASE_URL = "https://dine-sync-api-production.up.railway.app/send";

  Future<QueryStatus> sendOrderNotificationToKitchen(FoodOrder order) async {
    try {
      print(
          'Starting sendOrderNotificationToKitchen for order ID: ${order.orderId}');

      AuthController authController = Get.find<AuthController>();
      print('AuthController instance obtained');

      List<UserModel> kitchenStaff =
          await authController.getAllUsersByUserType(UserType.CHEF);
      print('Kitchen staff retrieved: ${kitchenStaff.length} users');

      if (kitchenStaff.isEmpty) {
        print('No kitchen staff available');
        return QueryStatus.ERROR;
      }

      List<String> tokens = kitchenStaff.map((e) => e.fcmToken).toList();
      print('FCM tokens extracted: $tokens');

      if (tokens.isEmpty) {
        print('No FCM tokens available');
        return QueryStatus.ERROR;
      }

      print("Number of tokens: ${tokens.length}");

      if (tokens.isEmpty) {
        print('No FCM tokens available');
        return QueryStatus.ERROR;
      }

      // String tableName = order.customerData.customerSeatingPlace ?? "";
      // int noOfItems = order.orderItems.length;
      // String orderId =
      //     "#" + " " + parseOrderId(order.orderId)['counter'].toString();
      // String messageTitle = "New Order!";
      // String messageBody = "Check the new order!";
      // String imageUrl = order.orderItems.entries.first.key.foodImage;
      // String messageId = order.orderId;

      String tableName =
          order.customerData.customerSeatingPlace ?? "Unknown Table";
      int noOfItems = order.orderItems.length;
      String orderId = "#" + parseOrderId(order.orderId)['counter'].toString();
      String messageTitle = "🧾 New Order Received!";
      String messageBody =
          "Order $orderId from Table - $tableName - $noOfItems item(s). Please prepare.";
      String imageUrl = order.orderItems.entries.first.key.foodImage;
      String messageId = order.orderId;

      Map<String, dynamic> body = {
        "messageTitle": messageTitle,
        "messageBody": messageBody,
        "imageUrl": imageUrl,
        "messageId": messageId,
        "tokens": tokens,
      };

      print("Tokens: $tokens");

      print('Notification payload: $body');

      // Send the POST request to the notification service
      final response = await http.post(
        Uri.parse("https://dine-sync-api-production.up.railway.app/send"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      print('Notification response status: ${response.statusCode}');
      print('Notification response body: ${response.body}');

      // Check the response status
      if (response.statusCode == 200) {
        print('Notification sent successfully');
        return QueryStatus.SUCCESS;
      } else {
        print('Failed to send notification');
        return QueryStatus.ERROR;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return QueryStatus.ERROR;
    }
  }
}
