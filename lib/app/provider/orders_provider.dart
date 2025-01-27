import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a reference to the orders collection
  CollectionReference<Map<String, dynamic>> get ordersCollection =>
      _firestore.collection('orders');

  // Get a reference to the analytics collection
  CollectionReference<Map<String, dynamic>> get analyticsCollection =>
      _firestore.collection('analytics');

  // Get orders stream for a specific date
  Stream<List<FoodOrder>> getOrdersStream(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return ordersCollection
        .where('orderTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('orderTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodOrder.fromJson(doc.data()))
            .toList());
  }

  // Get orders for a specific date
  Future<List<FoodOrder>> getOrders(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final querySnapshot = await ordersCollection
        .where('orderTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('orderTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('orderTime', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => FoodOrder.fromJson(doc.data()))
        .toList();
  }

  // Create a new order
  Future<void> createOrder(FoodOrder order) async {
    await ordersCollection.doc(order.orderId).set(order.toJson());
  }

  // Update an existing order
  Future<void> updateOrder(FoodOrder order) async {
    await ordersCollection.doc(order.orderId).update(order.toJson());
  }

  // Delete an order
  Future<void> deleteOrder(String orderId) async {
    await ordersCollection.doc(orderId).delete();
  }

  // Get a single order by ID
  Future<FoodOrder?> getOrderById(String orderId) async {
    final docSnapshot = await ordersCollection.doc(orderId).get();
    if (docSnapshot.exists) {
      return FoodOrder.fromJson(docSnapshot.data()!);
    }
    return null;
  }

  // Get orders by status
  Future<List<FoodOrder>> getOrdersByStatus(
      FoodOrderStatus status, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final querySnapshot = await ordersCollection
        .where('orderTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('orderTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('orderStatus', isEqualTo: status.name)
        .orderBy('orderTime', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => FoodOrder.fromJson(doc.data()))
        .toList();
  }

  // Stream orders by status
  Stream<List<FoodOrder>> getOrdersByStatusStream(
      FoodOrderStatus status, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return ordersCollection
        .where('orderTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('orderTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('orderStatus', isEqualTo: status.name)
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodOrder.fromJson(doc.data()))
            .toList());
  }

  // Get analytics ID based on type and date
  String getAnalyticsId(DateTime date, String type) {
    switch (type) {
      case "daily":
        return "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
      case "monthly":
        return "${date.year}${date.month.toString().padLeft(2, '0')}";
      case "yearly":
        return "${date.year}";
      default:
        throw ArgumentError("Invalid analytics type: $type");
    }
  }
}
