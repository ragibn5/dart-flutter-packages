# selection_group

A fully customizable selection group.

## Installation

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your `pubspec.yaml`

```yaml
dependencies:
  selection_group: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
dependencies:
  selection_group:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: selection_group
      ref: main
```

## Get Started

1. Create a model that extends [
   `SelectionItemUiModel`](lib/src/models/selection_item_ui_model.dart).
2. Pass a list of those models to [`SelectionGroup`](lib/src/selection_group.dart).
3. Choose a layout config: `ListLayoutConfig`, `GridLayoutConfig`, or `WrapLayoutConfig`.
4. Build each cell in `cellBuilder`.
5. Handle selection changes in `onSelectionChanged`.
6. Optionally limit concurrent selections with `maxSelectionCount`.

This example shows a basic list-based selection group with one disabled item, a selection limit, and
local state for the current selection.

**Create a model that extends `SelectionItemUiModel`**

```dart
class DemoOption extends SelectionItemUiModel {
  final String title;

  const DemoOption({
    required this.title,
    super.shouldBeSelected = true,
  });
}
```

Set `shouldBeSelected` to false on any item if you want that item to be non-selectable.

**Construct a selection group that sends a list of the model defined above**

```dart
class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  static const options = [
    DemoOption(title: 'Starter'),
    DemoOption(title: 'Pro'),
    DemoOption(title: 'Disabled', shouldBeSelected: false),
  ];

  List<int> selectedIndices = [0];

  @override
  Widget build(BuildContext context) {
    return SelectionGroup<DemoOption>(
      uiModels: options,
      layoutConfig: const ListLayoutConfig(
        spacing: 12,
        padding: EdgeInsets.all(16),
      ),
      initialSelectionIndices: selectedIndices,
      maxSelectionCount: 2,
      onSelectionChanged: (newSelectionIndices) {
        setState(() {
          selectedIndices = newSelectionIndices;
        });
      },
      onSelectionOverflow: () {
        debugPrint('Selection limit reached');
      },
      cellBuilder: (model, {required selected}) =>
          Container(
            padding: const EdgeInsets.all(16),
            color: selected ? Colors.green : Colors.grey.shade300,
            child: Text(model.title),
          ),
    );
  }
}
```

You may use different layout configs to arrange the items in different ways, for example:

List-based arrangement:

```dart

final listLayoutConfig = ListLayoutConfig.scrollable(
  spacing: 8,
  padding: EdgeInsets.all(8),
);
```

Grid-based arrangement:

```dart

final gridLayoutConfig = GridLayoutConfig.scrollable(
  crossAxisItemCount: 2,
  horizontalSpacing: 8,
  verticalSpacing: 8,
  padding: EdgeInsets.all(8),
);
```

Wrap-based arrangement:

```dart

final wrapLayoutConfig = WrapLayoutConfig(
  spacing: 8,
  runSpacing: 8,
);
```

## Example

Check out the [example](demo) project for more info and visuals.

## License

Click [here](../LICENSE) to see the license.
