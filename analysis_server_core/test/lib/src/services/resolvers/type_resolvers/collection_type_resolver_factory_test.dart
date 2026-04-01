import 'package:analysis_server_core/src/services/resolvers/type_resolvers/collection_type_resolver.dart';
import 'package:analysis_server_core/src/services/resolvers/type_resolvers/collection_type_resolver_factory.dart';
import 'package:test/test.dart';

void main() {
  test('creates CollectionTypeResolver instance', () {
    final sut = CollectionTypeResolverFactory.create();

    expect(sut, isA<CollectionTypeResolver>());
  });
}
