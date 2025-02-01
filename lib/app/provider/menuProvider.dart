import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Menuprovider {
  final menuCollection = FirebaseFirestore.instance.collection('menu');
  final globalMenuCollection =
      FirebaseFirestore.instance.collection('globalmenu');

  String newId() {
    return menuCollection.doc().id;
  }

  ///Add a new category to the menu
  Future<QueryStatus> addNewCategory(FoodCategory category) async {
    try {
      await menuCollection.doc(category.categoryId).set(category.toJson());
      debugPrint('Category added successfully');
      return QueryStatus.SUCCESS;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return QueryStatus.ERROR;
    }
  }

  ///Get all categories from the menu
  Future<List<FoodCategory>> getAllCategories() async {
    try {
      QuerySnapshot snapshot =
          await menuCollection.where('isAvailable', isEqualTo: true).get();
      return snapshot.docs
          .map((doc) =>
              FoodCategory.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<QueryStatus> massChangeKitchenCategoryForItems(
      FoodCategory category) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Get the snapshot of food items
      QuerySnapshot snapshot = await menuCollection
          .doc(category.categoryId)
          .collection('fooditems')
          .get();

      int totalDocs = snapshot.docs.length;
      if (totalDocs == 0) {
        return QueryStatus.SUCCESS;
      }

      int processedDocs = 0;

      // Update each document in the batch and track progress
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'foodCategory': category.toJson()});
        processedDocs++;

        // Update progress after processing each document
      }

      // Commit the batch
      await batch.commit();

      // Ensure progress shows 100% after commit

      return QueryStatus.SUCCESS;
    } catch (e) {
      // Handle errors
      return QueryStatus.ERROR;
    }
  }

  Future<QueryStatus> removeCategory(FoodCategory category) async {
    try {
      await menuCollection.doc(category.categoryId).set({
        'isAvailable': false,
      }, SetOptions(merge: true));
      return QueryStatus.SUCCESS;
    } catch (e) {
      return QueryStatus.ERROR;
    }
  }

  Future<QueryStatus> updateCategory(FoodCategory category) async {
    try {
      await menuCollection.doc(category.categoryId).update(category.toJson());
      return QueryStatus.SUCCESS;
    } catch (e) {
      return QueryStatus.ERROR;
    }
  }

  Future<QueryStatus> addNewMenuItem(
      FoodItem item, FoodCategory foodCategory) async {
    try {
      await menuCollection
          .doc(foodCategory.categoryId)
          .collection('fooditems')
          .doc(item.foodId)
          .set(item.toJson());
      return QueryStatus.SUCCESS;
    } catch (e) {
      return QueryStatus.ERROR;
    }
  }

  Future<QueryStatus> removeMenuItem(
      FoodItem item, FoodCategory foodCategory) async {
    try {
      await menuCollection
          .doc(foodCategory.categoryId)
          .collection('fooditems')
          .doc(item.foodId)
          .delete();
      return QueryStatus.SUCCESS;
    } catch (e) {
      return QueryStatus.ERROR;
    }
  }

  Future<QueryStatus> updateMenuItem(
      FoodItem item, FoodCategory foodCategory) async {
    try {
      // debugPrint('Updating item');
      // debugPrint("Category Id: ${foodCategory.categoryId}");
      // debugPrint("Id: ${item.foodId}");
      await menuCollection
          .doc(foodCategory.categoryId)
          .collection('fooditems')
          .doc(item.foodId)
          .set(item.toJson());
      return QueryStatus.SUCCESS;
    } catch (e) {
      debugPrint('Error updating item: $e');
      return QueryStatus.ERROR;
    }
  }

  Future<List<FoodItem>> getAllItems(FoodCategory category) async {
    try {
      QuerySnapshot snapshot = await menuCollection
          .doc(category.categoryId)
          .collection('fooditems')
          .get();
      return snapshot.docs
          .map((doc) => FoodItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<QueryStatus> addAllAllergens() async {
    List<Allergens> allergens = [
      Allergens(
          allergenId: '1',
          allergenName: 'Gluten',
          allergenImage: 'assets/svg/allergens/gluten.png'),
      Allergens(
          allergenId: '2',
          allergenName: 'Dairy',
          allergenImage: 'assets/svg/allergens/dairy.png'),
      Allergens(
          allergenId: '3',
          allergenName: 'Eggs',
          allergenImage: 'assets/svg/allergens/eggs.png'),
      Allergens(
          allergenId: '4',
          allergenName: 'Nuts',
          allergenImage: 'assets/svg/allergens/nuts.png'),
      Allergens(
          allergenId: '5',
          allergenName: 'Peanuts',
          allergenImage: 'assets/svg/allergens/peanuts.png'),
      Allergens(
          allergenId: '6',
          allergenName: 'Shellfish',
          allergenImage: 'assets/svg/allergens/shellfish.png'),
      Allergens(
          allergenId: '7',
          allergenName: 'Fish',
          allergenImage: 'assets/svg/allergens/fish.png'),
      Allergens(
          allergenId: '8',
          allergenName: 'Soy',
          allergenImage: 'assets/svg/allergens/soy.png'),
      Allergens(
          allergenId: '9',
          allergenName: 'Sesame',
          allergenImage: 'assets/svg/allergens/sesame.png'),
      Allergens(
          allergenId: '10',
          allergenName: 'Mustard',
          allergenImage: 'assets/svg/allergens/mustard.png'),
      Allergens(
          allergenId: '11',
          allergenName: 'Celery',
          allergenImage: 'assets/svg/allergens/celery.png'),
      Allergens(
          allergenId: '12',
          allergenName: 'Lupin',
          allergenImage: 'assets/svg/allergens/lupin.png'),
      Allergens(
          allergenId: '13',
          allergenName: 'Sulfites',
          allergenImage: 'assets/svg/allergens/sulfites.png'),
      Allergens(
          allergenId: '14',
          allergenName: 'Corn',
          allergenImage: 'assets/svg/allergens/corn.png'),
      Allergens(
          allergenId: '15',
          allergenName: 'Bovine Proteins',
          allergenImage: 'assets/svg/allergens/bovine_proteins.png'),
    ];

    try {
      await menuCollection.doc('allergens').set({
        'allergens': allergens.map((a) => a.allergenName).toList(),
      });
      return QueryStatus.SUCCESS;
    } catch (e) {
      return QueryStatus.ERROR;
    }
  }

  Future<void> storeFoodItemInGlobalMenu(FoodItem item) async {
    try {
      DocumentSnapshot doc = await globalMenuCollection.doc("allitems").get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Convert the item to JSON and store it with foodId as the key
        await globalMenuCollection.doc("allitems").update({
          item.foodId.toString(): item.toJson(),
        });
      } else {
        // If the document doesn't exist, create it with the first item
        await globalMenuCollection.doc("allitems").set({
          item.foodId.toString(): item.toJson(),
        });
      }
    } catch (e) {
      debugPrint('Error storing/updating item in global menu: $e');
      throw e;
    }
  }

  Future<void> syncMenuWithGlobalMenu() async {
    try {
      List<FoodCategory> categories = await getAllCategories();
      for (var category in categories) {
        List<FoodItem> items = await getAllItems(category);
        for (var item in items) {
          await storeFoodItemInGlobalMenu(item);
        }
      }
    } catch (e) {
      debugPrint('Error syncing menu with global menu: $e');
      throw e;
    }
  }

  // Get all food items
  Future<List<FoodItem>> getAllFoodItemsFromGlobalMenu() async {
    try {
      DocumentSnapshot doc = await globalMenuCollection.doc("allitems").get();

      if (!doc.exists) {
        return [];
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<FoodItem> items = [];

      data.forEach((key, value) {
        try {
          items.add(FoodItem.fromJson(value as Map<String, dynamic>));
        } catch (e) {
          debugPrint('Error parsing food item with ID $key: $e');
          // Continue processing other items even if one fails
        }
      });

      return items;
    } catch (e) {
      debugPrint('Error retrieving all food items from global menu: $e');
      throw e;
    }
  }
}
