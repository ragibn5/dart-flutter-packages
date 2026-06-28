// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/auth/data/repositories/auth_refresh_error_mapper.dart';
import 'package:app_template/features/auth/domain/entities/auth_data_refresh_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

void main() {
  late AuthRefreshErrorMapper mapper;

  setUp(() {
    mapper = AuthRefreshErrorMapper();
  });

  test('INVALID_REFRESH_TOKEN maps to `InvalidRefreshToken`', () {
    final result = mapper.convertDataToDomain(
      const ServerMessage(code: AuthRefreshErrorMapper.INVALID_REFRESH_TOKEN),
    );

    expect(result, isA<InvalidRefreshToken>());
  });

  test(
    'INVALID_AUTH_STATE_FOR_REFRESH maps to `InvalidAuthStateForRefresh`',
    () {
      final result = mapper.convertDataToDomain(
        const ServerMessage(
          code: AuthRefreshErrorMapper.INVALID_AUTH_STATE_FOR_REFRESH,
        ),
      );

      expect(result, isA<InvalidAuthStateForRefresh>());
    },
  );

  test('Unknown code throws `ArgumentError`', () {
    expect(
      () => mapper.convertDataToDomain(const ServerMessage(code: 'unknown')),
      throwsA(isA<ArgumentError>()),
    );
  });
}
