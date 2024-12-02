import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaiterView extends StatefulWidget {
  const WaiterView({super.key});

  @override
  State<WaiterView> createState() => _WaiterViewState();
}

class _WaiterViewState extends State<WaiterView> {
  AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  authController.signOut();
                },
                child: Row(
                  children: [
                    Text(
                      "Logout Waiter",
                      style: context.textTheme.headlineLarge!.copyWith(),
                    ),
                    Icon(Icons.logout),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
