import 'package:cho_nun_btk/app/components/network_image.dart';
import 'package:cho_nun_btk/app/components/snackBars.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/controller/new_order_controller.dart';
import 'package:cho_nun_btk/app/provider/analytics_provider.dart';
import 'package:cho_nun_btk/app/provider/food_order_provider.dart';
import 'package:cho_nun_btk/app/services/registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class CheckoutView extends StatefulWidget {
  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final WaiterOrderController waiterOrderController =
      Get.find<WaiterOrderController>();

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneNumberController =
      TextEditingController();
  final TextEditingController discountNameController = TextEditingController();
  final TextEditingController discountCodeController = TextEditingController();
  final TextEditingController discountAmountController =
      TextEditingController();
  final TextEditingController specialInstructionsController =
      TextEditingController();

  Gender? selectedGender;
  bool isDiscountApplied = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late FoodOrderProvider foodOrderProvider;

  AuthController authController = Get.put(AuthController());

  OrderType orderType = OrderType.DINE_IN;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    foodOrderProvider = serviceLocator<FoodOrderProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Checkout',
            style: TextStyle(
              color: AppColors.onPrimaryLight,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          backgroundColor: AppColors.primaryLight,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.chevron_left, color: AppColors.onPrimaryLight),
            iconSize: 30,
          ),
        ),
        body: Padding(
          padding: AppPading.containerPadding,
          child: GetBuilder<WaiterOrderController>(
            init: waiterOrderController,
            builder: (controller) {
              if (controller.orderItems.isEmpty) {
                return Center(
                  child: Text(
                    'Your cart is empty!',
                    style: context.textTheme.bodyLarge!.copyWith(
                      color: AppColors.onSurfaceLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildItemList(controller),
                    SizedBox(height: 2.h),
                    _buildOrderType(context),
                    SizedBox(height: 2.h),
                    _buildCustomerDetailsCard(context),
                    SizedBox(height: 2.h),
                    _buildWaiterCard(context),
                    SizedBox(height: 2.h),
                    _buildDiscountDetailsCard(context),
                    SizedBox(height: 2.h),
                    _buildSpecialInstruction(context),
                    SizedBox(height: 2.h),
                    _summaryWidget(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Card _buildItemList(WaiterOrderController controller) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.orderItems.length,
          separatorBuilder: (context, index) => Divider(
            thickness: 1,
            color: AppColors.surfaceDark.withOpacity(0.1),
          ),
          itemBuilder: (context, index) {
            FoodItem foodItem = controller.orderItems.keys.elementAt(index);
            int quantity = controller.orderItems[foodItem]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomNetworkImage(
                        imageUrl: foodItem.foodImage,
                        size: 15.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodItem.foodName,
                            style: context.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '₹${foodItem.foodPrice.toStringAsFixed(2)}',
                            style: context.textTheme.bodySmall!.copyWith(
                              color: AppColors.secondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        border: Border.all(color: AppColors.primaryLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.removeOrderItem(foodItem);
                            },
                            child: Icon(
                              Icons.remove_circle,
                              color: AppColors.primaryLight,
                              size: 20.sp,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Text(
                              '$quantity',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.addOrderItem(foodItem);
                            },
                            child: Icon(
                              Icons.add_circle,
                              color: AppColors.primaryLight,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                // Container(
                //   padding: EdgeInsets.symmetric(vertical: 1.h),
                //   decoration: BoxDecoration(
                //     color: AppColors.surfaceLight.withOpacity(0.5),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "Don't send to kitchen",
                //         style: context.textTheme.bodySmall!.copyWith(
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //       Obx(
                //         () => Checkbox(
                //           value: controller.orderIdsNotToBeSendToKichen
                //               .contains(foodItem.foodId),
                //           onChanged: (value) {
                //             controller.saveOrderId(foodItem);
                //           },
                //           activeColor: AppColors.primaryLight,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }

  Card _buildOrderType(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Order Type',
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    orderType = OrderType.DINE_IN;
                  }),
                  child: Container(
                    child: Text(
                      "Dine-In",
                      style: context.textTheme.bodyMedium!.copyWith(
                          color: orderType == OrderType.DINE_IN
                              ? AppColors.white
                              : AppColors.black),
                    ),
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: orderType == OrderType.DINE_IN
                          ? AppColors.primaryLight
                          : AppColors.searchBarLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: () => setState(() {
                    orderType = OrderType.TAKE_AWAY;
                  }),
                  child: Container(
                    child: Text(
                      "Takeaway",
                      style: context.textTheme.bodyMedium!.copyWith(
                          color: orderType == OrderType.TAKE_AWAY
                              ? AppColors.white
                              : AppColors.black),
                    ),
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: orderType == OrderType.TAKE_AWAY
                          ? AppColors.primaryLight
                          : AppColors.searchBarLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card _buildCustomerDetailsCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Customer Details',
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: customerNameController,
              validator: (value) =>
                  value!.isEmpty ? 'Enter customer name' : null,
              decoration: InputDecoration(
                labelText: 'Customer Name *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<Gender>(
              value: selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: Gender.values
                  .map(
                    (gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender.name.capitalize!),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                selectedGender = value;
              }),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: customerPhoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildDiscountDetailsCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Discount Details',
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 2.h),
            SwitchListTile(
              title: Text(
                'Apply Discount',
                style: context.textTheme.bodyMedium,
              ),
              value: isDiscountApplied,
              onChanged: (value) => setState(() {
                isDiscountApplied = value;
              }),
            ),
            if (isDiscountApplied) ...[
              SizedBox(height: 2.h),
              TextField(
                controller: discountNameController,
                decoration: InputDecoration(
                  labelText: 'Discount Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: discountCodeController,
                decoration: InputDecoration(
                  labelText: 'Discount Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: discountAmountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Discount Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Card _buildSpecialInstruction(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Special Instructions',
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 1.h),
            TextField(
              maxLines: 3,
              controller: specialInstructionsController,
              decoration: InputDecoration(
                hintText: 'Add special instructions',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildWaiterCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Waiter Details',
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomNetworkImage(
                  imageUrl: authController.userModel!.photoUrl,
                  size: 10.w,
                  fit: BoxFit.cover,
                  isCircular: true,
                ),
                SizedBox(width: 2.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authController.userModel!.name!,
                      style: context.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authController.userModel!.email!,
                      style: context.textTheme.bodySmall!.copyWith(
                        color: AppColors.secondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _summaryWidget(BuildContext context) {
    return GetBuilder(
        init: waiterOrderController,
        builder: (controller) {
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        EasyLoading.show(status: 'Placing Order...');
                        String orderId =
                            await foodOrderProvider.getNewFoodOrderId();
                        CustomerData customerData = CustomerData(
                          customerName: customerNameController.text,
                          customerPhoneNumber:
                              customerPhoneNumberController.text,
                          customerGender: selectedGender,
                        );

                        DiscountData discountData = DiscountData(
                          isDiscountApplied: isDiscountApplied,
                          discountName: discountNameController.text,
                          discountCode: discountCodeController.text,
                          discountAmount: double.tryParse(
                            discountAmountController.text,
                          ),
                        );

                        FoodOrder foodOrder = FoodOrder(
                          orderStatus: FoodOrderStatus.PENDING,
                          orderItems: controller.orderItems,
                          orderId: orderId,
                          customerData: customerData,
                          specialInstructions:
                              specialInstructionsController.text,
                          orderTime: DateTime.now(),
                          waiterData: WaiterData(
                            waiterId: authController.userModel!.uid ?? "",
                            waiterImage:
                                authController.userModel!.photoUrl ?? "",
                            waiterName: authController.userModel!.name ?? "",
                          ),
                          totalAmount: 0,
                          queuePosition: 0,
                          discountData: discountData,
                          orderType: orderType,
                        );

                        QueryStatus status =
                            await foodOrderProvider.createOrder(foodOrder);

                        AnalyticsProvider analyticsProvider =
                            serviceLocator<AnalyticsProvider>();

                        QueryStatus astatus =
                            await analyticsProvider.recordAnalytics(foodOrder);

                        if (status == QueryStatus.SUCCESS) {
                          EasyLoading.dismiss();
                          Get.until((route) => route.isFirst);
                          CustomSnackBar.showSuccess(
                            'Success',
                            'Order has been placed successfully',
                            context,
                          );
                        } else {
                          EasyLoading.dismiss();
                          CustomSnackBar.showError(
                            'Error',
                            'Failed to place order',
                            context,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
