import 'package:analysis_server_plugin_core/src/services/resolvers/type_resolvers/collection_type_resolver.dart';

final class CollectionTypeResolverFactory {
  // Never created: it only holds static members.
  const CollectionTypeResolverFactory._(); // coverage:ignore-line

  static CollectionTypeResolver create() =>
      const DefaultCollectionTypeResolver();
}
