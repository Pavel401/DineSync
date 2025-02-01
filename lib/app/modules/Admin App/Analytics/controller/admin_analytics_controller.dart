import 'package:cho_nun_btk/app/models/analytics/analytics.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/provider/analytics_provider.dart';
import 'package:cho_nun_btk/app/provider/menuProvider.dart';
import 'package:get/get.dart';

class AdminAnalyticsController extends GetxController {
  final AnalyticsProvider _analyticsProvider = AnalyticsProvider();
  Menuprovider menuprovider = Menuprovider();
  final selectedFilter = 'Today'.obs;
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  final totalOrders = 0.obs;
  final totalCustomers = 0.obs;
  final cancelledOrders = 0.obs;
  final totalDiscountedOrders = 0.obs;

  RxBool isLoading = false.obs;

  Map<String, int> itemSalesData = <String, int>{}.obs;
  Map<String, int> categorySalesData = <String, int>{}.obs;

  Map<FoodItem, int> salesData = <FoodItem, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    isLoading.value = true;
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

  void updateAnalyticsData(FoodAnalytics analytics) async {
    totalOrders.value = analytics.totalOrders;
    totalCustomers.value = analytics.totalCustomers;
    cancelledOrders.value = analytics.cancelledOrders;
    totalDiscountedOrders.value = analytics.totalDiscountedOrders;
    itemSalesData = analytics.itemSalesCount;

    categorySalesData = await sortTredningCategoryData(analytics.categorySales);

    salesData = await getSalesData(itemSalesData);
    isLoading.value = false;

    update();
  }

  Future<Map<FoodItem, int>> getSalesData(Map<String, int> itemsData) async {
    List<FoodItem> allitems =
        await menuprovider.getAllFoodItemsFromGlobalMenu();

    Map<FoodItem, int> salesData = {};

    for (int i = 0; i < allitems.length; i++) {
      if (itemsData.containsKey(allitems[i].foodId)) {
        salesData[allitems[i]] = itemsData[allitems[i].foodId]!;
      }
    }

    // Convert to list of entries, sort, and convert back to map
    var sortedEntries = salesData.entries.toList()
      ..sort(
          (a, b) => b.value.compareTo(a.value)); // Sort by value (descending)

    // Create a new LinkedHashMap to maintain the sorted order
    Map<FoodItem, int> sortedSalesData = Map.fromEntries(sortedEntries);

    // Debug print (optional)
    sortedSalesData.forEach((item, quantity) {
      print('${item.foodName}: $quantity');
    });

    // salesData.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedSalesData;
  }

  Future<Map<String, int>> sortTredningCategoryData(
      Map<String, int> categoryData) async {
    var sortedEntries = categoryData.entries.toList()
      ..sort(
          (a, b) => b.value.compareTo(a.value)); // Sort by value (descending)

    // Create a new LinkedHashMap to maintain the sorted order
    Map<String, int> sortedCategoryData = Map.fromEntries(sortedEntries);

    // Debug print (optional)
    sortedCategoryData.forEach((category, quantity) {
      print('$category: $quantity');
    });

    return sortedCategoryData;
  }
}
