import 'dart:math';

import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodOrderProvider {
  final ordersCollection = FirebaseFirestore.instance.collection('orders');

  final analyticsCollection =
      FirebaseFirestore.instance.collection('analytics');
  String getDailyAnalyticsId(DateTime date) =>
      "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";

  String getMonthlyAnalyticsId(DateTime date) =>
      "${date.year}${date.month.toString().padLeft(2, '0')}";

  String getYearlyAnalyticsId(DateTime date) => "${date.year}";

  String newId() {
    return ordersCollection.doc().id;
  }

  String _generateRandomString(int length) {
    const String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<String> getNewFoodOrderId() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference metadataCollection =
        firestore.collection('order_metadata');
    final String documentId = 'daily_metadata';

    // Get the current date in YYYYMMDD format
    final DateTime now = DateTime.now();
    final String currentDate =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

    try {
      final DocumentReference docRef = metadataCollection.doc(documentId);

      // Firestore transaction to safely update the order count
      return await firestore.runTransaction((transaction) async {
        final DocumentSnapshot snapshot = await transaction.get(docRef);

        int orderCount;
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final String storedDate = data['date'] ?? '';
          orderCount = data['orderCount'] ?? 0;

          if (storedDate == currentDate) {
            // Increment the count for the current date
            orderCount++;
          } else {
            // Reset the count for a new day
            orderCount = 1;
          }
        } else {
          // Initialize if the document does not exist
          orderCount = 1;
        }

        // Update Firestore with the new date and order count
        transaction.set(docRef, {
          'date': currentDate,
          'orderCount': orderCount,
        });

        // Generate the new order ID
        final String paddedCount = orderCount.toString().padLeft(3, '0');
        final String randomString = _generateRandomString(4);
        return "##ORDER-$currentDate-##$paddedCount-##$randomString";
      });
    } catch (e) {
      throw Exception("Failed to generate order ID: $e");
    }
  }

  Future<QueryStatus> createOrder(FoodOrder order) async {
    try {
      // Create order
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.orderId)
          .set(order.toJson());

      return QueryStatus.SUCCESS;
    } catch (e) {
      print(e);
      return QueryStatus.ERROR;
    }
  }

  // Stream to listen to orders
  Stream<List<FoodOrder>> listenToBookings(DateTime currentDate) {
    DateTime startOfDay =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    return ordersCollection
        .where('orderTime', isGreaterThanOrEqualTo: startOfDay)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodOrder.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, FoodOrderStatus status) async {
    try {
      await ordersCollection.doc(orderId).update({'orderStatus': status.name});
    } catch (e) {
      print("Error updating order status: $e");
    }
  }

  Future<void> updateKitchenData(
      String orderId, KitchenData kitchenData) async {
    try {
      await ordersCollection.doc(orderId).update({'kitchenData': kitchenData});
    } catch (e) {
      print("Error updating kitchen data: $e");
    }
  }

  Future<void> updateCookingStartTime(
      String orderId, DateTime cookingStartTime) async {
    try {
      await ordersCollection
          .doc(orderId)
          .update({'cookingStartTime': cookingStartTime});
    } catch (e) {
      print("Error updating cooking start time: $e");
    }
  }

  Future<void> updateCookingEndTime(
      String orderId, DateTime cookingEndTime) async {
    try {
      await ordersCollection
          .doc(orderId)
          .update({'cookingEndTime': cookingEndTime});
    } catch (e) {
      print("Error updating cooking end time: $e");
    }
  }

  String getAnalyticsId(DateTime date, String type) {
    switch (type) {
      case "daily":
        return "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
      case "monthly":
        return "${date.year}${date.month.toString().padLeft(2, '0')}";
      case "yearly":
        return "${date.year}";
      default:
        throw ArgumentError("Invalid analytics type: $type");
    }
  }
}
