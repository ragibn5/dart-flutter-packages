// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/core/converters/data_domain_converter.dart';
import 'package:app_template/features/user_data/data/models/user_data_dto.dart';
import 'package:app_template/features/user_data/data/repositories/user_data_repository_impl.dart';
import 'package:app_template/features/user_data/data/sources/user_data_data_source.dart';
import 'package:app_template/features/user_data/domain/models/user_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserDateConverter extends Mock
    implements DataDomainConverter<UserDataDTO, UserData> {}

class _MockUserDataDataSource extends Mock implements UserDataDataSource {}

void main() {
  const uid = 'ragib';
  const dto = UserDataDTO(id: uid, name: 'Ragib');
  final entity = UserData(id: dto.id, name: dto.name);

  late _MockUserDateConverter mockUserDateConverter;
  late _MockUserDataDataSource mockUserDataDataSource;

  late UserDataRepositoryImpl repositoryImpl;

  setUpAll(() {
    registerFallbackValue(dto);
    registerFallbackValue(entity);
  });

  setUp(() {
    mockUserDateConverter = _MockUserDateConverter();
    mockUserDataDataSource = _MockUserDataDataSource();

    repositoryImpl = UserDataRepositoryImpl(
      mockUserDateConverter,
      mockUserDataDataSource,
    );
  });

  test('`getUserData` should return null if no record was found', () async {
    when(
      () => mockUserDataDataSource.getUserData(uid),
    ).thenAnswer((_) async => null);

    final result = await repositoryImpl.getUserData(uid);

    expect(result, isNull);
  });

  test(
    '`getUserData` should return correct domain model if a record was found',
    () async {
      when(
        () => mockUserDataDataSource.getUserData(uid),
      ).thenAnswer((_) async => dto);
      when(
        () => mockUserDateConverter.convertDataToDomain(dto),
      ).thenReturn(entity);

      final result = await repositoryImpl.getUserData(uid);

      expect(result, entity);
    },
  );

  test('`setUserData` should call the data source with correct dto', () async {
    when(
      () => mockUserDateConverter.convertDomainToData(entity),
    ).thenReturn(dto);
    when(
      () => mockUserDataDataSource.setUserData(dto),
    ).thenAnswer((_) async {});

    await repositoryImpl.setUserData(entity);

    verify(() => mockUserDateConverter.convertDomainToData(entity)).called(1);
    verify(() => mockUserDataDataSource.setUserData(dto)).called(1);
  });

  test(
    '`removeUserData` should call the data source with correct userId',
    () async {
      when(
        () => mockUserDataDataSource.removeUserData(uid),
      ).thenAnswer((_) async {});

      await repositoryImpl.removeUserData(uid);

      verify(() => mockUserDataDataSource.removeUserData(uid)).called(1);
    },
  );
}
