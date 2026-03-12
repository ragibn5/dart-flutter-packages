import 'package:flutter/widgets.dart';

class LeadingTrailingAwareChildBuilder extends StatelessWidget {
  final int index;
  final int itemCount;
  final List<Widget> leadingWidgets;
  final List<Widget> trailingWidgets;
  final Widget Function(int index) builder;

  const LeadingTrailingAwareChildBuilder({
    super.key,
    required this.index,
    required this.itemCount,
    required this.leadingWidgets,
    required this.trailingWidgets,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final totalWidgets =
        leadingWidgets.length + itemCount + trailingWidgets.length;
    if (index < 0 || index >= totalWidgets) {
      throw RangeError.range(index, 0, totalWidgets, 'index');
    }

    // Leading region
    if (index < leadingWidgets.length && leadingWidgets.isNotEmpty) {
      return leadingWidgets[index];
    }

    // Trailing region
    final trailingStart = leadingWidgets.length + itemCount;
    if (index >= trailingStart && trailingWidgets.isNotEmpty) {
      return trailingWidgets[index - trailingStart];
    }

    // Content region (builder)
    return builder(index - leadingWidgets.length);
  }
}
