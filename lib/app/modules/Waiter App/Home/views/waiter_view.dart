import 'package:cho_nun_btk/app/components/empty_widget.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Home/controller/home_controller.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/More/view/more_view.dart';
import 'package:cho_nun_btk/app/modules/Waiter%20App/Order%20Overview/views/waiter_overview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class WaiterHomeView extends StatelessWidget {
  WaiterHomeView({super.key});
  HomeController homeController = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    AuthController authController = Get.put(AuthController());

    bool isBlocked = authController.userModel!.blocked ?? false;

    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: buildBottomNavBar(context, themeProvider),
        body: Obx(
          () => IndexedStack(
            index: homeController.currentIndex.value,
            children: [
              // Container(),
              // Placeholder(),
              isBlocked
                  ? EmptyIllustrations(
                      title: "Blocked",
                      message:
                          "You have been blocked by the admin\nContact the admin for more information",
                      width: 60.w,
                    )
                  : OrderOverview(),

              WaiterMoreView(),
            ],
          ),
        ),
      ),
    );
  }

  NavigationBarTheme buildBottomNavBar(
      BuildContext context, ThemeProvider themeProvider) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        // indicatorColor: Colors.red,

        labelTextStyle: WidgetStateProperty.all(
          context.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode
                ? AppColors.secondaryDark
                : AppColors.secondaryLight,
          ),
        ),
      ),
      child: Obx(
        () => NavigationBar(
          onDestinationSelected: (int index) {
            homeController.changeIndex(index);
          },

          elevation: 0.4,
          backgroundColor: themeProvider.isDarkMode
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          indicatorColor: themeProvider.isDarkMode
              ? AppColors.tertiaryDark
              : AppColors.tertiaryLight,
          selectedIndex: homeController.currentIndex.value,
          // labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,

          destinations: <Widget>[
            NavigationDestination(
              icon: Icon(
                Icons.list_alt_outlined,
                color: themeProvider.isDarkMode
                    ? AppColors.secondaryDark
                    : AppColors.secondaryLight,
              ),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.menu_outlined,
                color: themeProvider.isDarkMode
                    ? AppColors.secondaryDark
                    : AppColors.secondaryLight,
              ),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
