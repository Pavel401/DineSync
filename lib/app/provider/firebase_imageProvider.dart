import 'dart:io';

import 'package:cho_nun_btk/app/components/snackBars.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FirebaseImageprovider {
  Future<String?> uploadImageToFirebase(
      String categoryId, File? _selectedImage, BuildContext context) async {
    if (_selectedImage == null) return null;

    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('categories/$categoryId.jpg');
      final uploadTask = await storageRef.putFile(_selectedImage!);
      EasyLoading.dismiss();
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      CustomSnackBar.showError('Error', 'Failed to upload image', context);
      return null;
    }
  }
}
