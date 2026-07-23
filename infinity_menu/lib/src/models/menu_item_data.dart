import 'package:infinity_menu/src/models/icon_path_or_data.dart';
import 'package:infinity_menu/src/models/menu_data.dart';

class MenuItemData<D> {
  final D? data;
  final String itemTitle;
  final IconPathOrData? itemIcon;
  final MenuData<D>? subMenuData;
  final void Function(D? data)? onItemAction;

  MenuItemData({
    required this.data,
    required this.itemTitle,
    this.itemIcon,
    this.subMenuData,
    this.onItemAction,
  });
}
