import 'package:analysis_server_core/src/services/resolvers/type_resolvers/collection_type_resolver.dart';

final class CollectionTypeResolverFactory {
  const CollectionTypeResolverFactory._();

  static CollectionTypeResolver create() =>
      const DefaultCollectionTypeResolver();
}
