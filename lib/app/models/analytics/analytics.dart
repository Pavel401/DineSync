class DailyAnalytics {
  String aid; // Analytics ID
  DateTime date; // Date for analytics

  // Basic Metrics
  int totalOrders; // Total number of orders
  double totalRevenue; // Total revenue for the day
  int totalCustomers; // Total unique customers for the day
  int totalItemsSold; // Total items sold

  // Discount Metrics
  int totalDiscountedOrders; // Number of orders with discounts applied

  // Category-Specific Sales
  Map<String, int> categorySales; // E.g., {'Food': 50, 'Beverage': 30}

  Map<String, int> itemSalesCount; // E.g., {'itemID1': 10, 'itemID2': 5}

  // Order Timing
  int peakHour; // Hour with the most orders
  int ordersDuringPeakHour; // Number of orders during peak hour

  // Payment Method Metrics
  Map<String, int> paymentMethods; // E.g., {'Cash': 50, 'Card': 30}

  // Cancellation Metrics
  int cancelledOrders; // Total number of cancelled orders
  List<String> cancelledReasons; // Reasons for cancellations (optional)

  double averageOrderValue; // Average revenue per order

  DailyAnalytics({
    required this.aid,
    required this.date,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalCustomers,
    required this.totalItemsSold,
    this.totalDiscountedOrders = 0,
    this.categorySales = const {},
    this.itemSalesCount = const {},
    this.peakHour = 0,
    this.ordersDuringPeakHour = 0,
    this.paymentMethods = const {},
    this.cancelledOrders = 0,
    this.cancelledReasons = const [],
    this.averageOrderValue = 0.0,
  });

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'aid': aid,
        'date': date.toIso8601String(),
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'totalCustomers': totalCustomers,
        'totalItemsSold': totalItemsSold,
        'totalDiscountedOrders': totalDiscountedOrders,
        'categorySales': categorySales,
        'itemSalesCount': itemSalesCount,
        'peakHour': peakHour,
        'ordersDuringPeakHour': ordersDuringPeakHour,
        'paymentMethods': paymentMethods,
        'cancelledOrders': cancelledOrders,
        'cancelledReasons': cancelledReasons,
        'averageOrderValue': averageOrderValue,
      };

  // JSON deserialization
  factory DailyAnalytics.fromJson(Map<String, dynamic> json) {
    return DailyAnalytics(
      aid: json['aid'],
      date: DateTime.parse(json['date']),
      totalOrders: json['totalOrders'],
      totalRevenue: json['totalRevenue'],
      totalCustomers: json['totalCustomers'],
      totalItemsSold: json['totalItemsSold'],
      totalDiscountedOrders: json['totalDiscountedOrders'],
      categorySales: json['categorySales'],
      itemSalesCount: json['itemSalesCount'],
      peakHour: json['peakHour'],
      ordersDuringPeakHour: json['ordersDuringPeakHour'],
      paymentMethods: json['paymentMethods'],
      cancelledOrders: json['cancelledOrders'],
      cancelledReasons: json['cancelledReasons'],
      averageOrderValue: json['averageOrderValue'],
    );
  }
}
