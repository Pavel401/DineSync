// import 'package:cho_nun_btk/app/components/order_status_chip.dart';
// import 'package:cho_nun_btk/app/constants/colors.dart';
// import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
// import 'package:cho_nun_btk/app/utils/date_utils.dart';
// import 'package:cho_nun_btk/app/utils/order_parser.dart';
// import 'package:dotted_line/dotted_line.dart';
// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';

// class OrderCard extends StatelessWidget {
//   final FoodOrder order;
//   final VoidCallback? onTap;

//   const OrderCard({
//     Key? key,
//     required this.order,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final flag = isOrderNeededToKitchen(order);
//     if (!flag) return const SizedBox();

//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         color: AppColors.white,
//         elevation: 3,
//         margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.all(3.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Order number & status
//                   Row(
//                     children: [
//                       Text(
//                         "Order No: ",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Text(
//                         "#${parseOrderId(order.orderId)['counter']}",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const Spacer(),
//                       OrderStatusChip(status: order.orderStatus),
//                     ],
//                   ),
//                   SizedBox(height: 1.h),

//                   // Table number
//                   if (order.customerData.customerSeatingPlace != null)
//                     Padding(
//                       padding: EdgeInsets.only(bottom: 0.5.h),
//                       child: Row(
//                         children: [
//                           Text(
//                             "Table No: ",
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           Text(
//                             order.customerData.customerSeatingPlace!,
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.errorLight,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   // Customer Name
//                   if (order.customerData.customerName != null &&
//                       order.customerData.customerName!.isNotEmpty)
//                     Row(
//                       children: [
//                         Text(
//                           "Name: ",
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Text(
//                           order.customerData.customerName.toString(),
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
// DottedLine(
//   dashColor: AppColors.primaryDark,
//   dashLength: 6,
//   lineThickness: 1,
// ),
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(3.w),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryDark.withOpacity(0.08),
//                 borderRadius: const BorderRadius.vertical(
//                   bottom: Radius.circular(12),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Text(
//                     "x${order.orderItems.length}",
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   const Icon(Icons.schedule, size: 18),
//                   SizedBox(width: 1.w),
//                   Text(
//                     DateUtilities.formatDateTime(order.orderTime),
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     order.orderType == OrderType.DINE_IN
//                         ? "Dine In"
//                         : "Take Away",
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.primaryLight,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';

import 'package:cho_nun_btk/app/components/order_status_chip.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/utils/date_utils.dart';
import 'package:cho_nun_btk/app/utils/order_parser.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// class OrderCard extends StatelessWidget {
//   final FoodOrder order;
//   final VoidCallback? onTap;

//   const OrderCard({
//     Key? key,
//     required this.order,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final flag = isOrderNeededToKitchen(order);
//     if (!flag) return const SizedBox();

//     final textTheme = Theme.of(context).textTheme;
//     final bool isUrgent = _isOrderUrgent(order);

//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         color: AppColors.white,
//         elevation: 2, // Reduced elevation for minimalism
//         margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10), // Slightly reduced radius
//         ),
//         child: Column(
//           children: [
//             // Header section with order ID and status
//             Container(
//               decoration: BoxDecoration(
//                 color: AppColors.primaryDark
//                     .withOpacity(0.03), // Lighter background
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(10),
//                 ),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
//               child: Row(
//                 children: [
//                   // Order counter with larger font
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Text(
//                           "#${parseOrderId(order.orderId)['counter']}",
//                           style: textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w800,
//                             fontSize: 15, // Increased font size
//                           ),
//                         ),
//                         if (order.orderType != null)
//                           Padding(
//                             padding: EdgeInsets.only(left: 2.w),
//                             child: _buildOrderTypeIndicator(order.orderType!),
//                           ),
//                       ],
//                     ),
//                   ),
//                   // Status chip
//                   OrderStatusChip(status: order.orderStatus),
//                 ],
//               ),
//             ),

//             // Main content section
//             Padding(
//               padding:
//                   EdgeInsets.all(4.w), // Increased padding for better spacing
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Table number & customer name with proper labels
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Table information with label
//                       if (order.customerData.customerSeatingPlace != null)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Table",
//                               style: textTheme.bodySmall?.copyWith(
//                                 color: Colors.grey[600],
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 11,
//                               ),
//                             ),
//                             SizedBox(height: 0.5.h),
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 2.5.w, vertical: 0.7.h),
//                               decoration: BoxDecoration(
//                                 color: AppColors.errorLight.withOpacity(0.08),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.table_bar,
//                                     size: 16,
//                                     color: AppColors.errorLight,
//                                   ),
//                                   SizedBox(width: 1.w),
//                                   Text(
//                                     order.customerData.customerSeatingPlace!,
//                                     style: textTheme.bodyMedium?.copyWith(
//                                       fontWeight: FontWeight.w700,
//                                       color: AppColors.errorLight,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),

//                       SizedBox(height: 1.5.h),

//                       // Customer name with label
//                       if (order.customerData.customerName != null &&
//                           order.customerData.customerName!.isNotEmpty)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Customer",
//                               style: textTheme.bodySmall?.copyWith(
//                                 color: Colors.grey[600],
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 11,
//                               ),
//                             ),
//                             SizedBox(height: 0.5.h),
//                             Text(
//                               order.customerData.customerName.toString(),
//                               style: textTheme.bodyMedium?.copyWith(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                                 color: Colors.black87,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),

//                   SizedBox(height: 2.2.h), // Increased spacing

//                   // Order items overview - simplified
//                   Row(
//                     children: [
//                       // Items count with icon
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 2.w, vertical: 0.5.h),
//                         decoration: BoxDecoration(
//                           color: AppColors.primaryDark
//                               .withOpacity(0.06), // Lighter bg
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.restaurant_menu,
//                               size: 16, // Increased icon size
//                               color: AppColors.primaryDark,
//                             ),
//                             SizedBox(width: 1.w),
//                             Text(
//                               "${order.orderItems.length} items",
//                               style: textTheme.bodyMedium?.copyWith(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13, // Increased font size
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Special instructions indicator - simplified
//                       if (order.specialInstructions != null &&
//                           order.specialInstructions!.isNotEmpty)
//                         Padding(
//                           padding: EdgeInsets.only(left: 2.w),
//                           child: Icon(
//                             Icons.info_outline,
//                             size: 16, // Increased icon size
//                             color: AppColors.primaryLight,
//                           ),
//                         ),

//                       Spacer(),

//                       // Order time with simplified format
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.schedule,
//                             size: 16, // Increased icon size
//                             color: isUrgent
//                                 ? AppColors.errorLight
//                                 : Colors.grey[600],
//                           ),
//                           SizedBox(width: 1.w),
//                           Text(
//                             DateUtilities.formatDateTime(order.orderTime),
//                             style: textTheme.bodySmall?.copyWith(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 12, // Increased font size
//                               color: isUrgent
//                                   ? AppColors.errorLight
//                                   : Colors.grey[700],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             DottedLine(
//               dashColor: AppColors.primaryDark,
//               dashLength: 6,
//               lineThickness: 1,
//             ),
//             // Footer - simplified
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFA5D6A7)
//                     .withOpacity(0.08), // Soft leafy pastel

