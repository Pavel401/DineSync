import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/utils/date_utils.dart';
import 'package:flutter/material.dart';

class OrderTimeline extends StatelessWidget {
  final FoodOrder order;

  const OrderTimeline({required this.order});

  int _getCurrentStep() {
    if (order.orderStatus == FoodOrderStatus.READY) {
      return 2;
    } else if (order.orderStatus == FoodOrderStatus.PREPARING) {
      return 1;
    } else if (order.orderStatus == FoodOrderStatus.COMPLETED) {
      return 3;
    } else if (order.orderStatus == FoodOrderStatus.CANCELLED) {
      return 4;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentStep = _getCurrentStep();

    return Column(
      children: [
        _buildTimelineStep(
          title: "Order Placed",
          subtitle:
              'Placed on ${DateUtilities.formatDateTime(order.orderTime)}',
          isActive: currentStep >= 0,
          showDivider: true,
        ),
        _buildTimelineStep(
          title: "Cooking Started",
          subtitle: order.cookingStartTime != null
              ? 'Started at ${DateUtilities.formatDateTime(order.cookingStartTime!)}'
              : "Not started yet",
          isActive: currentStep >= 1,
          showDivider: true,
        ),
        _buildTimelineStep(
          title: "Order Ready",
          subtitle: order.cookingEndTime != null
              ? 'Ready at ${DateUtilities.formatDateTime(order.cookingEndTime!)}'
              : "Not ready yet",
          isActive: currentStep >= 2,
          showDivider: false, // No divider after the last step
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isActive,
    required bool showDivider,
  }) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // Circle for the step indicator
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isActive ? Colors.green : Colors.grey,
                  child: Icon(
                    isActive ? Icons.check : Icons.circle,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                // Divider below the circle (if applicable)
                if (showDivider)
                  Container(
                    height: 40,
                    width: 2,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
