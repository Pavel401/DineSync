import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/provider/food_order_provider.dart';
import 'package:cho_nun_btk/app/services/registry.dart';
import 'package:cho_nun_btk/app/utils/order_parser.dart';
import 'package:dotted_line/dotted_line.dart';
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
      ),
      body: Padding(
        padding: AppPading.containerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            _buildItemList(),
            Text(
              "Note:",
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.errorLight,
              ),
            ),
            Text(
              order.specialInstructions ?? "No special instructions",
              style: context.textTheme.bodyMedium!.copyWith(),
            ),
            SizedBox(height: 2.h),
            DottedLine(
              dashColor: AppColors.primaryLight,
            ),
            SizedBox(height: 2.h),
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
            DottedLine(
              dashColor: AppColors.primaryLight,
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
            DottedLine(
              dashColor: AppColors.primaryLight,
            ),
            SizedBox(height: 2.h),
            Text("Order Type",
                style: context.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            Container(
              child: Text(
                order.orderType == OrderType.DINE_IN ? "Dine In" : "Take Away",
                style: context.textTheme.bodyMedium!
                    .copyWith(color: AppColors.white),
              ),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 2.h),
            DottedLine(
              dashColor: AppColors.primaryLight,
            ),
            SizedBox(height: 2.h),
            SwipeButton(
              thumbPadding: EdgeInsets.all(3),
              thumb: Icon(
                Icons.chevron_right,
                color: Colors.white,
              ),
              elevationThumb: 2,
              elevationTrack: 2,
              child: Text(
                order.orderStatus == FoodOrderStatus.PENDING
                    ? "Start Cooking"
                    : order.orderStatus == FoodOrderStatus.PREPARING
                        ? "Mark as Ready"
                        : "Mark as Completed",
                style: context.textTheme.bodyMedium!.copyWith(),
              ),
              onSwipe: () {
                EasyLoading.show(status: 'Updating Order Status...');
                if (order.orderStatus == FoodOrderStatus.PENDING) {
                  _foodOrderProvider!.updateOrderStatus(
                    order.orderId,
                    FoodOrderStatus.PREPARING,
                  );

                  KitchenData kitchenData = KitchenData(
                    kitchenStaffId: authController.userModel!.uid ?? "",
                    kitchenStaffName: authController.userModel!.name ?? "",
                  );

                  _foodOrderProvider!.updateKitchenData(
                    order.orderId,
                    kitchenData,
                  );
                  DateTime cookingStartTime = DateTime.now();
                  _foodOrderProvider!.updateCookingStartTime(
                    order.orderId,
                    cookingStartTime,
                  );
                  _foodOrderProvider!.updateCookingStartTime(
                    order.orderId,
                    cookingStartTime,
                  );

                  Get.back();
                }
                if (order.orderStatus == FoodOrderStatus.PREPARING) {
                  _foodOrderProvider!.updateOrderStatus(
                    order.orderId,
                    FoodOrderStatus.READY,
                  );

                  DateTime cookingEndTime = DateTime.now();
                  _foodOrderProvider!.updateCookingEndTime(
                    order.orderId,
                    cookingEndTime,
                  );
                  Get.back();
                }
                EasyLoading.dismiss();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  _buildItemList() {
    return ListView.separated(
      separatorBuilder: (context, index) => DottedLine(
        dashColor: AppColors.primaryLight,
      ),
      shrinkWrap: true,
      itemCount: order.orderItems.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // Access the map entries
        final entry = order.orderItems.entries.elementAt(index);
        final foodItem = entry.key; // The FoodItem
        final quantity = entry.value; // The quantity

        return order.sendToKitchen!.contains(foodItem.foodId)
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
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
