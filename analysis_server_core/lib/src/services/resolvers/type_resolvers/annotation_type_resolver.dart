import 'package:analyzer/dart/ast/ast.dart';

abstract interface class AnnotationTypeResolver {
  String? resolveTypeName(Annotation node);
}

class ConstantValueAnnotationTypeResolver implements AnnotationTypeResolver {
  const ConstantValueAnnotationTypeResolver();

  @override
  String? resolveTypeName(Annotation node) {
    return node.elementAnnotation?.computeConstantValue()?.type?.element?.name;
  }
}
