import 'package:flutter/material.dart';
import 'package:infinity_menu/menu.dart';

void main() {
  runApp(
    const MaterialApp(title: 'Menu Example', home: ExampleHomePage()),
  );
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  String _lastSelection = 'Nothing selected yet';

  late final _menuData = MenuData<String>(menuItems: [
    MenuItemData<String>(
      data: 'theme',
      itemTitle: 'Theme',
      itemIcon: IconFromIconData(Icons.palette),
      // Adding the submenu as the child of this menu item
      subMenuData: MenuData<String>(
        menuItems: [
          MenuItemData<String>(
            data: 'light-theme',
            itemTitle: 'Light Theme',
            onItemAction: _onItemAction,
          ),
          MenuItemData<String>(
            data: 'dark-theme',
            itemTitle: 'Dark Theme',
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
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Menu Example'),
      ),
      body: Center(
        child: Builder(builder: (context) {
          return Column(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                child: const Text('Show Menu'),
                onPressed: () => _showMenu(
                  context,
                  _menuData,
                  null,
                ),
              ),
              Text(_lastSelection),
            ],
          );
        }),
      ),
    );
  }

  void _onItemAction(String? data) {
    setState(() {
      _lastSelection = data == null ? 'Selected: null' : 'Selected: $data';
    });
  }

  void _showMenu(
    BuildContext context,
    MenuData<String> menuData,
    MenuItemData<String>? parentItemData,
  ) {
    showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Menu(
          parent: parentItemData,
          menuData: menuData,
          menuItemBuilder: (_, __, item) => MenuItem(item: item),
          separatorBuilder: (_, __, item) => const Divider(height: 1),
          menuHeaderBuilder: (_, parent) => MenuHeader(parentItemData: parent),
          // Submenu request handler.
          // We are calling the method itself to do the job.
          onSubmenuRequest: (menuContext, submenu, parent) =>
              _showMenu(menuContext, submenu, parent),
        ),
      ),
    );
  }
}

class MenuHeader extends StatelessWidget {
  final MenuItemData<String>? parentItemData;

  const MenuHeader({
    super.key,
    required this.parentItemData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        parentItemData?.itemTitle ?? 'Menu',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final MenuItemData<String> item;

  const MenuItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        spacing: 8,
        children: [
          switch (item.itemIcon) {
            final IconFromPath path => Image.asset(path.iconPath),
            final IconFromIconData iconData => Icon(iconData.iconData),
            null => const SizedBox.shrink(),
          },
          Expanded(child: Text(item.itemTitle)),
          if (item.subMenuData != null)
            const Icon(Icons.arrow_right)
          else
            const SizedBox.shrink()
        ],
      ),
    );
  }
}
