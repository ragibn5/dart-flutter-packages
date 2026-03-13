/// A data structure to manage selection state with optional maximum selection limit.
/// Does not throw; invalid indices are silently ignored.
class SelectionData {
  int _selectionCount = 0;
  final int? _maxSelectionCount;
  final List<bool> _current;

  SelectionData({
    required int size,
    int? maxSelectionCount,
  })  : _current = List.filled(size, false),
        _maxSelectionCount = maxSelectionCount;

  /// Returns true if the index is currently selected, false if out of bounds.
  bool isSelected(int index) {
    if (index < 0 || index >= _current.length) {
      return false;
    }

    return _current[index];
  }

  /// Selects the index if not already selected and under max limit.
  void select(int index) {
    if (index < 0 || index >= _current.length) {
      return;
    }
    if (_maxSelectionCount != null && _selectionCount >= _maxSelectionCount!) {
      return;
    }
    if (_current[index]) {
      return;
    }

    _current[index] = true;
    _selectionCount++;
  }

  /// Unselects the index if currently selected.
  void unselect(int index) {
    if (index < 0 || index >= _current.length) {
      return;
    }
    if (!_current[index]) {
      return;
    }

    _current[index] = false;
    _selectionCount--;
  }

  /// Toggles selection for the index.
  void flipSelection(int index) {
    if (index < 0 || index >= _current.length) {
      return;
    }

    if (_current[index]) {
      unselect(index);
    } else {
      select(index);
    }
  }

  /// Returns the list of currently selected indices.
  List<int> getCurrentSelectionIndices() {
    final indices = <int>[];
    for (var i = 0; i < _current.length; i++) {
      if (_current[i]) indices.add(i);
    }
    return indices;
  }

  /// Maximum number of selections allowed.
  int? get maxSelectionCount => _maxSelectionCount;

  /// Number of currently selected items.
  int get selectionCount => _selectionCount;
}
