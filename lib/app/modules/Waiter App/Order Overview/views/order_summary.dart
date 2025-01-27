import 'package:cho_nun_btk/app/components/custom_buttons.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/models/table/table.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Chef%20App/components/steppers.dart';
import 'package:cho_nun_btk/app/provider/food_order_provider.dart';
import 'package:cho_nun_btk/app/provider/table_provider.dart';
import 'package:cho_nun_btk/app/services/registry.dart';
import 'package:cho_nun_btk/app/utils/order_parser.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class WaiterFlow extends StatefulWidget {
  final FoodOrder order;

  WaiterFlow({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<WaiterFlow> createState() => _WaiterFlowState();
}

class _WaiterFlowState extends State<WaiterFlow> {
  late FoodOrder order;

  FoodOrderProvider? _foodOrderProvider;

  User? user = FirebaseAuth.instance.currentUser;

  AuthController authController = Get.find<AuthController>();

  bool isExpanded = false;
  bool flag = true;
  @override
  void initState() {
    super.initState();
    order = widget.order;
    _foodOrderProvider = serviceLocator<FoodOrderProvider>();

    _foodOrderProvider!.listenToOrder(order.orderId).listen((updatedOrder) {
      setState(() {
        order = updatedOrder; // Update the order object
      });
    });

    flag = order.orderStatus == FoodOrderStatus.COMPLETED
        ? true
        : isOrderNeededToKitchen(order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order: # ${parseOrderId(order.orderId)["counter"]}'),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     Get.to(() => FoodLabelPrinter(
          //           order: order,
          //         ));
          //   },
          //   icon: Icon(Icons.print),
          // ),
        ],
      ),
      body: Padding(
        padding: AppPading.containerPadding,
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Order Summary",
                  style: context.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.errorLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(12),
              child: _buildItemList(),
            ),
            SizedBox(height: 2.h),
            Text(
              "Note:",
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.errorLight,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              order.specialInstructions!.isEmpty
                  ? "No special instructions"
                  : order.specialInstructions!,
              style: context.textTheme.bodyMedium!.copyWith(),
            ),
            SizedBox(height: 2.h),
            Text(
              "Order Type",
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.errorLight,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Container(
                  child: Text(
                    order.orderType == OrderType.DINE_IN
                        ? "Dine In"
                        : "Take Away",
                    style: context.textTheme.bodyMedium!
                        .copyWith(color: AppColors.white),
                  ),
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("More Details"),
                  Icon(isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down)
                ],
              ),
            ),
            Visibility(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 1.h,
                    ),
                    Text(
                      "Customer Details",
                      style: context.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${order.customerData.customerName}",
                      style: context.textTheme.bodyMedium!.copyWith(),
                    ),
                    SizedBox(height: 2.h),
                    Text("Waiter Details",
                        style: context.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    Text(
                      "${order.waiterData.waiterName}",
                      style: context.textTheme.bodyMedium!.copyWith(),
                    ),
                    widget.order.tableData != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Table Details",
                                  style: context.textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text(
                                "${order.tableData!.tableName}",
                                style: context.textTheme.bodyMedium!.copyWith(),
                              ),
                            ],
                          )
                        : SizedBox()
                  ],
                ),
                visible: isExpanded),
            isExpanded
                ? SizedBox(height: 5.h)
                : SizedBox(
                    height: 2.h,
                  ),
            Text(
              "TimeLine",
              style: context.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.errorLight,
              ),
            ),
            OrderTimeline(
              order: order,
            ),
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CafePrimaryButton(
                    isEnabled: order.orderStatus == FoodOrderStatus.CANCELLED
                        ? false
                        : flag == false
                            ? true
                            : order.orderStatus == FoodOrderStatus.READY,
                    width: 30.w,
                    buttonTitle: "Mark as Served",
                    onPressed: () {
                      if (flag == false) {
                        _foodOrderProvider!.updateOrderStatus(
                            order.orderId, FoodOrderStatus.COMPLETED);

                        _foodOrderProvider!.updateCookingStartTime(
                            order.orderId, DateTime.now());

                        _foodOrderProvider!.updateCookingEndTime(
                            order.orderId, DateTime.now());
                      } else {
                        order.cookingStartTime = DateTime.now();

                        _foodOrderProvider!.updateCookingStartTime(
                          order.orderId,
                          order.cookingStartTime!,
                        );
                        order.cookingEndTime = DateTime.now();
                        _foodOrderProvider!.updateCookingEndTime(
                          order.orderId,
                          order.cookingEndTime!,
                        );

                        _foodOrderProvider!.updateOrderStatus(
                            order.orderId, FoodOrderStatus.COMPLETED);

                        if (order.tableData != null) {
                          TableProvider tableProvider = TableProvider();

                          TableModel table = order.tableData!
                              .copyWith(tableStatus: TableStatus.AVAILABLE)!;

                          tableProvider.saveTable(table);
                        }
                      }

                      Get.back();
                    }),
                CafeCancelButton(
                    width: 30.w,
                    isEnabled: (order.orderStatus == FoodOrderStatus.READY ||
                            order.orderStatus == FoodOrderStatus.COMPLETED ||
                            order.orderStatus == FoodOrderStatus.CANCELLED)
                        ? false
                        : true,
                    buttonTitle: "Cancel Order",
                    onPressed: () {
                      _foodOrderProvider!.updateOrderStatus(
                          order.orderId, FoodOrderStatus.CANCELLED);

                      if (order.tableData != null) {
                        TableProvider tableProvider = TableProvider();

                        TableModel table = order.tableData!
                            .copyWith(tableStatus: TableStatus.AVAILABLE)!;

                        tableProvider.saveTable(table);
                      }
                      Get.back();
                    })
              ],
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  _buildItemList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: order.orderItems.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // Access the map entries
        final entry = order.orderItems.entries.elementAt(index);
        final foodItem = entry.key; // The FoodItem
        final quantity = entry.value; // The quantity

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 70.w,
                child: Text(
                  foodItem.foodName,
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('X$quantity'),
            ],
          ),
        );
      },
    );
  }
}
