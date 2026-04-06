# menu

A fully customizable menu for flutter apps with support for nested menu and much more.

## Features

- 📱 Fully customizable menu items, separators, and header
- 🌲 Support for infinitely nested menus
- 🎭 Visual feedback options (opacity or overlay)
- 🧩 Generic data type support for menu items
- 📝 Customizable headers for better organization
- 🚀 Simple API for complex menu structures

## Installation

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your `pubspec.yaml`

```yaml
dependencies:
  menu: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
dependencies:
  menu:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: menu
      ref: main
```

## Get Started

### Creating and displaying a menu

To show a menu, first create a
[`MenuData`](lib/src/models/menu_data.dart) instance.

It consists of:

- List of [`MenuItemData`](lib/src/models/menu_item_data.dart):
  List of menu item data that will be shown.
- [`MenuLayoutConfig`](lib/src/configs/menu_layout_config.dart):
  A configuration for the customization of the menu layout.
  Please note, `MenuLayoutConfig` is for customizing the menu as whole, not individual menu items or
  separators in particular.

```dart
final menuData = MenuData<String>(
  menuItems: [
    MenuItemData<String>(
      data: 'settings',
      itemTitle: 'Settings',
      itemIcon: IconFromIconData(Icons.settings),
      onItemAction: (data) => print("Selected: $data"),
    ),
    MenuItemData<String>(
      data: 'profile',
      itemTitle: 'Profile',
      itemIcon: IconFromIconData(Icons.person),
      onItemAction: (data) => print("Selected: $data"),
    ),
  ],
);
```

Then use the [`Menu`](lib/src/ui/menu.dart) widget to display it.

```dart
import 'package:flutter/material.dart';
import 'package:menu/menu.dart';

void showMenu(
  BuildContext context,
  MenuData<String> menuData,
  MenuItemData<String>? parentItemData,
) {
  showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Menu<String>(
        parent: parentItemData,
        menuData: menuData,
        menuItemBuilder: (index, hostMenuSize, itemData) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(itemData.itemTitle),
          );
        },
      ),
    ),
  );
}
```

### Working with Submenus

You can create nested menus by simply adding submenu data to menu item data.
There is no limit of how many levels you can nest your menus, you can make it as deep and organized
as you want.

```dart
final menuData = MenuData<String>(
  menuItems: [
    MenuItemData<String>(
      data: 'theme',
      itemTitle: 'Theme',
      itemIcon: IconFromIconData(Icons.palette),
      subMenuData: MenuData<String>(
        menuItems: [
          MenuItemData<String>(
            data: 'light-theme',
            itemTitle: 'Light Theme',
            onItemAction: (data) => print("Selected: $data"),
          ),
          MenuItemData<String>(
            data: 'dark-theme',
            itemTitle: 'Dark Theme',
            onItemAction: (data) => print("Selected: $data"),
          ),
        ],
      ),
    ),
    MenuItemData<String>(
      data: 'settings',
      itemTitle: 'Settings',
      itemIcon: IconFromIconData(Icons.settings),
      onItemAction: (data) => print("Selected: $data"),
    ),
  ],
);
```

To show a submenu, pass the tapped menu item back into `Menu.parent`:

```dart
import 'package:flutter/material.dart';
import 'package:menu/menu.dart';

void showMenu(
  BuildContext context,
  MenuData<String> menuData,
  MenuItemData<String>? parentItemData,
) {
  showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Menu<String>(
        parent: parentItemData,
        menuData: menuData,
        menuItemBuilder: (index, hostMenuSize, itemData) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(itemData.itemTitle),
          );
        },
        onSubmenuRequest: (menuContext, submenuData, parentItem) {
          showMenu(menuContext, submenuData, parentItem);
        },
      ),
    ),
  );
}
```

### Adding Headers and Separators

You can add headers and separators to enhance your menu's visual organization:

```dart
import 'package:flutter/material.dart';
import 'package:menu/menu.dart';

void showMenu(
  BuildContext context,
  MenuData<String> menuData,
  MenuItemData<String>? parentItemData,
) {
  showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Menu<String>(
        parent: parentItemData,
        menuData: menuData,
        menuItemBuilder: (index, size, itemData) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(itemData.itemTitle),
          );
        },
        menuHeaderBuilder: (context, parentItem) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(parentItem?.itemTitle ?? 'Menu'),
          );
        },
        separatorBuilder: (index, size, itemData) {
          return const Divider(height: 1);
        },
        onSubmenuRequest: (menuContext, submenuData, parentItem) {
          showMenu(menuContext, submenuData, parentItem);
        },
      ),
    ),
  );
}
```

## Example

Check out the [example](example) project for more info and visuals.

## License

Click [here](../LICENSE) to see the license.
