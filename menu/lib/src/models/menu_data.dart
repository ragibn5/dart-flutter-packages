import 'package:menu/src/configs/menu_layout_config.dart';
import 'package:menu/src/models/menu_item_data.dart';

class MenuData<D> {
  final MenuLayoutConfig menuLayoutConfig;
  final List<MenuItemData<D>> menuItems;

  MenuData({
    this.menuLayoutConfig = const MenuLayoutConfig(),
    required this.menuItems,
  });
}
