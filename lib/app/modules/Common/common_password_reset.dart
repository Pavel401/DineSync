import 'package:cho_nun_btk/app/components/snackBars.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonPasswordResetView extends StatefulWidget {
  const CommonPasswordResetView({super.key});

  @override
  State<CommonPasswordResetView> createState() =>
      _CommonPasswordResetViewState();
}

class _CommonPasswordResetViewState extends State<CommonPasswordResetView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  AuthController authController = Get.find<AuthController>();

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return; // Exit if validation fails
    }

    if (_oldPasswordController.text == _newPasswordController.text) {
      CustomSnackBar.showError(
        'Error',
        'New password cannot be the same as the old password.',
        context,
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      CustomSnackBar.showError(
        'Error',
        'New password and confirmation do not match.',
        context,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;

      if (user == null) {
        CustomSnackBar.showError(
          'Error',
          'No user is signed in.',
          context,
        );
        return;
      }

      // Re-authenticate the user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(_newPasswordController.text);

      CustomSnackBar.showSuccess(
        'Success',
        'Password updated successfully.',
        context,
      );

      await authController.updatePassword(
          _newPasswordController.text, authController.userModel!);

      // Optionally, navigate to another page or clear fields
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred.';
      if (e.code == 'requires-recent-login') {
        errorMessage = 'Please log in again to reset your password.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'The old password is incorrect.';
      }
      CustomSnackBar.showError('Error', errorMessage, context);
    } catch (e) {
      CustomSnackBar.showError('Error', 'Error: ${e.toString()}', context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  suffixIcon: IconButton(
                    icon: Icon(_isOldPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isOldPasswordVisible = !_isOldPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isOldPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(_isNewPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isNewPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password.';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isConfirmPasswordVisible,
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _resetPassword,
                      child: const Text('Reset Password'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
