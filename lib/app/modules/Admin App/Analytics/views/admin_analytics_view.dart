import 'package:cho_nun_btk/app/components/empty_widget.dart';
import 'package:cho_nun_btk/app/components/network_image.dart';
import 'package:cho_nun_btk/app/components/shimmers.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Analytics/controller/admin_analytics_controller.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/controllers/menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AdminAnalyticsView extends StatelessWidget {
  final controller = Get.put(AdminAnalyticsController());
  FoodMenuController foodMenuController = Get.put(FoodMenuController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Analytics Dashboard',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   backgroundColor: AppColors.white,
      //   elevation: 0,
      // ),
      // backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overview',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(() => _buildFilterDropdown(context)),
                ],
              ),
              SizedBox(height: 2.h),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 3.w,
                childAspectRatio: 1.5,
                children: [
                  Obx(() => _buildAnalyticsCard(
                        onTap: () => {},
                        context: context,
                        title: "Total Orders",
                        value: controller.totalOrders.value.toString(),
                        icon: Icons.shopping_cart,
                        color: Colors.blue,
                      )),
                  Obx(() => _buildAnalyticsCard(
                        onTap: () => {},
                        context: context,
                        title: "Total Customers",
                        value: controller.totalCustomers.value.toString(),
                        icon: Icons.person,
                        color: Colors.green,
                      )),
                  Obx(() => _buildAnalyticsCard(
                        context: context,
                        onTap: () => {},
                        title: "Cancelled Orders",
                        value: controller.cancelledOrders.value.toString(),
                        icon: Icons.cancel,
                        color: Colors.red,
                      )),
                  Obx(() => _buildAnalyticsCard(
                        context: context,
                        onTap: () => {},
                        title: "Discounted Orders",
                        value:
                            controller.totalDiscountedOrders.value.toString(),
                        icon: Icons.local_offer,
                        color: Colors.orange,
                      )),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'Trending Items',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              _buildTrendingItems(context),
              SizedBox(height: 2.h),
              Text(
                'Trending Categories',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              _buildTrendingCategories(context),
            ],
          ),
        ),
      ),
    );
  }

  Card _buildTrendingItems(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Selling Items',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 24,
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(),
                  child: Row(
                    children: [
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Item',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Text(
                        'Sold',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(width: 2.w),
                    ],
                  ),
                ),

                // List Items
                GetBuilder(builder: (AdminAnalyticsController controller) {
                  return controller.isLoading.value
                      ? ListViewSeparatedSkeleton()
                      : controller.salesData.length > 0
                          ? ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: controller.salesData.length,
                              separatorBuilder: (context, index) =>
                                  Divider(height: 1),
                              itemBuilder: (context, index) {
                                FoodItem item =
                                    controller.salesData.keys.elementAt(index);
                                int value = controller.salesData.values
                                    .elementAt(index);

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 1.h),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 15.w,
                                        height: 15.w,
                                        child: Stack(
                                          children: [
                                            CustomNetworkImage(
                                              imageUrl: item.foodImage,
                                              size: 15.w,
                                              isCircular: true,
                                              borderWidth: 2.0,
                                            ),
                                            if (index <
                                                3) // Show medal for top 3
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: [
                                                      Colors.amber,
                                                      Colors.grey[300],
                                                      Colors.brown[300]
                                                    ][index],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.foodName,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: context
                                                  .textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 3.w,
                                          vertical: 1.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          value.toString(),
                                          style: context.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : EmptyIllustrations(
                              title: "No Data",
                              message: "No data available for this period",
                              width: 40.w,
                            );
                })
              ],
            )
          ],
        ),
      ),
    );
  }

  Card _buildTrendingCategories(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Selling Categories',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 24,
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(),
                  child: Row(
                    children: [
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Category',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Text(
                        'Sold',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(width: 2.w),
                    ],
                  ),
                ),

                // List Items
                GetBuilder(builder: (AdminAnalyticsController controller) {
                  return controller.isLoading.value
                      ? ListViewSeparatedSkeleton()
                      : controller.categorySalesData.length > 0
                          ? ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: controller.categorySalesData.length,
                              separatorBuilder: (context, index) =>
                                  Divider(height: 1),
                              itemBuilder: (context, index) {
                                String item = controller.categorySalesData.keys
                                    .elementAt(index);
                                int value = controller.categorySalesData.values
                                    .elementAt(index);

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 1.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: context
                                                  .textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 3.w,
                                          vertical: 1.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          value.toString(),
                                          style: context.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : EmptyIllustrations(
                              title: "No Data",
                              message: "No data available for this period",
                              width: 40.w,
                            );
                })
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.textTheme.bodySmall?.copyWith(
                            // color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          value,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: controller.selectedFilter.value,
        underline: SizedBox(),
        items: ['Today', 'Yesterday', 'Weekly', 'Monthly', 'Yearly']
            .map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          controller.selectedFilter.value = value!;
          controller.loadAnalytics();
        },
      ),
    );
  }

  Widget _buildMonthYearPicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButton<int>(
              isExpanded: true,
              value: controller.selectedMonth.value,
              underline: SizedBox(),
              items: List.generate(12, (index) => index + 1).map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    DateTime(2024, value)
                        .toString()
                        .split(' ')[0]
                        .split('-')[1],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                controller.selectedMonth.value = value!;
                controller.loadAnalytics();
              },
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButton<int>(
              isExpanded: true,
              value: controller.selectedYear.value,
              underline: SizedBox(),
              items: List.generate(5, (index) => DateTime.now().year - index)
                  .map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                controller.selectedYear.value = value!;
                controller.loadAnalytics();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearPicker(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<int>(
        isExpanded: true,
        value: controller.selectedYear.value,
        underline: SizedBox(),
        items: List.generate(5, (index) => DateTime.now().year - index)
            .map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
        onChanged: (value) {
          controller.selectedYear.value = value!;
          controller.loadAnalytics();
        },
      ),
    );
  }
}
