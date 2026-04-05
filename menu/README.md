# menu

A fully customizable menu for flutter apps with support for nested menu and much more.

## Features

- 📱 Fully customizable menu items and separators
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

To show a menu, the first thing we need to do is to create a [
`MenuData`](lib/src/models/menu_data.dart) instance.

It consists of:

- List of [`MenuItemData`](lib/src/models/menu_item_data.dart):
  List of menu item data that will be shown.
- [`MenuLayoutConfig`](lib/src/configs/menu_layout_config.dart):
  A configuration for the customization of the menu layout.
  Please note, `MenuLayoutConfig` is for customizing the menu as whole, not individual menu items or
  separators in particular.

```dart
// Create menu data
final menuData = MenuData<String>(
  // Pass the items
  menuItems: [
    MenuItemData<String>(
      data: "item1",
      itemTitle: "Settings",
      itemIcon: IconFromIconData(Icons.settings),
      onItemAction: (data) => print("Selected: $data"),
    ),
    MenuItemData<String>(
      data: "item2",
      itemTitle: "Profile",
      itemIcon: IconFromIconData(Icons.person),
      onItemAction: (data) => print("Selected: $data"),
    ),
  ],
);
```

Finally, use the [`Menu`](lib/src/ui/menu.dart) widget to display your menu.

```dart
// We recommend using a method/function to show the menu.
// This will help us process the submenu request easily and consistently.
// We will discuss more on submenu on next section.
void showMenu(BuildContext context, MenuData<int?> menuData) {
  showBottomSheet(
    context: context,
    builder: (_) {
      return Menu(
        menuData: menuData,
        menuItemBuilder: (index, hostMenuSize, itemData) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(itemData.itemTitle),
          );
        },
      );
    },
  );
}
```

### Working with Submenus

You can create nested menus by simply adding submenu data to menu item data.
There is no limit of how many levels you can nest your menus, you can make it as deep and organized
as you want.

```dart
final subMenuItems = [
  MenuItemData<String>(
    data: "sub1",
    itemTitle: "Light Theme",
    onItemAction: (data) => print("Selected: $data"),
  ),
  MenuItemData<String>(
    data: "sub2",
    itemTitle: "Dark Theme",
    onItemAction: (data) => print("Selected: $data"),
  ),
];

final menuItems = [
  MenuItemData<String>(
    data: "item1",
    itemTitle: "Theme",
    itemIcon: IconFromIconData(Icons.palette),
    // Adding the submenu as the child of this menu item
    subMenuData: MenuData<String>(menuItems: subMenuItems),
  ),
  MenuItemData<String>(
    data: "item2",
    itemTitle: "Settings",
    itemIcon: IconFromIconData(Icons.settings),
    onItemAction: (data) => print("Selected: $data"),
  ),
];
```

<br>

To show the menu, with handling submenu opening request as well, use the `onSubmenuRequest` callback
like this:

```dart
void showMenu(BuildContext context, MenuData<int?> menuData) {
  showBottomSheet(
    context: context,
    builder: (_) {
      return Menu(
        menuData: menuData,
        menuItemBuilder: (index, hostMenuSize, itemData) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(itemData.itemTitle),
          );
        },
        // Submenu request handler
        // We are calling the method itself to do the job.
        onSubmenuRequest: (menuContext, submenuData) {
          showMenu(menuContext, submenuData);
        },
      );
    },
  );
}
```

### Adding Headers and Separators

You can add headers and separators to enhance your menu's visual organization:

```dart
void showMenu(BuildContext context, MenuData<int?> menuData) {
  showBottomSheet(
    context: context,
    builder: (_) {
      return Menu<String>(
        menuData: menuData,
        menuItemBuilder: (index, size, itemData) =>
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(itemData.itemTitle),
            ),
        menuHeaderBuilder: (context, parentItemData) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(parentItemData?.itemTitle ?? "Menu"),
          );
        },
        separatorBuilder: (index, size, itemData) {
          return const Divider(height: 1);
        },
      );
    },
  );
}
```

## License

Click [here](../LICENSE) to see the license.