import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/utils.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AllergenChip extends StatelessWidget {
  AllergenChip({
    super.key,
    required this.allergen,
    required this.isSelected,
    required this.onSelected,
  });
  final bool isSelected;

  final Allergens allergen;
  final Function(bool) onSelected;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Color selectedChipColor = themeProvider.isDarkMode
        ? AppColors.primaryDark
        : AppColors.primaryLight;

    Color unselectedChipColor = Colors.transparent;

    Color enabledBorderColor = themeProvider.isDarkMode
        ? AppColors.secondaryDark
        : AppColors.secondaryLight;

    Color enabledTextColor = themeProvider.isDarkMode
        ? isSelected
            ? AppColors.onPrimaryDark
            : AppColors.primaryDark
        : isSelected
            ? AppColors.onPrimaryLight
            : AppColors.primaryLight;

    Color disabledBorderNTextColor = themeProvider.isDarkMode
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    return GestureDetector(
      onTap: () {
        onSelected(!isSelected);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? selectedChipColor : unselectedChipColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabledBorderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              allergen.allergenImage,
              color: isSelected ? enabledTextColor : disabledBorderNTextColor,
              width: 4.w,
              height: 2.h,
            ),
            SizedBox(width: 1.w),
            Text(
              allergen.allergenName,
              style: context.textTheme.labelMedium!.copyWith(
                color: isSelected ? enabledTextColor : disabledBorderNTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
