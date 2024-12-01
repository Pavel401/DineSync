import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.chevron_left),
          iconSize: 30,
        ),
      ),
      body: Padding(
        padding: AppPading.containerPadding,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 5.h),
              Center(
                child: SvgPicture.asset(
                  authController.selectedUserType == UserType.CHEF
                      ? 'assets/svg/chef.svg'
                      : authController.selectedUserType == UserType.ADMIN
                          ? 'assets/svg/admin.svg'
                          : authController.selectedUserType == UserType.WAITER
                              ? 'assets/svg/waiter.svg'
                              : 'assets/svg/waiter.svg',
                  width: 40.w,
                  height: 20.h,
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              TextFormField(
                // focusNode: _otpFocusNode,
                // enabled: otpSent,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: authController.emailController,
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Please enter valid email';
                  }

                  return null;
                },
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(hintText: 'Email', counterText: ''),
              ),
              TextFormField(
                // focusNode: _otpFocusNode,
                // enabled: otpSent,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: authController.passwordController,
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Please enter valid email';
                  }

                  return null;
                },
                keyboardType: TextInputType.visiblePassword,
                maxLength: 10,
                decoration:
                    InputDecoration(hintText: 'Password', counterText: ''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
