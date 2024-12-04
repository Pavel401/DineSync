import 'package:cho_nun_btk/app/components/network_image.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class FoodCard extends StatefulWidget {
  final FoodItem foodItem;
  final int index;
  final void Function() onDelete;
  const FoodCard(
      {super.key,
      required this.foodItem,
      required this.index,
      required this.onDelete});

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Food Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomNetworkImage(
                imageUrl: widget.foodItem.foodImage,
                size: 25.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 4.w),

            // Food Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name with Vegan Mark
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.foodItem.foodName,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.foodItem.isVegan) ...[
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.eco_rounded,
                          color: Colors.green,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 1.h),

                  // Food Description
                  Text(
                    widget.foodItem.foodDescription,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),

                  // Price and Nutritional Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nutritional Info
                      Row(
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              color: Colors.orange, size: 16),
                          SizedBox(width: 1.w),
                          Text(
                            '${widget.foodItem.nutritionalInfo} kcal',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade400),
                        ),
                        child: Text(
                          '₱${widget.foodItem.foodPrice.toStringAsFixed(2)}',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
