import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/models/analytics/analytics.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsProvider {
  final ordersCollection = FirebaseFirestore.instance.collection('orders');

  final analyticsCollection =
      FirebaseFirestore.instance.collection('analytics');
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

  Future<void> updateDailyAnalytics(FoodOrder order) async {
    String dailyAnalyticsId = getAnalyticsId(order.orderTime, "daily");

    String aid = dailyAnalyticsId;
    DateTime date = DateTime.now(); // Date for analytics

    int totalOrders = 0;
    int totalCustomers = 0;

    int totalDiscountedOrders = 0;

    Map<String, int> categorySales = {};

    Map<String, int> itemSalesCount = {};

    int cancelledOrders = 0;

    double averageOrderValue = 0.0;

    try {
      final DocumentReference docRef = analyticsCollection
          .doc("daily")
          .collection("dates")
          .doc(dailyAnalyticsId);

      final response = await docRef.get();

      if (response.exists) {
        FoodAnalytics analytics =
            FoodAnalytics.fromJson(response.data() as Map<String, dynamic>);

        aid = analytics.aid;
        date = analytics.date;
        totalOrders = analytics.totalOrders;
        totalCustomers = analytics.totalCustomers;
        totalDiscountedOrders = analytics.totalDiscountedOrders;
        categorySales = analytics.categorySales;
        itemSalesCount = analytics.itemSalesCount;
        cancelledOrders = analytics.cancelledOrders;
        averageOrderValue = analytics.averageOrderValue;
      }

      totalOrders++;
      totalCustomers++;

      if (order.discountData != null && order.discountData!.isDiscountApplied) {
        totalDiscountedOrders++;
      }

      // Update sales data for each item in the order
      order.orderItems.forEach((foodItem, quantity) {
        // Increment category sales
        categorySales.update(
          foodItem.foodCategory.categoryName,
          (value) => value + quantity,
          ifAbsent: () => quantity,
        );

        // Increment item sales count
        itemSalesCount.update(
          foodItem.foodId,
          (value) => value + quantity,
          ifAbsent: () => quantity,
        );
      });

      if (order.orderStatus == FoodOrderStatus.CANCELLED) {
        cancelledOrders++;
      }

      averageOrderValue =
          (averageOrderValue * (totalOrders - 1) + order.totalAmount) /
              totalOrders;

      FoodAnalytics newAnalytics = FoodAnalytics(
        aid: aid,
        date: date,
        totalOrders: totalOrders,
        totalCustomers: totalCustomers,
        totalDiscountedOrders: totalDiscountedOrders,
        categorySales: categorySales,
        itemSalesCount: itemSalesCount,
        cancelledOrders: cancelledOrders,
        averageOrderValue: averageOrderValue,
      );

      await docRef.set(newAnalytics.toJson());
    } catch (e) {
      print("Error fetching daily analytics: $e");
    }
  }

  Future<void> updateMonthlyAnalytics(FoodOrder order) async {
    String monthlyAnalyticsId = getAnalyticsId(order.orderTime, "monthly");

    String aid = monthlyAnalyticsId;
    DateTime date = DateTime.now(); // Date for analytics

    int totalOrders = 0;
    int totalCustomers = 0;

    int totalDiscountedOrders = 0;

    Map<String, int> categorySales = {};

    Map<String, int> itemSalesCount = {};

    int cancelledOrders = 0;

    double averageOrderValue = 0.0;

    try {
      final DocumentReference docRef = analyticsCollection
          .doc("monthly")
          .collection("months")
          .doc(monthlyAnalyticsId);

      final response = await docRef.get();

      if (response.exists) {
        FoodAnalytics analytics =
            FoodAnalytics.fromJson(response.data() as Map<String, dynamic>);

        aid = analytics.aid;
        date = analytics.date;
        totalOrders = analytics.totalOrders;
        totalCustomers = analytics.totalCustomers;
        totalDiscountedOrders = analytics.totalDiscountedOrders;
        categorySales = analytics.categorySales;
        itemSalesCount = analytics.itemSalesCount;
        cancelledOrders = analytics.cancelledOrders;
        averageOrderValue = analytics.averageOrderValue;
      }

      totalOrders++;
      totalCustomers++;

      if (order.discountData != null && order.discountData!.isDiscountApplied) {
        totalDiscountedOrders++;
      }

      // Update sales data for each item in the order
      order.orderItems.forEach((foodItem, quantity) {
        categorySales.update(
          foodItem.foodCategory.categoryName,
          (value) => value + quantity,
          ifAbsent: () => quantity,
        );

        itemSalesCount.update(
          foodItem.foodId,
          (value) => value + quantity,
          ifAbsent: () => quantity,
        );
      });

      if (order.orderStatus == FoodOrderStatus.CANCELLED) {
        cancelledOrders++;
      }

      averageOrderValue =
          (averageOrderValue * (totalOrders - 1) + order.totalAmount) /
              totalOrders;

      FoodAnalytics newAnalytics = FoodAnalytics(
        aid: aid,
        date: date,
        totalOrders: totalOrders,
        totalCustomers: totalCustomers,
        totalDiscountedOrders: totalDiscountedOrders,
        categorySales: categorySales,
        itemSalesCount: itemSalesCount,
        cancelledOrders: cancelledOrders,
        averageOrderValue: averageOrderValue,
      );

      await docRef.set(newAnalytics.toJson());
    } catch (e) {
      print("Error fetching monthly analytics: $e");
    }
  }

  Future<void> updateYearlyAnalytics(FoodOrder order) async {
    String yearlyAnalyticsId = getAnalyticsId(order.orderTime, "yearly");

    String aid = yearlyAnalyticsId;
    DateTime date = DateTime.now(); // Date for analytics

    int totalOrders = 0;
    int totalCustomers = 0;

    int totalDiscountedOrders = 0;

    Map<String, int> categorySales = {};

    Map<String, int> itemSalesCount = {};

    int cancelledOrders = 0;

    double averageOrderValue = 0.0;

    try {
      final DocumentReference docRef = analyticsCollection
          .doc("yearly")
          .collection("years")
          .doc(yearlyAnalyticsId);

      final response = await docRef.get();

      if (response.exists) {
        FoodAnalytics analytics =
            FoodAnalytics.fromJson(response.data() as Map<String, dynamic>);

        aid = analytics.aid;
        date = analytics.date;
        totalOrders = analytics.totalOrders;
        totalCustomers = analytics.totalCustomers;
        totalDiscountedOrders = analytics.totalDiscountedOrders;
        categorySales = analytics.categorySales;
        itemSalesCount = analytics.itemSalesCount;
        cancelledOrders = analytics.cancelledOrders;
        averageOrderValue = analytics.averageOrderValue;
      }

      totalOrders++;
      totalCustomers++;

      if (order.discountData != null && order.discountData!.isDiscountApplied) {
        totalDiscountedOrders++;
      }

      // Update sales data for each item in the order
      order.orderItems.forEach((foodItem, quantity) {
        categorySales.update(
          foodItem.foodCategory.categoryName,
          (value) => value + quantity,
          ifAbsent: () => quantity,
        );

        itemSalesCount.update(
          foodItem.foodId,
          (value) => value + quantity,
          ifAbsent: () => quantity,
        );
      });

      if (order.orderStatus == FoodOrderStatus.CANCELLED) {
        cancelledOrders++;
      }

      averageOrderValue =
          (averageOrderValue * (totalOrders - 1) + order.totalAmount) /
              totalOrders;

      FoodAnalytics newAnalytics = FoodAnalytics(
        aid: aid,
        date: date,
        totalOrders: totalOrders,
        totalCustomers: totalCustomers,
        totalDiscountedOrders: totalDiscountedOrders,
        categorySales: categorySales,
        itemSalesCount: itemSalesCount,
        cancelledOrders: cancelledOrders,
        averageOrderValue: averageOrderValue,
      );

      await docRef.set(newAnalytics.toJson());
    } catch (e) {
      print("Error fetching yearly analytics: $e");
    }
  }

  Future<QueryStatus> recordAnalytics(FoodOrder order) async {
    try {
      // Update daily analytics
      await updateDailyAnalytics(order);

      // Update monthly analytics
      await updateMonthlyAnalytics(order);

      // Update yearly analytics
      await updateYearlyAnalytics(order);

      return QueryStatus.SUCCESS;
    } catch (e) {
      print("Error recording analytics for order: $e");
      return QueryStatus.ERROR;
    }
  }
}
