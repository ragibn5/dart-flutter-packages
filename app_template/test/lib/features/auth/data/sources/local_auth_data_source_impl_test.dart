// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';

import 'package:app_template/core/infrastructure/storage/preference/preference_store.dart';
import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/sources/local_auth_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPreferenceStore extends Mock implements PreferenceStore {}

void main() {
  final authDataDTO = AuthDataDTO(
    userId: 'userId',
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );

  late _MockPreferenceStore mockPreferenceStore;

  late LocalAuthDataSourceImpl localAuthDataSource;

  setUp(() {
    mockPreferenceStore = _MockPreferenceStore();
    localAuthDataSource = LocalAuthDataSourceImpl(mockPreferenceStore);
  });

  test(
    'getCurrentAuthData should return null if no auth data is NOT set',
    () async {
      when(
        () => mockPreferenceStore.getString(any()),
      ).thenAnswer((_) async => null);

      final result = await localAuthDataSource.getCurrentAuthData();
      expect(result, isNull);
    },
  );

  test(
    'getCurrentAuthData should return valid auth data if auth data is set',
    () async {
      when(
        () => mockPreferenceStore.getString(any()),
      ).thenAnswer((_) async => jsonEncode(authDataDTO.toJson()));

      final result = await localAuthDataSource.getCurrentAuthData();
      expect(result, isNotNull);
      expect(result?.userId, equals(authDataDTO.userId));
      expect(result?.accessToken, equals(authDataDTO.accessToken));
      expect(result?.refreshToken, equals(authDataDTO.refreshToken));
      expect(
        result?.accessTokenExpiry,
        equals(authDataDTO.accessTokenExpiry.toUtc()),
      );
      expect(
        result?.refreshTokenExpiry,
        equals(authDataDTO.refreshTokenExpiry.toUtc()),
      );
    },
  );

  test(
    'setCurrentAuthData removes auth data when authDataDTO is null',
    () async {
      when(() => mockPreferenceStore.remove(any())).thenAnswer((_) async {});

      await localAuthDataSource.setCurrentAuthData(null);

      verify(
        () => mockPreferenceStore.remove(LocalAuthDataSourceImpl.preferenceKey),
      ).called(1);
      verifyNever(() => mockPreferenceStore.setString(any(), any()));
    },
  );

  test(
    'setCurrentAuthData sets correct auth data when auth data is NOT null',
    () async {
      when(
        () => mockPreferenceStore.setString(any(), any()),
      ).thenAnswer((_) async {});

      await localAuthDataSource.setCurrentAuthData(authDataDTO);

      verifyNever(() => mockPreferenceStore.remove(any()));
      verify(
        () => mockPreferenceStore.setString(
          LocalAuthDataSourceImpl.preferenceKey,
          any(),
        ),
      ).called(1);
    },
  );
}
