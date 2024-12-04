import 'package:cho_nun_btk/app/components/network_image.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/controllers/menu_controller.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/views/add_category.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/views/add_item.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class MenuView extends StatelessWidget {
  MenuView({super.key});

  FoodMenuController menuController = Get.put(FoodMenuController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            "Manage Menu",
            style: context.textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
            padding: AppPading.containerPadding,
            child: FutureBuilder(
                future: menuController.getAllCategories(),
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

                  return GetBuilder(builder: (FoodMenuController controller) {
                    return SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
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
                                style: context.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "(${menuController.categories.length.toString()})",
                                style: context.textTheme.titleSmall!.copyWith(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              Expanded(child: SizedBox()),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => AddCategory());
                                },
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: Radius.circular(12),
                                  padding: EdgeInsets.all(6),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add),
                                      Text("Add Category"),
                                    ],
                                  ),
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
                                      itemCount:
                                          menuController.categories.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.all(1.w),
                                          child: GestureDetector(
                                            onTap: () {
                                              menuController.changecategory(
                                                  menuController
                                                      .categories[index]);

                                              menuController
                                                  .getItemsForCategory(
                                                      menuController
                                                          .selectedCategory!);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(2.w),
                                              decoration: BoxDecoration(
                                                color: menuController
                                                            .categories[index]
                                                            .categoryId ==
                                                        menuController
                                                            .selectedCategory!
                                                            .categoryId
                                                    ? AppColors.searchBarLight
                                                    : AppColors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                children: [
                                                  CustomNetworkImage(
                                                    imageUrl: menuController
                                                        .categories[index]
                                                        .categoryImage,
                                                    size: 100.0,
                                                    isCircular: true,
                                                    borderWidth: 4.0,
                                                  ),
                                                  Text(
                                                    menuController
                                                        .categories[index]
                                                        .categoryName,
                                                    style: context
                                                        .textTheme.titleMedium!
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
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
                                        child: Text("No Categories Found")),
                                  ),
                                ),

                          SizedBox(
                            height: 2.h,
                          ),
                          Row(
                            children: [
                              Text(
                                "Menu Items",
                                style: context.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(child: SizedBox()),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => AddMenuItem())!.then((value) {
                                    menuController.getItemsForCategory(
                                        menuController.selectedCategory!);
                                  });
                                },
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: Radius.circular(12),
                                  padding: EdgeInsets.all(6),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add),
                                      Text("Add Item"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 1.h,
                          ),

                          menuController.items.length > 0
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: controller.items.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Get.to(() => AddMenuItem(
                                                  item: controller.items[index],
                                                ))!
                                            .then((value) {
                                          controller.getItemsForCategory(
                                              controller.selectedCategory!);
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(2.w),
                                        decoration: BoxDecoration(
                                          color: AppColors.searchBarLight,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  controller
                                                      .items[index].foodName,
                                                  style: context
                                                      .textTheme.titleMedium!
                                                      .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
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
                                        style: context.textTheme.titleMedium!
                                            .copyWith(
                                          color: AppColors.primaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                        ],
                      ),
                    );
                  });
                })));
  }
}
