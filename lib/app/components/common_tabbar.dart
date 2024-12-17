import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

//Common Tab Bar that can be used in various screens
// titleAndWidget: it is a map object that contains title(at the top) and the widget to be displayed
// isInBetween: Set this to true when tabbar is used in between the screen (that is along with other widgets)
//example:
/*
EsCommonTabBar(
        titleAndWidget: {
          'Cohorts': CohortHome(),
          'Clubs': Container(),
          'Events': EventsHomePage(),
          'SIGS': Container(),
        },
  ) */

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({
    super.key,
    required this.titleAndWidget,
    required this.isInBetween,
    this.backgroundColor,
    this.pagePadding = EdgeInsets.zero,
    this.dense = false,
    this.onTap,
  });
  final Color? backgroundColor;
  final Map<String, dynamic> titleAndWidget;
  final EdgeInsets pagePadding;
  final bool dense;
  final Function()? onTap;

  /// Set this to true when tabbar is used in between the screen (with other widgets in the column)
  final bool isInBetween;

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final tabBarKey = GlobalKey();
  double bottomLinePos = 0;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: widget.titleAndWidget.keys.length,
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox box = tabBarKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        bottomLinePos = box.size.height - 2.3.h;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isScrollable = widget.titleAndWidget.keys.length > 2;
    return Column(
      children: [
        Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                top: bottomLinePos == 0 ? 5.h : bottomLinePos,
                left: widget.dense ? 1.w : 4.w,
                right: widget.dense ? 1.w : 4.w,
              ),
              height: 1,
              decoration: BoxDecoration(color: AppColors.primaryLight),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: widget.dense ? 1.w : 4.w,
              ),
              child: TabBar(
                key: tabBarKey,
                onTap: (value) {
                  if (widget.onTap != null) {
                    widget.onTap!();
                  }
                  setState(() {});
                },
                isScrollable: isScrollable,
                tabAlignment: isScrollable ? TabAlignment.start : null,
                indicator: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  color: widget.backgroundColor ??
                      Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryLight,
                      offset: Offset(4, -2),
                      spreadRadius: 0,
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: AppColors.primaryLight,
                      offset: Offset(-1, -2),
                      spreadRadius: 0,
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: widget.backgroundColor ??
                          Theme.of(context).scaffoldBackgroundColor,
                      offset: Offset(0, 2),
                      spreadRadius: 0,
                      blurRadius: 0,
                    ),
                  ],
                ),
                padding: EdgeInsets.only(
                  top: 2.h,
                  bottom: 2.h,
                  left: 1,
                  right: 4,
                ),
                labelPadding: EdgeInsets.symmetric(vertical: 0.5.h),
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: context.textTheme.bodySmall,
                unselectedLabelStyle: context.textTheme.bodyMedium,
                dividerColor: Colors.transparent,
                overlayColor: MaterialStatePropertyAll(Colors.transparent),
                indicatorColor: Colors.transparent,
                tabs: [
                  for (String title in widget.titleAndWidget.keys)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      constraints: BoxConstraints(minWidth: 20.w),
                      child: Center(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (!widget.isInBetween)
          Expanded(
            child: Padding(
              padding: widget.pagePadding,
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  for (var widget in widget.titleAndWidget.values) widget,
                ],
              ),
            ),
          ),
        if (widget.isInBetween)
          widget.titleAndWidget.values.toList()[_tabController.index]!
      ],
    );
  }
}
