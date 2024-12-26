// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cho_nun_btk/app/components/allergen_chip.dart';
import 'package:cho_nun_btk/app/components/custom_buttons.dart';
import 'package:cho_nun_btk/app/components/network_image.dart';
import 'package:cho_nun_btk/app/components/snackBars.dart';
import 'package:cho_nun_btk/app/constants/allergens.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/controllers/menu_controller.dart';
import 'package:cho_nun_btk/app/provider/firebase_imageProvider.dart';
import 'package:cho_nun_btk/app/provider/menuProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class AddMenuItem extends StatefulWidget {
  FoodItem? item;
  AddMenuItem({
    Key? key,
    this.item,
  }) : super(key: key);

  @override
  _AddMenuItemState createState() => _AddMenuItemState();
}

class _AddMenuItemState extends State<AddMenuItem> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _nutritionController = TextEditingController();
  bool isAvailable = true;
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

  List<FoodItem> sides = [];

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
  void initState() {
    // TODO: implement initState

    if (widget.item != null) {
      sides = widget.item!.sides;
      _nameController.text = widget.item!.foodName;
      _descriptionController.text = widget.item!.foodDescription;
      _priceController.text = widget.item!.foodPrice.toString();
      _isVegan = widget.item!.isVegan;
      _isGlutenFree = widget.item!.isGlutenFree;
      _isLactoseFree = widget.item!.isLactoseFree;
      _containsEgg = widget.item!.containsEgg;
      _selectedAllergens = widget.item!.allergies;
      _spiceLevel = widget.item!.spiceLevel;

      _nutritionController.text = widget.item!.nutritionalInfo.toString();
      isAvailable = widget.item!.isAvailable;

      // print('Image: ${widget.item!.foodImage}');
      // for (int i = 0; i < _selectedAllergens.length; i++) {
      //   print('Allergen: ${_selectedAllergens[i].allergenName}');
      //   print('Allergen: ${_selectedAllergens[i].allergenId}');
      //   print('Allergen: ${_selectedAllergens[i].allergenImage}');

      //   if (allergens.contains(_selectedAllergens[i])) {
      //     print('Allergen: ${_selectedAllergens[i].allergenName} found');
      //   }
      // }
      setState(() {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item == null ? 'Add New Menu Item' : 'Edit Menu Item',
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
                  child: Stack(
                    children: [
                      // Display selected image or default placeholders
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!,
                                fit: BoxFit.cover, width: double.infinity)
                            : widget.item?.foodImage != null &&
                                    widget.item!.foodImage.isNotEmpty
                                ? CustomNetworkImage(
                                    imageUrl: widget.item!.foodImage,
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

              // Name Field
              TextFormField(
                controller: _nameController,
                maxLength: 100,
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
                maxLength: 400,
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
              TextFormField(
                controller: _nutritionController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nutritional Info (kcal)',
                  suffixText: 'kcal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
              ),

              SizedBox(height: 2.h),

              // // Price Field
              // TextFormField(
              //   controller: _priceController,
              //   keyboardType: TextInputType.number,
              //   decoration: InputDecoration(
              //     labelText: 'Price',
              //     prefixText: '\₱',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     filled: true,
              //     fillColor: AppColors.surfaceLight,
              //   ),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter a price';
              //     }
              //     if (double.tryParse(value) == null) {
              //       return 'Please enter a valid number';
              //     }
              //     return null;
              //   },
              // ),

              // Category Dropdown

              SizedBox(height: 2.h),

              Text(
                'Dish Availability',
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isAvailable
                      ? Text(
                          'Available',
                          style: context.textTheme.bodyLarge,
                        )
                      : Text(
                          'Not Available',
                          style: context.textTheme.bodyLarge,
                        ),
                  Switch(
                      value: isAvailable,
                      onChanged: (value) {
                        setState(() {
                          isAvailable = value;
                        });
                      }),
                ],
              ),
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
                'Select Allergens',
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),

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

              SizedBox(height: 2.h),

              // Row(
              //   children: [
              //     Text(
              //       'Select Sides & Extras(Optional)',
              //       style: context.textTheme.titleMedium!.copyWith(
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //     Expanded(child: SizedBox()),
              //     GestureDetector(
              //       onTap: () {
              //         Get.to(() => SelectSidesView(
              //                   sides: sides,
              //                 ))!
              //             .then((value) {
              //           if (value != null) {
              //             setState(() {
              //               sides = List.from(value);
              //             });
              //           }
              //         });
              //       },
              //       child: DottedBorder(
              //         borderType: BorderType.RRect,
              //         radius: Radius.circular(12),
              //         padding: EdgeInsets.all(6),
              //         child: Row(
              //           children: [
              //             Icon(Icons.add),
              //             Text("Add "),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),

              // sides.length > 0
              //     ? ListView.builder(
              //         shrinkWrap: true,
              //         physics: const NeverScrollableScrollPhysics(),
              //         itemCount: sides.length,
              //         itemBuilder: (context, index) {
              //           final foodItem = sides[index];

              //           return Card(
              //             margin: const EdgeInsets.symmetric(vertical: 8),
              //             elevation: 4,
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(12),
              //             ),
              //             child: Padding(
              //               padding: const EdgeInsets.all(12.0),
              //               child: Row(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   // Food Image
              //                   CustomNetworkImage(
              //                     imageUrl: foodItem.foodImage,
              //                     size: 25.w,
              //                     fit: BoxFit.cover,
              //                   ),
              //                   SizedBox(width: 4.w),

              //                   // Food Details
              //                   Expanded(
              //                     child: Column(
              //                       crossAxisAlignment:
              //                           CrossAxisAlignment.start,
              //                       children: [
              //                         Text(
              //                           foodItem.foodName,
              //                           style: context.textTheme.bodyLarge
              //                               ?.copyWith(
              //                             fontWeight: FontWeight.bold,
              //                           ),
              //                           maxLines: 2,
              //                           overflow: TextOverflow.ellipsis,
              //                         ),
              //                         SizedBox(height: 1.h),
              //                         Text(
              //                           foodItem.foodDescription,
              //                           style: context.textTheme.bodyMedium,
              //                           maxLines: 3,
              //                           overflow: TextOverflow.ellipsis,
              //                         ),
              //                         SizedBox(height: 1.h),
              //                         Text(
              //                           '${foodItem.nutritionalInfo} kcal | \₱${foodItem.foodPrice.toStringAsFixed(2)}',
              //                           style: context.textTheme.bodySmall
              //                               ?.copyWith(
              //                             color: Colors.grey,
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                   IconButton(
              //                       onPressed: () {
              //                         sides.removeAt(index);
              //                         setState(() {});
              //                       },
              //                       icon: Icon(Icons.delete_outline))
              //                 ],
              //               ),
              //             ),
              //           );
              //         },
              //       )
              //     : Center(child: Text("No sides selected")),
              SizedBox(height: 2.h),

              // Submit Button
              Row(
                mainAxisAlignment: widget.item == null
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceEvenly,
                children: [
                  // ElevatedButton.icon(
                  //   onPressed: _submitForm,
                  //   icon: Icon(Icons.add),
                  //   label: Text(
                  //     widget.item == null ? 'Add Item' : 'Update Item',
                  //   ),
                  // ),
                  CafePrimaryButton(
                      buttonTitle:
                          widget.item == null ? 'Add Item' : 'Update Item',
                      width: 25.w,
                      onPressed: () {
                        _submitForm();
                      }),
                  widget.item != null
                      ? CafePrimaryButton(
                          buttonTitle: "Remove",
                          width: 20.w,
                          onPressed: () {
                            menuController.removeMenuItem(
                                widget.item!, menuController.selectedCategory);
                          })
                      : SizedBox(),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Uploading...');

      Menuprovider menuprovider = Menuprovider();

      String? imageUrl =
          widget.item?.foodImage; // Default to existing image URL

      // If there's a new image, upload it
      if (_selectedImage != null &&
          _selectedImage!.path != widget.item?.foodImage) {
        FirebaseImageprovider firebaseImageprovider = FirebaseImageprovider();
        imageUrl = await firebaseImageprovider.uploadImageToFirebase(
          menuController
              .selectedCategory.categoryId, // Replace with the category ID
          _selectedImage,
          context,
        );
      }

      if (imageUrl != null) {
        EasyLoading.dismiss();

        // Create FoodItem from form inputs
        final newMenuItem = FoodItem(
          foodId: widget.item?.foodId ?? menuprovider.newId(),
          foodName: _nameController.text,
          foodDescription: _descriptionController.text,
          foodPrice: _priceController.text.isNotEmpty
              ? double.parse(_priceController.text)
              : 0,
          foodCategory: menuController.selectedCategory,
          foodImage: imageUrl,
          isVegan: _isVegan,
          isGlutenFree: _isGlutenFree,
          isLactoseFree: _isLactoseFree,
          containsEgg: _containsEgg,
          allergies: _selectedAllergens,
          spiceLevel: _spiceLevel,
          isAvailable: isAvailable,
          sides: sides,
          nutritionalInfo: _nutritionController.text.isNotEmpty
              ? double.parse(_nutritionController.text)
              : 0,
        );

        if (widget.item == null) {
          // Add new item
          menuController.addNewMenuItem(
              newMenuItem, menuController.selectedCategory);
        } else {
          // Update existing item
          menuController.updateMenuItem(
              newMenuItem, menuController.selectedCategory);
        }

        Get.back();
      } else {
        EasyLoading.dismiss();
        CustomSnackBar.showError('Error', 'Failed to save item', context);
      }
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
