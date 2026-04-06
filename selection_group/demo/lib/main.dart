import 'package:flutter/material.dart';
import 'package:selection_group/selection_group.dart' as custom_selection_group;

void main() {
  runApp(const MyApp());
}

class DemoOption extends custom_selection_group.SelectionItemUiModel {
  final String title;
  final String subtitle;

  const DemoOption({
    required this.title,
    required this.subtitle,
    super.shouldBeSelected = true,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'selection_group example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: const SelectionGroupExampleApp(),
    );
  }
}

class SelectionGroupExampleApp extends StatelessWidget {
  const SelectionGroupExampleApp({super.key});

  static const _options = [
    DemoOption(title: 'Starter', subtitle: 'Essential workflow coverage'),
    DemoOption(title: 'Automation', subtitle: 'Background task support'),
    DemoOption(title: 'Analytics', subtitle: 'Reports and deeper insights'),
    DemoOption(
      title: 'Disabled',
      subtitle: 'Non-selectable example',
      shouldBeSelected: false,
    ),
    DemoOption(title: 'Notifications', subtitle: 'Delivery and reminders'),
    DemoOption(title: 'Export', subtitle: 'CSV and PDF handoff'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('selection_group example'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Center(
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  tabs: [
                    Tab(text: 'List'),
                    Tab(text: 'Grid'),
                    Tab(text: 'Wrap'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _ModePage(
              title: 'List layout',
              description:
                  'A vertical multi-select group with room for detail.',
              layoutConfig: custom_selection_group.ListLayoutConfig(
                spacing: 12,
                padding: const EdgeInsets.all(20),
              ),
              uiModels: _options,
              initialSelectionIndices: const [0, 2],
            ),
            _ModePage(
              title: 'Grid layout',
              description:
                  'A two-column selection group with shared selection cap.',
              layoutConfig: custom_selection_group.GridLayoutConfig(
                crossAxisItemCount: 2,
                horizontalSpacing: 12,
                verticalSpacing: 12,
                padding: const EdgeInsets.all(20),
              ),
              uiModels: _options,
              initialSelectionIndices: const [1],
            ),
            _ModePage(
              title: 'Wrap layout',
              description:
                  'A compact flow layout for chip-like multi-selection.',
              layoutConfig: const custom_selection_group.WrapLayoutConfig(
                spacing: 12,
                runSpacing: 12,
              ),
              uiModels: _options,
              initialSelectionIndices: const [0, 4],
              compactCells: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModePage extends StatefulWidget {
  final String title;
  final String description;
  final List<DemoOption> uiModels;
  final custom_selection_group.SelectionGroupLayoutConfig layoutConfig;
  final List<int> initialSelectionIndices;
  final bool compactCells;

  const _ModePage({
    required this.title,
    required this.description,
    required this.uiModels,
    required this.layoutConfig,
    required this.initialSelectionIndices,
    this.compactCells = false,
  });

  @override
  State<_ModePage> createState() => _ModePageState();
}

class _ModePageState extends State<_ModePage> {
  static const _maxSelectionCount = 3;

  late List<int> _selectedIndices;
  String? _overflowMessage;

  @override
  void initState() {
    super.initState();
    _selectedIndices = List<int>.from(widget.initialSelectionIndices);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedTitles = _selectedIndices
        .map((index) => widget.uiModels[index].title)
        .join(', ');

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(widget.description),
                const SizedBox(height: 12),
                Text(
                  'Selected (${_selectedIndices.length}/$_maxSelectionCount): '
                  '${selectedTitles.isEmpty ? 'None' : selectedTitles}',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap again to remove an item. Disabled items ignore taps.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_overflowMessage != null) ...[
                  const SizedBox(height: 16),
                  _OverflowBanner(message: _overflowMessage!),
                ],
                const SizedBox(height: 16),
                custom_selection_group.SelectionGroup<DemoOption>(
                  uiModels: widget.uiModels,
                  layoutConfig: widget.layoutConfig,
                  maxSelectionCount: _maxSelectionCount,
                  initialSelectionIndices: widget.initialSelectionIndices,
                  onSelectionChanged: (newSelectionIndices) {
                    setState(() {
                      _selectedIndices = newSelectionIndices;
                      _overflowMessage = null;
                    });
                  },
                  onSelectionOverflow: () {
                    setState(() {
                      _overflowMessage =
                          'You can select up to $_maxSelectionCount items at once.';
                    });
                  },
                  cellBuilder: (model, {required selected}) => _OptionTile(
                    model: model,
                    selected: selected,
                    compact: widget.compactCells,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final DemoOption model;
  final bool selected;
  final bool compact;

  const _OptionTile({
    required this.model,
    required this.selected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = !model.shouldBeSelected;
    final backgroundColor = disabled
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
        : selected
            ? scheme.primaryContainer
            : scheme.surfaceContainerLow;
    final sideColor = disabled
        ? scheme.outlineVariant
        : selected
            ? scheme.primary
            : scheme.outline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sideColor),
      ),
      child: compact
          ? _buildCompactContent(context, scheme, disabled)
          : _buildFullContent(context, scheme, disabled),
    );
  }

  Widget _buildCompactContent(
    BuildContext context,
    ColorScheme scheme,
    bool disabled,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          disabled
              ? Icons.block
              : selected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
          color: disabled
              ? scheme.outline
              : selected
                  ? scheme.primary
                  : scheme.onSurfaceVariant,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          model.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: disabled ? scheme.onSurfaceVariant : null,
              ),
        ),
      ],
    );
  }

  Widget _buildFullContent(
    BuildContext context,
    ColorScheme scheme,
    bool disabled,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                model.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: disabled ? scheme.onSurfaceVariant : null,
                    ),
              ),
            ),
            Icon(
              disabled
                  ? Icons.block
                  : selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
              color: disabled
                  ? scheme.outline
                  : selected
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          model.subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: disabled ? scheme.onSurfaceVariant : null,
              ),
        ),
      ],
    );
  }
}

class _OverflowBanner extends StatelessWidget {
  final String message;

  const _OverflowBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
