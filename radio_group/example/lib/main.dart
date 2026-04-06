import 'package:flutter/material.dart';
import 'package:radio_group/radio_group.dart' as custom_radio_group;

void main() {
  runApp(const MyApp());
}

class DemoOption extends custom_radio_group.RadioItemUiModel {
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
      title: 'radio_group example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7490)),
        useMaterial3: true,
      ),
      home: const RadioGroupExampleApp(),
    );
  }
}

class RadioGroupExampleApp extends StatelessWidget {
  const RadioGroupExampleApp({super.key});

  static const _options = [
    DemoOption(title: 'Starter', subtitle: 'Good for new users'),
    DemoOption(title: 'Pro', subtitle: 'Most balanced choice'),
    DemoOption(title: 'Team', subtitle: 'For collaboration'),
    DemoOption(
      title: 'Disabled',
      subtitle: 'Non-selectable example',
      shouldBeSelected: false,
    ),
    DemoOption(title: 'Enterprise', subtitle: 'Larger deployments'),
    DemoOption(title: 'Custom', subtitle: 'Build your own setup'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('radio_group example'),
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
              description: 'A vertical radio group using list spacing.',
              layoutConfig: custom_radio_group.ListLayoutConfig(
                spacing: 12,
                padding: const EdgeInsets.all(20),
              ),
              uiModels: _options,
            ),
            _ModePage(
              title: 'Grid layout',
              description: 'A two-column radio group with fixed gaps.',
              layoutConfig: custom_radio_group.GridLayoutConfig(
                crossAxisItemCount: 2,
                horizontalSpacing: 12,
                verticalSpacing: 12,
                padding: const EdgeInsets.all(20),
              ),
              uiModels: _options,
            ),
            _ModePage(
              title: 'Wrap layout',
              description: 'A compact flow layout for chip-like choices.',
              layoutConfig: const custom_radio_group.WrapLayoutConfig(
                spacing: 12,
                runSpacing: 12,
              ),
              uiModels: _options,
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
  final custom_radio_group.RadioGroupLayoutConfig layoutConfig;
  final bool compactCells;

  const _ModePage({
    required this.title,
    required this.description,
    required this.uiModels,
    required this.layoutConfig,
    this.compactCells = false,
  });

  @override
  State<_ModePage> createState() => _ModePageState();
}

class _ModePageState extends State<_ModePage> {
  DemoOption? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.uiModels.firstWhere((option) => option.shouldBeSelected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(widget.description),
                const SizedBox(height: 12),
                Text(
                  'Selected: ${_selected?.title ?? 'None'}',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                custom_radio_group.RadioGroup<DemoOption>(
                  uiModels: widget.uiModels,
                  layoutConfig: widget.layoutConfig,
                  initialSelectionIndex: 0,
                  onSelectionChanged: (selectedModel) {
                    setState(() {
                      _selected = selectedModel;
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
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
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
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
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
