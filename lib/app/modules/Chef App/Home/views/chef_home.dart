import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Home/controller/home_controller.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:cho_nun_btk/app/modules/Chef%20App/More/views/more_view.dart';
import 'package:cho_nun_btk/app/modules/Chef%20App/OverView/views/overview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ChefHomeView extends StatelessWidget {
  ChefHomeView({super.key});
  HomeController homeController = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    AuthController authController = Get.put(AuthController());

    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: buildBottomNavBar(context, themeProvider),
        body: Obx(
          () => IndexedStack(
            index: homeController.currentIndex.value,
            children: [
              // Container(),
              // Placeholder(),
              KitchenOverView(),

              ChefMoreView(),
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
            // NavigationDestination(
            //   icon: Icon(
            //     Icons.history_outlined,
            //     color: themeProvider.isDarkMode
            //         ? AppColors.secondaryDark
            //         : AppColors.secondaryLight,
            //   ),
            //   label: 'History',
            // ),
            NavigationDestination(
              icon: Icon(
                Icons.list_alt_outlined,
                color: themeProvider.isDarkMode
                    ? AppColors.secondaryDark
                    : AppColors.secondaryLight,
              ),
              label: 'Orders',
            ),
            // NavigationDestination(
            //   icon: Icon(
            //     Icons.menu_book_outlined,
            //     color: themeProvider.isDarkMode
            //         ? AppColors.secondaryDark
            //         : AppColors.secondaryLight,
            //   ),
            //   label: 'Menu',
            // ),
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
