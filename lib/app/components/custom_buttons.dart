import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CafePrimaryButton extends StatelessWidget {
  final double? width;
  final double? height;
  final String buttonTitle;
  final Function()? onPressed;
  final bool isEnabled;

  CafePrimaryButton({
    required this.buttonTitle,
    required this.onPressed,
    this.width,
    this.height,
    this.isEnabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? AppColors.primaryLight : Colors.black38,
      ),
      child: Container(
        width: width ?? 80.w,
        height: height ?? 5.h,
        child: Center(
          child: Text(
            buttonTitle,
            style: TextStyle(
              color: isEnabled ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class CafeSecondaryButton extends StatelessWidget {
  final double? width;
  final double? height;
  final String buttonTitle;
  final Function()? onPressed;
  final bool isEnabled;

  const CafeSecondaryButton({
    required this.buttonTitle,
    required this.onPressed,
    this.width,
    this.height,
    this.isEnabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isEnabled ? AppColors.primaryLight : Colors.grey,
        ),
      ),
      child: Container(
        width: width ?? 80.w,
        height: height ?? 5.h,
        child: Center(
          child: Text(
            buttonTitle,
            style: TextStyle(
              color: isEnabled ? AppColors.primaryLight : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class TurfActionButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData icon;
  final bool isEnabled;

  const TurfActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        padding: EdgeInsets.all(1.h),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 2,
            color: isEnabled
                ? (themeProvider.isDarkMode
                    ? AppColors.primaryDark
                    : AppColors.surfaceLight)
                : Colors.grey,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 30,
            color: isEnabled
                ? (themeProvider.isDarkMode
                    ? AppColors.primaryDark
                    : AppColors.secondaryLight)
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class TurfPaymentButton extends StatelessWidget {
  final double totalAmount;
  final void Function() onPressed;
  final bool isDisabled;

  const TurfPaymentButton({
    super.key,
    required this.totalAmount,
    required this.onPressed,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 8.h,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDisabled ? theme.disabledColor : theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 2.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                      color: isDisabled
                          ? Colors.grey
                          : theme.colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    "₹$totalAmount",
                    style: TextStyle(
                      color: isDisabled
                          ? Colors.grey
                          : theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                "Continue",
                style: TextStyle(
                  color: isDisabled ? Colors.grey : theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
