import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  UserType selectedUserType = UserType.NONE;

  void setUserType(UserType type) {
    selectedUserType = type;
    update();
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
}

enum UserType { CHEF, ADMIN, WAITER, NONE }
