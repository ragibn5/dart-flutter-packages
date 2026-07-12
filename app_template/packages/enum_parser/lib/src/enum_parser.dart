T parseEnum<T extends Enum>(
  List<T> values, {
  required String? rawValue,
  required T fallbackValue,
  bool ignoreCase = true,
}) {
  bool matches(T e) => ignoreCase
      ? e.name.toUpperCase() == rawValue?.toUpperCase()
      : e.name == rawValue;

  return values.where(matches).firstOrNull ?? fallbackValue;
}
