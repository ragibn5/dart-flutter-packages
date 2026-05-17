// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/server_message.dart';
import 'package:app_template/features/auth/data/mappers/auth_refresh_error_mapper.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuthRefreshErrorMapper mapper;

  setUp(() {
    mapper = AuthRefreshErrorMapper();
  });

  test('If error is `$AppError`, return as is', () {
    final error = ApiError<ServerError<ServerMessage>>.fromAppError(
      const IllegalStateError(message: 'Test'),
    );

    mapper
        .convertDataToDomain(error)
        .fold((ae) => expect(ae, isNotNull), (ne) {}, (se) {});
  });

  test('If error is `$TransportError`, return as is', () {
    final error = ApiError<ServerError<ServerMessage>>.fromNetworkError(
      const ConnectionTimeout(message: 'Test'),
    );

    mapper
        .convertDataToDomain(error)
        .fold((ae) {}, (ne) => expect(ne, isNotNull), (se) {});
  });

  test('If error is `$ServerError`, map to appropriate domain error', () {
    ApiError<ServerError<ServerMessage>> error;

    // INVALID_REFRESH_TOKEN
    error = ApiError<ServerError<ServerMessage>>.fromServerError(
      const ServerError(
        statusCode: HttpStatus.badRequest,
        errorResponse: ServerMessage(
          code: AuthRefreshErrorMapper.INVALID_REFRESH_TOKEN,
        ),
      ),
    );
    mapper.convertDataToDomain(error).fold(
      (ae) => fail('Should not be of type $AppError'),
      (ne) => fail('Should not be of type $TransportError'),
      (se) {
        expect(se, isA<InvalidRefreshToken>());
      },
    );

    // INVALID_AUTH_STATE_FOR_REFRESH
    error = ApiError<ServerError<ServerMessage>>.fromServerError(
      const ServerError(
        statusCode: HttpStatus.badRequest,
        errorResponse: ServerMessage(
          code: AuthRefreshErrorMapper.INVALID_AUTH_STATE_FOR_REFRESH,
        ),
      ),
    );
    mapper.convertDataToDomain(error).fold(
      (ae) => fail('Should not be of type $AppError'),
      (ne) => fail('Should not be of type $TransportError'),
      (se) {
        expect(se, isA<InvalidAuthStateForRefresh>());
      },
    );

    // UNKNOWN
    error = ApiError<ServerError<ServerMessage>>.fromServerError(
      const ServerError(
        statusCode: HttpStatus.badRequest,
        errorResponse: ServerMessage(code: 'unknown'),
      ),
    );
    expect(
      () => mapper.convertDataToDomain(error).fold((ae) {}, (ne) {}, (se) {}),
      throwsA(isA<ArgumentError>()),
    );
  });
}
