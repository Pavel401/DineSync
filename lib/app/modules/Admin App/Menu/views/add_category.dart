import 'dart:io';

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
  const AddCategory({super.key});

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
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      CustomSnackBar.showError(
          'Error', 'Please fill all fields and select an image', context);
      return;
    }

    // Show loading indicator
    EasyLoading.show(status: 'Uploading image...');
    FirebaseImageprovider _firebaseImageprovider = FirebaseImageprovider();
    Menuprovider _menuprovider = Menuprovider();

    try {
      final categoryId = _menuprovider.newId();
      final imageUrl = await _firebaseImageprovider.uploadImageToFirebase(
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

      await _controller.addCategory(category, context); // Wait for addCategory
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Category',
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
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? const Center(
                          child: Text(
                            'Tap to select an image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
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
                decoration: const InputDecoration(
                  labelText: 'Category Description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveCategory,
                child: const Text('Save Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
