import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({super.key, required this.item});

  final MenuItemData<String> item;

  @override
  Widget build(BuildContext context) {
    final hasSubmenu = item.subMenuData != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          switch (item.itemIcon) {
            final IconFromPath path => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Image.asset(path.iconPath, width: 24, height: 24),
              ),
            final IconFromIconData iconData => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(iconData.iconData, size: 22),
              ),
            null => const SizedBox.shrink(),
          },
          Expanded(
            child: Text(
              item.itemTitle,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (hasSubmenu)
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}
