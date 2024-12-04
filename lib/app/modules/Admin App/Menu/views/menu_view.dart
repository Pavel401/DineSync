import 'package:cho_nun_btk/app/components/food_card.dart';
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
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';

class MenuView extends StatefulWidget {
  MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  FoodMenuController menuController = Get.put(FoodMenuController());

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
        // appBar: AppBar(
        //   centerTitle: false,
        //   title: Text(
        //     "Manage Menu",
        //     style: context.textTheme.titleLarge!.copyWith(
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        // ),
        body: Padding(
            padding: AppPading.containerPadding,
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

                  return GetBuilder(builder: (FoodMenuController controller) {
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
                                  height: 22.h,
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
                                                  SizedBox(
                                                    width: 30.w,
                                                    child: Text(
                                                      menuController
                                                          .categories[index]
                                                          .categoryName,
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: context.textTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  // Row(
                                                  //   children: [
                                                  //     Text("Edit"),
                                                  //     Icon(Icons.edit)
                                                  //   ],
                                                  // )

                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: AppColors
                                                            .primaryLight,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12)),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        Get.to(
                                                                () =>
                                                                    AddCategory(
                                                                      category:
                                                                          menuController
                                                                              .categories[index],
                                                                    ))!
                                                            .then((value) {
                                                          menuController
                                                              .getAllCategories();
                                                        });
                                                      },
                                                      icon: Icon(
                                                        Icons.edit_outlined,
                                                        color: AppColors
                                                            .primaryDark,
                                                      ),
                                                    ),
                                                  )
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
                              Text(
                                "(${menuController.items.length.toString()})",
                                style: context.textTheme.titleSmall!.copyWith(
                                  color: AppColors.primaryLight,
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
                                                .selectedCategory.categoryName,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
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
                                            menuController.selectedCategory
                                                .categoryDescription!,
                                            trimMode: TrimMode.Line,
                                            trimLines: 2,
                                            colorClickableText:
                                                AppColors.primaryLight,
                                            trimCollapsedText: 'Show more',
                                            trimExpandedText: 'Show less',
                                            moreStyle: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
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
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: controller.items.length,
                                  physics: NeverScrollableScrollPhysics(),
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
                                      child: FoodCard(
                                        foodItem: controller.items[index],
                                        index: index,
                                        onDelete: () {},
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
