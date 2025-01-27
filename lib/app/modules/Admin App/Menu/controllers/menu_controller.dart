import 'package:cho_nun_btk/app/components/snackBars.dart';
import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/provider/menuProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class FoodMenuController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  RxList<FoodItem> items = <FoodItem>[].obs;
  RxList<FoodItem> sideItems = <FoodItem>[].obs;

  RxBool isItemsLoading = false.obs;
  RxBool isSideItemsLoading = false.obs;

  RxList<FoodCategory> categories = <FoodCategory>[].obs;

  FoodCategory selectedCategory = FoodCategory(
    categoryName: '',
    categoryImage: '',
    categoryId: '',
    categoryDescription: '',
  );

  FoodCategory selectedSideCategory = FoodCategory(
    categoryName: '',
    categoryImage: '',
    categoryId: '',
    categoryDescription: '',
  );
  Menuprovider menuprovider = Menuprovider();

  Future<void> changecategory(FoodCategory category) async {
    selectedCategory = category;

    update();
  }

  Future<void> changeSideCategory(FoodCategory category) async {
    selectedSideCategory = category;
    await getSideItemsForCategory(category);
    update();
  }

  Future<void> clearSelectedCategory() async {
    selectedCategory = FoodCategory(
      categoryName: '',
      categoryImage: '',
      categoryId: '',
      categoryDescription: '',
    );
    update();
  }

  Future<void> selectInitialCategory() async {
    if (categories.isNotEmpty) {
      selectedCategory = categories[0];

      getItemsForCategory(selectedCategory);
    }
    update();
  }

  Future<void> addCategory(FoodCategory category, BuildContext context) async {
    EasyLoading.show(status: 'Adding category');
    categories.add(category);
    QueryStatus status = await menuprovider.addNewCategory(category);
    if (status == QueryStatus.ERROR) {
      CustomSnackBar.showError('Error', 'Failed to add category', context);
      // categories.remove(category);
      EasyLoading.dismiss();

      return;
    } else {
      CustomSnackBar.showSuccess(
          'Success', 'Category added successfully', context);
    }
    EasyLoading.dismiss();

    Get.back(); // Close the form

    update();
  }

  Future<void> removeCategory(FoodCategory category) async {
    EasyLoading.show(status: 'Removing category');
    categories.remove(category);
    QueryStatus status = await menuprovider.removeCategory(category);

    if (status == QueryStatus.ERROR) {
      CustomSnackBar.showError(
          'Error', 'Failed to remove category', Get.context!);
      categories.add(category);
      return;
    } else {
      CustomSnackBar.showSuccess(
          'Success', 'Category removed successfully', Get.context!);
    }

    EasyLoading.dismiss();
    update();
  }

  Future<void> updateCategory(
      FoodCategory category, BuildContext context) async {
    EasyLoading.show(status: 'Updating category');
    QueryStatus status = await menuprovider.updateCategory(category);

    // categories[categories.indexWhere((element) => element == category)] =
    //     category;

    if (status == QueryStatus.ERROR) {
      CustomSnackBar.showError('Error', 'Failed to update category', context);
      return;
    } else {
      CustomSnackBar.showSuccess(
          'Success', 'Category updated successfully', context);
    }

    Get.back();
    EasyLoading.dismiss();
    update();
  }

  Future<void> changeMassKitchenStatusForOrders(FoodCategory) {
    return menuprovider.massChangeKitchenCategoryForItems(FoodCategory);
  }

  Future<List<FoodCategory>> getAllCategories() async {
    categories.value = await menuprovider.getAllCategories();

    selectInitialCategory();

    update();
    return categories;
  }

  Future<void> addNewMenuItem(FoodItem item, FoodCategory foodCategory) async {
    EasyLoading.show(status: 'Adding item');
    QueryStatus status = await menuprovider.addNewMenuItem(item, foodCategory);

    if (status == QueryStatus.ERROR) {
      CustomSnackBar.showError('Error', 'Failed to add item', Get.context!);
      EasyLoading.dismiss();
      return;
    } else {
      CustomSnackBar.showSuccess(
          'Success', 'Item added successfully', Get.context!);
    }

    EasyLoading.dismiss();
    Get.back();
    update();
  }

  Future<void> removeMenuItem(FoodItem item, FoodCategory foodCategory) async {
    EasyLoading.show(status: 'Removing item');
    QueryStatus status = await menuprovider.removeMenuItem(item, foodCategory);

    if (status == QueryStatus.ERROR) {
      CustomSnackBar.showError('Error', 'Failed to remove item', Get.context!);
      EasyLoading.dismiss();
      return;
    } else {
      CustomSnackBar.showSuccess(
          'Success', 'Item removed successfully', Get.context!);
    }

    EasyLoading.dismiss();
    Get.back();
    update();
  }

  Future<void> updateMenuItem(FoodItem item, FoodCategory foodCategory) async {
    EasyLoading.show(status: 'Updating item');
    QueryStatus status = await menuprovider.updateMenuItem(item, foodCategory);

    if (status == QueryStatus.ERROR) {
      CustomSnackBar.showError('Error', 'Failed to update item', Get.context!);
      EasyLoading.dismiss();
      return;
    } else {
      CustomSnackBar.showSuccess(
          'Success', 'Item updated successfully', Get.context!);
    }

    EasyLoading.dismiss();
    Get.back();
    update();
  }

  Future<void> getItemsForCategory(FoodCategory category) async {
    EasyLoading.show(status: 'Fetching items');
    isItemsLoading.value = true;

    items.clear();
    print('Fetching items');
    List<FoodItem> itemsT = await menuprovider.getAllItems(category);

    items.value = itemsT;

    isItemsLoading.value = false;
    EasyLoading.dismiss();

    update();
  }

  Future<void> getSideItemsForCategory(FoodCategory category) async {
    EasyLoading.show(status: 'Fetching items');
    isSideItemsLoading.value = true;

    sideItems.clear();
    print('Fetching items');
    List<FoodItem> itemsT = await menuprovider.getAllItems(category);

    sideItems.value = itemsT;

    isSideItemsLoading.value = false;
    EasyLoading.dismiss();

    update();
  }

  Future<String> generateFoodId() async {
    return await menuprovider.newId();
  }
}
