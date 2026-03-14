import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:menu/src/configs/menu_layout_config.dart';
import 'package:menu/src/models/menu_data.dart';
import 'package:menu/src/models/menu_item_data.dart';
import 'package:menu/src/ui/feedback/click_feedback_container.dart';

class Menu<D> extends StatelessWidget {
  /// # The data for the menu to be shown.
  final MenuData<D> menuData;

  /// ### Build menu item widget.
  ///
  /// Note: Do not wrap the returning widget with any user event
  /// detector like `InkWell` or `GestureDetector`. You just provide
  /// the UI that the user will look at and the we will handle the rest.
  ///
  /// For customizing the visual feedback on click events, see the
  /// [MenuData.menuLayoutConfig] and
  /// [MenuLayoutConfig.selectionFeedbackConfig].
  final Widget Function(
    int index,
    int hostMenuSize,
    MenuItemData<D> itemData,
  ) menuItemBuilder;

  /// ### Build menu header widget.
  /// If omitted, no headers will be shown.
  ///
  /// Params:
  /// - `menuContext` :
  ///   The [BuildContext] of the menu.
  ///   You may use this to cancel the menu or do other stuff.
  /// - `submenuRootMenuItemData` :
  ///   - For the root menu, this will always be null.
  ///   - If the currently showing menu is a submenu, this will be non-null.
  ///
  /// You may use the `submenuRootMenuItemData` to customize your header
  /// based on the parent of the current submenu, such as showing the title
  /// and icon of the parent menu item.
  final Widget Function(
    BuildContext menuContext,
    MenuItemData<D>? submenuRootMenuItemData,
  )? menuHeaderBuilder;

  /// ### Build menu item separator widget.
  /// If omitted, no separator is shown.
  ///
  /// You can use the callback params to determine the position of the
  final Widget Function(
    int index,
    int hostMenuSize,
    MenuItemData<D> itemData,
  )? separatorBuilder;

  /// ### Submenu request callback.
  /// If omitted, submenu requests are not sent.
  ///
  /// If the selected menu item contains a submenu, first it will pop
  /// the current menu using [onPop] (or Default [Navigator.pop] if [onPop]
  /// was not provided), and then [onSubmenuRequest] will be called with the
  /// submenu data. It is the user's responsibility to open the submenu the
  /// way he opened the menu.
  final void Function(
    BuildContext menuContext,
    MenuData<D> submenuData,
  )? onSubmenuRequest;

  /// # Handle pop action
  /// If omitted, will use the default [Navigator.pop].
  ///
  /// Used to dismiss or pop the current menu when a selection is made.
  final void Function(BuildContext menuContext)? onPop;

  /// # Create a [Menu] widget
  /// Please see the doc for each parameters for more info.
  const Menu({
    super.key,
    required this.menuData,
    required this.menuItemBuilder,
    this.menuHeaderBuilder,
    this.separatorBuilder,
    this.onSubmenuRequest,
    this.onPop,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: menuData.menuLayoutConfig.shrinkWrap,
      physics: menuData.menuLayoutConfig.scrollPhysics,
      padding: menuData.menuLayoutConfig.padding,
      itemCount: menuData.menuItems.length + 1,
      separatorBuilder: (_, index) => _buildSeparator(index),
      itemBuilder: _buildMenuItem,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return menuHeaderBuilder?.call(context, null) ?? const SizedBox.shrink();
  }

  Widget _buildSeparator(int index) {
    if (index == 0 || separatorBuilder == null) {
      return const SizedBox();
    }

    return separatorBuilder!(
      index - 1,
      menuData.menuItems.length,
      menuData.menuItems[index - 1],
    );
  }

  Widget _buildMenuItem(BuildContext context, int index) {
    if (index == 0) {
      return _buildHeader(context);
    }

    final itemIndex = index - 1;
    final itemData = menuData.menuItems[itemIndex];
    return ClickFeedbackContainer(
      feedbackConfig: menuData.menuLayoutConfig.selectionFeedbackConfig,
      onTap: () => _handleTap(context, itemData),
      child: menuItemBuilder(
        itemIndex,
        menuData.menuItems.length,
        itemData,
      ),
    );
  }

  void _handleTap(BuildContext context, MenuItemData<D> itemData) {
    // pop the current menu page
    onPop != null ? onPop!(context) : Navigator.pop(context);

    // fire the given callback for this item
    itemData.onItemAction?.call(itemData.data);

    // if there is a non-empty submenu, send request to open it
    // (if `onSubmenuRequest` is not null)
    final submenu = itemData.subMenuData;
    if (submenu != null && submenu.menuItems.isNotEmpty) {
      onSubmenuRequest?.call(context, submenu);
    }
  }
}
