import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/provider/food_order_provider.dart';
import 'package:cho_nun_btk/app/services/app_to_app_notification.dart';
import 'package:cho_nun_btk/app/services/registry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final RxList<FoodOrder> allOrders = <FoodOrder>[].obs;

  late FoodOrderProvider orderProvider;

  AuthController authController = Get.find<AuthController>();

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
      // if (orders.length > allOrders.length &&
      //     authController.userModel!.userType == UserType.CHEF &&
      //     orders.isNotEmpty &&
      //     orders.last.orderStatus == FoodOrderStatus.PENDING) {
      //   triggerNewOrderCreatedNotification(orders.last);
      // }

      allOrders.assignAll(orders);
    });
    debugPrint('Listening to orders');
    debugPrint('All orders: $allOrders');
  }

  void listenToOrder(String orderId) {
    orderProvider.listenToOrder(orderId).listen((FoodOrder updatedOrder) {
      int index = allOrders
          .indexWhere((order) => order.orderId == updatedOrder.orderId);
      if (index != -1) {
        // Update the specific order in the list
        allOrders[index] = updatedOrder;
        allOrders.refresh(); // Notify listeners
        triggerNotification(updatedOrder);
      }

      debugPrint('Updated order: $updatedOrder');
    });
  }

  void triggerNotification(FoodOrder foodOrder) {
    if (foodOrder.orderStatus == FoodOrderStatus.READY) {
      AppToAppNotification.showNotificationDialog(foodOrder, 'Order Ready',
          'Order ${foodOrder.orderId} is ready for delivery', () {
        orderProvider.updateOrderStatus(
            foodOrder.orderId, FoodOrderStatus.COMPLETED);
        Get.back();
      }, () {
        Get.back();
      }, Get.context!);
    } else if (foodOrder.orderStatus == FoodOrderStatus.PREPARING) {
      AppToAppNotification.showNotificationDialog(foodOrder, 'Order Preparing',
          'Order ${foodOrder.orderId} is being prepared', () {
        Get.back();
      }, () {
        Get.back();
      }, Get.context!);
    } else if (foodOrder.orderStatus == FoodOrderStatus.COMPLETED) {
      AppToAppNotification.showNotificationDialog(foodOrder, 'Order Completed',
          'Order ${foodOrder.orderId} has been completed', () {
        Get.back();
      }, () {
        Get.back();
      }, Get.context!);
    } else if (foodOrder.orderStatus == FoodOrderStatus.CANCELLED) {
      AppToAppNotification.showNotificationDialog(foodOrder, 'Order Cancelled',
          'Order ${foodOrder.orderId} has been cancelled', () {
        Get.back();
      }, () {
        Get.back();
      }, Get.context!);
    } else {}
  }

  void triggerNewOrderCreatedNotification(FoodOrder foodOrder) {
    AppToAppNotification.showNotificationDialog(
        foodOrder, 'New Order', 'A new order has been created', () {
      Get.back();
    }, () {
      Get.back();
    }, Get.context!);
  }
}
