import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseHelper {
  static final FirebaseHelper _instance = FirebaseHelper._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirebaseHelper() {
    return _instance;
  }

  FirebaseHelper._internal();

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<void> saveFCMToken(String userId, String newToken) async {
    debugPrint("saveFCMToken: FCM Token: $newToken");

    // Use batch write
    // 1. Store the token in Firestore under the user's document as fcmToken
    // 2. Store it in notification collection where cache is the doc name.
    // UID is field name and token is the value
    WriteBatch batch = _firestore.batch();

    DocumentReference userDocRef = _firestore.collection('users').doc(userId);
    DocumentReference notificationDocRef =
        _firestore.collection('notifications').doc('cache');

    batch.set(userDocRef, {'fcmToken': newToken}, SetOptions(merge: true));
    batch.set(notificationDocRef, {userId: newToken}, SetOptions(merge: true));

    await batch.commit();

    debugPrint("saveFCMToken: FCM Token stored in Firestore");
  }
}
