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
              Card(
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
                      // Obx(
                      //   () => FutureBuilder(
                      //     future: foodMenuController
                      //         .getItemsForCategory(controller.itemSalesData),
                      //     builder: (context, snapshot) {
                      //       if (snapshot.connectionState ==
                      //           ConnectionState.waiting) {
                      //         return Center(
                      //           child: CircularProgressIndicator(),
                      //         );
                      //       }
                      //       if (snapshot.hasData) {
                      //         Map<FoodItem, int> items =
                      //             snapshot.data as Map<FoodItem, int>;
                      //         return Column(
                      //           children: items.entries
                      //               .map(
                      //                 (e) => ListTile(
                      //                   title: Text(e.key.foodName),
                      //                   subtitle: Text(
                      //                       'Quantity: ${e.value} | Revenue: \$${e.key.foodPrice * e.value}'),
                      //                 ),
                      //               )
                      //               .toList(),
                      //         );
                      //       }
                      //       return Container();
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
