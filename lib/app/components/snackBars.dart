import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class CustomSnackBar {
  static showSuccess(String title, String message, BuildContext context) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      primaryColor: AppColors.primaryLight,
      title: Text(title),
      description: Text(message),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: Duration(seconds: 2),
      borderRadius: BorderRadius.circular(12.0),
    );
  }

  static showError(String title, String message, BuildContext context) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      primaryColor: AppColors.primaryLight,
      title: Text(title),
      description: Text(message),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 2),
      borderRadius: BorderRadius.circular(12.0),
    );
  }
}
