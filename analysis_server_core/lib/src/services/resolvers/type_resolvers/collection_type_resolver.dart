import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

/// Resolves whether a [TypeAnnotation] represents a specific collection type,
/// such as `List<T>` or `Map<K, V>`, using the analyzer's element model.
///
/// Unlike purely syntactic checks, this resolver resolves through typedef
/// aliases — for example, `typedef MyList = List<String>` will correctly
/// match `isListOf(..., valueType: 'String')`.
abstract class CollectionTypeResolver {
  /// Returns true if [typeAnnotation] resolves to `List<[valueType]>`.
  ///
  /// Resolves through typedef aliases — `typedef MyList = List<String>` will
  /// correctly match `isListOf(..., valueType: 'String')`.
  ///
  /// By default, neither the outer type nor the type argument may be nullable.
  /// Use [allowNullable] to allow `List<String>?` and
  /// [allowNullableValueType] to allow `List<String?>`.
  ///
  /// **Limitations:**
  /// - Only exact `List` is supported — subtypes such as `UnmodifiableListView`
  ///   or any custom class that implements `List` will not match.
  /// - Nested generics are not recursively checked — `List<List<int>>` will
  ///   match `isListOf(..., valueType: 'List')` but the inner `List<int>` is
  ///   not verified.
  /// - Type parameters are not supported — `List<T>` where `T` is a generic
  ///   type parameter will not match any concrete type name.
  /// - Only `dynamic` is handled as a special case for element-less types.
  ///   Other special types such as `void`, `Never`, and `Object?` will not
  ///   match unless explicitly allowed via [allowNullableValueType].
  bool isListOf(
    TypeAnnotation? typeAnnotation, {
    required String valueType,
    bool allowNullable = false,
    bool allowNullableValueType = false,
  });

  /// Returns true if [typeAnnotation] resolves to
  /// `Map<[keyType], [valueType]>`.
  ///
  /// Resolves through typedef aliases —
  /// `typedef JsonMap = Map<String, dynamic>`
  /// will correctly match
  /// `isMapOf(..., keyType: 'String', valueType: 'dynamic')`.
  ///
  /// By default, neither the outer type nor the type arguments may be nullable.
  /// Use [allowNullable] to allow `Map<String, dynamic>?`,
  /// [allowNullableKeyType] to allow `Map<String?, dynamic>`, and
  /// [allowNullableValueType] to allow `Map<String, dynamic?>`.
  ///
  /// **Limitations:**
  /// - Only exact `Map` is supported — subtypes such as `LinkedHashMap`,
  ///   `SplayTreeMap`, or any custom class that implements `Map` will not
  ///   match.
  /// - Nested generics are not recursively checked — `Map<String, List<int>>`
  ///   will match `isMapOf(..., keyType: 'String', valueType: 'List')` but the
  ///   inner `List<int>` is not verified.
  /// - Type parameters are not supported — `Map<K, V>` where `K` and `V` are
  ///   generic type parameters will not match any concrete type name.
  /// - Only `dynamic` is handled as a special case for element-less types.
  ///   Other special types such as `void`, `Never`, and `Object?` will not
  ///   match unless explicitly allowed via [allowNullableKeyType] or
  ///   [allowNullableValueType].
  bool isMapOf(
    TypeAnnotation? typeAnnotation, {
    required String keyType,
    required String valueType,
    bool allowNullable = false,
    bool allowNullableKeyType = false,
    bool allowNullableValueType = false,
  });
}

class DefaultCollectionTypeResolver implements CollectionTypeResolver {
  const DefaultCollectionTypeResolver();

  @override
  bool isListOf(
    TypeAnnotation? typeAnnotation, {
    required String valueType,
    bool allowNullable = false,
    bool allowNullableValueType = false,
  }) {
    if (typeAnnotation is! NamedType) {
      return false;
    }

    final type = typeAnnotation.type;
    if (type == null || type is! InterfaceType) {
      return false;
    }
    if (!allowNullable && type.nullabilitySuffix != NullabilitySuffix.none) {
      return false;
    }
    if (type.element.name != 'List') {
      return false;
    }

    final args = type.typeArguments;
    if (args.length != 1) {
      return false;
    }

    return _matchesType(
      args[0],
      valueType,
      allowNullable: allowNullableValueType,
    );
  }

  @override
  bool isMapOf(
    TypeAnnotation? typeAnnotation, {
    required String keyType,
    required String valueType,
    bool allowNullable = false,
    bool allowNullableKeyType = false,
    bool allowNullableValueType = false,
  }) {
    if (typeAnnotation is! NamedType) {
      return false;
    }

    final type = typeAnnotation.type;
    if (type == null || type is! InterfaceType) {
      return false;
    }
    if (!allowNullable && type.nullabilitySuffix != NullabilitySuffix.none) {
      return false;
    }
    if (type.element.name != 'Map') {
      return false;
    }

    final args = type.typeArguments;
    if (args.length != 2) {
      return false;
    }

    return _matchesType(
          args[0],
          keyType,
          allowNullable: allowNullableKeyType,
        ) &&
        _matchesType(args[1], valueType, allowNullable: allowNullableValueType);
  }

  bool _matchesType(
    DartType type,
    String typeName, {
    required bool allowNullable,
  }) {
    if (!allowNullable && type.nullabilitySuffix != NullabilitySuffix.none) {
      return false;
    }
    if (typeName == 'dynamic') return type is DynamicType;
    return type.element?.name == typeName;
  }
}
