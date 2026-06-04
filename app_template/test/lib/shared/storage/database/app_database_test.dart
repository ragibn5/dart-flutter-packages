// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite_db/sqlite_db.dart';

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

  late AppDatabase sut;

  setUpAll(() {
    registerFallbackValue(connectionData);
  });

  setUp(() {
    mockDbInitializationScripts = _MockDbInitializationScripts();
    mockDatabaseFactory = _MockDatabaseFactory();
    mockDatabase = _MockDatabase();

    sut = AppDatabase.test(
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
      await sut.initialize();

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
    'methods must throw StateError if database is not yet initialized',
    () {
      final localDatabase = AppDatabase.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );

      expect(
        localDatabase.get('t', 'id', ['1']),
        throwsA(isA<StateError>()),
      );
    },
  );

  test('methods work after initialization', () async {
    final localDatabase = AppDatabase.test(
      connectionData,
      mockDbInitializationScripts,
      mockDatabaseFactory,
    );

    when(() => mockDatabase.isOpen).thenReturn(true);
    when(
      () => mockDatabase.query(
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
        distinct: any(named: 'distinct'),
        groupBy: any(named: 'groupBy'),
        having: any(named: 'having'),
        orderBy: any(named: 'orderBy'),
      ),
    ).thenAnswer((_) async => []);
    when(() => mockDatabase.delete(any())).thenAnswer((_) async => 0);
    await localDatabase.initialize();

    expect(localDatabase.get('t', 'id', ['1']), completes);
    expect(localDatabase.deleteAll('t'), completes);
  });
}
