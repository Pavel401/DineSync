import 'package:cho_nun_btk/app/modules/Waiter%20App/New%20Order/views/new_order.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderOverview extends StatefulWidget {
  const OrderOverview({super.key});

  @override
  State<OrderOverview> createState() => _OrderOverviewState();
}

class _OrderOverviewState extends State<OrderOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => AddNewOrderView());
          },
          child: Icon(Icons.add)),
      body: Container(
        child: Center(
          child: Text('Order Overview'),
        ),
      ),
    );
  }
}
