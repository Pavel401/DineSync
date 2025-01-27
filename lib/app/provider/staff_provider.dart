import 'package:cho_nun_btk/app/models/auth/authmodels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserModel> _users = [];

  List<UserModel> get users => _users;

  Future<void> fetchUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      _users = querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  Future<void> blockUser(String uid, bool block) async {
    try {
      await _firestore.collection('users').doc(uid).update({'blocked': block});
      _users = _users.map((user) {
        if (user.uid == uid) {
          return user.copyWith(blocked: block);
        }
        return user;
      }).toList();
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }

  Future<void> unblockUser(String uid, bool block) async {
    try {
      await _firestore.collection('users').doc(uid).update({'blocked': block});
      _users = _users.map((user) {
        if (user.uid == uid) {
          return user.copyWith(blocked: block);
        }
        return user;
      }).toList();
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }
}
