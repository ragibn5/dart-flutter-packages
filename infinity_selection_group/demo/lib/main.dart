import 'package:flutter/material.dart';
import 'package:infinity_selection_group/infinity_selection_group.dart'
    as selection_group;

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
      title: 'Selection Group',
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
  static const _maxSelectionCount = 3;

  late final TabController _tabController;
  late List<int> _selectedIndices;
  String? _overflowMessage;

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
    _selectedIndices = [
      for (var i = 0; i < demoOptions.length; i++)
        if (demoOptions[i].shouldBeSelected) i,
    ].take(_maxSelectionCount).toList();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  void _handleSelectionChanged(List<int> indices) {
    setState(() {
      _selectedIndices = indices;
      _overflowMessage = null;
    });
  }

  void _handleSelectionOverflow() {
    setState(() {
      _overflowMessage = 'You can select up to $_maxSelectionCount items '
          'at once.';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedOptions = [
      for (final index in _selectedIndices) demoOptions[index],
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DemoHeader(
              selected: selectedOptions,
              maxSelectionCount: _maxSelectionCount,
              layoutInfo: _layoutInfos[_tabController.index],
            ),
            const SizedBox(height: 10),
            _LayoutTabBar(controller: _tabController),
            const SizedBox(height: 6),
            if (_overflowMessage != null) ...[
              _OverflowBanner(message: _overflowMessage!),
              const SizedBox(height: 6),
            ],
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  LayoutDemo(
                    layoutConfig: selection_group.ListLayoutConfig(
                      spacing: 8,
                    ),
                    selectedIndices: _selectedIndices,
                    maxSelectionCount: _maxSelectionCount,
                    onSelectionChanged: _handleSelectionChanged,
                    onSelectionOverflow: _handleSelectionOverflow,
                  ),
                  LayoutDemo(
                    layoutConfig: selection_group.GridLayoutConfig(
                      crossAxisItemCount: 2,
                      horizontalSpacing: 8,
                      verticalSpacing: 8,
                      mainAxisExtent: 92,
                    ),
                    selectedIndices: _selectedIndices,
                    maxSelectionCount: _maxSelectionCount,
                    onSelectionChanged: _handleSelectionChanged,
                    onSelectionOverflow: _handleSelectionOverflow,
                  ),
                  LayoutDemo(
                    layoutConfig: const selection_group.WrapLayoutConfig(
                      spacing: 8,
                      runSpacing: 8,
                    ),
                    selectedIndices: _selectedIndices,
                    maxSelectionCount: _maxSelectionCount,
                    onSelectionChanged: _handleSelectionChanged,
                    onSelectionOverflow: _handleSelectionOverflow,
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

class _OverflowBanner extends StatelessWidget {
  final String message;

  const _OverflowBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
