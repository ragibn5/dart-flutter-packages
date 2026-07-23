import 'package:infinity_menu/src/configs/menu_layout_config.dart';
import 'package:infinity_menu/src/models/menu_item_data.dart';

class MenuData<D> {
  final MenuLayoutConfig menuLayoutConfig;
  final List<MenuItemData<D>> menuItems;

  MenuData({
    this.menuLayoutConfig = const MenuLayoutConfig(),
    required this.menuItems,
  });
}
