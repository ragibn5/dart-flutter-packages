// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/user_data/data/models/user_data_dto.dart';
import 'package:app_template/features/user_data/data/sources/user_data_data_source_impl.dart';
import 'package:app_template/features/user_data/domain/models/user_data.dart';
import 'package:app_template/features/user_data/infrastructure/database/user_data_table_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite_db/sqlite_db.dart';

class _MockSQLiteDb extends Mock implements SQLiteDb {}

void main() {
  const uid = 'ragib';
  const dto = UserDataDTO(id: uid, name: 'Ragib');

  final entity = UserData(id: dto.id, name: dto.name);

  late _MockSQLiteDb mockSQLiteDb;

  late UserDataDataSourceImpl sut;

  setUpAll(() {
    registerFallbackValue(dto);
    registerFallbackValue(entity);
  });

  setUp(() {
    mockSQLiteDb = _MockSQLiteDb();

    sut = UserDataDataSourceImpl(mockSQLiteDb);
  });

  test(
    '`getUserData` should call get() with correct user id and return dto',
    () async {
      when(
        () => mockSQLiteDb.get(any(), any(), [uid]),
      ).thenAnswer((_) async => [dto.toJson()]);

      final result = await sut.getUserData(uid);

      expect(result, dto);
      verify(
        () => mockSQLiteDb.get(
          UserDataTableConstants.NAME,
          UserDataTableConstants.COLUMN_ID,
          [uid],
        ),
      ).called(1);
    },
  );

  test(
    '`setUserData` should call insert() with a list containing encoded entity',
    () async {
      when(() => mockSQLiteDb.insert(any(), any())).thenAnswer((_) async => 1);

      await sut.setUserData(dto);

      verify(
        () => mockSQLiteDb.insert(UserDataTableConstants.NAME, [dto.toJson()]),
      ).called(1);
    },
  );

  test(
    '`removeUserData` should call delete() with a list containing given id',
    () async {
      when(
        () => mockSQLiteDb.delete(any(), any(), [uid]),
      ).thenAnswer((_) async => 1);

      await sut.removeUserData(uid);

      verify(
        () => mockSQLiteDb.delete(
          UserDataTableConstants.NAME,
          UserDataTableConstants.COLUMN_ID,
          [uid],
        ),
      ).called(1);
    },
  );
}
