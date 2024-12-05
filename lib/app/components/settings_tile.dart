import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CafeMoreTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Function()? onTap;
  final bool showRightArrow;
  const CafeMoreTileWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showRightArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Bounceable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: themeProvider.isDarkMode
              ? AppColors.searchBarDark
              : AppColors.searchBarLight,
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    height: 5.h,
                    width: 5.h,
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeProvider.isDarkMode
                          ? AppColors.tertiaryDark
                          : AppColors.tertiaryLight,
                    ),
                    child: Icon(
                      icon,
                      color: themeProvider.isDarkMode
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleMedium!.copyWith(),
                      ),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall!.copyWith(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showRightArrow)
              Icon(
                Icons.chevron_right_outlined,
                color: themeProvider.isDarkMode
                    ? AppColors.primaryDark
                    : AppColors.primaryLight,
              ),
          ],
        ),
      ),
    );
  }
}
