import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

MenuData<String> buildOverlayFeedbackMenu(void Function(String?) onItemAction) {
  return MenuData(
    menuItems: [
      MenuItemData(
        data: 'colors',
        itemTitle: 'Colors',
        itemIcon: IconFromIconData(Icons.colorize_rounded),
        subMenuData: MenuData(
          menuItems: [
            MenuItemData(
              data: 'red',
              itemTitle: 'Red',
              onItemAction: onItemAction,
            ),
            MenuItemData(
              data: 'green',
              itemTitle: 'Green',
              onItemAction: onItemAction,
            ),
            MenuItemData(
              data: 'blue',
              itemTitle: 'Blue',
              onItemAction: onItemAction,
            ),
            MenuItemData(
              data: 'purple',
              itemTitle: 'Purple',
              onItemAction: onItemAction,
            ),
            MenuItemData(
              data: 'orange',
              itemTitle: 'Orange',
              onItemAction: onItemAction,
            ),
          ],
        ),
      ),
      MenuItemData(
        data: 'sizes',
        itemTitle: 'Sizes',
        itemIcon: IconFromIconData(Icons.straighten_rounded),
        subMenuData: MenuData(
          menuItems: [
            MenuItemData(
              data: 'xs',
              itemTitle: 'Extra Small',
              onItemAction: onItemAction,
            ),
            MenuItemData(
              data: 'sm',
              itemTitle: 'Small',
              onItemAction: onItemAction,
            ),
            MenuItemData(
              data: 'md',
              itemTitle: 'Medium',
              onItemAction: onItemAction,
            ),
            MenuItemData(
              data: 'lg',
              itemTitle: 'Large',
              onItemAction: onItemAction,
            ),
            MenuItemData(
              data: 'xl',
              itemTitle: 'Extra Large',
              onItemAction: onItemAction,
            ),
          ],
        ),
      ),
      MenuItemData(
        data: 'material',
        itemTitle: 'Material',
        itemIcon: IconFromIconData(Icons.category_rounded),
        onItemAction: onItemAction,
      ),
    ],
  );
}
