import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class OrderStatusChip extends StatelessWidget {
  final FoodOrderStatus status;

  OrderStatusChip({super.key, required this.status});

  // Method to get dynamic color based on status
  Color getStatusColor() {
    switch (status) {
      case FoodOrderStatus.PENDING:
        return AppColors.primaryLight;
      case FoodOrderStatus.PREPARING:
        return AppColors.primaryLight;
      case FoodOrderStatus.CANCELLED:
        return AppColors.errorLight;
      case FoodOrderStatus.READY:
        return AppColors.primaryLight;
      case FoodOrderStatus.COMPLETED:
        return AppColors.primaryLight;
      default:
        return AppColors.primaryLight;
    }
  }

  // Method to get icon based on status
  IconData getStatusIcon() {
    switch (status) {
      case FoodOrderStatus.PENDING:
        return Icons.hourglass_empty;
      case FoodOrderStatus.PREPARING:
        return Icons.kitchen;
      case FoodOrderStatus.CANCELLED:
        return Icons.cancel;
      case FoodOrderStatus.READY:
        return Icons.check_circle;
      case FoodOrderStatus.COMPLETED:
        return Icons.delivery_dining;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: getStatusColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getStatusIcon(),
            color: getStatusColor(),
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Text(
            status.name,
            style: context.textTheme.bodySmall!.copyWith(
              color: getStatusColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
