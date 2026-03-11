import 'package:flutter/widgets.dart';

class LeadingTrailingAwareChildBuilder extends StatelessWidget {
  final int _index;
  final int _itemCount;
  final Widget Function(int index) _builder;

  final List<Widget> _leadingWidgets;
  final List<Widget> _trailingWidgets;

  const LeadingTrailingAwareChildBuilder({
    super.key,
    required int index,
    required int itemCount,
    required Widget Function(int) builder,
    required List<Widget> leadingWidgets,
    required List<Widget> trailingWidgets,
  })  : _index = index,
        _itemCount = itemCount,
        _builder = builder,
        _leadingWidgets = leadingWidgets,
        _trailingWidgets = trailingWidgets;

  @override
  Widget build(BuildContext context) {
    final totalWidgets =
        _leadingWidgets.length + _itemCount + _trailingWidgets.length;
    if (_index < 0 || _index >= totalWidgets) {
      throw RangeError.range(_index, 0, totalWidgets, 'index');
    }

    // Leading region
    if (_index < _leadingWidgets.length && _leadingWidgets.isNotEmpty) {
      return _leadingWidgets[_index];
    }

    // Trailing region
    final trailingStart = _leadingWidgets.length + _itemCount;
    if (_index >= trailingStart && _trailingWidgets.isNotEmpty) {
      return _trailingWidgets[_index - trailingStart];
    }

    // Content region (builder)
    return _builder(_index - _leadingWidgets.length);
  }
}
