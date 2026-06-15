import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite_db/sqlite_db.dart';
import 'package:sqlite_db/src/sqlite_db_impl.dart';

class _MockDbInitializationScripts extends Mock
    implements DbInitializerScripts {}

void main() {
  const connectionData = DbConnectionData(
    hostDirectoryPath: 'a/b/c',
    name: 'APP_DB',
    version: 1,
  );

  late _MockDbInitializationScripts mockDbInitializationScripts;
  late SQLiteDbFactory sut;

  setUp(() {
    mockDbInitializationScripts = _MockDbInitializationScripts();

    sut = const SQLiteDbFactory();
  });

  test('Create passes connectionData and initializerScripts through', () async {
    final result = sut.create(connectionData, mockDbInitializationScripts);

    expect(
      result,
      isA<SQLiteDbImpl>()
          .having(
            (i) => i.connectionData,
            'connectionData',
            same(connectionData),
          )
          .having(
            (i) => i.initializerScripts,
            'initializerScripts',
            same(mockDbInitializationScripts),
          ),
    );
  });
}
