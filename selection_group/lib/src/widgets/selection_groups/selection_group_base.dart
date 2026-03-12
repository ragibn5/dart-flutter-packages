import 'package:flutter/widgets.dart';
import 'package:selection_group/src/configs/selection_group_layout_config.dart';
import 'package:selection_group/src/controllers/cached_stream_controller.dart';
import 'package:selection_group/src/data_structures/selection_data.dart';
import 'package:selection_group/src/models/selection_item_ui_model.dart';

abstract class SelectionGroupBase<T extends SelectionItemUiModel,
    LayoutConfig extends SelectionGroupLayoutConfig> extends StatefulWidget {
  final List<T> _uiModels;
  final LayoutConfig _layoutConfig;
  final Widget Function(T model, {required bool selected}) _cellBuilder;
  final void Function(List<int> newSelectionIndices) _onSelectionChanged;

  final int? _maxSelectionCount;
  final List<int> _initialSelectionIndices;
  final void Function()? _onSelectionOverflow;

  const SelectionGroupBase({
    super.key,
    required List<T> uiModels,
    required LayoutConfig layoutConfig,
    required Widget Function(T model, {required bool selected}) cellBuilder,
    required void Function(List<int> newSelectionIndices) onSelectionChanged,
    int? maxSelectionCount,
    List<int> initialSelectionIndices = const [],
    required void Function()? onSelectionOverflow,
  })  : _uiModels = uiModels,
        _layoutConfig = layoutConfig,
        _cellBuilder = cellBuilder,
        _onSelectionOverflow = onSelectionOverflow,
        _onSelectionChanged = onSelectionChanged,
        _maxSelectionCount = maxSelectionCount,
        _initialSelectionIndices = initialSelectionIndices;

  @override
  State<SelectionGroupBase<T, LayoutConfig>> createState() =>
      _SelectionGroupBaseState<T, LayoutConfig>();

  Widget buildContentWidget(
    int itemCount,
    LayoutConfig layoutConfig,
    Widget Function(int index) cellBuilder,
  );
}

class _SelectionGroupBaseState<T extends SelectionItemUiModel,
        LayoutConfig extends SelectionGroupLayoutConfig>
    extends State<SelectionGroupBase<T, LayoutConfig>> {
  late final _selectionController =
      CachedStreamController<SelectionData>.single();

  @override
  void initState() {
    super.initState();

    _initializeInitialSelection();
  }

  @override
  void dispose() {
    _selectionController.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SelectionData>(
      stream: _selectionController.stream,
      builder: (context, snapshot) => widget.buildContentWidget(
        widget._uiModels.length,
        widget._layoutConfig,
        (index) => _TappableItem(
          index: index,
          uiModel: widget._uiModels[index],
          selectionController: _selectionController,
          onSelectionChanged: widget._onSelectionChanged,
          cellBuilder: widget._cellBuilder,
          onSelectionOverflow: widget._onSelectionOverflow,
        ),
      ),
    );
  }

  void _initializeInitialSelection() {
    final maxSelectionCount = widget._maxSelectionCount;
    assert(
      maxSelectionCount == null ||
          widget._initialSelectionIndices.length < maxSelectionCount,
      'Initial selection indices count must be <= Given max selection count',
    );

    _selectionController.add(
      _getInitialSelection(
        widget._uiModels,
        widget._initialSelectionIndices,
      ),
    );
  }

  SelectionData _getInitialSelection(
    List<T> uiModes,
    List<int> initialSelectionIndices,
  ) {
    final selectionStructure = SelectionData(
      size: uiModes.length,
      maxSelectionCount: widget._maxSelectionCount,
    );
    for (final e in initialSelectionIndices) {
      if (uiModes[e].shouldBeSelected) {
        selectionStructure.select(e);
      }
    }

    return selectionStructure;
  }
}

class _TappableItem<T extends SelectionItemUiModel> extends StatelessWidget {
  final int index;
  final T uiModel;
  final CachedStreamController<SelectionData> selectionController;
  final void Function(List<int> newSelectionIndices) onSelectionChanged;
  final Widget Function(T model, {required bool selected}) cellBuilder;

  final void Function()? onSelectionOverflow;

  const _TappableItem({
    super.key,
    required this.index,
    required this.uiModel,
    required this.selectionController,
    required this.onSelectionChanged,
    required this.cellBuilder,
    required this.onSelectionOverflow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleCellTap(index),
      child: cellBuilder(
        uiModel,
        selected: uiModel.shouldBeSelected &&
            (selectionController.lastItem?.isSelected(index) ?? false),
      ),
    );
  }

  void _handleCellTap(int index) {
    // Exit early if the cell should not be selected
    if (!uiModel.shouldBeSelected) {
      return;
    }

    // Exit early if there is no value in the selection controller
    final value = selectionController.lastItem;
    if (value == null) {
      return;
    }

    // If already selected, flip and notify, then exit
    if (value.isSelected(index)) {
      _updateSelection(value, index);
      return;
    }

    // If selection count has reached max, notify overflow, and return
    final lastSelectionCount = value.selectionCount;
    final maxSelectionCount = value.maxSelectionCount;
    if (maxSelectionCount != null && lastSelectionCount == maxSelectionCount) {
      onSelectionOverflow?.call();
      return;
    }

    // If all checks pass, update the selection
    _updateSelection(value, index);
  }

  void _updateSelection(SelectionData value, int index) {
    value.flipSelection(index);
    selectionController.add(value);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onSelectionChanged(value.getCurrentSelectionIndices());
    });
  }
}
