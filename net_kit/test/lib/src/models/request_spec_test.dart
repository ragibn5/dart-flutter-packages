import 'package:net_kit/net_kit.dart';
import 'package:test/test.dart';

void main() {
  group('uri', () {
    test('Returns pathOrUrl as-is when no baseUrl is given', () {
      final spec = RequestSpec(pathOrUrl: '/users', method: HttpMethod.GET);
      expect(spec.uri.toString(), '/users');
    });

    test('Appends query parameters when no baseUrl is given', () {
      final spec = RequestSpec(
        pathOrUrl: '/users',
        method: HttpMethod.GET,
        queryParameters: {'role': 'admin'},
      );
      expect(spec.uri.toString(), '/users?role=admin');
    });

    test('Joins baseUrl with relative path', () {
      final spec = RequestSpec(
        pathOrUrl: '/users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
      );
      expect(spec.uri.toString(), 'https://api.example.com/users');
    });

    test('Handles baseUrl with trailing slash', () {
      final spec = RequestSpec(
        pathOrUrl: 'users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com/',
      );
      expect(spec.uri.toString(), 'https://api.example.com/users');
    });

    test(
      'Handles path with leading slash and baseUrl without trailing slash',
      () {
        final spec = RequestSpec(
          pathOrUrl: '/users',
          method: HttpMethod.GET,
          baseUrl: 'https://api.example.com',
        );
        expect(spec.uri.toString(), 'https://api.example.com/users');
      },
    );

    test('Includes query parameters in the constructed URL', () {
      final spec = RequestSpec(
        pathOrUrl: '/users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
        queryParameters: {'role': 'admin', 'active': 'true'},
      );
      expect(
        spec.uri.toString(),
        'https://api.example.com/users?role=admin&active=true',
      );
    });

    test('Uses pathOrUrl as-is when it already has a scheme', () {
      final spec = RequestSpec(
        pathOrUrl: 'https://other.com/users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
      );
      expect(spec.uri.toString(), 'https://other.com/users');
    });

    test('Appends query params to a full URL', () {
      final spec = RequestSpec(
        pathOrUrl: 'https://other.com/users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
        queryParameters: {'page': '1'},
      );
      expect(
        spec.uri.toString(),
        'https://other.com/users?page=1',
      );
    });

    test('Coerces non-string query param values to strings', () {
      final spec = RequestSpec(
        pathOrUrl: '/search',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
        queryParameters: {'count': 5, 'enabled': true},
      );
      expect(
        spec.uri.toString(),
        'https://api.example.com/search?count=5&enabled=true',
      );
    });

    test('Ignores empty query parameters map', () {
      final spec = RequestSpec(
        pathOrUrl: '/users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
        queryParameters: {},
      );
      expect(spec.uri.toString(), 'https://api.example.com/users');
    });

    test('Ignores null query parameters', () {
      final spec = RequestSpec(
        pathOrUrl: '/users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
      );
      expect(spec.uri.toString(), 'https://api.example.com/users');
    });

    test('Normalizes dot segments in the path', () {
      final spec = RequestSpec(
        pathOrUrl: '/users/../users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
      );
      expect(spec.uri.toString(), 'https://api.example.com/users');
    });
  });
}
