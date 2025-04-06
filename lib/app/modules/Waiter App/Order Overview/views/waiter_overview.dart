import 'package:cho_nun_btk/app/components/common_tabbar.dart';
import 'package:cho_nun_btk/app/components/empty_widget.dart';
import 'package:cho_nun_btk/app/components/foodCard.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/views/new_order.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/Order%20Overview/controller/order_controller.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/Order%20Overview/views/order_summary.dart';
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
            'Ongoing': buildOrderList(statuses: [
              FoodOrderStatus.PENDING,
              FoodOrderStatus.PREPARING,
              FoodOrderStatus.READY,
            ]),
            // 'Pending': buildOrderList(statuses: [FoodOrderStatus.PENDING]),
            'Archived': buildOrderList(statuses: [
              FoodOrderStatus.COMPLETED,
              FoodOrderStatus.CANCELLED,
            ]),
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
          return OrderCard(
            order: order,
            onTap: () {
              Get.to(() => WaiterFlow(order: order));
            },
          );
          // Container(
          //   child: GestureDetector(
          //       onTap: () {
          //         Clipboard.setData(
          //             ClipboardData(text: order.toJson().toString()));
          //       },
          //       child: Text(order.toJson().toString())),
          // );
        },
      );
    });
  }
}
