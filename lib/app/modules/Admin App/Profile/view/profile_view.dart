import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/constants/paddings.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:cho_nun_btk/app/models/auth/authmodels.dart';
import 'package:cho_nun_btk/app/modules/Common/common_password_reset.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AdminProfileView extends StatefulWidget {
  final UserModel userModel;

  AdminProfileView({super.key, required this.userModel});

  @override
  State<AdminProfileView> createState() => _AdminProfileViewState();
}

class _AdminProfileViewState extends State<AdminProfileView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isBlocked = false;
  UserType userType = UserType.ADMIN;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.userModel != null) {
      nameController.text = widget.userModel.name;
      emailController.text = widget.userModel.email;
      phoneController.text = widget.userModel.phone;
      addressController.text = widget.userModel.address;
      userType = widget.userModel.userType;
      isBlocked = widget.userModel.blocked;
      passwordController.text = widget.userModel.password;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(color: AppColors.onPrimaryLight),
        ),
        backgroundColor: AppColors.primaryLight,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.chevron_left,
            color: AppColors.onPrimaryLight,
          ),
          iconSize: 30,
        ),
      ),
      body: Padding(
        padding: AppPading.containerPadding,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 2.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (widget.userModel.photoUrl.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    widget.userModel.photoUrl)
                                : null),
                        child: _selectedImage == null &&
                                widget.userModel.photoUrl.isEmpty
                            ? Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            _pickImage();
                          },
                          child: CircleAvatar(
                            radius: 12.sp,
                            backgroundColor: themeProvider.isDarkMode
                                ? AppColors.searchBarDark
                                : AppColors.searchBarLight,
                            child: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: themeProvider.isDarkMode
                                  ? AppColors.primaryDark
                                  : AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 2.h,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade400),
                ),
                child: Text(
                  userType == UserType.WAITER
                      ? 'Waiter'
                      : userType == UserType.CHEF
                          ? 'Chef'
                          : 'Admin',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                controller: nameController,
                maxLength: 40,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                controller: emailController,
                maxLength: 40,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                maxLength: 12,
                readOnly: true,
                decoration: InputDecoration(
                  suffix: GestureDetector(
                      onTap: () {
                        Get.to(() => CommonPasswordResetView());
                      },
                      child: Icon(Icons.edit_outlined)),
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }

                  return null;
                },
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                controller: phoneController,
                maxLength: 12,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }

                  return null;
                },
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                controller: addressController,
                maxLength: 200,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }

                  return null;
                },
              ),
              SizedBox(
                height: 2.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
