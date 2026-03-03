// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/shared/storage/database/app_database.dart';
import 'package:app_template/shared/storage/database/models/db_connection_data.dart';
import 'package:app_template/shared/storage/database/models/db_initialization_scripts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _MockDbInitializationScripts extends Mock
    implements DbInitializerScripts {}

class _MockDatabaseFactory extends Mock implements DatabaseFactory {}

class _MockDatabase extends Mock implements Database {}

void main() {
  const connectionData = DbConnectionData(
    hostDirectoryPath: 'a/b/c',
    name: 'APP_DB',
    version: 1,
  );

  late _MockDbInitializationScripts mockDbInitializationScripts;
  late _MockDatabaseFactory mockDatabaseFactory;
  late _MockDatabase mockDatabase;

  late AppDatabase database;

  setUpAll(() {
    registerFallbackValue(connectionData);
  });

  setUp(() {
    mockDbInitializationScripts = _MockDbInitializationScripts();
    mockDatabaseFactory = _MockDatabaseFactory();
    mockDatabase = _MockDatabase();

    database = AppDatabase.test(
      connectionData,
      mockDbInitializationScripts,
      mockDatabaseFactory,
    );

    when(() => mockDbInitializationScripts.configurationScripts).thenReturn([]);
    when(() => mockDbInitializationScripts.creationScripts).thenReturn([]);
    when(() => mockDbInitializationScripts.upgradeScripts).thenReturn([]);
    when(() => mockDbInitializationScripts.openScripts).thenReturn([]);
    when(
      () => mockDatabaseFactory.openDatabase(
        any(),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => mockDatabase);
  });

  test(
    'AppDatabase is initialized with correct path, name and version',
    () async {
      await database.initialize();

      verify(
        () => mockDatabaseFactory.openDatabase(
          path.join(connectionData.hostDirectoryPath, connectionData.name),
          options: any(
            named: 'options',
            that: isA<OpenDatabaseOptions>().having(
              (d) => d.version,
              'version',
              connectionData.version,
            ),
          ),
        ),
      ).called(1);
    },
  );

  test(
    '`dao` getter must throw StateError if database is not yet initialized',
    () {
      final localDatabase = AppDatabase.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );

      expect(() => localDatabase.dao, throwsA(isA<StateError>()));
    },
  );

  test('`initialize()` initializes  `dao`', () async {
    final localDatabase = AppDatabase.test(
      connectionData,
      mockDbInitializationScripts,
      mockDatabaseFactory,
    );

    await localDatabase.initialize();

    expect(() => localDatabase.dao, isNotNull);
  });
}
