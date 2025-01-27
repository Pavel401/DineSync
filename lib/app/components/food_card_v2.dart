import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'network_image.dart';

class FoodCardReadWidget extends StatefulWidget {
  final FoodItem foodItem;
  final int itemCount;
  final void Function() onAdd;
  final void Function() onRemove;
  final void Function() onTap;

  const FoodCardReadWidget({
    super.key,
    required this.foodItem,
    required this.itemCount,
    required this.onAdd,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<FoodCardReadWidget> createState() => _FoodCardReadWidgetState();
}

class _FoodCardReadWidgetState extends State<FoodCardReadWidget> {
  int _quantity = 0;

  @override
  void initState() {
    // TODO: implement initState
    _quantity = widget.itemCount;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        margin: EdgeInsets.only(top: 2.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineLight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Food Image
              Hero(
                tag: widget.foodItem.foodId,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomNetworkImage(
                    imageUrl: widget.foodItem.foodImage,
                    size: 25.w,
                    fit: BoxFit.cover,
                  ),
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

                    // Price, Nutritional Info, and Add/Remove Buttons
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

                        // Add/Remove Buttons
                        widget.foodItem.isAvailable
                            ? Row(
                                children: [
                                  // Remove Button
                                  IconButton(
                                    onPressed: widget.onRemove,
                                    icon: Icon(Icons.remove_circle_outline),
                                    color: _quantity > 0
                                        ? Colors.red
                                        : Colors.grey,
                                  ),

                                  // Quantity
                                  Text(
                                    widget.itemCount.toString(),
                                    style:
                                        context.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),

                                  // Add Button
                                  IconButton(
                                    onPressed: widget.onAdd,
                                    icon: Icon(Icons.add_circle_outline),
                                    color: Colors.green,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(Icons.block),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'Not Available',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