//                 borderRadius: const BorderRadius.vertical(
//                   bottom: Radius.circular(10),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Time elapsed indicator
//                   _buildTimeElapsedIndicator(order.orderTime),

//                   // View details button - simplified
//                   Row(
//                     children: [
//                       Text(
//                         "Details",
//                         style: textTheme.bodyMedium?.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.primaryDark,
//                           fontSize: 13, // Increased font size
//                         ),
//                       ),
//                       SizedBox(width: 1.w),
//                       Icon(
//                         Icons.arrow_forward_ios,
//                         size: 14, // Increased icon size
//                         color: AppColors.primaryDark,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper method to determine if an order is urgent based on time elapsed
//   bool _isOrderUrgent(FoodOrder order) {
//     final currentTime = DateTime.now();
//     final difference = currentTime.difference(order.orderTime).inMinutes;

//     // Consider orders older than 15 minutes as urgent
//     return difference > 15 &&
//         (order.orderStatus == FoodOrderStatus.PENDING ||
//             order.orderStatus == FoodOrderStatus.PREPARING);
//   }

//   // Widget for displaying order type with icon - simplified
//   Widget _buildOrderTypeIndicator(OrderType type) {
//     IconData icon;
//     String text;
//     Color color;

//     switch (type) {
//       case OrderType.DINE_IN:
//         icon = Icons.restaurant;
//         text = "Dine In";
//         color = AppColors.primaryLight;
//         break;
//       case OrderType.TAKE_AWAY:
//         icon = Icons.takeout_dining;
//         text = "Take Away";
//         color = Colors.amber[700]!;
//         break;
//     }

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.08), // Lighter background
//         borderRadius: BorderRadius.circular(5),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 14, // Increased icon size
//             color: color,
//           ),
//           SizedBox(width: 1.w),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 11, // Increased font size
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimeElapsedIndicator(DateTime orderTime) {
//     final currentTime = DateTime.now();
//     final difference = currentTime.difference(orderTime).inMinutes;

//     // If more than 3 hours, don't show the indicator
//     if (difference > 180) return const SizedBox();

//     Color indicatorColor;
//     String text = "$difference min";

//     if (difference < 10) {
//       indicatorColor = Colors.green;
//     } else if (difference < 20) {
//       indicatorColor = Colors.amber;
//     } else {
//       indicatorColor = AppColors.errorLight;
//     }

//     return Row(
//       children: [
//         Container(
//           width: 10,
//           height: 10,
//           decoration: BoxDecoration(
//             color: indicatorColor,
//             shape: BoxShape.circle,
//           ),
//         ),
//         SizedBox(width: 1.w),
//         Text(
//           text,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: indicatorColor,
//           ),
//         ),
//       ],
//     );
//   }
// }
class OrderCard extends StatefulWidget {
  final FoodOrder order;
  final VoidCallback? onTap;
  final bool? isAdmin;

  const OrderCard({
    Key? key,
    required this.order,
    this.onTap,
    this.isAdmin,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  late ValueNotifier<Duration> elapsedTimeNotifier;
  Timer? _timer;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    elapsedTimeNotifier = ValueNotifier(_getElapsedTime());
    _checkOrderCompletion();
    if (!isCompleted) {
      _startTimer();
    }
  }

  Duration _getElapsedTime() {
    final now = DateTime.now();
    return now.difference(widget.order.orderTime);
  }

  void _checkOrderCompletion() {
    isCompleted = widget.order.orderStatus == FoodOrderStatus.COMPLETED ||
        widget.order.orderStatus == FoodOrderStatus.CANCELLED;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      elapsedTimeNotifier.value = _getElapsedTime();
      if (widget.order.orderStatus == FoodOrderStatus.COMPLETED ||
          widget.order.orderStatus == FoodOrderStatus.CANCELLED) {
        isCompleted = true;
        _timer?.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(covariant OrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.orderStatus != widget.order.orderStatus) {
      _checkOrderCompletion();
      if (isCompleted) {
        _timer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    elapsedTimeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowOrder =
        widget.isAdmin == true || isOrderNeededToKitchen(widget.order);
    if (!shouldShowOrder) return const SizedBox();

    final textTheme = Theme.of(context).textTheme;
    final bool isUrgent = _isOrderUrgent(widget.order);

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: AppColors.white,
        elevation: 1,
        margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.02),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "#${parseOrderId(widget.order.orderId)['counter']}",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (widget.order.orderType != null)
                          Padding(
                            padding: EdgeInsets.only(left: 1.5.w),
                            child: _buildOrderTypeIndicator(
                                widget.order.orderType!),
                          ),
                      ],
                    ),
                  ),
                  OrderStatusChip(status: widget.order.orderStatus),
                ],
              ),
            ),

            // Body
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.order.customerData.customerSeatingPlace != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Table",
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(height: 0.4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.4.h),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.table_bar,
                                  size: 14, color: AppColors.errorLight),
                              SizedBox(width: 1.w),
                              Text(
                                widget.order.customerData.customerSeatingPlace!,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppColors.errorLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (widget.order.customerData.customerName != null &&
                      widget.order.customerData.customerName!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 0.8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Customer",
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            widget.order.customerData.customerName!,
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 1.5.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.restaurant_menu,
                                size: 14, color: AppColors.primaryDark),
                            SizedBox(width: 1.w),
                            Text(
                              "${widget.order.orderItems.length} items",
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.order.specialInstructions?.isNotEmpty ?? false)
                        Padding(
                          padding: EdgeInsets.only(left: 2.w),
                          child: Icon(Icons.info_outline,
                              size: 14, color: AppColors.primaryLight),
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 14,
                              color: isUrgent
                                  ? AppColors.errorLight
                                  : Colors.grey[600]),
                          SizedBox(width: 1.w),
                          Text(
                            DateUtilities.formatDateTime(
                                widget.order.orderTime),
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isUrgent
                                  ? AppColors.errorLight
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            DottedLine(
              dashColor: AppColors.primaryDark,
              dashLength: 5,
              lineThickness: 0.8,
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFA5D6A7).withOpacity(0.05),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder<Duration>(
                    valueListenable: elapsedTimeNotifier,
                    builder: (context, value, _) {
                      return isCompleted
                          ? _buildCompletionTimeIndicator(value)
                          : _buildRealTimeElapsedIndicator(value);
                    },
                  ),
                  Row(
                    children: [
                      Text(
                        "Details",
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(Icons.arrow_forward_ios,
                          size: 12, color: AppColors.primaryDark),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isOrderUrgent(FoodOrder order) {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(order.orderTime).inMinutes;
    return difference > 15 &&
        (order.orderStatus == FoodOrderStatus.PENDING ||
            order.orderStatus == FoodOrderStatus.PREPARING);
  }

  Widget _buildOrderTypeIndicator(OrderType type) {
    IconData icon;
    String text;
    Color color;

    switch (type) {
      case OrderType.DINE_IN:
        icon = Icons.restaurant;
        text = "Dine In";
        color = AppColors.primaryLight;
        break;
      case OrderType.TAKE_AWAY:
        icon = Icons.takeout_dining;
        text = "Take Away";
        color = Colors.amber[700]!;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 1.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeElapsedIndicator(Duration elapsedTime) {
    if (elapsedTime.inMinutes > 180) return const SizedBox();

    final minutes = elapsedTime.inMinutes;
    final seconds = elapsedTime.inSeconds % 60;

    Color indicatorColor;
    if (minutes < 10) {
      indicatorColor = Colors.green;
    } else if (minutes < 20) {
      indicatorColor = Colors.amber;
    } else {
      indicatorColor = AppColors.errorLight;
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          '${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: indicatorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionTimeIndicator(Duration elapsedTime) {
    final minutes = elapsedTime.inMinutes;
    final seconds = elapsedTime.inSeconds % 60;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.green[700],
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          'Completed in ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }
}
