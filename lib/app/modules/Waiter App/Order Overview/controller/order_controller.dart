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
    debugPrint('[OrderController] Started listening to orders');
    orderProvider.listenToBookings(DateTime.now()).listen(
        (List<FoodOrder> orders) {
      debugPrint('[OrderController] Received ${orders.length} orders');

      // Debug logging the last order
      if (orders.isNotEmpty) {
        debugPrint('[OrderController] Last order: ${orders.last.toJson()}');
      }

      // Optional: Check for new order created
      // if (orders.length > allOrders.length &&
      //     authController.userModel?.userType == UserType.CHEF &&
      //     orders.last.orderStatus == FoodOrderStatus.PENDING) {
      //   triggerNewOrderCreatedNotification(orders.last);
      // }

      allOrders.assignAll(orders);

      print(
          '[OrderController] Updated allOrders list with ${orders.length} orders');
    }, onError: (error) {
      debugPrint('[OrderController] Error listening to bookings: $error');
    });
  }

  void listenToOrder(String orderId) {
    debugPrint('[OrderController] Listening to orderId: $orderId');
    orderProvider.listenToOrder(orderId).listen((FoodOrder updatedOrder) {
      debugPrint(
          '[OrderController] Received update for order: ${updatedOrder.toJson()}');

      int index = allOrders
          .indexWhere((order) => order.orderId == updatedOrder.orderId);
      if (index != -1) {
        allOrders[index] = updatedOrder;
        allOrders.refresh();
        debugPrint('[OrderController] Updated order in list at index $index');
        triggerNotification(updatedOrder);
      } else {
        debugPrint('[OrderController] Order not found in current list');
      }
    }, onError: (error) {
      debugPrint('[OrderController] Error listening to order $orderId: $error');
    });
  }

  void triggerNotification(FoodOrder foodOrder) {
    debugPrint(
        '[OrderController] Triggering notification for status: ${foodOrder.orderStatus}');

    switch (foodOrder.orderStatus) {
      case FoodOrderStatus.READY:
        AppToAppNotification.showNotificationDialog(foodOrder, 'Order Ready',
            'Order ${foodOrder.orderId} is ready for delivery', () {
          orderProvider.updateOrderStatus(
              foodOrder.orderId, FoodOrderStatus.COMPLETED);
          Get.back();
        }, () => Get.back(), Get.context!);
        break;

      case FoodOrderStatus.PREPARING:
        AppToAppNotification.showNotificationDialog(
            foodOrder,
            'Order Preparing',
            'Order ${foodOrder.orderId} is being prepared',
            () => Get.back(),
            () => Get.back(),
            Get.context!);
        break;

      case FoodOrderStatus.COMPLETED:
        AppToAppNotification.showNotificationDialog(
            foodOrder,
            'Order Completed',
            'Order ${foodOrder.orderId} has been completed',
            () => Get.back(),
            () => Get.back(),
            Get.context!);
        break;

      case FoodOrderStatus.CANCELLED:
        AppToAppNotification.showNotificationDialog(
            foodOrder,
            'Order Cancelled',
            'Order ${foodOrder.orderId} has been cancelled',
            () => Get.back(),
            () => Get.back(),
            Get.context!);
        break;

      default:
        debugPrint(
            '[OrderController] No notification handler for status: ${foodOrder.orderStatus}');
    }
  }

  void triggerNewOrderCreatedNotification(FoodOrder foodOrder) {
    debugPrint(
        '[OrderController] Triggering new order created notification for ${foodOrder.orderId}');
    AppToAppNotification.showNotificationDialog(
        foodOrder,
        'New Order',
        'A new order has been created',
        () => Get.back(),
        () => Get.back(),
        Get.context!);
  }
}
