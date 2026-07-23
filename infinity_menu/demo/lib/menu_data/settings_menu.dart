import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

MenuData<String> buildSettingsMenu(void Function(String?) onItemAction) {
  return MenuData(
    menuItems: [
      MenuItemData(
        data: 'notifications',
        itemTitle: 'Notifications',
        itemIcon: IconFromIconData(Icons.notifications_rounded),
        subMenuData: MenuData(
          menuItems: [
            MenuItemData(
              data: 'push',
              itemTitle: 'Push Notifications',
              itemIcon: IconFromIconData(Icons.notifications_active_rounded),
              subMenuData: MenuData(
                menuItems: [
                  MenuItemData(
                    data: 'push-all',
                    itemTitle: 'All',
                    onItemAction: onItemAction,
                  ),
                  MenuItemData(
                    data: 'push-important',
                    itemTitle: 'Important Only',
                    onItemAction: onItemAction,
                  ),
                  MenuItemData(
                    data: 'push-none',
                    itemTitle: 'None',
                    onItemAction: onItemAction,
                  ),
                ],
              ),
            ),
            MenuItemData(
              data: 'email-notif',
              itemTitle: 'Email Notifications',
              itemIcon: IconFromIconData(Icons.email_rounded),
              onItemAction: onItemAction,
            ),
            MenuItemData(
              data: 'sms-notif',
              itemTitle: 'SMS Notifications',
              itemIcon: IconFromIconData(Icons.sms_rounded),
              onItemAction: onItemAction,
            ),
          ],
        ),
      ),
      MenuItemData(
        data: 'privacy',
        itemTitle: 'Privacy',
        itemIcon: IconFromIconData(Icons.lock_rounded),
        subMenuData: MenuData(
          menuItems: [
            MenuItemData(
              data: 'visibility',
              itemTitle: 'Profile Visibility',
              subMenuData: MenuData(
                menuItems: [
                  MenuItemData(
                    data: 'vis-public',
                    itemTitle: 'Public',
                    onItemAction: onItemAction,
                  ),
                  MenuItemData(
                    data: 'vis-friends',
                    itemTitle: 'Friends Only',
                    onItemAction: onItemAction,
                  ),
                  MenuItemData(
                    data: 'vis-private',
                    itemTitle: 'Private',
                    onItemAction: onItemAction,
                  ),
                ],
              ),
            ),
            MenuItemData(
              data: 'activity',
              itemTitle: 'Activity Status',
              itemIcon: IconFromIconData(Icons.wifi_rounded),
              onItemAction: onItemAction,
            ),
          ],
        ),
      ),
      MenuItemData(
        data: 'storage',
        itemTitle: 'Storage',
        itemIcon: IconFromIconData(Icons.storage_rounded),
        onItemAction: onItemAction,
      ),
    ],
  );
}
