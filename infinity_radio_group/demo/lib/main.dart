import 'package:flutter/material.dart';
import 'package:infinity_radio_group/infinity_radio_group.dart' as radio_group;

import 'package:example/widgets/demo_header.dart';
import 'package:example/widgets/demo_option.dart';
import 'package:example/widgets/layout_demo.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Radio Group',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4F46E5),
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  DemoOption? _selected;

  static const _layoutInfos = [
    LayoutInfo(
      icon: Icons.view_agenda_rounded,
      title: 'List layout',
      description: 'Vertical stack with equal spacing.',
    ),
    LayoutInfo(
      icon: Icons.grid_view_rounded,
      title: 'Grid layout',
      description: 'Two-column responsive grid.',
    ),
    LayoutInfo(
      icon: Icons.wrap_text_rounded,
      title: 'Wrap layout',
      description: 'Flowing chip-like options.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _selected = demoOptions.firstWhere((option) => option.shouldBeSelected);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DemoHeader(
              selected: _selected,
              layoutInfo: _layoutInfos[_tabController.index],
            ),
            const SizedBox(height: 10),
            _LayoutTabBar(controller: _tabController),
            const SizedBox(height: 6),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  LayoutDemo(
                    layoutConfig: radio_group.ListLayoutConfig(
                      spacing: 8,
                    ),
                    selected: _selected,
                    onSelectionChanged: (option) {
                      setState(() => _selected = option);
                    },
                  ),
                  LayoutDemo(
                    layoutConfig: radio_group.GridLayoutConfig(
                      crossAxisItemCount: 2,
                      horizontalSpacing: 8,
                      verticalSpacing: 8,
                      mainAxisExtent: 92,
                    ),
                    selected: _selected,
                    onSelectionChanged: (option) {
                      setState(() => _selected = option);
                    },
                  ),
                  LayoutDemo(
                    layoutConfig: radio_group.WrapLayoutConfig(
                      spacing: 8,
                      runSpacing: 8,
                    ),
                    selected: _selected,
                    onSelectionChanged: (option) {
                      setState(() => _selected = option);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayoutTabBar extends StatelessWidget {
  final TabController controller;

  const _LayoutTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(21),
      ),
      child: TabBar(
        controller: controller,
        padding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.fill,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(17),
        ),
        labelColor: cs.onPrimary,
        labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        unselectedLabelColor: cs.onSurfaceVariant,
        unselectedLabelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'List'),
          Tab(text: 'Grid'),
          Tab(text: 'Wrap'),
        ],
      ),
    );
  }
}
