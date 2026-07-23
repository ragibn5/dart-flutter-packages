import 'package:flutter/material.dart';
import 'package:infinity_menu/menu.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Infinity Menu Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _lastSelection = 'Nothing selected yet';

  void _onItemAction(String? data) {
    setState(() {
      _lastSelection = data ?? 'null';
    });
  }

  void _openMenu(
    BuildContext context,
    MenuData<String> menuData,
    MenuItemData<String>? parentItem,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Menu(
          parent: parentItem,
          menuData: menuData,
          menuItemBuilder: (_, __, item) => _buildItem(item),
          menuHeaderBuilder: (_, parent) => Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              parent?.itemTitle ?? 'Menu',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          separatorBuilder: (_, __, ___) => const Divider(height: 1),
          onSubmenuRequest: (ctx, submenu, parent) =>
              _openMenu,
        ),
      ),
    );
  }

  Widget _buildItem(MenuItemData<String> item) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (item.itemIcon case IconFromIconData(:final iconData))
            Icon(iconData),
          const SizedBox(width: 8),
          Expanded(child: Text(item.itemTitle)),
          if (item.subMenuData != null) const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuData = MenuData<String>(
      menuItems: [
        MenuItemData<String>(
          data: 'theme',
          itemTitle: 'Theme',
          itemIcon: IconFromIconData(Icons.palette),
          subMenuData: MenuData<String>(
            menuItems: [
              MenuItemData(
                data: 'light',
                itemTitle: 'Light',
                onItemAction: _onItemAction,
              ),
              MenuItemData(
                data: 'dark',
                itemTitle: 'Dark',
                onItemAction: _onItemAction,
              ),
            ],
          ),
        ),
        MenuItemData<String>(
          data: 'settings',
          itemTitle: 'Settings',
          itemIcon: IconFromIconData(Icons.settings),
          onItemAction: _onItemAction,
        ),
        MenuItemData<String>(
          data: 'info',
          itemTitle: 'About',
          onItemAction: _onItemAction,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Infinity Menu')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            FilledButton(
              onPressed: () => _openMenu(context, menuData, null),
              child: const Text('Open Menu'),
            ),
            Text('Selected: $_lastSelection'),
          ],
        ),
      ),
    );
  }
}
