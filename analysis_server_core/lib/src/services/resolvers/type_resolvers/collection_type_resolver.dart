// ignore_for_file: avoid_init_to_null

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
  /// Nullability is matched strictly — append `?` to the type name to match
  /// a nullable type argument. For example, `valueType: 'String'` matches
  /// only `List<String>`, and `valueType: 'String?'` matches only
  /// `List<String?>`.
  ///
  /// By default the outer `List` itself must be non-nullable. Pass
  /// [listNullable] as `true` to also match `List<...>?`.
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
  ///   Other special types such as `void` and `Never` are not supported.
  bool isListOf(
    TypeAnnotation? typeAnnotation, {
    required String valueType,
    bool listNullable = false,
  });

  /// Returns true if [typeAnnotation] resolves to
  /// `Map<[keyType], [valueType]>`.
  ///
  /// Resolves through typedef aliases —
  /// `typedef JsonMap = Map<String, dynamic>`
  /// will correctly match
  /// `isMapOf(..., keyType: 'String', valueType: 'dynamic')`.
  ///
  /// Nullability is matched strictly — append `?` to the type name to match
  /// a nullable type argument. For example, `keyType: 'String'` matches only
  /// `Map<String, ...>`, and `keyType: 'String?'` matches only
  /// `Map<String?, ...>`. Same applies to [valueType].
  ///
  /// By default the outer `Map` itself must be non-nullable. Pass
  /// [mapNullable] as `true` to also match `Map<...>?`.
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
  ///   Other special types such as `void` and `Never` are not supported.
  /// - Nullable map keys (`Map<String?, ...>`) are valid Dart but strongly
  ///   discouraged in practice.
  bool isMapOf(
    TypeAnnotation? typeAnnotation, {
    required String keyType,
    required String valueType,
    bool mapNullable = false,
  });
}

class DefaultCollectionTypeResolver implements CollectionTypeResolver {
  const DefaultCollectionTypeResolver();

  @override
  bool isListOf(
    TypeAnnotation? typeAnnotation, {
    required String valueType,
    bool listNullable = false,
  }) {
    if (typeAnnotation is! NamedType) {
      return false;
    }

    final type = typeAnnotation.type;
    if (type == null || type is! InterfaceType) {
      return false;
    }
    if (!listNullable && type.nullabilitySuffix != NullabilitySuffix.none) {
      return false;
    }
    if (type.element.name != 'List') {
      return false;
    }

    final args = type.typeArguments;
    if (args.length != 1) {
      return false;
    }

    return _matchesType(args[0], valueType);
  }

  @override
  bool isMapOf(
    TypeAnnotation? typeAnnotation, {
    required String keyType,
    required String valueType,
    bool mapNullable = false,
  }) {
    if (typeAnnotation is! NamedType) {
      return false;
    }

    final type = typeAnnotation.type;
    if (type == null || type is! InterfaceType) {
      return false;
    }
    if (!mapNullable && type.nullabilitySuffix != NullabilitySuffix.none) {
      return false;
    }
    if (type.element.name != 'Map') {
      return false;
    }

    final args = type.typeArguments;
    if (args.length != 2) {
      return false;
    }

    return _matchesType(args[0], keyType) && _matchesType(args[1], valueType);
  }

  bool _matchesType(DartType type, String typeName) {
    final expectedNullable = typeName.endsWith('?');
    final name = expectedNullable
        ? typeName.substring(0, typeName.length - 1)
        : typeName;

    // dynamic absorbs nullability in Dart — dynamic? is identical to dynamic.
    // So we skip the nullability check for dynamic entirely.
    if (name == 'dynamic') {
      return type is DynamicType;
    }

    final actualNullable = type.nullabilitySuffix == NullabilitySuffix.question;
    if (actualNullable != expectedNullable) {
      return false;
    }

    return type.element?.name == name;
  }
}
