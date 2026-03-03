import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';

extension AnnotationExtensions on Annotation {
  DartObject? findArgument(String argName) {
    return elementAnnotation?.computeConstantValue()?.getField(argName);
  }
}
