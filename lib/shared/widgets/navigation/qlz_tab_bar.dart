import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// A customized tab bar with consistent styling for the app.
final class QlzTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<String> tabs;
  final List<Widget>? tabWidgets;
  final bool isScrollable;
  final Color? selectedColor, unselectedColor, indicatorColor;
  final double indicatorWeight;
  final bool showIndicator;
  final EdgeInsetsGeometry tabPadding;
  final TabAlignment tabAlignment;
  final double indicatorWidthFactor;
  final double height;
  final Function(int)? onTap;

  const QlzTabBar({
    super.key,
    required this.controller,
    this.tabs = const [],
    this.tabWidgets,
    this.isScrollable = false,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.indicatorWeight = 3.0,
    this.showIndicator = true,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.tabAlignment = TabAlignment.start,
    this.indicatorWidthFactor = 1.0,
    this.height = 48,
    this.onTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  List<Widget> getTabWidgets() {
    if (tabs.isEmpty && tabWidgets == null) {
      throw ArgumentError('Either `tabs` or `tabWidgets` must be provided.');
    }
    return tabWidgets ?? tabs.map((tab) => Tab(text: tab)).toList();
  }

  Map<String, Color> getEffectiveColors(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return {
      'selected': selectedColor ?? AppColors.primary,
      'unselected': unselectedColor ??
          (isDarkMode
              ? Colors.white.withOpacity(0.7)
              : Colors.black.withOpacity(0.7)),
      'indicator': indicatorColor ?? selectedColor ?? AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = getEffectiveColors(context);

    return TabBar(
      controller: controller,
      tabs: getTabWidgets(),
      isScrollable: isScrollable,
      labelColor: colors['selected'],
      unselectedLabelColor: colors['unselected'],
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      indicatorColor: colors['indicator'],
      indicatorWeight: indicatorWeight,
      indicatorSize: TabBarIndicatorSize.tab,
      padding: EdgeInsets.zero,
      tabAlignment: tabAlignment,
      dividerColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      enableFeedback: true,
      onTap: onTap,
      indicator: showIndicator
          ? UnderlineTabIndicator(
              borderSide: BorderSide(
                  width: indicatorWeight, color: colors['indicator']!),
              insets: EdgeInsets.symmetric(
                  horizontal: 16 * (1 - indicatorWidthFactor)),
            )
          : const BoxDecoration(),
    );
  }
}

/// A widget that combines a [QlzTabBar] with a [TabBarView].
final class QlzTabView extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final List<Widget>? tabWidgets;
  final List<Widget> pages;
  final bool isScrollable;
  final Color? selectedColor, unselectedColor, indicatorColor;
  final double indicatorWeight;
  final bool showIndicator;
  final double indicatorWidthFactor;
  final double tabBarHeight;
  final ScrollPhysics? physics;
  final bool enablePageChange;
  final Function(int)? onPageChanged;

  const QlzTabView({
    super.key,
    required this.controller,
    required this.pages,
    this.tabs = const [],
    this.tabWidgets,
    this.isScrollable = false,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.indicatorWeight = 3.0,
    this.showIndicator = true,
    this.indicatorWidthFactor = 1.0,
    this.tabBarHeight = 48,
    this.physics,
    this.enablePageChange = true,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if ((tabs.isEmpty && tabWidgets == null) || pages.isEmpty) {
      throw ArgumentError(
          'Both `tabs/tabWidgets` and `pages` must be provided.');
    }

    return Column(
      children: [
        QlzTabBar(
          controller: controller,
          tabs: tabs,
          tabWidgets: tabWidgets,
          isScrollable: isScrollable,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          indicatorColor: indicatorColor,
          indicatorWeight: indicatorWeight,
          showIndicator: showIndicator,
          indicatorWidthFactor: indicatorWidthFactor,
          height: tabBarHeight,
          onTap: enablePageChange
              ? null
              : (index) {
                  controller.animateTo(index);
                  onPageChanged?.call(index);
                },
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            physics: enablePageChange
                ? (physics ?? const AlwaysScrollableScrollPhysics())
                : const NeverScrollableScrollPhysics(),
            children: pages,
          ),
        ),
      ],
    );
  }
}
