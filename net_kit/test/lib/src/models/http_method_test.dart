import 'package:net_kit/src/models/http_method.dart';
import 'package:test/test.dart';

void main() {
  test('Returns the matching method for normalized input', () {
    expect(HttpMethod.fromValue(' post '), HttpMethod.POST);
  });

  test('Throws for an unsupported method', () {
    expect(() => HttpMethod.fromValue('TRACE'), throwsA(isA<ArgumentError>()));
  });
}
