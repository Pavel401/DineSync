import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class ChefHomeView extends StatefulWidget {
  const ChefHomeView({super.key});

  @override
  State<ChefHomeView> createState() => _ChefHomeViewState();
}

class _ChefHomeViewState extends State<ChefHomeView> {
  AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: () {
                authController.signOut();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centers the children horizontally
                children: [
                  Text(
                    "Logout Chef",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge, // Use a valid text style
                  ),
                  const SizedBox(width: 8), // Adds space between text and icon
                  const Icon(Icons.logout),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
