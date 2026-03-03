/// A data structure to mimic the select/deselect behaviour.
///
/// Note, this data structure is design to hold and manipulate limited
/// number of selection data, i.e., the `size` constructor param should
/// be small.
class SelectionData {
  int _selectionCount = 0;

  final int? _maxSelectionCount;
  final List<bool> _current;

  SelectionData({
    required int size,
    int? maxSelectionCount,
  })  : _current = List.filled(size, false),
        _maxSelectionCount = maxSelectionCount;

  bool isSelected(int index) {
    assert(
      index >= 0 && index < _current.length,
      'Index is out of promised bound',
    );

    return _current[index];
  }

  /// Adds the given index to the selection if we have not yet reached limit.
  void select(int newIndex) {
    assert(
      newIndex >= 0 && newIndex < _current.length,
      'Index is out of promised bound',
    );

    if (_selectionCount == (_maxSelectionCount ?? _current.length)) {
      return;
    }

    _current[newIndex] = true;
    ++_selectionCount;
  }

  /// Unselects the given index (if was selected previously).
  void unselect(int newIndex) {
    assert(
      newIndex >= 0 && newIndex < _current.length,
      'Index is out of promised bound',
    );

    if (_selectionCount == 0) {
      return;
    }

    _current[newIndex] = false;
    --_selectionCount;
  }

  /// Adds or removes the given index from the selection.
  void flipSelection(int newIndex) {
    assert(
      newIndex >= 0 && newIndex < _current.length,
      'Index is out of promised bound',
    );

    if (_current[newIndex]) {
      unselect(newIndex);
    } else {
      select(newIndex);
    }
  }

  List<int> getCurrentSelectionIndices() {
    final indices = <int>[];
    for (var i = 0; i < _current.length; ++i) {
      if (_current[i]) indices.add(i);
    }

    return indices;
  }

  int? get maxSelectionCount => _maxSelectionCount;

  int get selectionCount => _selectionCount;
}
