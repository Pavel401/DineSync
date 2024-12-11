import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:get/get.dart';

class WaiterOrderController extends GetxController {
  Map<FoodItem, int> orderItems = {};

  RxBool isOrderEmpty = true.obs;

  void addOrderItem(FoodItem foodItem) {
    if (orderItems.containsKey(foodItem)) {
      orderItems[foodItem] = orderItems[foodItem]! + 1;
    } else {
      orderItems[foodItem] = 1;
    }
    isOrderEmpty.value = false;
    update();
  }

  void removeOrderItem(FoodItem foodItem) {
    if (orderItems.containsKey(foodItem)) {
      if (orderItems[foodItem]! > 1) {
        orderItems[foodItem] = orderItems[foodItem]! - 1;
      } else {
        orderItems.remove(foodItem);
      }
    }
    if (orderItems.isEmpty) {
      isOrderEmpty.value = true;
    }
    update();
  }

  void clearOrder() {
    orderItems.clear();
    update();
  }

  int totalItemCountForOrder(FoodItem foodItem) {
    return orderItems[foodItem] ?? 0;
  }
}
