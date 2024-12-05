import 'package:cho_nun_btk/app/components/snackBars.dart';
import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/models/auth/authmodels.dart';
import 'package:cho_nun_btk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Rx variables for reactive updates
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);

  // User details
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  // User type selection
  UserType selectedUserType = UserType.NONE;

  // Getters
  UserModel? get userModel => _userModel.value;
  User? get firebaseUser => _firebaseUser.value;

  @override
  void onInit() {
    _firebaseUser.bindStream(_auth.authStateChanges());
    super.onInit();
    loadUserModel();
  }

  /// Sets the selected user type
  void setUserType(UserType type) {
    selectedUserType = type;
    update();
  }

  Future<UserType> checkUserType() async {
    if (_auth.currentUser != null) {
      try {
        DocumentSnapshot snapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        if (snapshot.exists) {
          _userModel.value =
              UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
          return _userModel.value!.userType;
        }
        debugPrint("User model loaded: ${_userModel.value}");
      } catch (e) {
        debugPrint("Error loading user model: $e");
      }
    }
    return UserType.NONE;
  }

  /// Loads the user model from Firestore if a user is logged in
  Future<void> loadUserModel() async {
    if (_auth.currentUser != null) {
      try {
        DocumentSnapshot snapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        if (snapshot.exists) {
          _userModel.value =
              UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
        }
        debugPrint("User model loaded: ${_userModel.value}");
      } catch (e) {
        debugPrint("Error loading user model: $e");
      }
    }
  }

  /// Saves the `UserModel` to Firestore
  Future<void> saveUserToFirestore(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
      _userModel.value = user; // Update the cached user model
    } catch (e) {
      debugPrint("Error saving user to Firestore: $e");
    }
  }

  Future<void> updatePassword(String new_password, UserModel model) async {
    debugPrint("Updating password...");
    UserModel updatedModel = model.copyWith(password: new_password);
    try {
      await _firestore
          .collection('users')
          .doc(updatedModel.uid)
          .update(updatedModel.toJson());
      _userModel.value = model; // Update the cached user model

      signOut();
    } catch (e) {
      debugPrint("Error updating password: $e");
    }
  }

  /// Handles user signup
  Future<QueryStatus> signUp({
    required String email,
    required String password,
    required String name,
    String photoUrl = '',
    String phone = '',
    String address = '',
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a new UserModel
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        photoUrl: photoUrl,
        phone: phone,
        address: address,
        userType: selectedUserType,
        blocked: false,
        joinedOn: DateTime.now(),
        lastLogin: DateTime.now(),
        password: password,
        fcmToken: '', // Update with actual token if using FCM
      );

      // Save user data in Firestore
      await saveUserToFirestore(newUser);

      CustomSnackBar.showSuccess(
        "Success",
        "Account created successfully!",
        context,
      );
      return QueryStatus.SUCCESS;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          CustomSnackBar.showError(
            "Error",
            "This email is already in use. Please try another.",
            context,
          );
          break;
        case 'invalid-email':
          CustomSnackBar.showError(
            "Error",
            "The email address is not valid.",
            context,
          );
          break;
        case 'weak-password':
          CustomSnackBar.showError(
            "Error",
            "The password is too weak. Use a stronger password.",
            context,
          );
          break;
        default:
          CustomSnackBar.showError(
            "Error",
            e.message ?? "An unknown error occurred.",
            context,
          );
          break;
      }
    } catch (e) {
      CustomSnackBar.showError(
        "Error",
        "An unexpected error occurred: $e",
        context,
      );
    }
    return QueryStatus.ERROR;
  }

  /// Handles user login
  Future<QueryStatus> signIn(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await loadUserModel(); // Load the user model after login
      // CustomSnackBar.showSuccess(
      //   "Success",
      //   "Logged in successfully!",
      //   context,
      // );

      return QueryStatus.SUCCESS;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          CustomSnackBar.showError(
            "Error",
            "No user found with this email.",
            context,
          );
          break;
        case 'wrong-password':
          CustomSnackBar.showError(
            "Error",
            "Incorrect password. Please try again.",
            context,
          );
          break;
        case 'invalid-email':
          CustomSnackBar.showError(
            "Error",
            "The email address is not valid.",
            context,
          );
          break;
        case 'user-disabled':
          CustomSnackBar.showError(
            "Error",
            "This account has been disabled.",
            context,
          );
          break;
        default:
          CustomSnackBar.showError(
            "Error",
            e.message ?? "An unknown error occurred.",
            context,
          );
      }
      return QueryStatus.ERROR;
    } catch (e) {
      CustomSnackBar.showError(
        "Error",
        "An unexpected error occurred: $e",
        context,
      );
      return QueryStatus.ERROR;
    }
  }

  /// Handles user logout
  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      _userModel.value = null; // Clear the cached user model

      await FirebaseAuth.instance.signOut();
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      phoneController.clear();
      selectedUserType = UserType.NONE;

      Get.offAll(() => SplashScreen());
      return true;
    } catch (e) {
      debugPrint("Error signing out: $e");
      return false;
    }
  }
}
