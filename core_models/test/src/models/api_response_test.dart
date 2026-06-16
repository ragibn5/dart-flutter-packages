import 'package:core_models/core_models.dart';
import 'package:test/test.dart';

void main() {
  group('Success', () {
    test('Should store data, statusCode, and headers', () {
      final success = Success(data: 42, statusCode: 200, headers: {
        'x-test': ['v']
      });
      expect(success.data, 42);
      expect(success.statusCode, 200);
      expect(success.headers, {
        'x-test': ['v']
      });
    });
  });

  group('Failure', () {
    test('Should store error, statusCode, and headers', () {
      final failure = Failure(
        error: 'err',
        statusCode: 400,
        headers: {
          'content-type': ['application/json']
        },
      );
      expect(failure.error, 'err');
      expect(failure.statusCode, 400);
      expect(failure.headers, {
        'content-type': ['application/json']
      });
    });
  });

  group('ApiResponse', () {
    test('Should call onFailure for Failure', () {
      final failure = Failure(
        error: 404,
        statusCode: 404,
        headers: {
          'content-type': ['application/json']
        },
      );
      final result = failure.fold(
        onFailure: (e) => 'error: $e',
        onSuccess: (d) => 'data: $d',
      );
      expect(result, 'error: 404');
    });

    test('Should call onSuccess for Success', () {
      final success = Success(
        data: 'hello',
        statusCode: 200,
        headers: {
          'content-type': ['application/json']
        },
      );
      final result = success.fold(
        onFailure: (e) => 'error: $e',
        onSuccess: (d) => 'data: $d',
      );
      expect(result, 'data: hello');
    });
  });
}
