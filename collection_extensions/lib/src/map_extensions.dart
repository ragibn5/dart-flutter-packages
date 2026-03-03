extension MapExtension<K, V> on Map<K, V> {
  /// Returns a new map with values replaced based on a test function
  Map<K, V> replaceWhereValue(
    bool Function(V value) test, {
    required V Function(V oldValue) replacement,
  }) {
    return Map<K, V>.fromEntries(
      entries.map(
        (entry) => MapEntry(
          entry.key,
          test(entry.value) ? replacement(entry.value) : entry.value,
        ),
      ),
    );
  }

  /// Returns a new map with entries replaced based on a test function
  Map<K, V> replaceWhereEntry(
    bool Function(MapEntry<K, V> entry) test, {
    required MapEntry<K, V> Function(MapEntry<K, V> oldEntry) replacement,
  }) {
    return Map<K, V>.fromEntries(
      entries.map((entry) => test(entry) ? replacement(entry) : entry),
    );
  }
}
