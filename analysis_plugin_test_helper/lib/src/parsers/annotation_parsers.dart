import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

/// Returns the first [Annotation] whose resolved type name matches
/// [annotationName] on any [D] declaration in [unit], or `null` if none
/// is found.
///
/// Note:
/// - Unresolved units will always return `null`.
/// - [D] controls which declaration kind is searched
///   (e.g. [ClassDeclaration], [MixinDeclaration], [FunctionDeclaration]).
Annotation? findAnnotation<D extends CompilationUnitMember>(
  CompilationUnit unit, {
  required String annotationName,
}) {
  for (final declaration in unit.declarations) {
    if (declaration is D) {
      for (final metadata in declaration.metadata) {
        if (metadata.elementAnnotation
                ?.computeConstantValue()
                ?.type
                ?.element
                ?.name ==
            annotationName) {
          return metadata;
        }
      }
    }
  }

  return null;
}

/// Returns the first [Annotation] whose resolved type name matches
/// [annotationName] on any [D] declaration in [unit], failing the test
/// if absent.
///
/// Note:
/// - Unresolved units will always return `null`.
/// - [D] controls which declaration kind is searched
///   (e.g. [ClassDeclaration], [MixinDeclaration], [FunctionDeclaration]).
Annotation getAnnotation<D extends CompilationUnitMember>(
  CompilationUnit unit, {
  required String annotationName,
}) {
  final annotation = findAnnotation<D>(unit, annotationName: annotationName);
  if (annotation == null) {
    fail('Could not find @$annotationName on any $D in the compilation unit');
  }

  return annotation;
}
