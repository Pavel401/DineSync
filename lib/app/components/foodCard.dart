import 'package:cho_nun_btk/app/components/order_status_chip.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/utils/date_utils.dart';
import 'package:cho_nun_btk/app/utils/order_parser.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class OrderCard extends StatelessWidget {
  final FoodOrder order;
  final VoidCallback? onTap;

  const OrderCard({
    Key? key,
    required this.order,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flag = isOrderNeededToKitchen(order);
    if (!flag) return const SizedBox();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppColors.white,
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order number & status
                  Row(
                    children: [
                      Text(
                        "Order No: ",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "#${parseOrderId(order.orderId)['counter']}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      OrderStatusChip(status: order.orderStatus),
                    ],
                  ),
                  SizedBox(height: 1.h),

                  // Table number
                  if (order.customerData.customerSeatingPlace != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 0.5.h),
                      child: Row(
                        children: [
                          Text(
                            "Table No: ",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            order.customerData.customerSeatingPlace!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.errorLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Customer Name
                  if (order.customerData.customerName != null &&
                      order.customerData.customerName!.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          "Name: ",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          order.customerData.customerName.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            DottedLine(
              dashColor: AppColors.primaryDark,
              dashLength: 6,
              lineThickness: 1,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    "x${order.orderItems.length}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.schedule, size: 18),
                  SizedBox(width: 1.w),
                  Text(
                    DateUtilities.formatDateTime(order.orderTime),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order.orderType == OrderType.DINE_IN
                        ? "Dine In"
                        : "Take Away",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
