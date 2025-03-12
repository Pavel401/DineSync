import 'package:cho_nun_btk/app/components/snackBars.dart';
import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/models/auth/authmodels.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Analytics/controller/admin_analytics_controller.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Home/controller/home_controller.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/controllers/menu_controller.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/controller/new_order_controller.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/Order%20Overview/controller/order_controller.dart';
import 'package:cho_nun_btk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    if (_auth.currentUser != null && _userModel.value == null) {
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
      } catch (e) {
        debugPrint("Error loading user model: $e");
      }
    }
  }

  /// Saves the `UserModel` to Firestore
  Future<void> saveUserToFirestore(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
      _userModel.value = user;
    } catch (e) {
      debugPrint("Error saving user to Firestore: $e");
    }
  }

  Future<void> updatePassword(String newPassword, UserModel model) async {
    try {
      await firebaseUser?.updatePassword(newPassword);
      UserModel updatedModel = model.copyWith(password: newPassword);
      await _firestore
          .collection('users')
          .doc(updatedModel.uid)
          .update(updatedModel.toJson());
      _userModel.value = updatedModel;
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
      debugPrint("Attempting to sign in with email: $email");
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      debugPrint("Sign-in successful, loading user model...");
      await loadUserModel(); // Load the user model after login
      return QueryStatus.SUCCESS;
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.code} - ${e.message}");
      switch (e.code) {
        case 'user-not-found':
          CustomSnackBar.showError(
              "Error", "No user found with this email.", context);
          break;
        case 'wrong-password':
          CustomSnackBar.showError(
              "Error", "Incorrect password. Please try again.", context);
          break;
        case 'invalid-email':
          CustomSnackBar.showError(
              "Error", "The email address is not valid.", context);
          break;
        case 'user-disabled':
          CustomSnackBar.showError(
              "Error", "This account has been disabled.", context);
          break;
        default:
          CustomSnackBar.showError(
              "Error", e.message ?? "An unknown error occurred.", context);
      }
      return QueryStatus.ERROR;
    } catch (e) {
      debugPrint("Unexpected error: $e");
      CustomSnackBar.showError(
          "Error", "An unexpected error occurred: $e", context);
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

      Get.delete<HomeController>();
      Get.delete<AdminAnalyticsController>();
      Get.delete<FoodMenuController>();
      Get.delete<OrderController>();
      Get.delete<WaiterOrderController>();

      selectedUserType = UserType.NONE;

      Get.offAll(() => SplashScreen());
      return true;
    } catch (e) {
      debugPrint("Error signing out: $e");
      return false;
    }
  }

  Future<void> updateProfile(
      {required UserModel model, required BuildContext context}) async {
    try {
      EasyLoading.show(status: 'Updating profile...');
      await _firestore
          .collection('users')
          .doc(model.uid)
          .update(model.toJson());
      await loadUserModel(); // Reload the updated user model
      EasyLoading.dismiss();

      CustomSnackBar.showSuccess(
        "Success",
        "Profile updated successfully!",
        context,
      );
      Get.back();
    } catch (e) {
      EasyLoading.dismiss();
      CustomSnackBar.showError(
        "Error",
        "Failed to update profile: $e",
        context,
      );
    }
  }

  Future<List<UserModel>> getAllUsersByUserType(UserType type) async {
    List<UserModel> users = [];
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: type.toString())
          .get();

      users = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Error loading users: $e");
    }
    return users;
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<QueryStatus> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in flow
        return QueryStatus.ERROR;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Create or update the user in Firestore
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        name: userCredential.user!.displayName ?? '',
        photoUrl: userCredential.user!.photoURL ?? '',
        phone: '',
        address: '',
        userType: selectedUserType,
        blocked: false,
        joinedOn: DateTime.now(),
        lastLogin: DateTime.now(),
        password: '', // Not applicable for Google Sign-In
        fcmToken: '',
      );

      await saveUserToFirestore(newUser);

      return QueryStatus.SUCCESS;
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      return QueryStatus.ERROR;
    }
  }
}
