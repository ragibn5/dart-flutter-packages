import 'package:analysis_server_plugin_core/src/services/resolvers/type_resolvers/annotation_type_resolver.dart';

final class AnnotationTypeResolverFactory {
  const AnnotationTypeResolverFactory._();

  static AnnotationTypeResolver create() =>
      const ConstantValueAnnotationTypeResolver();
}
