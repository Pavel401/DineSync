import 'package:cho_nun_btk/app/components/custom_buttons.dart';
import 'package:cho_nun_btk/app/components/snackBars.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Chef%20App/components/steppers.dart';
import 'package:cho_nun_btk/app/modules/Common/order_printer.dart';
import 'package:cho_nun_btk/app/provider/food_order_provider.dart';
import 'package:cho_nun_btk/app/services/registry.dart';
import 'package:cho_nun_btk/app/utils/date_utils.dart';
import 'package:cho_nun_btk/app/utils/order_parser.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class ChefFlow extends StatefulWidget {
  final FoodOrder order;

  ChefFlow({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<ChefFlow> createState() => _ChefFlowState();
}

class _ChefFlowState extends State<ChefFlow> {
  late FoodOrder order;

  FoodOrderProvider? _foodOrderProvider;

  User? user = FirebaseAuth.instance.currentUser;

  AuthController authController = Get.find<AuthController>();

  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    order = widget.order;
    _foodOrderProvider = serviceLocator<FoodOrderProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order: # ${parseOrderId(order.orderId)["counter"]}'),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     Get.to(
          //       () => InvoicePrinter(
          //         order: order,
          //       ),
          //     );
          //   },
          //   icon: Icon(Icons.print),
          // ),
          IconButton(
            onPressed: () {
              Get.to(
                () => OldPrinter(
                  order: order,
                ),
              );
            },
            icon: Icon(Icons.print),
          ),
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
            if (order.customerData.customerSeatingPlace != null &&
                order.customerData.customerSeatingPlace!.isNotEmpty) ...[
              Text(
                "Table No",
                style: context.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.errorLight,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                order.customerData.customerSeatingPlace!.isEmpty
                    ? "No table assigned"
                    : order.customerData.customerSeatingPlace!,
                style: context.textTheme.bodyMedium!.copyWith(),
              ),
              SizedBox(height: 2.h),
            ],
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
                    SizedBox(height: 2.h),
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
            order.orderStatus == FoodOrderStatus.READY
                ? CafePrimaryButton(
                    buttonTitle: "Order is Ready", onPressed: () {})
                : SwipeButton(
                    thumbPadding: EdgeInsets.all(3),
                    thumb: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                    elevationThumb: 2,
                    elevationTrack: 2,
                    activeTrackColor: Colors.green,
                    child: Text(
                      order.orderStatus == FoodOrderStatus.PENDING
                          ? "Swipe to Start Cooking"
                          : order.orderStatus == FoodOrderStatus.PREPARING
                              ? "Swipe to Mark Ready"
                              : "Swipe to Mark Completed",
                      style: context.textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    onSwipe: () async {
                      EasyLoading.show(status: 'Updating Order Status...');
                      if (order.orderStatus == FoodOrderStatus.PENDING) {
                        await _foodOrderProvider!.updateOrderStatus(
                          order.orderId,
                          FoodOrderStatus.PREPARING,
                        );
                        order.cookingStartTime = DateTime.now();

                        _foodOrderProvider!.updateCookingStartTime(
                          order.orderId,
                          order.cookingStartTime!,
                        );
                        CustomSnackBar.showSuccess(
                          "Order Status Updated",
                          "The order is now in the 'Preparing' state.",
                          context,
                        );
                      } else if (order.orderStatus ==
                          FoodOrderStatus.PREPARING) {
                        await _foodOrderProvider!.updateOrderStatus(
                          order.orderId,
                          FoodOrderStatus.READY,
                        );
                        order.cookingEndTime = DateTime.now();
                        _foodOrderProvider!.updateCookingEndTime(
                          order.orderId,
                          order.cookingEndTime!,
                        );
                        CustomSnackBar.showSuccess(
                          "Order Status Updated",
                          "The order is now 'Ready'.",
                          context,
                        );
                      }
                      EasyLoading.dismiss();
                      Get.back();
                    },
                  ),
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

        return foodItem.foodCategory.noNeedToSendToKitchen
            ? SizedBox()
            : Padding(
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
