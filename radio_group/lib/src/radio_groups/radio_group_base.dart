import 'package:flutter/widgets.dart';
import 'package:radio_group/src/configs/radio_group_layout_config.dart';
import 'package:radio_group/src/controllers/cached_stream_controller.dart';
import 'package:radio_group/src/models/radio_item_ui_model.dart';

abstract class RadioGroupBase<T extends RadioItemUiModel,
    LayoutConfig extends RadioGroupLayoutConfig> extends StatefulWidget {
  final List<T> _uiModels;
  final LayoutConfig _layoutConfig;
  final Widget Function(T model, {required bool selected}) _cellBuilder;
  final void Function(T selectedModel) _onSelectionChanged;

  final int? _initialSelectionIndex;

  const RadioGroupBase({
    super.key,
    required List<T> uiModels,
    required LayoutConfig layoutConfig,
    required Widget Function(T model, {required bool selected}) cellBuilder,
    required void Function(T selectedModel) onSelectionChanged,
    int? initialSelectionIndex,
  })  : _uiModels = uiModels,
        _layoutConfig = layoutConfig,
        _cellBuilder = cellBuilder,
        _onSelectionChanged = onSelectionChanged,
        _initialSelectionIndex = initialSelectionIndex;

  @override
  State<RadioGroupBase<T, LayoutConfig>> createState() =>
      _RadioGroupBaseState<T, LayoutConfig>();

  Widget buildContentWidget(
    int itemCount,
    LayoutConfig layoutConfig,
    Widget Function(int index) cellBuilder,
  );
}

class _RadioGroupBaseState<T extends RadioItemUiModel,
        LayoutConfig extends RadioGroupLayoutConfig>
    extends State<RadioGroupBase<T, LayoutConfig>> {
  final _selectionController = CachedStreamController<int>.single();

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
    return StreamBuilder<int>(
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
        ),
      ),
    );
  }

  void _initializeInitialSelection() {
    final validatedInitialSelectionIndex = _getInitialSelectionIndex(
      widget._uiModels,
      widget._initialSelectionIndex,
    );

    if (validatedInitialSelectionIndex == null) {
      return;
    }

    _selectionController.add(validatedInitialSelectionIndex);
  }

  int? _getInitialSelectionIndex(List<T> uiModes, int? initialSelectionIndex) {
    if (initialSelectionIndex == null) {
      return null;
    }

    if (initialSelectionIndex < 0 || initialSelectionIndex >= uiModes.length) {
      // Initial selection index is out of bounds, ignoring.
      return null;
    }

    return widget._uiModels[initialSelectionIndex].shouldBeSelected
        ? initialSelectionIndex
        : null;
  }
}

class _TappableItem<T extends RadioItemUiModel> extends StatelessWidget {
  final int index;
  final T uiModel;
  final CachedStreamController<int> selectionController;
  final void Function(T selectedModel) onSelectionChanged;
  final Widget Function(T model, {required bool selected}) cellBuilder;

  const _TappableItem({
    super.key,
    required this.index,
    required this.uiModel,
    required this.selectionController,
    required this.onSelectionChanged,
    required this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleCellTap(index),
      child: cellBuilder(
        uiModel,
        selected:
            uiModel.shouldBeSelected && index == selectionController.lastItem,
      ),
    );
  }

  void _handleCellTap(int index) {
    if (!uiModel.shouldBeSelected) {
      return;
    }

    selectionController.add(index);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onSelectionChanged(uiModel);
    });
  }
}
