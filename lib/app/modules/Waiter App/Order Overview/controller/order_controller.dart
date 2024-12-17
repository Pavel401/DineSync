import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/provider/food_order_provider.dart';
import 'package:cho_nun_btk/app/services/registry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final RxList<FoodOrder> allOrders = <FoodOrder>[].obs;

  late FoodOrderProvider orderProvider;

  @override
  void onInit() {
    super.onInit();
    orderProvider = serviceLocator<FoodOrderProvider>();
    listenToOrders();
  }

  void listenToOrders() {
    orderProvider
        .listenToBookings(DateTime.now())
        .listen((List<FoodOrder> orders) {
      allOrders.assignAll(orders);
    });
    debugPrint('Listening to orders');
    debugPrint('All orders: $allOrders');
  }
}
