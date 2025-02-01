import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/models/analytics/analytics.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  Future<QueryStatus> updateCancelledOrderAnalytics(FoodOrder order) async {
    try {
      String dailyAnalyticsId = getAnalyticsId(order.orderTime, "daily");
      String monthlyAnalyticsId = getAnalyticsId(order.orderTime, "monthly");
      String yearlyAnalyticsId = getAnalyticsId(order.orderTime, "yearly");

      debugPrint("Daily: $dailyAnalyticsId");
      debugPrint("Monthly: $monthlyAnalyticsId");
      debugPrint("Yearly: $yearlyAnalyticsId");
      await analyticsCollection
          .doc("daily")
          .collection("dates")
          .doc(dailyAnalyticsId)
          .update({"cancelledOrders": FieldValue.increment(1)});

      await analyticsCollection
          .doc("monthly")
          .collection("months")
          .doc(monthlyAnalyticsId)
          .update({"cancelledOrders": FieldValue.increment(1)});

      await analyticsCollection
          .doc("yearly")
          .collection("years")
          .doc(yearlyAnalyticsId)
          .update({"cancelledOrders": FieldValue.increment(1)});

      return QueryStatus.SUCCESS;
    } catch (e) {
      print("Error recording analytics for order: $e");
      return QueryStatus.ERROR;
    }
  }

  Future<FoodAnalytics> fetchDailyAnalytics(DateTime date) async {
    String dailyAnalyticsId = getAnalyticsId(date, "daily");

    try {
      final DocumentReference docRef = analyticsCollection
          .doc("daily")
          .collection("dates")
          .doc(dailyAnalyticsId);

      final response = await docRef.get();

      if (response.exists) {
        return FoodAnalytics.fromJson(response.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching daily analytics: $e");
    }

    return FoodAnalytics(
      aid: dailyAnalyticsId,
      date: date,
      totalOrders: 0,
      totalCustomers: 0,
      totalDiscountedOrders: 0,
      categorySales: {},
      itemSalesCount: {},
      cancelledOrders: 0,
      averageOrderValue: 0.0,
    );
  }

  Future<FoodAnalytics> getMonthlyAnalytics(DateTime date) async {
    String monthlyAnalyticsId = getAnalyticsId(date, "monthly");

    try {
      final DocumentReference docRef = analyticsCollection
          .doc("monthly")
          .collection("months")
          .doc(monthlyAnalyticsId);

      final response = await docRef.get();

      if (response.exists) {
        return FoodAnalytics.fromJson(response.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching monthly analytics: $e");
    }

    return FoodAnalytics(
      aid: monthlyAnalyticsId,
      date: date,
      totalOrders: 0,
      totalCustomers: 0,
      totalDiscountedOrders: 0,
      categorySales: {},
      itemSalesCount: {},
      cancelledOrders: 0,
      averageOrderValue: 0.0,
    );
  }

  Future<FoodAnalytics> getYearlyAnalytics(DateTime date) async {
    String yearlyAnalyticsId = getAnalyticsId(date, "yearly");

    try {
      final DocumentReference docRef = analyticsCollection
          .doc("yearly")
          .collection("years")
          .doc(yearlyAnalyticsId);

      final response = await docRef.get();

      if (response.exists) {
        return FoodAnalytics.fromJson(response.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching yearly analytics: $e");
    }

    return FoodAnalytics(
      aid: yearlyAnalyticsId,
      date: date,
      totalOrders: 0,
      totalCustomers: 0,
      totalDiscountedOrders: 0,
      categorySales: {},
      itemSalesCount: {},
      cancelledOrders: 0,
      averageOrderValue: 0.0,
    );
  }

  Future<FoodAnalytics> weeklyAnalytics(DateTime date) async {
    // Get start and end dates for the week
    final startDate =
        date.subtract(Duration(days: 6)); // 7 days including today
    final endDate = date;

    int totalOrders = 0;
    int totalCustomers = 0;
    int totalDiscountedOrders = 0;
    Map<String, int> categorySales = {};
    Map<String, int> itemSalesCount = {};
    int cancelledOrders = 0;
    double totalOrderValue = 0.0;

    try {
      // Fetch daily analytics for each day in the week
      for (var day = startDate;
          !day.isAfter(endDate);
          day = day.add(Duration(days: 1))) {
        final dailyAnalytics = await fetchDailyAnalytics(day);

        // Aggregate the data
        totalOrders += dailyAnalytics.totalOrders;
        totalCustomers += dailyAnalytics.totalCustomers;
        totalDiscountedOrders += dailyAnalytics.totalDiscountedOrders;
        cancelledOrders += dailyAnalytics.cancelledOrders;
        totalOrderValue +=
            dailyAnalytics.averageOrderValue * dailyAnalytics.totalOrders;

        // Merge category sales
        dailyAnalytics.categorySales.forEach((category, count) {
          categorySales.update(category, (value) => value + count,
              ifAbsent: () => count);
        });

        // Merge item sales
        dailyAnalytics.itemSalesCount.forEach((item, count) {
          itemSalesCount.update(item, (value) => value + count,
              ifAbsent: () => count);
        });
      }

      double averageOrderValue =
          totalOrders > 0 ? totalOrderValue / totalOrders : 0.0;

      return FoodAnalytics(
        aid:
            "WEEK_${getAnalyticsId(startDate, 'daily')}_${getAnalyticsId(endDate, 'daily')}",
        date: date,
        totalOrders: totalOrders,
        totalCustomers: totalCustomers,
        totalDiscountedOrders: totalDiscountedOrders,
        categorySales: categorySales,
        itemSalesCount: itemSalesCount,
        cancelledOrders: cancelledOrders,
        averageOrderValue: averageOrderValue,
      );
    } catch (e) {
      print("Error fetching weekly analytics: $e");
      return FoodAnalytics(
        aid: "",
        date: date,
        totalOrders: 0,
        totalCustomers: 0,
        totalDiscountedOrders: 0,
        categorySales: {},
        itemSalesCount: {},
        cancelledOrders: 0,
        averageOrderValue: 0.0,
      );
    }
  }
}
