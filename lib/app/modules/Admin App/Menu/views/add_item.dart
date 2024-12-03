import 'dart:io';

import 'package:cho_nun_btk/app/components/allergen_chip.dart';
import 'package:cho_nun_btk/app/constants/allergens.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/controllers/menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class AddMenuItem extends StatefulWidget {
  const AddMenuItem({Key? key}) : super(key: key);

  @override
  _AddMenuItemState createState() => _AddMenuItemState();
}

class _AddMenuItemState extends State<AddMenuItem> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Image picker
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Dropdown selections
  FoodCategory? _selectedCategory;
  int _spiceLevel = 1;

  // Dietary options
  bool _isVegan = false;
  bool _isGlutenFree = false;
  bool _isLactoseFree = false;
  bool _containsEgg = false;

  // Allergens selection
  List<Allergens> _selectedAllergens = [];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  FoodMenuController menuController = Get.find<FoodMenuController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Menu Item',
          style: TextStyle(color: AppColors.onPrimaryLight),
        ),
        backgroundColor: AppColors.primaryLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outlineLight),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: AppColors.primaryLight,
                              size: 50,
                            ),
                            Text(
                              'Tap to Select Image',
                              style: TextStyle(color: AppColors.outlineLight),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 2.h),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Food Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Price Field
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              // Category Dropdown

              SizedBox(height: 2.h),

              // Spice Level Slider
              Text(
                'Spice Level',
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: _spiceLevel.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _spiceLevel.toString(),
                activeColor: AppColors.primaryLight,
                inactiveColor: AppColors.tertiaryLight,
                onChanged: (double value) {
                  setState(() {
                    _spiceLevel = value.toInt();
                  });
                },
              ),
              SizedBox(height: 2.h),

              // Dietary Options
              Text(
                'Dietary Options',
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              CheckboxListTile(
                title: Text(
                  'Vegan',
                  style: context.textTheme.bodyLarge,
                ),
                value: _isVegan,
                activeColor: AppColors.primaryLight,
                onChanged: (bool? value) {
                  setState(() {
                    _isVegan = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text(
                  'Gluten Free',
                  style: context.textTheme.bodyLarge,
                ),
                value: _isGlutenFree,
                activeColor: AppColors.primaryLight,
                onChanged: (bool? value) {
                  setState(() {
                    _isGlutenFree = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text(
                  'Lactose Free',
                  style: context.textTheme.bodyLarge,
                ),
                value: _isLactoseFree,
                activeColor: AppColors.primaryLight,
                onChanged: (bool? value) {
                  setState(() {
                    _isLactoseFree = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text(
                  'Contains Egg',
                  style: context.textTheme.bodyLarge,
                ),
                value: _containsEgg,
                activeColor: AppColors.primaryLight,
                onChanged: (bool? value) {
                  setState(() {
                    _containsEgg = value ?? false;
                  });
                },
              ),

              // Allergens Selection
              SizedBox(height: 2.h),
              Text(
                'Allergens',
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 1.h,
                runSpacing: 2.w,
                children: [
                  for (int i = 0; i < allergens.length; i++)
                    AllergenChip(
                      allergen: allergens[i],
                      isSelected: _selectedAllergens.contains(allergens[i]),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedAllergens.add(allergens[i]);
                          } else {
                            _selectedAllergens.remove(allergens[i]);
                          }
                        });
                      },
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Add Menu Item',
                  style: TextStyle(
                    color: AppColors.onPrimaryLight,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create FoodItem from form inputs
      final newMenuItem = FoodItem(
        foodId: DateTime.now()
            .millisecondsSinceEpoch
            .toString(), // Generate unique ID
        foodName: _nameController.text,
        foodDescription: _descriptionController.text,
        foodPrice: double.parse(_priceController.text),
        foodCategory: menuController.selectedCategory,
        foodImage: _selectedImage?.path ?? '',
        isVegan: _isVegan,
        isGlutenFree: _isGlutenFree,
        isLactoseFree: _isLactoseFree,
        containsEgg: _containsEgg,
        allergies: [],
        spiceLevel: _spiceLevel,
      );

      // TODO: Implement saving logic (e.g., to database or API)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu Item Added: ${newMenuItem.foodName}'),
          backgroundColor: AppColors.primaryLight,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
