import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeIterableExtensions on List<DartType> {
  /// Checks if two lists of types match element-wise.
  bool typeListsMatch(List<DartType> b) {
    if (length != b.length) return false;
    for (var i = 0; i < length; i++) {
      if (!this[i].typesMatch(b[i])) return false;
    }
    return true;
  }
}

extension DartTypeExtensions on DartType {
  /// Checks if two types match, including their type arguments.
  bool typesMatch(DartType b) {
    final a = this;
    if (a is InterfaceType && b is InterfaceType) {
      return a.element3 == b.element3 &&
          b.typeArguments.typeListsMatch(a.typeArguments);
    }
    return this == b;
  }

  /// Converts the type to a display string including type parameters.
  String get displayStringWithTypeArgsSection {
    if (this is InterfaceType) {
      final type = this as InterfaceType;
      return '${type.element3.name3}'
          '${_typeArgumentsToString(type.typeArguments)}';
    } else if (this is FunctionType) {
      return _functionTypeToString(this as FunctionType);
    } else if (this is TypeParameterType) {
      return (this as TypeParameterType).element3.name3 ?? '';
    }
    return getDisplayString();
  }

  /// Helper method for formatting type arguments.
  String _typeArgumentsToString(List<DartType> typeArguments) {
    if (typeArguments.isEmpty) return '';
    return '<${typeArguments.map((t) => t.displayStringWithTypeArgsSection).join(', ')}>';
  }

  /// Helper method for formatting function types.
  String _functionTypeToString(FunctionType type) {
    final buffer = StringBuffer()
      ..write(type.returnType.displayStringWithTypeArgsSection)
      ..write(' Function(')
      ..write(_parametersToString(type.parameters))
      ..write(')');
    return buffer.toString();
  }

  /// Helper method for formatting parameters.
  String _parametersToString(List<ParameterElement> parameters) {
    return parameters.map((p) {
      final buffer = StringBuffer();
      if (p.isNamed) buffer.write('{');
      if (p.isOptional) buffer.write('[');
      buffer.write(p.type.displayStringWithTypeArgsSection);
      if (p.isNamed) buffer.write(' ${p.name}');
      if (p.isOptional) buffer.write(']');
      if (p.isNamed) buffer.write('}');
      return buffer.toString();
    }).join(', ');
  }
}
