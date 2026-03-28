import 'package:analysis_server_core/src/services/resolvers/type_resolvers/annotation_type_resolver.dart';

final class TypeResolverFactory {
  const TypeResolverFactory._();

  static AnnotationTypeResolver createAnnotationTypeResolver() =>
      const ConstantValueAnnotationTypeResolver();
}
