// lib/shared/widgets/data_display/qlz_list.dart

import 'package:flutter/material.dart';

/// A customized list widget with item separator and support for
/// swipe actions, pull-to-refresh, and infinite loading.
final class QlzList<T> extends StatelessWidget {
  /// The list of items to display.
  final List<T> items;

  /// Builder function for list items.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// The padding around the list.
  final EdgeInsetsGeometry padding;

  /// Whether to add a separation between items.
  final bool addSeparator;

  /// Custom separator widget between items.
  final Widget? separator;

  /// Whether the list is loading more items.
  final bool isLoading;

  /// Whether the list has more items to load.
  final bool hasMoreItems;

  /// Callback when the user refreshes the list.
  final Future<void> Function()? onRefresh;

  /// Callback when the user scrolls to the bottom of the list.
  final VoidCallback? onLoadMore;

  /// How many items from the bottom before triggering onLoadMore.
  final int loadMoreThreshold;

  /// Custom widget to display when the list is empty.
  final Widget? emptyWidget;

  /// The loading indicator widget.
  final Widget? loadingWidget;

  /// The scroll controller.
  final ScrollController? scrollController;

  /// Scroll physics for the list.
  final ScrollPhysics? physics;

  /// Whether to shrink wrap the list.
  final bool shrinkWrap;

  /// Left-to-right swipe action.
  final Widget Function(BuildContext context, T item, int index)?
      leftSwipeAction;

  /// Right-to-left swipe action.
  final Widget Function(BuildContext context, T item, int index)?
      rightSwipeAction;

  /// Callback when left swipe is completed.
  final void Function(T item, int index)? onLeftSwipe;

  /// Callback when right swipe is completed.
  final void Function(T item, int index)? onRightSwipe;

  const QlzList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.padding = const EdgeInsets.all(16),
    this.addSeparator = true,
    this.separator,
    this.isLoading = false,
    this.hasMoreItems = false,
    this.onRefresh,
    this.onLoadMore,
    this.loadMoreThreshold = 3,
    this.emptyWidget,
    this.loadingWidget,
    this.scrollController,
    this.physics,
    this.shrinkWrap = false,
    this.leftSwipeAction,
    this.rightSwipeAction,
    this.onLeftSwipe,
    this.onRightSwipe,
  });

  @override
  Widget build(BuildContext context) {
    // If list is empty, show empty widget
    if (items.isEmpty && !isLoading) {
      return emptyWidget ?? _buildDefaultEmptyWidget(context);
    }

    // Create a scroll controller if not provided
    final controller = scrollController ?? ScrollController();

    // Add scroll listener for infinite loading
    if (onLoadMore != null && scrollController == null) {
      controller.addListener(() {
        if (hasMoreItems && !isLoading) {
          final maxScroll = controller.position.maxScrollExtent;
          final currentScroll = controller.position.pixels;
          final delta = MediaQuery.of(context).size.height * 0.2;

          if (maxScroll - currentScroll <= delta) {
            onLoadMore?.call();
          }
        }
      });
    }

    // Build the list
    Widget listWidget = ListView.separated(
      controller: controller,
      padding: padding,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      itemCount: items.length + (isLoading && hasMoreItems ? 1 : 0),
      separatorBuilder: (context, index) {
        if (!addSeparator) return const SizedBox.shrink();
        return separator ?? const Divider(height: 1);
      },
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom if loading more
        if (index == items.length) {
          return loadingWidget ??
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              );
        }

        // Build list item with swipe actions if provided
        final item = items[index];
        final listItem = itemBuilder(context, item, index);

        // If no swipe actions, return simple list item
        if (leftSwipeAction == null && rightSwipeAction == null) {
          return listItem;
        }

        // Otherwise, wrap with dismissible for swipe actions
        return Dismissible(
          key: ValueKey('${item.hashCode}-$index'),
          background: leftSwipeAction != null
              ? leftSwipeAction!(context, item, index)
              : null,
          secondaryBackground: rightSwipeAction != null
              ? rightSwipeAction!(context, item, index)
              : null,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              onLeftSwipe?.call(item, index);
            } else {
              onRightSwipe?.call(item, index);
            }
            return false; // Don't actually dismiss the item
          },
          child: listItem,
        );
      },
    );

    // Add pull-to-refresh if needed
    if (onRefresh != null) {
      listWidget = RefreshIndicator(
        onRefresh: onRefresh!,
        child: listWidget,
      );
    }

    return listWidget;
  }

  Widget _buildDefaultEmptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
          ),
        ],
      ),
    );
  }
}
