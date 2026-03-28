import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Extensions on [ResolvedUnitResult] for locating annotations in the resolved
/// AST.
extension AnnotationResolution on ResolvedUnitResult {
  /// Finds the first annotation matching [annotationName]
  /// across all top-level declarations in the resolved unit.
  ///
  /// Returns `null` if no matching annotation is found.
  Annotation? findAnnotation({required String annotationName}) {
    for (final decl in unit.declarations) {
      final annotation = decl.metadata.where((a) {
        final name = a.name;
        if (name is PrefixedIdentifier) {
          return '${name.prefix.name}.${name.identifier.name}' ==
              annotationName;
        }
        return name.name == annotationName;
      }).firstOrNull;
      if (annotation != null) return annotation;
    }
    return null;
  }
}
