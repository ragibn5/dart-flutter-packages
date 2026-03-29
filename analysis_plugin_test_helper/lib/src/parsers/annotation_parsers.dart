import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:test/test.dart';

/// Returns the first [Annotation] whose name matches [annotationName]
/// on any [D] declaration in [unit], or `null` if none is found.
///
/// [D] controls which declaration kind is searched
/// (e.g. [ClassDeclaration], [MixinDeclaration], [FunctionDeclaration]).
Annotation? findAnnotation<D extends CompilationUnitMember>(
  CompilationUnit unit, {
  required String annotationName,
}) {
  for (final declaration in unit.declarations) {
    if (declaration is D) {
      for (final metadata in declaration.metadata) {
        if (metadata.name.name == annotationName) return metadata;
      }
    }
  }
  return null;
}

/// Parses [content] and returns the first [Annotation] whose name matches
/// [annotationName] on any [D] declaration, or `null` if none is found.
///
/// [D] controls which declaration kind is searched
/// (e.g. [ClassDeclaration], [MixinDeclaration], [FunctionDeclaration]).
///
/// The returned [Annotation] is **unresolved** — the AST is parsed
/// syntactically only. Properties that require resolution, such as
/// [Annotation.elementAnnotation], [Element] references, and constant
/// values, will be `null`. Use [DartUnitResolver] if resolved information
/// is needed.
Annotation? findParsedAnnotation<D extends CompilationUnitMember>(
  String content, {
  required String annotationName,
}) {
  final unit = parseString(content: content).unit;
  return findAnnotation<D>(unit, annotationName: annotationName);
}

/// Parses [content] and returns the first [Annotation] whose name matches
/// [annotationName] on any [D] declaration, failing the test if absent.
///
/// [D] controls which declaration kind is searched
/// (e.g. [ClassDeclaration], [MixinDeclaration], [FunctionDeclaration]).
///
/// The returned [Annotation] is **unresolved** —
/// see [findParsedAnnotation] for details.
Annotation getParsedAnnotation<D extends CompilationUnitMember>(
  String content, {
  required String annotationName,
}) {
  final annotation = findParsedAnnotation<D>(
    content,
    annotationName: annotationName,
  );
  if (annotation == null) {
    fail('Could not find @$annotationName');
  }
  return annotation;
}
