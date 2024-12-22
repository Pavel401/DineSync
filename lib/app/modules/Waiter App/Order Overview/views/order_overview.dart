import 'package:cho_nun_btk/app/components/common_tabbar.dart';
import 'package:cho_nun_btk/app/components/empty_widget.dart';
import 'package:cho_nun_btk/app/components/order_status_chip.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/views/new_order.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/Order%20Overview/controller/order_controller.dart';
import 'package:cho_nun_btk/app/utils/date_utils.dart';
import 'package:cho_nun_btk/app/utils/order_parser.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class OrderOverview extends StatelessWidget {
  OrderOverview({super.key});
  final OrderController orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Order Overview"),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => AddNewOrderView());
          },
          child: const Icon(Icons.add),
        ),
        body: CustomTabBar(
          isInBetween: false,
          pagePadding: EdgeInsets.all(2.w),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          titleAndWidget: {
            'All': buildOrderList(statuses: [
              FoodOrderStatus.PENDING,
              FoodOrderStatus.PREPARING,
              FoodOrderStatus.READY,
              FoodOrderStatus.COMPLETED,
              FoodOrderStatus.CANCELLED,
            ]),
            // 'Pending': buildOrderList(statuses: [FoodOrderStatus.PENDING]),
            'Completed': buildOrderList(statuses: [FoodOrderStatus.COMPLETED]),
          },
        ),
      ),
    );
  }

  Widget buildOrderList({required List<FoodOrderStatus> statuses}) {
    return Obx(() {
      final orders = orderController.allOrders
          .where((order) => statuses.contains(order.orderStatus))
          .toList();

      if (orders.isEmpty) {
        return EmptyIllustrations(
          // placeInCenter: false,
          imageHeight: 20.h,
          // removeHeightValue: true,
          width: 80.w,
          title: "No Orders Today",
          message: "You have not received any orders today",
          imagePath: "assets/svg/empty.svg",
        );
      }

      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          FoodOrder order = orders[index];
          return Card(
            color: AppColors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Order No: ",
                            style: context.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "#" +
                                parseOrderId(order.orderId)['counter']
                                    .toString(),
                            style: context.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          OrderStatusChip(status: order.orderStatus),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Text(
                            "Name:",
                            style: context.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            order.customerData.customerName ?? "",
                            style: context.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                DottedLine(
                  dashColor: AppColors.primaryDark,
                ),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "X" + order.orderItems.length.toString(),
                            style: context.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.schedule),
                          Text(
                            DateUtilities.formatDateTime(order.orderTime),
                            style: context.textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text(
                            order.orderType!.name == OrderType.DINE_IN.name
                                ? "Dine In"
                                : "Take Away",
                            style: context.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      );
    });
  }
}
