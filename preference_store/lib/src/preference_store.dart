/// The base class for preference based data storage.
abstract interface class PreferenceStore {
  /// Reads a boolean value from persistent storage.
  ///
  /// Returns null if the key doesn't exist or the value is not a boolean.
  Future<bool?> getBool(String key);

  /// Reads an integer value from persistent storage.
  ///
  /// Returns null if the key doesn't exist or the value is not an integer.
  Future<int?> getInt(String key);

  /// Reads a double value from persistent storage.
  ///
  /// Returns null if the key doesn't exist or the value is not a double.
  Future<double?> getDouble(String key);

  /// Reads a string value from persistent storage.
  ///
  /// Returns null if the key doesn't exist or the value is not a string.
  Future<String?> getString(String key);

  /// Reads a list of strings from persistent storage.
  ///
  /// Returns null if the key doesn't exist or the value
  /// is not a list of strings.
  Future<List<String>?> getStringList(String key);

  /// Reads a set of string values from persistent storage.
  ///
  /// Returns null if the key doesn't exist or the value is
  /// not a set of strings.
  ///
  /// Note: This method might not be available in all SharedPreferences
  /// implementations.
  Future<Set<String>?> getStringSet(String key);

  /// Returns all keys in the persistent storage.
  ///
  /// If [allowList] is provided, only keys present in the allowList
  /// are returned.
  Future<Set<String>> getKeys({Set<String>? allowList});

  /// Returns true if the persistent storage contains the given key.
  Future<bool> containsKey(String key);

  //

  /// Stores a boolean value in persistent storage.
  // ignore: avoid_positional_boolean_parameters
  Future<void> setBool(String key, bool value);

  /// Stores an integer value in persistent storage.
  Future<void> setInt(String key, int value);

  /// Stores a double value in persistent storage.
  Future<void> setDouble(String key, double value);

  /// Stores a string value in persistent storage.
  Future<void> setString(String key, String value);

  /// Stores a list of strings in persistent storage.
  Future<void> setStringList(String key, List<String> value);

  /// Stores a set of string values in persistent storage.
  Future<void> setStringSet(String key, Set<String> value);

  /// Removes an entry from persistent storage.
  Future<void> remove(String key);

  /// Removes multiple entries from persistent storage.
  ///
  /// - If [allowList] is null, all entries are removed.
  /// - If [allowList] is provided, only keys present in the allowList
  ///   are removed.
  Future<void> removeAll({Set<String>? allowList});
}
