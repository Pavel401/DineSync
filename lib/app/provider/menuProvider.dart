import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Menuprovider {
  final menuCollection = FirebaseFirestore.instance.collection('menu');

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
      QuerySnapshot snapshot = await menuCollection.get();
      return snapshot.docs
          .map((doc) =>
              FoodCategory.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<QueryStatus> removeCategory(FoodCategory category) async {
    try {
      await menuCollection.doc(category.categoryId).delete();
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
}
