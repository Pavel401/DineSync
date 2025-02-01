import 'package:cho_nun_btk/app/components/order_status_chip.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Orders/views/read_only_oder_view.dart';
import 'package:cho_nun_btk/app/utils/date_utils.dart';
import 'package:cho_nun_btk/app/utils/order_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  late DateTime selectedDate;
  final ordersCollection = FirebaseFirestore.instance.collection('orders');
  FoodOrderStatus? selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  DateTime get startOfDay =>
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  DateTime get endOfDay => DateTime(
      selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

  Stream<List<FoodOrder>> getOrdersStream() {
    return ordersCollection
        .where('orderTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('orderTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
                (doc) => FoodOrder.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // New method to filter orders locally
  List<FoodOrder> filterOrders(List<FoodOrder> orders) {
    if (selectedStatus == null) return orders;
    return orders
        .where((order) => order.orderStatus == selectedStatus)
        .toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: now,
      selectableDayPredicate: (DateTime date) {
        return date.isBefore(now) ||
            date.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _handleStatusFilter(FoodOrderStatus? status) {
    setState(() {
      selectedStatus = status == selectedStatus ? null : status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              margin: EdgeInsets.only(right: 2.w),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  bottom: BorderSide(color: AppColors.primaryDark, width: 2),
                  top: BorderSide(color: AppColors.primaryDark, width: 2),
                  left: BorderSide(color: AppColors.primaryDark, width: 2),
                  right: BorderSide(color: AppColors.primaryDark, width: 2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 20),
                  SizedBox(width: 1.w),
                  Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                    style: context.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    selected: selectedStatus == FoodOrderStatus.PENDING,
                    label: Text('Pending'),
                    onSelected: (_) =>
                        _handleStatusFilter(FoodOrderStatus.PENDING),
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.orange.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selectedStatus == FoodOrderStatus.PENDING
                          ? Colors.orange
                          : Colors.black,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  FilterChip(
                    selected: selectedStatus == FoodOrderStatus.PREPARING,
                    label: Text('Preparing'),
                    onSelected: (_) =>
                        _handleStatusFilter(FoodOrderStatus.PREPARING),
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.blue.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selectedStatus == FoodOrderStatus.PREPARING
                          ? Colors.blue
                          : Colors.black,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  FilterChip(
                    selected: selectedStatus == FoodOrderStatus.COMPLETED,
                    label: Text('Completed'),
                    onSelected: (_) =>
                        _handleStatusFilter(FoodOrderStatus.COMPLETED),
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.green.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selectedStatus == FoodOrderStatus.COMPLETED
                          ? Colors.green
                          : Colors.black,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  FilterChip(
                    selected: selectedStatus == FoodOrderStatus.CANCELLED,
                    label: Text('Cancelled'),
                    onSelected: (_) =>
                        _handleStatusFilter(FoodOrderStatus.CANCELLED),
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.red.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selectedStatus == FoodOrderStatus.CANCELLED
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FoodOrder>>(
              stream: getOrdersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allOrders = snapshot.data ?? [];
                final filteredOrders = filterOrders(allOrders);

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          selectedStatus == null
                              ? 'No orders for ${DateFormat('MMM dd, yyyy').format(selectedDate)}'
                              : 'No ${selectedStatus!.name.toLowerCase()} orders for ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      bool flag = isOrderNeededToKitchen(order);

                      return flag
                          ? GestureDetector(
                              onTap: () {
                                Get.to(() => AdminOrderFlow(order: order));
                              },
                              child: Card(
                                color: AppColors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(2.w),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Order No: ",
                                                style: context
                                                    .textTheme.bodyLarge!
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "#" +
                                                    parseOrderId(order.orderId)[
                                                            'counter']
                                                        .toString(),
                                                style: context
                                                    .textTheme.bodyLarge!
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Spacer(),
                                              OrderStatusChip(
                                                  status: order.orderStatus),
                                            ],
                                          ),
                                          SizedBox(height: 2.h),
                                          Row(
                                            children: [
                                              Text(
                                                "Name: ",
                                                style: context
                                                    .textTheme.bodyLarge!
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                order.customerData
                                                        .customerName ??
                                                    "",
                                                style: context
                                                    .textTheme.bodyLarge!
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    DottedLine(
                                      dashColor: AppColors.primaryDark,
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryDark
                                            .withOpacity(0.2),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "X${order.orderItems.length}",
                                            style: context.textTheme.bodyLarge!
                                                .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(Icons.schedule),
                                          Text(
                                            DateUtilities.formatDateTime(
                                                order.orderTime),
                                            style: context.textTheme.bodySmall!
                                                .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Spacer(),
                                          Text(
                                            order.orderType!.name ==
                                                    OrderType.DINE_IN.name
                                                ? "Dine In"
                                                : "Take Away",
                                            style: context.textTheme.bodyLarge!
                                                .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : SizedBox();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
