import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

MenuData<String> buildSimpleMenu(void Function(String?) onItemAction) {
  return MenuData(
    menuItems: [
      MenuItemData(
        data: 'edit',
        itemTitle: 'Edit',
        itemIcon: IconFromIconData(Icons.edit_rounded),
        onItemAction: onItemAction,
      ),
      MenuItemData(
        data: 'share',
        itemTitle: 'Share',
        itemIcon: IconFromIconData(Icons.share_rounded),
        onItemAction: onItemAction,
      ),
      MenuItemData(
        data: 'duplicate',
        itemTitle: 'Duplicate',
        itemIcon: IconFromIconData(Icons.content_copy_rounded),
        onItemAction: onItemAction,
      ),
      MenuItemData(
        data: 'archive',
        itemTitle: 'Archive',
        itemIcon: IconFromIconData(Icons.archive_rounded),
        onItemAction: onItemAction,
      ),
      MenuItemData(
        data: 'delete',
        itemTitle: 'Delete',
        itemIcon: IconFromIconData(Icons.delete_rounded),
        onItemAction: onItemAction,
      ),
    ],
  );
}
