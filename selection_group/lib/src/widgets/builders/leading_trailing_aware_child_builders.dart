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
    if (_leadingWidgets.isNotEmpty && (_index < _leadingWidgets.length)) {
      return _leadingWidgets[_index];
    } else if (_trailingWidgets.isNotEmpty &&
        _index >= (_leadingWidgets.length + _itemCount)) {
      return _trailingWidgets[_index - (_leadingWidgets.length + _itemCount)];
    } else {
      return _builder(_index - _leadingWidgets.length);
    }
  }
}
