import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/provider/food_order_provider.dart';
import 'package:cho_nun_btk/app/services/app_to_app_notification.dart';
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
      // triggerNotification(orders[0], Get.context!);
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
        // triggerNotification(updatedOrder, Get.context!);

        allOrders.refresh(); // Notify listeners
      }
      debugPrint('Updated order: $updatedOrder');
    });
  }

  void triggerNotification(FoodOrder foodOrder, BuildContext context) {
    String title = "";
    String message = "";
    Function() onTapOk = () {
      Navigator.of(context).pop(); // Dismiss the dialog
    };
    Function() onTapNo = () {
      Navigator.of(context).pop(); // Dismiss the dialog
    };

    bool flag = false;

    switch (foodOrder.orderStatus) {
      case FoodOrderStatus.READY:
        title = "Order Ready";
        message =
            "Your order (ID: ${foodOrder.orderId}) is ready to be served.";
        break;

      case FoodOrderStatus.PREPARING:
        title = "Order Preparing";
        message =
            "Your order (ID: ${foodOrder.orderId}) is currently being prepared. Please wait a moment.";
        break;

      case FoodOrderStatus.COMPLETED:
        title = "Order Completed";
        message =
            "Your order (ID: ${foodOrder.orderId}) has been completed. Thank you!";
        break;

      case FoodOrderStatus.CANCELLED:
        title = "Order Cancelled";
        message = "Your order (ID: ${foodOrder.orderId}) has been cancelled.";
        break;

      default:
        flag = true;
        break;
    }

    if (flag) {
      return;
    }
    AppToAppNotification.showNotificationDialog(
      foodOrder,
      title,
      message,
      onTapOk,
      onTapNo,
      context,
    );
  }
}
