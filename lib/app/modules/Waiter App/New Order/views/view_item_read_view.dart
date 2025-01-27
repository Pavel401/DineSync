import 'package:cached_network_image/cached_network_image.dart';
import 'package:cho_nun_btk/app/components/allergen_chip.dart';
import 'package:cho_nun_btk/app/components/photo_view.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/controller/new_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class ViewOrderReadView extends StatefulWidget {
  final FoodItem foodItem;

  const ViewOrderReadView({Key? key, required this.foodItem}) : super(key: key);

  @override
  State<ViewOrderReadView> createState() => _ViewOrderReadViewState();
}

class _ViewOrderReadViewState extends State<ViewOrderReadView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Color? _dominantColor;
  final PageController _imageController = PageController();

  WaiterOrderController waiterOrderController =
      Get.find<WaiterOrderController>();
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.foodItem;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with Dynamic Color
          SliverAppBar(
            expandedHeight: 35.h,
            pinned: true,
            // backgroundColor: _dominantColor?.withOpacity(0.8) ??
            //     theme.appBarTheme.backgroundColor,
            leading: IconButton(
              icon: CircleAvatar(
                backgroundColor: AppColors.searchBarLight,
                child: Icon(
                  Icons.chevron_left,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: food.foodId,
                    child: GestureDetector(
                      onTap: () => Get.to(() => PhotoViewScreen(
                            imageUrl: food.foodImage,
                            heroId: food.foodId,
                          )),
                      child: CachedNetworkImage(
                        imageUrl: food.foodImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child:
                              const Icon(Icons.broken_image, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SliverPadding(
            padding: AppPading.containerPadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Dietary and Nutritional Info
                FadeTransition(
                  opacity: _animationController,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2.h),
                            GetBuilder(
                              init: waiterOrderController,
                              builder: (_) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 3.w, vertical: 1.5.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                        color: AppColors.primaryLight
                                            .withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Food item name
                                      Expanded(
                                        child: Text(
                                          widget.foodItem.foodName,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      // Decrease button
                                      GestureDetector(
                                        onTap: () {
                                          waiterOrderController
                                              .removeOrderItem(widget.foodItem);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            color: AppColors.primaryLight,
                                            size: 18.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      // Quantity display
                                      Text(
                                        '${waiterOrderController.orderItems[widget.foodItem] ?? 0}',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      // Increase button
                                      GestureDetector(
                                        onTap: () {
                                          waiterOrderController
                                              .addOrderItem(widget.foodItem);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: AppColors.primaryLight,
                                            size: 18.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 2.h),

                            // Spice Level, Nutritional Info, Availability

                            // Dietary Icons
                            Row(
                              children: [
                                if (food.isVegan)
                                  _buildDietaryChip('Vegan', Colors.green),
                                if (food.isLactoseFree)
                                  _buildDietaryChip(
                                      'Lactose Free', Colors.orange),
                                if (food.containsEgg)
                                  _buildDietaryChip(
                                      'Contains Egg', Colors.yellow[800]!),
                                if (food.isGlutenFree)
                                  _buildDietaryChip('Gluten Free', Colors.blue),
                              ],
                            ),
                            SizedBox(height: 2.h),

                            // Food Description
                            Text(
                              food.foodDescription,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Divider(),
                            SizedBox(height: 2.h),

                            // Allergen Chips

                            _buildFoodInfoSection(food),

                            SizedBox(height: 2.h),
                            Wrap(
                              spacing: 1.h,
                              runSpacing: 2.w,
                              children: food.allergies
                                  .map((allergen) => AllergenChip(
                                        allergen: allergen,
                                        isSelected:
                                            true, // Static for view-only mode
                                        onSelected:
                                            (_) {}, // No-op for view mode
                                      ))
                                  .toList(),
                            ),
                            SizedBox(height: 2.h),

                            // Recommendations Section
                          ],
                        ),
                      ]),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryChip(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 1.w),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFoodInfoSection(FoodItem food) {
    return Column(
      children: [
        // Spice Level UI
        Row(
          children: [
            Text(
              'Spice Level:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 2.w),
            Row(
              children: List.generate(
                food.spiceLevel,
                (index) => Icon(
                  Icons.local_fire_department,
                  color: Colors.redAccent,
                  size: 18.sp,
                ),
              ),
            ),
            if (food.spiceLevel < 5)
              Row(
                children: List.generate(
                  5 - food.spiceLevel,
                  (index) => Icon(
                    Icons.local_fire_department,
                    color: Colors.grey[300],
                    size: 18.sp,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 1.5.h),

        // Nutritional Info UI
        if (food.nutritionalInfo > 0)
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: Colors.green,
                size: 20.sp,
              ),
              SizedBox(width: 1.w),
              Text(
                '${food.nutritionalInfo.toStringAsFixed(0)} kcal',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        SizedBox(height: 1.5.h),

        // Availability UI
        Row(
          children: [
            Icon(
              food.isAvailable ? Icons.check_circle : Icons.cancel,
              color: food.isAvailable ? Colors.green : Colors.redAccent,
              size: 20.sp,
            ),
            SizedBox(width: 1.w),
            Text(
              food.isAvailable ? 'Available' : 'Not Available',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: food.isAvailable ? Colors.green : Colors.redAccent,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}
