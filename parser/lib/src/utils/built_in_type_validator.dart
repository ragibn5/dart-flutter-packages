class BuiltInTypeValidator {
  /// Checks if the given type is a built-in type.
  bool isBuiltInType(Type type) {
    return _isPrimitiveType(type) ||
        _isListType(type) ||
        _isSetType(type) ||
        _isMapType(type) ||
        _isOtherBuiltInType(type);
  }

  /// Checks if the type is a primitive type.
  bool _isPrimitiveType(Type type) {
    return type == bool ||
        type == int ||
        type == double ||
        type == num ||
        type == String ||
        type == Null;
  }

  /// Checks if the type is a List type.
  bool _isListType(Type type) {
    return type == List || type.toString().startsWith('List<');
  }

  /// Checks if the type is a Map type.
  bool _isMapType(Type type) {
    return type == Map || type.toString().startsWith('Map<');
  }

  /// Checks if the type is a Set type.
  bool _isSetType(Type type) {
    return type == Set || type.toString().startsWith('Set<');
  }

  /// Checks if the type is another built-in type.
  bool _isOtherBuiltInType(Type type) {
    return type == dynamic || type == Object;
  }

  /// Checks if the type is a generic built-in type.
  bool isGenericBuiltInType(Type type) {
    if (!isBuiltInType(type)) return false;

    final typeString = type.toString();
    return typeString.contains('<') && typeString.contains('>');
  }
}
