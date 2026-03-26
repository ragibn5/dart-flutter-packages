import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:test/test.dart';

/// Parses [content] and returns the first [Annotation] whose name matches
/// [annotationName], or `null` if none is found.
Annotation? parseAnnotation(
  String content, {
  String annotationName = 'GenerateJsonParser',
}) {
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
Annotation parseValidAnnotation(
  String content, {
  String annotationName = 'GenerateJsonParser',
}) {
  final annotation = parseAnnotation(content, annotationName: annotationName);
  if (annotation == null) {
    fail('Expected @$annotationName annotation in content, got: |$content|');
  }
  return annotation;
}
