import 'package:cho_nun_btk/app/components/custom_buttons.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Chef%20App/components/steppers.dart';
import 'package:cho_nun_btk/app/provider/food_order_provider.dart';
import 'package:cho_nun_btk/app/services/registry.dart';
import 'package:cho_nun_btk/app/utils/date_utils.dart';
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

    flag = isOrderNeededToKitchen(order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order: # ${parseOrderId(order.orderId)["counter"]}'),
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
              // padding: EdgeInsets.all(2.w),
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
                    isEnabled: order.orderStatus == FoodOrderStatus.READY,
                    width: 30.w,
                    buttonTitle: "Mark as Served",
                    onPressed: () {
                      _foodOrderProvider!.updateOrderStatus(
                          order.orderId, FoodOrderStatus.COMPLETED);
                      Get.back();
                    }),
                CafeCancelButton(
                    width: 30.w,
                    buttonTitle: "Cancel Order",
                    onPressed: () {
                      _foodOrderProvider!.updateOrderStatus(
                          order.orderId, FoodOrderStatus.COMPLETED);
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

  Widget _buildStepper() {
    return Stepper(
      currentStep: _getCurrentStep(),
      steps: [
        Step(
          title: const Text("Order Placed"),
          subtitle: Text(
            'Placed on ${DateUtilities.formatDateTime(order.orderTime)}',
            style: TextStyle(fontSize: 12),
          ),
          content: CircularProgressIndicator(),
          isActive: true,
        ),
        Step(
          title: const Text("Cooking Started"),
          subtitle: Text(
            order.cookingStartTime != null
                ? 'Started at ${DateUtilities.formatDateTime(order.cookingStartTime!)}'
                : "Not started yet",
            style: TextStyle(fontSize: 12),
          ),
          content: CircularProgressIndicator(),
          isActive: order.orderStatus == FoodOrderStatus.PREPARING ||
              order.orderStatus == FoodOrderStatus.READY,
        ),
        Step(
          title: const Text("Order Ready"),
          subtitle: Text(
            order.cookingEndTime != null
                ? 'Ready at ${DateUtilities.formatDateTime(order.cookingEndTime!)}'
                : "Not ready yet",
            style: TextStyle(fontSize: 12),
          ),
          content: CircularProgressIndicator(),
          isActive: order.orderStatus == FoodOrderStatus.READY,
        ),
      ],
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
