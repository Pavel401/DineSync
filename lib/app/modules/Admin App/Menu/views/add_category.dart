import 'dart:io';

import 'package:cho_nun_btk/app/components/network_image.dart';
import 'package:cho_nun_btk/app/components/snackBars.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/controllers/menu_controller.dart';
import 'package:cho_nun_btk/app/provider/firebase_imageProvider.dart';
import 'package:cho_nun_btk/app/provider/menuProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
      );

      if (widget.category != null) {
        await _controller.updateCategory(category, context);
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
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  height: 200,
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLength: 400,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Category Description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveCategory,
                child: widget.category != null
                    ? const Text('Update Category')
                    : const Text('Add Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
