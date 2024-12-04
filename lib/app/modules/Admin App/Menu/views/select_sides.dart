import 'package:cho_nun_btk/app/components/network_image.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/controllers/menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class SelectSidesView extends StatelessWidget {
  const SelectSidesView({super.key});

  @override
  Widget build(BuildContext context) {
    final FoodMenuController controller = Get.find<FoodMenuController>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.back();
        },
        child: const Icon(Icons.check),
      ),
      appBar: AppBar(
        title: Text(
          'Select Sides',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Dropdown
            DropdownButtonFormField<FoodCategory>(
              decoration: InputDecoration(
                labelText: 'Select Side Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: controller.categories.map((category) {
                return DropdownMenuItem<FoodCategory>(
                  value: category,
                  child: Text(category.categoryName),
                );
              }).toList(),
              onChanged: (selectedCategory) {
                if (selectedCategory != null) {
                  controller.changeSideCategory(selectedCategory);
                }
              },
              hint: const Text('Choose a Side Category'),
            ),

            const SizedBox(height: 20),

            GetBuilder<FoodMenuController>(
              init: controller,
              builder: (_) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.sideItems.length,
                  itemBuilder: (context, index) {
                    final foodItem = controller.sideItems[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Food Image
                            CustomNetworkImage(
                              imageUrl: foodItem.foodImage,
                              size: 25.w,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 4.w),

                            // Food Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    foodItem.foodName,
                                    style:
                                        context.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    foodItem.foodDescription,
                                    style: context.textTheme.bodyMedium,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    '${foodItem.nutritionalInfo} kcal | \$${foodItem.foodPrice.toStringAsFixed(2)}',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Checkbox
                            Checkbox(
                              value: controller.selectedSideItems
                                  .contains(foodItem),
                              onChanged: (value) {
                                controller.selectSide(foodItem);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
