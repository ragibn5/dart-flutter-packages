import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:test/test.dart';

/// Parses [content] and returns the first [Annotation] whose name matches
/// [annotationName], or `null` if none is found.
///
/// The returned [Annotation] is **unresolved** — the AST is parsed
/// syntactically only. Properties that require resolution, such as
/// [Annotation.elementAnnotation], [Element] references, and constant
/// values, will be `null`. Use [DartUnitResolver] if resolved information
/// is needed.
Annotation? parseAnnotation(String content, {required String annotationName}) {
  final unit = parseString(content: content).unit;
  for (final declaration in unit.declarations) {
    if (declaration is ClassDeclaration) {
      for (final metadata in declaration.metadata) {
        if (metadata.name.name == annotationName) return metadata;
      }
    }
  }
  return null;
}

/// Parses [content] and returns the annotation, failing the test if absent.
///
/// The returned [Annotation] is **unresolved** — see [parseAnnotation] for
/// details.
Annotation parseValidAnnotation(
  String content, {
  required String annotationName,
}) {
  final annotation = parseAnnotation(content, annotationName: annotationName);
  if (annotation == null) {
    fail('Expected @$annotationName annotation in content, got: |$content|');
  }
  return annotation;
}
