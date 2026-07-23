import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

class MenuHeader extends StatelessWidget {
  const MenuHeader({super.key, required this.parentItemData, this.rootTitle});

  final MenuItemData<String>? parentItemData;
  final String? rootTitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final title = parentItemData?.itemTitle ?? rootTitle ?? 'Menu';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.primary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
