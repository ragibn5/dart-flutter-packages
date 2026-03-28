import 'package:analysis_server_core/src/services/resolvers/type_resolvers/annotation_type_resolver.dart';
import 'package:analysis_server_core/src/services/resolvers/type_resolvers/type_resolver_factory.dart';
import 'package:test/test.dart';

void main() {
  test('creates ConstantValueAnnotationTypeResolver instance', () {
    final resolver = TypeResolverFactory.createAnnotationTypeResolver();

    expect(resolver, isA<ConstantValueAnnotationTypeResolver>());
  });
}
