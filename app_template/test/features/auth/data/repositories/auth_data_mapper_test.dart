// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/repositories/auth_data_mapper.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.now();
  final authData = AuthData(
    userId: 'domain.userId',
    accessToken: 'domain.accessToken',
    refreshToken: 'domain.refreshToken',
    accessTokenExpiry: now.add(const Duration(days: 1)),
    refreshTokenExpiry: now.add(const Duration(days: 2)),
  );
  final authDataDTO = AuthDataDTO(
    userId: 'data.userId',
    accessToken: 'data.accessToken',
    refreshToken: 'data.refreshToken',
    accessTokenExpiry: now.add(const Duration(days: 3)),
    refreshTokenExpiry: now.add(const Duration(days: 4)),
  );

  late AuthDataMapper sut;

  setUp(() {
    sut = AuthDataMapper();
  });

  test('Map Data to Domain model', () {
    final result = sut.convertDataToDomain(authDataDTO);
    expect(result.accessToken, authDataDTO.accessToken);
    expect(result.refreshToken, authDataDTO.refreshToken);
    expect(result.accessTokenExpiry, authDataDTO.accessTokenExpiry);
    expect(result.refreshTokenExpiry, authDataDTO.refreshTokenExpiry);
  });

  test('Map Domain to Data model', () {
    final result = sut.convertDomainToData(authData);
    expect(result.accessToken, authData.accessToken);
    expect(result.refreshToken, authData.refreshToken);
    expect(result.accessTokenExpiry, authData.accessTokenExpiry);
    expect(result.refreshTokenExpiry, authData.refreshTokenExpiry);
  });
}
