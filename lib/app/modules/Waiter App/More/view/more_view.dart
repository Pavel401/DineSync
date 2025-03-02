import 'package:cho_nun_btk/app/components/custom_buttons.dart';
import 'package:cho_nun_btk/app/components/settings_tile.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/enums.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:cho_nun_btk/app/models/menu/menu.dart';
import 'package:cho_nun_btk/app/models/order/foodOrder.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/Profile/view/profile_view.dart';
import 'package:cho_nun_btk/app/services/fcm_notification.dart';
import 'package:cho_nun_btk/app/services/registry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class WaiterMoreView extends StatefulWidget {
  const WaiterMoreView({super.key});

  @override
  State<WaiterMoreView> createState() => _WaiterMoreViewState();
}

class _WaiterMoreViewState extends State<WaiterMoreView> {
  final AuthController authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CafeMoreTileWidget(
              icon: Icons.person_outline,
              title: 'Profile',
              subtitle: 'View and edit your profile',
              onTap: () {
                Get.to(
                  () => WaiterProfileView(
                    userModel: authController.userModel!,
                  ),
                );
              },
            ),
            // SizedBox(height: 2.h),

            // kDebugMode
            //     ? CafeMoreTileWidget(
            //         icon: Icons.settings_outlined,
            //         title: 'Test RAW Label Printer',
            //         subtitle: 'THis is the test for the nimboo label printer',
            //         onTap: () {
            //           Get.to(
            //             () => LablePrinterView(),
            //           );
            //         },
            //       )
            //     : SizedBox(),

            // SizedBox(height: 2.h),

            // CafeMoreTileWidget(
            //   icon: Icons.settings_outlined,
            //   title: 'Test Firebase Analytics',
            //   subtitle: 'THis is the test firebase analytics',
            //   onTap: () async {
            //     print('Tapped on Firebase Analytics');
            //     AnalyticsService analyticsService = AnalyticsService();

            //     try {
            //       await analyticsService.logEvent(
            //         eventName: 'created_new_order',
            //         parameters: <String, Object>{
            //           Analytics.TAP_SKILL_CARD: 'created_new_order',
            //         },
            //       );
            //     } catch (error) {
            //       print('Error in logging event: $error');
            //     }
            //   },
            // ),

            SizedBox(height: 2.h),

            // // Switch Theme
            // CafeMoreTileWidget(
            //   showRightArrow: false,
            //   icon: Get.isDarkMode
            //       ? Icons.light_mode_outlined
            //       : Icons.dark_mode_outlined,
            //   title: Get.isDarkMode ? 'Light Mode' : 'Dark Mode',
            //   subtitle: Get.isDarkMode
            //       ? 'Switch to light mode'
            //       : 'Switch to dark mode',
            //   onTap: () {
            //     themeProvider.toggleTheme();
            //   },
            // ),
            // SizedBox(height: 2.h),

            CafeMoreTileWidget(
              icon: Icons.logout_outlined,
              title: 'Logout',
              subtitle: 'Logout from your account',
              onTap: () async {
                bool shouldLogout =
                    await logOutConfirmationDialog(context) ?? false;
                if (shouldLogout) {
                  EasyLoading.show();
                  if (await authController.signOut()) {
                    EasyLoading.dismiss();
                  }
                  EasyLoading.dismiss();
                }
              },
            ),
            SizedBox(height: 2.h),
            kDebugMode
                ? CafeMoreTileWidget(
                    icon: Icons.logout_outlined,
                    title: 'Test Order Notification',
                    subtitle: 'Send a test order notification',
                    onTap: () async {
                      try {
                        FcmNotificationProvider fcmNotificationProvider =
                            serviceLocator<FcmNotificationProvider>();

                        // Create a test FoodOrder object
                        FoodOrder order = FoodOrder(
                          waiterData: WaiterData(
                            waiterId: 'test_waiter_id',
                            waiterName: 'Test Waiter',
                          ),
                          orderId: 'test_order_id',
                          orderTime: DateTime.now(),
                          customerData:
                              CustomerData(customerName: 'Test Customer'),
                          orderItems: {
                            FoodItem(
                              foodId: 'test_food_id',
                              foodDescription: "Test Description",
                              foodCategory: FoodCategory(
                                categoryId: 'test_category_id',
                                categoryName: 'Test Category',
                                categoryImage:
                                    'https://firebasestorage.googleapis.com/v0/b/cho-nun-bar-to-kitchen.firebasestorage.app/o/categories%2F0r9HzwviHybzswNHDUUv.jpg?alt=media&token=3348afc1-6d9a-421b-993a-076443e6287a',
                              ),
                              foodName: 'Test Food',
                              foodPrice: 100,
                              foodImage:
                                  'https://firebasestorage.googleapis.com/v0/b/cho-nun-bar-to-kitchen.firebasestorage.app/o/categories%2F0r9HzwviHybzswNHDUUv.jpg?alt=media&token=3348afc1-6d9a-421b-993a-076443e6287a',
                            ): 1,
                          },
                          orderStatus: FoodOrderStatus.PENDING,
                          orderType: OrderType.DINE_IN,
                          totalAmount: 100,
                        );

                        // Send the test order notification
                        QueryStatus status = await fcmNotificationProvider
                            .sendOrderNotificationToKitchen(order);

                        // Show feedback based on the result
                        if (status == QueryStatus.SUCCESS) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Test notification sent successfully!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Failed to send test notification.')),
                          );
                        }
                      } catch (error) {
                        // Handle any unexpected errors
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error')),
                        );
                      }
                    },
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<dynamic> logOutConfirmationDialog(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Padding(
            padding: EdgeInsets.fromLTRB(2.w, 3.h, 2.w, 1.h),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              direction: Axis.vertical,
              children: [
                Icon(
                  Icons.logout_outlined,
                  size: 20.w,
                  color: isDarkMode
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Oh no! You are leaving...',
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Are you sure?',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                CafePrimaryButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  buttonTitle: 'Naah, I\'ll stay <3',
                  width: 45.w,
                ),
                SizedBox(height: 1.h),
                CafeSecondaryButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  buttonTitle: 'Log me out!',
                  width: 45.w,
                ),
              ],
            ),
          ),
          // actions: [
          //   TurfitPrimaryButton(
          //     onPressed: () {
          //       Navigator.pop(context, false);
          //     },
          //     buttonTitle: 'Cancel',
          //     width: 12.w,
          //   ),
          //   TurfitSecondaryButton(
          //     onPressed: () {
          //       Navigator.pop(context, true);
          //     },
          //     buttonTitle: 'Logout',
          //     width: 14.w,
          //   ),
          // ],
        );
      },
    );
  }
}
