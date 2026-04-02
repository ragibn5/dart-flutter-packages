// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/core/infrastructure/storage/database/sqlite_db.dart';
import 'package:app_template/core/infrastructure/storage/database/sqlite_db_dao.dart';
import 'package:app_template/features/user_data/data/models/user_data_dto.dart';
import 'package:app_template/features/user_data/data/sources/user_data_data_source_impl.dart';
import 'package:app_template/features/user_data/domain/models/user_data.dart';
import 'package:app_template/features/user_data/infrastructure/database/user_data_table_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSQLiteDb extends Mock implements SQLiteDb {}

class _MockSQLiteDbDao extends Mock implements SQLiteDbDao {}

void main() {
  const uid = 'ragib';
  const dto = UserDataDTO(id: uid, name: 'Ragib');

  final entity = UserData(id: dto.id, name: dto.name);

  late _MockSQLiteDb mockSQLiteDb;
  late _MockSQLiteDbDao mockSQLiteDbDao;

  late UserDataDataSourceImpl sut;

  setUpAll(() {
    registerFallbackValue(dto);
    registerFallbackValue(entity);
  });

  setUp(() {
    mockSQLiteDb = _MockSQLiteDb();
    mockSQLiteDbDao = _MockSQLiteDbDao();

    sut = UserDataDataSourceImpl(mockSQLiteDb);

    when(() => mockSQLiteDb.dao).thenReturn(mockSQLiteDbDao);
  });

  test(
    '`getUserData` should call dao.get() with correct user id and return dto',
    () async {
      when(
        () => mockSQLiteDbDao.get(any(), any(), [uid]),
      ).thenAnswer((_) async => [dto.toJson()]);

      final result = await sut.getUserData(uid);

      expect(result, dto);
      verify(
        () => mockSQLiteDbDao.get(
          UserDataTableConstants.NAME,
          UserDataTableConstants.COLUMN_ID,
          [uid],
        ),
      ).called(1);
    },
  );

  test(
    '`setUserData` should call dao.insert() with a list containing encoded entity',
    () async {
      when(
        () => mockSQLiteDbDao.insert(any(), any()),
      ).thenAnswer((_) async => 1);

      await sut.setUserData(dto);

      verify(
        () =>
            mockSQLiteDbDao.insert(UserDataTableConstants.NAME, [dto.toJson()]),
      ).called(1);
    },
  );

  test(
    '`removeUserData` should call dao.delete() with a list containing given id',
    () async {
      when(
        () => mockSQLiteDbDao.delete(any(), any(), [uid]),
      ).thenAnswer((_) async => 1);

      await sut.removeUserData(uid);

      verify(
        () => mockSQLiteDbDao.delete(
          UserDataTableConstants.NAME,
          UserDataTableConstants.COLUMN_ID,
          [uid],
        ),
      ).called(1);
    },
  );
}
