class FoodAnalytics {
  String aid; // Analytics ID
  DateTime date; // Date for analytics

  // Basic Metrics
  int totalOrders; // Total number of orders
  int totalCustomers; // Total unique customers for the day

  // Discount Metrics
  int totalDiscountedOrders; // Number of orders with discounts applied

  // Category-Specific Sales
  Map<String, int> categorySales; // E.g., {'Food': 50, 'Beverage': 30}

  Map<String, int> itemSalesCount; // E.g., {'itemID1': 10, 'itemID2': 5}

  // Payment Method Metrics

  // Cancellation Metrics
  int cancelledOrders; // Total number of cancelled orders

  double averageOrderValue; // Average revenue per order

  FoodAnalytics({
    required this.aid,
    required this.date,
    required this.totalOrders,
    required this.totalCustomers,
    this.totalDiscountedOrders = 0,
    this.categorySales = const {},
    this.itemSalesCount = const {},
    this.cancelledOrders = 0,
    this.averageOrderValue = 0.0,
  });

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'aid': aid,
        'date': date.toIso8601String(),
        'totalOrders': totalOrders,
        'totalCustomers': totalCustomers,
        'totalDiscountedOrders': totalDiscountedOrders,
        'categorySales': categorySales,
        'itemSalesCount': itemSalesCount,
        'cancelledOrders': cancelledOrders,
        'averageOrderValue': averageOrderValue,
      };
  factory FoodAnalytics.fromJson(Map<String, dynamic> json) {
    return FoodAnalytics(
      aid: json['aid'],
      date: DateTime.parse(json['date']),
      totalOrders: json['totalOrders'],
      totalCustomers: json['totalCustomers'],
      totalDiscountedOrders: json['totalDiscountedOrders'],
      categorySales: (json['categorySales'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
      itemSalesCount: (json['itemSalesCount'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
      cancelledOrders: json['cancelledOrders'],
      averageOrderValue: json['averageOrderValue'],
    );
  }
}
