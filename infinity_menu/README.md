# ∞ infinity_menu

A fully customizable menu for flutter apps with support for nested menu and much more.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  infinity_menu: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  infinity_menu:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: infinity_menu
      ref: infinity_menu-1.0.0
```

For more information, see the [package on pub.dev](https://pub.dev/packages/infinity_menu) or the [GitHub repository](https://github.com/Ragibn5/dart-flutter-packages/tree/main/infinity_menu).

---

## ✨ Features

- **♾️ Infinite nesting** — nest submenus to any depth.
- **🎨 UI-agnostic** — you control how everything looks via builder callbacks.
- **📦 Strongly typed** — carry any data type through your menu and get it back on selection.
- **🔀 Wide compatibility** — works with Flutter 3.10.6+.

## 📸 Preview

<p style="text-align: center">
  <img src="assets/screenshots/0.png" alt="Home screen" style="width: 45%">
  &nbsp;&nbsp;
  <img src="assets/screenshots/3.png" alt="Menu selected" style="width: 45%">
</p>

<p style="text-align: center">
  <img src="assets/screenshots/1.1.png" alt="Deep nesting - level 1" style="width: 30%">
  <img src="assets/screenshots/1.2.png" alt="Deep nesting - level 2" style="width: 30%">
  <img src="assets/screenshots/1.3.png" alt="Deep nesting - level 3" style="width: 30%">
</p>

<p style="text-align: center">
  <img src="assets/screenshots/2.1.png" alt="Settings menu" style="width: 45%">
  &nbsp;&nbsp;
  <img src="assets/screenshots/2.2.png" alt="Settings submenu" style="width: 45%">
</p>

## 🚀 Get Started

### 1. Define your menu data

Build your menu tree with `MenuData` and `MenuItemData`. Nest as deep as you want — just set `subMenuData`.

```
import 'package:infinity_menu/infinity_menu.dart';

final menuData = MenuData<String>(
  menuItems: [
    MenuItemData<String>(
      data: 'theme',
      itemTitle: 'Theme',
      subMenuData: MenuData<String>(
        menuItems: [
          MenuItemData(data: 'light', itemTitle: 'Light', onItemAction: _onSelect),
          MenuItemData(data: 'dark', itemTitle: 'Dark', onItemAction: _onSelect),
        ],
      ),
    ),
    MenuItemData(data: 'settings', itemTitle: 'Settings', onItemAction: _onSelect),
  ],
);
```

### 2. Present the menu

Drop a `Menu` into any widget — bottom sheet, popup, dialog, wherever. You control how each item looks via `menuItemBuilder`.

```
showModalBottomSheet(
  context: context,
  builder: (_) => Menu<String>(
    menuData: menuData,
    menuItemBuilder: (index, size, item) => ListTile(
      title: Text(item.itemTitle),
      trailing: item.subMenuData != null ? Icon(Icons.chevron_right) : null,
    ),
    separatorBuilder: (_, __, ___) => Divider(height: 1),
    menuHeaderBuilder: (_, parent) => Padding(
      padding: EdgeInsets.all(8),
      child: Text(parent?.itemTitle ?? 'Menu', style: TextStyle(fontWeight: FontWeight.bold)),
    ),
    onSubmenuRequest: (ctx, submenu, parent) => _openMenu(ctx, submenu),
  ),
);
```

### 3. Recursively open submenus

When a user taps an item with a submenu, `onSubmenuRequest` fires. Just call your own function again — the recursion handles the rest.

```
void _openMenu(BuildContext context, MenuData<String> submenu) {
  showModalBottomSheet(
    context: context,
    builder: (_) => Menu<String>(
      menuData: submenu,
      menuItemBuilder: (index, size, item) => ListTile(title: Text(item.itemTitle)),
      onSubmenuRequest: (ctx, sub, parent) => _openMenu(ctx, sub),
    ),
  );
}
```

## 📦 API

All exported components from `package:infinity_menu/infinity_menu.dart`:

| Component               | Description                                                                                                    |
|-------------------------|----------------------------------------------------------------------------------------------------------------|
| `Menu<D>`               | The main widget. Renders a `MenuData<D>` as a list, handling tap feedback, item actions, and submenu dispatch. |
| `MenuData<D>`           | Holds a list of `MenuItemData<D>` items and a `MenuLayoutConfig`.                                              |
| `MenuItemData<D>`       | A single menu item — title, optional icon, optional payload `D`, optional submenu, optional tap callback.      |
| `IconFromIconData`      | Icon variant — wraps a Flutter `IconData`.                                                                     |
| `IconFromPath`          | Icon variant — wraps an asset path string.                                                                     |
| `MenuLayoutConfig`      | Layout options — shrink wrap, padding, scroll physics, selection feedback.                                     |
| `OpacityFeedbackConfig` | Tap feedback — briefly dims the tapped item.                                                                   |
| `OverlayFeedbackConfig` | Tap feedback — briefly shows a colored overlay on the tapped item.                                             |

## 🧪 Example

See [`example.dart`](example.dart) for a complete runnable example, or [`demo/`](demo) for a standalone Flutter project.

---