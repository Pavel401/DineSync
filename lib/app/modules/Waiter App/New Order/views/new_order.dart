import 'package:cho_nun_btk/app/components/custom_buttons.dart';
import 'package:cho_nun_btk/app/components/food_card_v2.dart';
import 'package:cho_nun_btk/app/components/network_image.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/controllers/menu_controller.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/controller/new_order_controller.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/views/view_item_read_view.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';

class AddNewOrderView extends StatefulWidget {
  AddNewOrderView({super.key});

  @override
  State<AddNewOrderView> createState() => _AddNewOrderViewState();
}

class _AddNewOrderViewState extends State<AddNewOrderView> {
  FoodMenuController menuController = Get.put(FoodMenuController());

  WaiterOrderController waiterOrderController =
      Get.put(WaiterOrderController());

  late Future<List<FoodCategory>> getCategories;

  @override
  void initState() {
    super.initState();
    getCategories = getAllCategories();
  }

  Future<List<FoodCategory>> getAllCategories() async {
    return await menuController.getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Order",
          style: TextStyle(color: AppColors.onPrimaryLight),
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
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: AppPading.containerPadding,
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder(
                    future: getCategories,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      menuController.categories =
                          snapshot.data as RxList<FoodCategory>;

                      return GetBuilder(
                        builder: (FoodMenuController controller) {
                          return SingleChildScrollView(
                            // physics: NeverScrollableScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Center(
                                //   child: SvgPicture.asset(
                                //     'assets/svg/empty.svg',
                                //     height: 20.h,
                                //     width: 50.w,
                                //   ),
                                // ),

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
                                      "(${menuController.categories.length.toString()})",
                                      style: context.textTheme.titleSmall!
                                          .copyWith(
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 1.h,
                                ),
                                menuController.categories.length > 0
                                    ? SizedBox(
                                        height: 18.h,
                                        width: 100.w,
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: menuController
                                                .categories.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: EdgeInsets.all(1.w),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    menuController
                                                        .changecategory(
                                                            menuController
                                                                    .categories[
                                                                index]);

                                                    menuController
                                                        .getItemsForCategory(
                                                            menuController
                                                                .selectedCategory!);
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.all(2.w),
                                                    decoration: BoxDecoration(
                                                      color: menuController
                                                                  .categories[
                                                                      index]
                                                                  .categoryId ==
                                                              menuController
                                                                  .selectedCategory!
                                                                  .categoryId
                                                          ? AppColors
                                                              .searchBarLight
                                                          : AppColors
                                                              .transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        CustomNetworkImage(
                                                          imageUrl:
                                                              menuController
                                                                  .categories[
                                                                      index]
                                                                  .categoryImage,
                                                          size: 20.w,
                                                          isCircular: true,
                                                          borderWidth: 4.0,
                                                        ),
                                                        SizedBox(
                                                          width: 30.w,
                                                          child: Text(
                                                            menuController
                                                                .categories[
                                                                    index]
                                                                .categoryName,
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: context
                                                                .textTheme
                                                                .titleMedium!
                                                                .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        // Row(
                                                        //   children: [
                                                        //     Text("Edit"),
                                                        //     Icon(Icons.edit)
                                                        //   ],
                                                        // )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                      )
                                    : Container(
                                        width: 100.w,
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          child: Center(
                                              child:
                                                  Text("No Categories Found")),
                                        ),
                                      ),

                                SizedBox(
                                  height: 2.h,
                                ),
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
                                      "(${menuController.items.length.toString()})",
                                      style: context.textTheme.titleSmall!
                                          .copyWith(
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 1.h,
                                ),
                                menuController.selectedCategory != null
                                    ? Row(
                                        children: [
                                          CustomNetworkImage(
                                            imageUrl: menuController
                                                .selectedCategory.categoryImage,
                                            size: 20.w,
                                            isCircular: true,
                                            borderWidth: 4.0,
                                          ),
                                          SizedBox(
                                            width: 2.w,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 60.w,
                                                child: Text(
                                                  menuController
                                                      .selectedCategory
                                                      .categoryName,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: context
                                                      .textTheme.titleMedium!
                                                      .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 60.w,
                                                child: ReadMoreText(
                                                  menuController
                                                      .selectedCategory
                                                      .categoryDescription!,
                                                  trimMode: TrimMode.Line,
                                                  trimLines: 2,
                                                  colorClickableText:
                                                      AppColors.primaryLight,
                                                  trimCollapsedText:
                                                      'Show more',
                                                  trimExpandedText: 'Show less',
                                                  moreStyle: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      )
                                    : SizedBox(),

                                // SizedBox(
                                //   height: 1.h,
                                // ),
                                // DottedLine(
                                //   direction: Axis.horizontal,
                                //   alignment: WrapAlignment.center,
                                //   lineLength: double.infinity,
                                //   lineThickness: 1.0,
                                //   dashLength: 4.0,
                                //   dashColor: Colors.black,
                                //   dashRadius: 0.0,
                                //   dashGapLength: 4.0,
                                //   dashGapColor: Colors.transparent,
                                //   dashGapRadius: 0.0,
                                // ),

                                SizedBox(
                                  height: 1.h,
                                ),
                                menuController.items.length > 0
                                    ? GetBuilder(
                                        init: waiterOrderController,
                                        builder: (WaiterOrderController
                                            ordercontroller) {
                                          return ListView.builder(
                                              shrinkWrap: true,
                                              itemCount:
                                                  controller.items.length,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return FoodCardReadWidget(
                                                  onTap: () {
                                                    Get.to(
                                                      () => ViewOrderReadView(
                                                          foodItem: controller
                                                              .items[index]),
                                                    );
                                                  },
                                                  foodItem:
                                                      controller.items[index],
                                                  itemCount: ordercontroller
                                                      .totalItemCountForOrder(
                                                          controller
                                                              .items[index]),
                                                  onRemove: () {
                                                    ordercontroller
                                                        .removeOrderItem(
                                                            controller
                                                                .items[index]);
                                                  },
                                                  onAdd: () {
                                                    ordercontroller
                                                        .addOrderItem(controller
                                                            .items[index]);
                                                  },
                                                );
                                              });
                                        })
                                    : Center(
                                        // Ensures the entire content is centered
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center, // Center vertically
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center, // Center horizontally

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
                                      ),

                                SizedBox(
                                  height: 10.h,
                                )
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
                    onPressed: () {},
                  ))),
        ],
      ),
    );
  }
}
