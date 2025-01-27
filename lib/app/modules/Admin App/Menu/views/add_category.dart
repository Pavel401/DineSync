import 'dart:io';

import 'package:cho_nun_btk/app/components/custom_buttons.dart';
import 'package:cho_nun_btk/app/components/network_image.dart';
import 'package:cho_nun_btk/app/components/snackBars.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/controllers/menu_controller.dart';
import 'package:cho_nun_btk/app/provider/firebase_imageProvider.dart';
import 'package:cho_nun_btk/app/provider/menuProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AddCategory extends StatefulWidget {
  FoodCategory? category;
  AddCategory({super.key, this.category});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool noNeedToSendToKitchen = false;

  final FoodMenuController _controller = Get.find<FoodMenuController>();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      CustomSnackBar.showError(
          'Error', 'Please fill all fields and select an image', context);
      return;
    }

    // Show loading indicator
    EasyLoading.show(status: 'Uploading image...');
    FirebaseImageprovider _firebaseImageprovider = FirebaseImageprovider();
    Menuprovider _menuprovider = Menuprovider();

    try {
      final categoryId = widget.category != null
          ? widget.category!.categoryId
          : _menuprovider.newId();
      final imageUrl = _selectedImage == null
          ? widget.category!.categoryImage
          : await _firebaseImageprovider.uploadImageToFirebase(
              categoryId, _selectedImage, context);

      if (imageUrl == null) {
        EasyLoading.dismiss();
        return;
      }

      final category = FoodCategory(
        categoryName: _nameController.text,
        categoryImage: imageUrl,
        categoryId: categoryId,
        categoryDescription: _descriptionController.text,
        noNeedToSendToKitchen: noNeedToSendToKitchen,
        isAvailable: true,
      );

      if (widget.category != null) {
        await _controller.updateCategory(category, context);
        await _controller.changeMassKitchenStatusForOrders(category);
      } else {
        await _controller.addCategory(
            category, context); // Wait for addCategory
      }
      EasyLoading.dismiss();
      if (mounted) {
        Get.back(); // Close only if still mounted
      }
    } catch (error) {
      EasyLoading.dismiss();
      CustomSnackBar.showError(
          'Error', 'Failed to save category: $error', context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    if (widget.category != null) {
      _nameController.text = widget.category!.categoryName;
      _descriptionController.text = widget.category!.categoryDescription!;

      noNeedToSendToKitchen = widget.category!.noNeedToSendToKitchen;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          widget.category != null ? 'Edit Category' : 'Add Category',
          style: TextStyle(color: AppColors.onPrimaryLight),
        ),
        backgroundColor: AppColors.primaryLight,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.chevron_left, color: AppColors.onPrimaryLight),
          iconSize: 30,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outlineLight),
                  ),
                  child: Stack(
                    children: [
                      // Display selected image or default placeholders
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!,
                                fit: BoxFit.cover, width: double.infinity)
                            : widget.category?.categoryImage != null &&
                                    widget.category!.categoryImage.isNotEmpty
                                ? CustomNetworkImage(
                                    imageUrl: widget.category!.categoryImage,
                                    fit: BoxFit.cover,
                                    size: double.infinity,
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo,
                                            size: 50,
                                            color: AppColors.onSurfaceLight),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Add Image",
                                          style: TextStyle(
                                              color: AppColors.onSurfaceLight,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),

                      // Overlay for edit and upload actions
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                      ),

                      // Action icons (Edit and Upload)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit,
                                color: AppColors.onSurfaceLight),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _nameController,
                maxLength: 50,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _descriptionController,
                maxLength: 400,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Category Description',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Don't send to kitchen",
                      style: context.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Checkbox(
                      value: noNeedToSendToKitchen,
                      onChanged: (value) {
                        setState(() {
                          noNeedToSendToKitchen = value!;
                        });
                      },
                      activeColor: AppColors.primaryLight,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: widget.category != null
                    ? MainAxisAlignment.spaceEvenly
                    : MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _saveCategory,
                    child: widget.category != null
                        ? const Text('Update Category')
                        : const Text('Add Category'),
                  ),
                  widget.category != null
                      ? ElevatedButton(
                          onPressed: () async {
                            bool shouldLogout =
                                await deleteCategoryConfirmationDialog(
                                        context) ??
                                    false;
                            if (shouldLogout) {
                              _controller.removeCategory(widget.category!);
                              Get.back();
                            } else {
                              // Get.back();
                            }
                          },
                          child: widget.category != null
                              ? const Text('Remove Category')
                              : const Text('Cancel'),
                        )
                      : SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future deleteCategoryConfirmationDialog(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16.0),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_forever_outlined,
                    size: MediaQuery.of(context).size.width * 0.2,
                    color: isDarkMode
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Are you sure you want to delete this category?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Warning: All food items under this category will be permanently deleted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  CafePrimaryButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    buttonTitle: 'Cancel',
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                  SizedBox(height: 8.0),
                  CafeSecondaryButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    buttonTitle: 'Yes, Delete Category',
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
