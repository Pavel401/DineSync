import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';

Map<String, dynamic> parseOrderId(String orderId) {
  // Define a regex to match the updated Order ID format
  final RegExp regex = RegExp(r'^##ORDER-(\d{8})-##(\d+)-##([A-Z0-9]+)$');
  final Match? match = regex.firstMatch(orderId);

  if (match != null) {
    // Extract components from the regex match groups
    final String date = match.group(1)!; // YYYYMMDD
    final String counter = match.group(2)!; // Counter
    final String randomPart = match.group(3)!; // Random alphanumeric part

    // Parse the date components
    final String year = date.substring(0, 4);
    final String month = date.substring(4, 6);
    final String day = date.substring(6, 8);
    final DateTime parsedDate = DateTime.parse('$year-$month-$day');

    return {
      'date': parsedDate,
      'counter': int.parse(counter),
      'randomPart': randomPart,
    };
  } else {
    throw FormatException('Invalid Order ID format');
  }
}

bool isOrderNeededToKitchen(FoodOrder order) {
  bool flag = false;
  for (int i = 0; i < order.orderItems.length; i++) {
    FoodItem item = order.orderItems.keys.elementAt(i);

    if (item.foodCategory.noNeedToSendToKitchen == false) {
      flag = true;
      break;
    }
  }

  return flag;
}
