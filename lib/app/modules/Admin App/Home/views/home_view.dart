import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:cho_nun_btk/app/constants/theme.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Analytics/views/admin_analytics_view.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Home/controller/home_controller.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Menu/views/menu_view.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/More/view/more_view.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Orders/views/order_view.dart';
import 'package:cho_nun_btk/app/modules/Admin%20App/Table/views/table_view.dart';
import 'package:cho_nun_btk/app/modules/Auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AdminHomeView extends StatelessWidget {
  AdminHomeView({super.key});
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
              OrderView(),
              AdminAnalyticsView(),
              TableBuilderView(),

              MenuView(),

              AdminMoreView(),
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
        labelTextStyle: WidgetStateProperty.all(
          context.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryLight,
          ),
        ),
      ),
      child: Obx(
        () => NavigationBar(
          onDestinationSelected: (int index) {
            homeController.changeIndex(index);
          },
          elevation: 0.4,
          backgroundColor: AppColors.primaryLight.withOpacity(0.1),
          indicatorColor: AppColors.tertiaryLight,
          selectedIndex: homeController.currentIndex.value,
          destinations: <Widget>[
            NavigationDestination(
              icon: Icon(
                Icons.list_alt_outlined,
                color: AppColors.secondaryLight,
              ),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.analytics_outlined,
                color: AppColors.secondaryLight,
              ),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.table_bar,
                color: AppColors.secondaryLight,
              ),
              label: 'Table',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.menu_book_outlined,
                color: AppColors.secondaryLight,
              ),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_outlined, color: AppColors.secondaryLight),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
