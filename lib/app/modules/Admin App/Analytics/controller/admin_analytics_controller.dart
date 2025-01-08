import 'package:cho_nun_btk/app/models/analytics/analytics.dart';
import 'package:cho_nun_btk/app/provider/analytics_provider.dart';
import 'package:get/get.dart';

class AdminAnalyticsController extends GetxController {
  final AnalyticsProvider _analyticsProvider = AnalyticsProvider();

  final selectedFilter = 'Today'.obs;
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  final totalOrders = 0.obs;
  final totalCustomers = 0.obs;
  final cancelledOrders = 0.obs;
  final totalDiscountedOrders = 0.obs;

  Map<String, int> itemSalesData = <String, int>{}.obs;
  Map<String, int> categorySalesData = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    DateTime date;
    FoodAnalytics analytics = FoodAnalytics(
      aid: '',
      date: DateTime.now(),
      totalOrders: 0,
      totalCustomers: 0,
      totalDiscountedOrders: 0,
      categorySales: {},
      itemSalesCount: {},
      cancelledOrders: 0,
      averageOrderValue: 0.0,
    );

    switch (selectedFilter.value) {
      case 'Today':
        date = DateTime.now();
        analytics = await _analyticsProvider.fetchDailyAnalytics(date);
        break;
      case 'Yesterday':
        date = DateTime.now().subtract(Duration(days: 1));
        analytics = await _analyticsProvider.fetchDailyAnalytics(date);
        break;
      case 'Weekly':
        // Implementation for weekly analytics

        date = DateTime.now();
        analytics = await _analyticsProvider.weeklyAnalytics(date);
        break;
      case 'Monthly':
        date = DateTime(selectedYear.value, selectedMonth.value);
        // Implement fetchMonthlyAnalytics
        analytics = await _analyticsProvider.getMonthlyAnalytics(date);
        break;
      case 'Yearly':
        date = DateTime(selectedYear.value);
        // Implement fetchYearlyAnalytics
        analytics = await _analyticsProvider.getYearlyAnalytics(date);
        break;
      default:
        date = DateTime.now();
        analytics = await _analyticsProvider.fetchDailyAnalytics(date);
    }

    updateAnalyticsData(analytics);
  }

  void updateAnalyticsData(FoodAnalytics analytics) {
    totalOrders.value = analytics.totalOrders;
    totalCustomers.value = analytics.totalCustomers;
    cancelledOrders.value = analytics.cancelledOrders;
    totalDiscountedOrders.value = analytics.totalDiscountedOrders;
    itemSalesData = analytics.itemSalesCount;
    categorySalesData = analytics.categorySales;
  }
}
