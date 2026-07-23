import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

MenuData<String> buildDeepNestingMenu(void Function(String?) onItemAction) {
  return MenuData(
    menuItems: [
      MenuItemData(
        data: 'app',
        itemTitle: 'App',
        itemIcon: IconFromIconData(Icons.phone_iphone_rounded),
        subMenuData: MenuData(
          menuItems: [
            MenuItemData(
              data: 'display',
              itemTitle: 'Display',
              itemIcon: IconFromIconData(Icons.brightness_6_rounded),
              subMenuData: MenuData(
                menuItems: [
                  MenuItemData(
                    data: 'theme',
                    itemTitle: 'Theme',
                    itemIcon: IconFromIconData(Icons.palette_rounded),
                    subMenuData: MenuData(
                      menuItems: [
                        MenuItemData(
                          data: 'light',
                          itemTitle: 'Light',
                          itemIcon: IconFromIconData(Icons.light_mode_rounded),
                          onItemAction: onItemAction,
                        ),
                        MenuItemData(
                          data: 'dark',
                          itemTitle: 'Dark',
                          itemIcon: IconFromIconData(Icons.dark_mode_rounded),
                          onItemAction: onItemAction,
                        ),
                        MenuItemData(
                          data: 'system',
                          itemTitle: 'System Default',
                          itemIcon: IconFromIconData(
                            Icons.settings_brightness_rounded,
                          ),
                          onItemAction: onItemAction,
                        ),
                      ],
                    ),
                  ),
                  MenuItemData(
                    data: 'font-size',
                    itemTitle: 'Font Size',
                    itemIcon: IconFromIconData(Icons.format_size_rounded),
                    subMenuData: MenuData(
                      menuItems: [
                        MenuItemData(
                          data: 'font-small',
                          itemTitle: 'Small',
                          onItemAction: onItemAction,
                        ),
                        MenuItemData(
                          data: 'font-medium',
                          itemTitle: 'Medium',
                          onItemAction: onItemAction,
                        ),
                        MenuItemData(
                          data: 'font-large',
                          itemTitle: 'Large',
                          onItemAction: onItemAction,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            MenuItemData(
              data: 'language',
              itemTitle: 'Language',
              itemIcon: IconFromIconData(Icons.language_rounded),
              onItemAction: onItemAction,
            ),
          ],
        ),
      ),
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
        data: 'account',
        itemTitle: 'Account',
        itemIcon: IconFromIconData(Icons.person_rounded),
        subMenuData: MenuData(
          menuItems: [
            MenuItemData(
              data: 'profile',
              itemTitle: 'Profile',
              itemIcon: IconFromIconData(Icons.badge_rounded),
              onItemAction: onItemAction,
            ),
            MenuItemData(
              data: 'security',
              itemTitle: 'Security',
              itemIcon: IconFromIconData(Icons.shield_rounded),
              subMenuData: MenuData(
                menuItems: [
                  MenuItemData(
                    data: 'password',
                    itemTitle: 'Change Password',
                    onItemAction: onItemAction,
                  ),
                  MenuItemData(
                    data: '2fa',
                    itemTitle: 'Two-Factor Auth',
                    subMenuData: MenuData(
                      menuItems: [
                        MenuItemData(
                          data: '2fa-sms',
                          itemTitle: 'SMS',
                          onItemAction: onItemAction,
                        ),
                        MenuItemData(
                          data: '2fa-app',
                          itemTitle: 'Authenticator App',
                          onItemAction: onItemAction,
                        ),
                        MenuItemData(
                          data: '2fa-email',
                          itemTitle: 'Email',
                          onItemAction: onItemAction,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        data: 'appearance',
        itemTitle: 'Appearance',
        itemIcon: IconFromIconData(Icons.color_lens_rounded),
        subMenuData: MenuData(
          menuItems: [
            MenuItemData(
              data: 'wallpaper',
              itemTitle: 'Wallpaper',
              itemIcon: IconFromIconData(Icons.wallpaper_rounded),
              subMenuData: MenuData(
                menuItems: [
                  MenuItemData(
                    data: 'gallery',
                    itemTitle: 'From Gallery',
                    itemIcon: IconFromIconData(Icons.photo_library_rounded),
                    onItemAction: onItemAction,
                  ),
                  MenuItemData(
                    data: 'camera',
                    itemTitle: 'Take Photo',
                    itemIcon: IconFromIconData(Icons.camera_alt_rounded),
                    onItemAction: onItemAction,
                  ),
                  MenuItemData(
                    data: 'default-wp',
                    itemTitle: 'Default',
                    itemIcon: IconFromIconData(Icons.image_rounded),
                    onItemAction: onItemAction,
                  ),
                ],
              ),
            ),
            MenuItemData(
              data: 'accent',
              itemTitle: 'Accent Color',
              itemIcon: IconFromIconData(Icons.colorize_rounded),
              subMenuData: MenuData(
                menuItems: [
                  MenuItemData(
                    data: 'indigo',
                    itemTitle: 'Indigo',
                    onItemAction: onItemAction,
                  ),
                  MenuItemData(
                    data: 'teal',
                    itemTitle: 'Teal',
                    onItemAction: onItemAction,
                  ),
                  MenuItemData(
                    data: 'amber',
                    itemTitle: 'Amber',
                    onItemAction: onItemAction,
                  ),
                  MenuItemData(
                    data: 'rose',
                    itemTitle: 'Rose',
                    onItemAction: onItemAction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
