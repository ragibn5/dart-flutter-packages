import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

import 'package:example/menu_data/deep_nesting_menu.dart';
import 'package:example/menu_data/overlay_feedback_menu.dart';
import 'package:example/menu_data/settings_menu.dart';
import 'package:example/menu_data/simple_menu.dart';
import 'package:example/widgets/demo_card.dart';
import 'package:example/widgets/menu_sheet.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinity Menu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _lastSelection;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Infinity Menu'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primaryContainer, cs.secondaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.menu_book_rounded, size: 40, color: cs.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Infinity Menu',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A fully customizable, recursive menu widget for Flutter. '
                    'Tap any card below to try a different menu.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onPrimaryContainer.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DemoCard(
            icon: Icons.account_tree_rounded,
            title: 'Deep Nesting',
            subtitle: '5 items, 4 levels deep',
            onTap: () => _openMenu(
              context,
              'Deep Nesting',
              buildDeepNestingMenu(_onItemAction),
              null,
            ),
          ),
          DemoCard(
            icon: Icons.color_lens_rounded,
            title: 'Overlay Feedback',
            subtitle: 'Colored overlay on tap',
            onTap: () => _openMenu(
              context,
              'Overlay Feedback',
              buildOverlayFeedbackMenu(_onItemAction),
              null,
            ),
          ),
          DemoCard(
            icon: Icons.devices_rounded,
            title: 'Multi-Level Settings',
            subtitle: 'Real-world settings hierarchy',
            onTap: () => _openMenu(
              context,
              'Multi-Level Settings',
              buildSettingsMenu(_onItemAction),
              null,
            ),
          ),
          DemoCard(
            icon: Icons.help_outline_rounded,
            title: 'Simple Menu',
            subtitle: 'Flat list, no nesting',
            onTap: () => _openMenu(
              context,
              'Simple Menu',
              buildSimpleMenu(_onItemAction),
              null,
            ),
          ),
          if (_lastSelection != null) ...[
            const SizedBox(height: 24),
            Center(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: Chip(
                  avatar: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(_lastSelection!),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openMenu(
    BuildContext context,
    String title,
    MenuData<String> menuData,
    MenuItemData<String>? parent,
  ) {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MenuSheet(
        title: title,
        menuData: menuData,
        parent: parent,
        onSubmenuRequest: (ctx, submenu, parentItem) =>
            _openMenu(ctx, parentItem.itemTitle, submenu, parentItem),
      ),
    );
  }

  void _onItemAction(String? data) {
    setState(() => _lastSelection = data);
  }
}
