import 'package:cho_nun_btk/app/components/custom_buttons.dart';
import 'package:cho_nun_btk/app/components/food_card_v2.dart';
import 'package:cho_nun_btk/app/components/network_image.dart';
import 'package:cho_nun_btk/app/components/snackBars.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/controllers/menu_controller.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/controller/new_order_controller.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/views/checkout_view.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/views/view_item_read_view.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';

class AddNewOrderView extends StatefulWidget {
  const AddNewOrderView({super.key});

  @override
  State<AddNewOrderView> createState() => _AddNewOrderViewState();
}

class _AddNewOrderViewState extends State<AddNewOrderView> {
  final FoodMenuController menuController = Get.put(FoodMenuController());
  final WaiterOrderController waiterOrderController =
      Get.put(WaiterOrderController());

  late Future<List<FoodCategory>> getCategories;

  @override
  void initState() {
    super.initState();
    getCategories = menuController.getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "New Order",
          style: TextStyle(color: AppColors.onPrimaryLight),
        ),
        backgroundColor: AppColors.primaryLight,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.chevron_left, color: AppColors.onPrimaryLight),
          iconSize: 30,
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: AppPading.containerPadding,
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder<List<FoodCategory>>(
                    future: getCategories,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      menuController.categories =
                          snapshot.data as RxList<FoodCategory>;

                      return GetBuilder<FoodMenuController>(
                        builder: (controller) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Categories",
                                      style: context.textTheme.titleMedium!
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      " (${controller.categories.length})",
                                      style: context.textTheme.titleSmall!
                                          .copyWith(
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                controller.categories.isNotEmpty
                                    ? SizedBox(
                                        height: 18.h,
                                        width: 100.w,
                                        child: ListView.builder(
                                          cacheExtent: 200,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount:
                                              controller.categories.length,
                                          itemBuilder: (context, index) {
                                            final category =
                                                controller.categories[index];
                                            final isSelected =
                                                category.categoryId ==
                                                    controller.selectedCategory
                                                        ?.categoryId;

                                            return Padding(
                                              padding: EdgeInsets.all(1.w),
                                              child: GestureDetector(
                                                onTap: () {
                                                  controller
                                                      .changecategory(category);
                                                  controller
                                                      .getItemsForCategory(
                                                          category);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(2.w),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? AppColors
                                                            .searchBarLight
                                                        : AppColors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      CustomNetworkImage(
                                                        imageUrl: category
                                                            .categoryImage,
                                                        size: 20.w,
                                                        isCircular: true,
                                                        borderWidth: 4.0,
                                                      ),
                                                      SizedBox(
                                                        width: 30.w,
                                                        child: Text(
                                                          category.categoryName,
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: context
                                                              .textTheme
                                                              .titleMedium!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : SizedBox(
                                        width: 100.w,
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          radius: const Radius.circular(12),
                                          child: const Center(
                                            child: Text("No Categories Found"),
                                          ),
                                        ),
                                      ),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    Text(
                                      "Menu Items",
                                      style: context.textTheme.titleMedium!
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      " (${controller.items.length})",
                                      style: context.textTheme.titleSmall!
                                          .copyWith(
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                if (controller.selectedCategory != null)
                                  Row(
                                    children: [
                                      CustomNetworkImage(
                                        imageUrl: controller
                                            .selectedCategory!.categoryImage,
                                        size: 20.w,
                                        isCircular: true,
                                        borderWidth: 4.0,
                                      ),
                                      SizedBox(width: 2.w),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 60.w,
                                            child: Text(
                                              controller.selectedCategory!
                                                  .categoryName,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: context
                                                  .textTheme.titleMedium!
                                                  .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 60.w,
                                            child: ReadMoreText(
                                              controller.selectedCategory!
                                                      .categoryDescription ??
                                                  '',
                                              trimMode: TrimMode.Line,
                                              trimLines: 2,
                                              colorClickableText:
                                                  AppColors.primaryLight,
                                              trimCollapsedText: 'Show more',
                                              trimExpandedText: 'Show less',
                                              moreStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                SizedBox(height: 1.h),
                                controller.items.isNotEmpty
                                    ? GetBuilder<WaiterOrderController>(
                                        init: waiterOrderController,
                                        builder: (ordercontroller) {
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: controller.items.length,
                                            itemBuilder: (context, index) {
                                              final item =
                                                  controller.items[index];
                                              return FoodCardReadWidget(
                                                key: ValueKey(item.foodId),
                                                foodItem: item,
                                                itemCount: ordercontroller
                                                    .totalItemCountForOrder(
                                                        item),
                                                onTap: () {
                                                  Get.to(() =>
                                                      ViewOrderReadView(
                                                          foodItem: item));
                                                },
                                                onAdd: () {
                                                  ordercontroller
                                                      .addOrderItem(item);
                                                },
                                                onRemove: () {
                                                  ordercontroller
                                                      .removeOrderItem(item);
                                                },
                                              );
                                            },
                                          );
                                        },
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/svg/empty.svg",
                                            height: 10.h,
                                            width: 20.w,
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            "No items found",
                                            style: context
                                                .textTheme.titleMedium!
                                                .copyWith(
                                              color: AppColors.primaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                SizedBox(height: 10.h),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 5.h,
            left: 10.w,
            right: 10.w,
            child: Obx(() => CafePrimaryButton(
                  buttonTitle: "Confirm Order",
                  isEnabled: !waiterOrderController.isOrderEmpty.value,
                  onPressed: () {
                    if (waiterOrderController.orderItems.isNotEmpty) {
                      Get.to(() => CheckoutView());
                    } else {
                      CustomSnackBar.showError(
                          'Error', 'Please add items to order', context);
                    }
                  },
                )),
          ),
        ],
      ),
    );
  }
}
