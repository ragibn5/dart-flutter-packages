import 'dart:collection';

import 'package:collection_extensions/collection_extensions.dart';

void main() {
  // Example for ListExtension
  final list = [1, 2, 3, 4, 5];
  final newList = list.replaceWhere(
    (e) => e.isEven,
    replacement: (old) => old * 10,
  );

  print('\nList before: $list');
  print('List after: $newList');

  // Example for MapExtension (replaceWhereValue)
  final map = {'a': 1, 'b': 2, 'c': 3};
  final newMapValue = map.replaceWhereValue(
    (value) => value == 2,
    replacement: (oldValue) => oldValue * 10,
  );

  print('\nMap before (replaceWhereValue): $map');
  print('Map after (replaceWhereValue): $newMapValue');

  // Example for MapExtension (replaceWhereEntry)
  final newMapEntry = map.replaceWhereEntry(
    (entry) => entry.value == 3,
    replacement: (oldEntry) => MapEntry(oldEntry.key, oldEntry.value * 10),
  );

  print('\nMap before (replaceWhereEntry): $map');
  print('Map after (replaceWhereEntry): $newMapEntry');

  // Example for QueueExtension
  final queue = Queue.of([1, 2, 3, 4, 5]);
  final newQueue = queue.replaceWhere(
    (e) => e > 3,
    replacement: (old) => old * 10,
  );

  print('\nQueue before: $queue');
  print('Queue after: $newQueue');

  // Example for SetExtension
  final set = {1, 2, 3, 4, 5};
  final newSet = set.replaceWhere(
    (e) => e < 3,
    replacement: (old) => old * 10,
  );

  print('\nSet before: $set');
  print('Set after: $newSet');
}
