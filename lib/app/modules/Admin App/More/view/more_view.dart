import 'package:cho_nun_btk/app/components/custom_buttons.dart';
import 'package:cho_nun_btk/app/components/settings_tile.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/More/view/staff_management.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/Profile/view/profile_view.dart';
import 'package:cho_nun_btk/app/provider/menuProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AdminMoreView extends StatefulWidget {
  const AdminMoreView({super.key});

  @override
  State<AdminMoreView> createState() => _AdminMoreViewState();
}

class _AdminMoreViewState extends State<AdminMoreView> {
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
            SizedBox(height: 2.h),

            CafeMoreTileWidget(
              icon: Icons.settings_outlined,
              title: 'Staff Management',
              subtitle: 'View and manage your settings',
              onTap: () {
                Get.to(() => StaffManagementView());
              },
            ),

            SizedBox(height: 2.h),
            kDebugMode
                ? CafeMoreTileWidget(
                    icon: Icons.settings_outlined,
                    title: 'Sync Menu with Global Menu',
                    subtitle: 'Sync your menu with global menu',
                    onTap: () {
                      Menuprovider menuprovider = Menuprovider();
                      menuprovider.syncMenuWithGlobalMenu();
                    },
                  )
                : SizedBox(),

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
