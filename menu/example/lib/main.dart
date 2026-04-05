import 'package:flutter/material.dart';
import 'package:menu/menu.dart';

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
      data: "theme",
      itemTitle: "Theme",
      itemIcon: IconFromIconData(Icons.palette),
      // Adding the submenu as the child of this menu item
      subMenuData: MenuData<String>(
        menuItems: [
          MenuItemData<String>(
            data: "light-theme",
            itemTitle: "Light Theme",
            onItemAction: _onItemAction,
          ),
          MenuItemData<String>(
            data: "dark-theme",
            itemTitle: "Dark Theme",
            onItemAction: _onItemAction,
          ),
        ],
      ),
    ),
    MenuItemData<String>(
      data: "settings",
      itemTitle: "Settings",
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
                onPressed: () => _showMenu(context, null, _menuData),
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
    MenuItemData<String>? parentItem,
    MenuData<String> menuData,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Menu(
          parentItem: parentItem,
          menuData: menuData,
          menuItemBuilder: (_, __, itemData) => MenuItem(itemData: itemData),
          separatorBuilder: (_, __, itemData) => const Divider(height: 1),
          menuHeaderBuilder: (_, parentItemData) =>
              MenuHeader(parentItemData: parentItemData),
          // Submenu request handler
          // We are calling the method itself to do the job.
          onSubmenuRequest: (menuContext, parentItem, submenuData) =>
              _showMenu(menuContext, parentItem, submenuData),
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
      padding: const EdgeInsets.all(8.0),
      child: Text(
        parentItemData?.itemTitle ?? "Menu",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final MenuItemData<String> itemData;

  const MenuItem({
    super.key,
    required this.itemData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        spacing: 8,
        children: [
          switch (itemData.itemIcon) {
            final IconFromPath path => Image.asset(path.iconPath),
            final IconFromIconData iconData => Icon(iconData.iconData),
            null => const SizedBox.shrink(),
          },
          Expanded(child: Text(itemData.itemTitle)),
          itemData.subMenuData != null
              ? const Icon(Icons.arrow_right)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
