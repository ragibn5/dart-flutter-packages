import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

import 'package:example/widgets/menu_header.dart';
import 'package:example/widgets/menu_item.dart';

class MenuSheet extends StatelessWidget {
  const MenuSheet({
    super.key,
    required this.title,
    required this.menuData,
    required this.parent,
    required this.onSubmenuRequest,
  });

  final String title;
  final MenuData<String> menuData;
  final MenuItemData<String>? parent;
  final void Function(
    BuildContext context,
    MenuData<String> submenu,
    MenuItemData<String> parent,
  ) onSubmenuRequest;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Menu<String>(
        parent: parent,
        menuData: menuData,
        menuHeaderBuilder: (_, p) => MenuHeader(
          parentItemData: p,
          rootTitle: title,
        ),
        menuItemBuilder: (_, __, item) => MenuItemWidget(item: item),
        separatorBuilder: (_, __, ___) => const Divider(height: 1),
        onSubmenuRequest: (ctx, submenu, parentItem) =>
            onSubmenuRequest(ctx, submenu, parentItem),
      ),
    );
  }
}
