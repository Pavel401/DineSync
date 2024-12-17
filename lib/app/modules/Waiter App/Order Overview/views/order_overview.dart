import 'package:cho_nun_btk/app/components/common_tabbar.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/views/new_order.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/Order%20Overview/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class OrderOverview extends StatelessWidget {
  OrderOverview({super.key});
  final OrderController orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
            'In-Progress': buildOrderList(status: FoodOrderStatus.PENDING),
            'Ready': buildOrderList(status: FoodOrderStatus.READY),
            'Completed': buildOrderList(status: FoodOrderStatus.DELIVERED),
          },
        ),
      ),
    );
  }

  Widget buildOrderList({required FoodOrderStatus status}) {
    return Obx(() {
      final orders = orderController.allOrders
          .where((order) => order.orderStatus == status)
          .toList();

      if (orders.isEmpty) {
        return Center(
          child: Text('No orders yet.'),
        );
      }

      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          FoodOrder order = orders[index];
          return Card(
            elevation: 2,
            color: AppColors.searchBarLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: EdgeInsets.all(2.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.primaryLight,
                        ),
                        padding: EdgeInsets.all(3.w),
                        child: Center(
                          child: Text(
                            order.customerData.customerName.substring(0, 2),
                            style: context.textTheme.bodySmall!.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerData.customerName,
                            style: context.textTheme.bodyMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            order.orderId,
                            style: context.textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
