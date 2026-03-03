import 'package:menu/menu.dart';

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
