import 'package:cached_network_image/cached_network_image.dart';
import 'package:cho_nun_btk/app/components/allergen_chip.dart';
import 'package:cho_nun_btk/app/components/photo_view.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class ViewOrderReadView extends StatefulWidget {
  final FoodItem foodItem;

  ViewOrderReadView({super.key, required this.foodItem});

  @override
  State<ViewOrderReadView> createState() => _ViewOrderReadViewState();
}

class _ViewOrderReadViewState extends State<ViewOrderReadView> {
  @override
  Widget build(BuildContext context) {
    final food = widget.foodItem;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          food.foodName,
          style: TextStyle(color: AppColors.onPrimaryLight),
        ),
        backgroundColor: AppColors.primaryLight,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.chevron_left, color: AppColors.onPrimaryLight),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Hero(
              tag: food.foodId,
              child: GestureDetector(
                onTap: () {
                  Get.to(PhotoViewScreen(
                    imageUrl: food.foodImage,
                    heroId: food.foodId,
                  ));
                },
                child: CachedNetworkImage(
                  imageUrl: food.foodImage,
                  fit: BoxFit.cover,
                  height: 30.h,
                  width: double.infinity,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.red),
                  ),
                ),
              ),
            ),
            // Food Details
            Padding(
              padding: AppPading.containerPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  Text(
                    food.foodName,
                    style: context.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Dietary Icons
                  Row(
                    children: [
                      if (food.isVegan)
                        _buildDietaryChip('Vegan', Colors.green),
                      if (food.isLactoseFree)
                        _buildDietaryChip('Lactose Free', Colors.orange),
                      if (food.containsEgg)
                        _buildDietaryChip('Contains Egg', Colors.yellow[800]!),
                      if (food.isGlutenFree)
                        _buildDietaryChip('Gluten Free', Colors.blue),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  Text(
                    food.foodDescription,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Price: \$${food.foodPrice.toStringAsFixed(2)}',
                  //       style: TextStyle(
                  //         fontSize: 16.sp,
                  //         fontWeight: FontWeight.w600,
                  //         color: Colors.black87,
                  //       ),
                  //     ),
                  //     if (food.discount != null)
                  //       Text(
                  //         'Discount: ${food.discount!.toStringAsFixed(1)}%',
                  //         style: TextStyle(
                  //           fontSize: 14.sp,
                  //           fontWeight: FontWeight.w500,
                  //           color: Colors.redAccent,
                  //         ),
                  //       ),
                  //   ],
                  // ),

                  SizedBox(height: 2.h),
                  Divider(),
                  SizedBox(height: 2.h),

                  // Allergen Chips
                  Wrap(
                    spacing: 1.h,
                    runSpacing: 2.w,
                    children: food.allergies
                        .map((allergen) => AllergenChip(
                              allergen: allergen,
                              isSelected: true, // Static for view-only mode
                              onSelected: (_) {}, // No-op for view mode
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 2.h),
                  // Nutritional Info
                  if (food.nutritionalInfo > 0)
                    Text(
                      'Nutritional Info: ${food.nutritionalInfo} kcal',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                  SizedBox(height: 3.h),
                  // Recommendations Section
                  if (food.recommendations.isNotEmpty)
                    _buildRecommendationSection(food.recommendations),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildRecommendationSection(List<FoodItem> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Dishes',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 20.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => SizedBox(width: 2.w),
            itemBuilder: (_, index) {
              final food = recommendations[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to another view if needed
                },
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: food.foodImage,
                        height: 15.h,
                        width: 30.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      food.foodName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
