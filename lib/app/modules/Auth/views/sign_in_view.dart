import 'package:cho_nun_btk/app/components/custom_buttons.dart';
import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/models/auth/authmodels.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Home/views/home_view.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Chef%20App/Home/views/chef_home.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/Home/views/waiter_view.dart';
import 'package:cho_nun_btk/app/utils/validators.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find<AuthController>();
    final isLargeScreen = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.chevron_left),
          iconSize: 30,
        ),
        title: Text(
          'Sign In',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: AppPading.containerPadding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isLargeScreen ? 600 : double.infinity,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: isLargeScreen ? 8.h : 5.h),

                    // User Type Icon
                    Center(
                      child: SvgPicture.asset(
                        authController.selectedUserType == UserType.CHEF
                            ? 'assets/svg/chef.svg'
                            : authController.selectedUserType == UserType.ADMIN
                                ? 'assets/svg/admin.svg'
                                : 'assets/svg/waiter.svg',
                        width: isLargeScreen ? 30.w : 40.w,
                        height: isLargeScreen ? 15.h : 20.h,
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 8.h : 5.h),

                    // Email Field
                    TextFormField(
                      controller: authController.emailController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => Validator.validateEmail(value!),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 3.h : 2.h),

                    // Password Field
                    TextFormField(
                      controller: authController.passwordController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: !_isPasswordVisible,
                      validator: (value) => Validator.validatePassword(value!),
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 4.h : 3.h),

                    // Login Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CafePrimaryButton(
                          width: isLargeScreen ? 25.w : 20.w,
                          buttonTitle: "Login",
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Logging in...'),
                                ),
                              );

                              UserModel user = UserModel(
                                uid: '',
                                email: authController.emailController.text,
                                name: '',
                                photoUrl: '',
                                phone: '',
                                address: '',
                                userType: authController.selectedUserType,
                                password:
                                    authController.passwordController.text,
                                blocked: false,
                                joinedOn: DateTime.now(),
                                lastLogin: DateTime.now(),
                                fcmToken: '',
                              );

                              QueryStatus status = await authController.signIn(
                                user.email,
                                user.password,
                                context,
                              );

                              if (status == QueryStatus.SUCCESS) {
                                Widget view = Container();
                                debugPrint('User Signed In');

                                await authController.loadUserModel();

                                if (authController.firebaseUser != null &&
                                    authController.userModel != null) {
                                  if (authController.userModel!.userType ==
                                      UserType.ADMIN) {
                                    view = AdminHomeView();
                                  } else if (authController
                                          .userModel!.userType ==
                                      UserType.CHEF) {
                                    view = ChefHomeView();
                                  } else if (authController
                                          .userModel!.userType ==
                                      UserType.WAITER) {
                                    view = WaiterHomeView();
                                  }
                                }

                                Get.offAll(view);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fix the errors'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                        CafePrimaryButton(
                          buttonTitle: "SignUp",
                          width: isLargeScreen ? 25.w : 20.w,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Signing up...'),
                                ),
                              );

                              UserModel user = UserModel(
                                uid: '',
                                email: authController.emailController.text,
                                name: '',
                                photoUrl: '',
                                phone: '',
                                address: '',
                                userType: authController.selectedUserType,
                                password:
                                    authController.passwordController.text,
                                blocked: false,
                                joinedOn: DateTime.now(),
                                lastLogin: DateTime.now(),
                                fcmToken: '',
                              );

                              QueryStatus status = await authController.signUp(
                                context: context,
                                email: user.email,
                                password: user.password,
                                name: user.name,
                                phone: user.phone,
                                address: user.address,
                              );

                              if (status == QueryStatus.SUCCESS) {
                                Widget view = Container();
                                debugPrint('User Signed Up');

                                await authController.loadUserModel();

                                if (authController.firebaseUser != null &&
                                    authController.userModel != null) {
                                  if (authController.userModel!.userType ==
                                      UserType.ADMIN) {
                                    view = AdminHomeView();
                                  } else if (authController
                                          .userModel!.userType ==
                                      UserType.CHEF) {
                                    view = ChefHomeView();
                                  } else if (authController
                                          .userModel!.userType ==
                                      UserType.WAITER) {
                                    view = WaiterHomeView();
                                  }
                                }

                                Get.offAll(view);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fix the errors'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: isLargeScreen ? 3.h : 2.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
