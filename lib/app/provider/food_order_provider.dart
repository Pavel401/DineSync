import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodOrderProvider {
  String getNewFoodOrderId() {
    String baseId = FirebaseFirestore.instance.collection('orders').doc().id;
    return "#Oder-$baseId";
  }

  Future<QueryStatus> createOrder(Foodorder order) async {
    try {
      // Create order
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.orderId)
          .set(order.toJson());
      return QueryStatus.SUCCESS;
    } catch (e) {
      print(e);
      return QueryStatus.ERROR;
    }
  }
}
