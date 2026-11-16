import 'package:analysis_server_plugin_core/src/services/resolvers/type_resolvers/annotation_type_resolver.dart';

final class AnnotationTypeResolverFactory {
  // Never created: it only holds static members.
  const AnnotationTypeResolverFactory._(); // coverage:ignore-line

  static AnnotationTypeResolver create() =>
      const ConstantValueAnnotationTypeResolver();
}
