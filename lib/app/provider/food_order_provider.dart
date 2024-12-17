import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/models/analytics/analytics.dart';
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

  String getNewFoodOrderId() {
    String baseId = FirebaseFirestore.instance.collection('orders').doc().id;
    return "#Order--$baseId";
  }

  Future<QueryStatus> createOrder(FoodOrder order) async {
    try {
      // Create order
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.orderId)
          .set(order.toJson());

      addDailyOrderAnalytics(order);

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

  Future<QueryStatus> updateOrderStatus(
      String orderId, FoodOrderStatus status) async {
    try {
      await ordersCollection.doc(orderId).update({'orderStatus': status.name});
      return QueryStatus.SUCCESS;
    } catch (e) {
      print(e);
      return QueryStatus.ERROR;
    }
  }

  Future<void> addDailyOrderAnalytics(FoodOrder order) async {
    String dailyAnalyticsId = getDailyAnalyticsId(order.orderTime);

    // Initialize metrics
    int totalOrders = 0;
    double totalRevenue = 0;
    int totalCustomers = 0;
    int totalItemsSold = 0;
    int totalDiscountedOrders = 0;
    Map<String, int> categorySales = {};
    Map<String, int> itemSalesCount = {};
    int cancelledOrders = 0;
    List<String> cancelledReasons = [];
    double averageOrderValue = 0.0;

    try {
      // Fetch existing analytics
      DocumentSnapshot doc = await analyticsCollection
          .doc("daily")
          .collection("dates")
          .doc(dailyAnalyticsId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?; // Safe cast

        FoodAnalytics analytics = FoodAnalytics.fromJson(data!);

        totalOrders = analytics.totalOrders;
        totalRevenue = analytics.totalRevenue;
        totalCustomers = analytics.totalCustomers;
        totalDiscountedOrders = analytics.totalDiscountedOrders;
        categorySales = analytics.categorySales;
        itemSalesCount = analytics.itemSalesCount;
        cancelledOrders = analytics.cancelledOrders;
        cancelledReasons = analytics.cancelledReasons;
        averageOrderValue = analytics.averageOrderValue;
      }

      // Update metrics based on the new order
      totalOrders += 1;
      totalRevenue += order.totalAmount;

      // Update total items sold
      order.orderItems.forEach((item, quantity) {
        totalItemsSold += quantity;
        itemSalesCount[item.foodId] =
            (itemSalesCount[item.foodId] ?? 0) + quantity;

        // Update category sales
        String category = item.foodCategory.categoryName;
        categorySales[category] = (categorySales[category] ?? 0) + quantity;
      });

      // Check if the order has a discount applied
      if (order.discountData?.isDiscountApplied ?? false) {
        totalDiscountedOrders += 1;
      }

      // Update average order value
      averageOrderValue = totalRevenue / totalOrders;

      // If the order is cancelled, update cancellation metrics
      if (order.orderStatus == FoodOrderStatus.CANCELLED) {
        cancelledOrders += 1;
        if (order.customerFeedback != null) {
          cancelledReasons.add(order.customerFeedback!);
        }
      }

      // Save updated analytics back to Firestore
      FoodAnalytics updatedAnalytics = FoodAnalytics(
        aid: dailyAnalyticsId,
        date: order.orderTime,
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        totalCustomers:
            totalCustomers, // Assuming unique customer logic is handled elsewhere
        totalDiscountedOrders: totalDiscountedOrders,
        categorySales: categorySales,
        itemSalesCount: itemSalesCount,
        cancelledOrders: cancelledOrders,
        cancelledReasons: cancelledReasons,
        averageOrderValue: averageOrderValue,
      );

      await analyticsCollection
          .doc("daily")
          .collection("dates")
          .doc(dailyAnalyticsId)
          .set(updatedAnalytics.toJson());
    } catch (e) {
      print("Error updating daily analytics: $e");
    }
  }
}
