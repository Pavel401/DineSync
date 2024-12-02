import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/models/auth/authmodels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider {
  final adminCollection = FirebaseFirestore.instance.collection('admin');

  Future<QueryStatus> addNewAdmin(UserModel user) async {
    try {
      // Convert the UserModel object to a map
      Map<String, dynamic> userData = user.toJson();

      // Add the new admin to the Firestore collection
      await adminCollection.doc(user.uid).set(userData).then((value) {
        return QueryStatus.SUCCESS;
      });
      debugPrint("Admin added successfully!");
    } catch (e) {
      // Handle any errors
      debugPrint("Failed to add admin: $e");
      return QueryStatus.ERROR;
    }
    return QueryStatus.ERROR;
  }
}
