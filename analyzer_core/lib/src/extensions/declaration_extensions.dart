import 'package:analyzer/dart/ast/ast.dart';

extension DeclarationExtensions on Declaration {
  Annotation? findAnnotation(String annotationName) {
    for (final annotation in metadata) {
      final computedValue =
          annotation.elementAnnotation?.computeConstantValue();
      final annotationTypeAsString = computedValue?.type?.element3?.name3;

      if (annotationTypeAsString == annotationName) {
        return annotation;
      }
    }

    return null;
  }
}
