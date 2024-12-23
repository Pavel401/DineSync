import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Auth/views/sign_in_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 768) {
            // Build UI for tablets or large screens
            return _buildLargeScreenUI(context);
          } else {
            // Build UI for smaller screens
            return _buildSmallScreenUI(context);
          }
        },
      ),
    );
  }

  Widget _buildSmallScreenUI(BuildContext context) {
    return Padding(
      padding: AppPading.containerPadding,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10.h),
            Center(
              child: SvgPicture.asset(
                'assets/svg/dining.svg',
                width: 60.w,
              ),
            ),
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Welcome to",
                    style: context.textTheme.headlineLarge!.copyWith()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Cho Nun BTK",
                  style: context.textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Log in as",
                  style: context.textTheme.bodyLarge!.copyWith(),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            _buildButtonList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeScreenUI(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey[200],
            child: Center(
              child: SvgPicture.asset(
                'assets/svg/dining.svg',
                width: 40.w,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: AppPading.containerPadding,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to",
                    style: context.textTheme.headlineLarge!.copyWith(),
                  ),
                  Text(
                    "Cho Nun BTK",
                    style: context.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Log in as",
                    style: context.textTheme.bodyLarge!.copyWith(),
                  ),
                  SizedBox(height: 5.h),
                  _buildButtonList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonList() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            authController.setUserType(UserType.CHEF);
            Get.to(() => SignInView());
          },
          child: Text("Chef"),
        ),
        SizedBox(height: 2.h),
        ElevatedButton(
          onPressed: () {
            authController.setUserType(UserType.WAITER);
            Get.to(() => SignInView());
          },
          child: Text("Waiter"),
        ),
        SizedBox(height: 2.h),
        ElevatedButton(
          onPressed: () {
            authController.setUserType(UserType.ADMIN);
            Get.to(() => SignInView());
          },
          child: Text("Admin"),
        ),
      ],
    );
  }
}
