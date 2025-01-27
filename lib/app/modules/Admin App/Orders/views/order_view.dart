import 'package:cho_nun_btk/app/components/order_status_chip.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
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

  @override
  void initState() {
    super.initState();
    // Initialize with current date
    selectedDate = DateTime.now();
  }

  // Get start and end of selected date
  DateTime get startOfDay =>
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  DateTime get endOfDay => DateTime(
      selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

  // Stream of orders for selected date
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000), // Set appropriate start date
      lastDate: now, // Current date as the last date
      selectableDayPredicate: (DateTime date) {
        // Only allow dates up to current date
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          // TextButton.icon(
          //   icon: const Icon(Icons.calendar_today),
          //   label: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
          //   onPressed: () => _selectDate(context),
          // ),
          GestureDetector(
            onTap: () {
              _selectDate(context);
            },
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
                  )),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                  ),
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
          )
        ],
      ),
      body: StreamBuilder<List<FoodOrder>>(
        stream: getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No orders for ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                bool flag = true;

                flag = isOrderNeededToKitchen(order);
                return GestureDetector(
                  onTap: () {},
                  child: flag
                      ? Card(
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
                                          style: context.textTheme.bodyLarge!
                                              .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "#" +
                                              parseOrderId(
                                                      order.orderId)['counter']
                                                  .toString(),
                                          style: context.textTheme.bodyLarge!
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
                                          "Name:",
                                          style: context.textTheme.bodyLarge!
                                              .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          order.customerData.customerName ?? "",
                                          style: context.textTheme.bodyLarge!
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
                                  color: AppColors.primaryDark.withOpacity(0.2),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "X" +
                                              order.orderItems.length
                                                  .toString(),
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
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      : SizedBox(),
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.PENDING:
        return Icons.access_time;
      case FoodOrderStatus.PREPARING:
        return Icons.restaurant;
      case FoodOrderStatus.COMPLETED:
        return Icons.check_circle;
      case FoodOrderStatus.CANCELLED:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.PENDING:
        return Colors.orange;
      case FoodOrderStatus.PREPARING:
        return Colors.blue;
      case FoodOrderStatus.COMPLETED:
        return Colors.green;
      case FoodOrderStatus.CANCELLED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
