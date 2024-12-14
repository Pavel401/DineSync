import 'package:cho_nun_btk/app/components/network_image.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/controller/new_order_controller.dart';
import 'package:cho_nun_btk/app/provider/food_order_provider.dart';
import 'package:cho_nun_btk/app/services/registry.dart';
import 'package:flutter/material.dart';
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
                    Card(
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
                            FoodItem foodItem =
                                controller.orderItems.keys.elementAt(index);
                            int quantity = controller.orderItems[foodItem]!;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CustomNetworkImage(
                                    imageUrl: foodItem.foodImage,
                                    size: 15.w,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        foodItem.foodName,
                                        style: context.textTheme.bodyMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        '₹${foodItem.foodPrice.toStringAsFixed(2)}',
                                        style: context.textTheme.bodySmall!
                                            .copyWith(
                                                color:
                                                    AppColors.secondaryLight),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 2.w),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.primaryLight),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          controller.removeOrderItem(foodItem);
                                        },
                                        icon: Icon(
                                          Icons.remove_circle,
                                          color: AppColors.primaryLight,
                                        ),
                                      ),
                                      Text(
                                        '$quantity',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          controller.addOrderItem(foodItem);
                                        },
                                        icon: Icon(
                                          Icons.add_circle,
                                          color: AppColors.primaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    _buildCustomerDetailsCard(context),
                    SizedBox(height: 2.h),
                    _buildDiscountDetailsCard(context),
                    SizedBox(height: 2.h),
                    _buildSpecialInstruction(context),
                    SizedBox(height: 2.h),
                    _summaryWidget(context, controller),
                  ],
                ),
              );
            },
          ),
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

  _summaryWidget(BuildContext context, WaiterOrderController controller) {
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
                  Text(
                    'Summary',
                    style: context.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Items:'),
                      Text(
                        '${controller.orderItems.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        String orderId = foodOrderProvider.getNewFoodOrderId();
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

                        Foodorder foodOrder = Foodorder(
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
                        );
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
                      'Send to Kitchen',
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
