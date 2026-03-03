import 'dart:async';

import 'package:app_template/core/infrastructure/storage/database/sqlite_db.dart';
import 'package:app_template/core/infrastructure/storage/database/sqlite_db_dao.dart';
import 'package:app_template/shared/storage/database/daos/sqflite_db_dao_impl.dart';
import 'package:app_template/shared/storage/database/models/db_connection_data.dart';
import 'package:app_template/shared/storage/database/models/db_initialization_scripts.dart';
import 'package:app_template/shared/storage/database/models/db_script.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// The main app database.
///
/// It is almost always sufficient to have only one database per app.
/// But if you need more, you may create any number of them.
///
/// **Note:**
/// - Be sure to migrate the database when needed.
/// - Prefer using a singleton instance of this class.
class AppDatabase implements SQLiteDb {
  /// Connection data of the database we want to connect to.
  final DbConnectionData _connectionData;

  /// The initializer scripts to use.
  ///
  /// **Note:**
  /// Scripts are executed in the order they are given.
  final DbInitializerScripts _initializerScripts;

  /// The database factory to use.
  final DatabaseFactory _databaseFactory;

  /// The database connection to use.
  Database? _database;

  AppDatabase(
    DbConnectionData connectionData,
    DbInitializerScripts initializerScripts,
  ) : this._(connectionData, initializerScripts, databaseFactory);

  @visibleForTesting
  AppDatabase.test(
    DbConnectionData connectionData,
    DbInitializerScripts initializerScripts,
    DatabaseFactory dbFactory,
  ) : this._(connectionData, initializerScripts, dbFactory);

  AppDatabase._(
    this._connectionData,
    this._initializerScripts,
    this._databaseFactory,
  );

  @override
  SQLiteDbDao get dao {
    if (_database == null || _database?.isOpen == false) {
      throw StateError('Database is not initialized.');
    }

    return SqfLiteDbDaoImpl(_database!);
  }

  @override
  FutureOr<void> initialize() async {
    final version = _connectionData.version;
    final dbFilePath = path.join(
      _connectionData.hostDirectoryPath,
      _connectionData.name,
    );
    _database = await _databaseFactory.openDatabase(
      dbFilePath,
      options: OpenDatabaseOptions(
        version: _connectionData.version,
        onConfigure: (db) => _executeSingleVersionedScripts(
          db,
          version,
          _initializerScripts.configurationScripts,
        ),
        onCreate: (db, version) => _executeSingleVersionedScripts(
          db,
          version,
          _initializerScripts.creationScripts,
        ),
        onUpgrade: (db, oldVersion, newVersion) => _executeDualVersionedScripts(
          db,
          oldVersion,
          newVersion,
          _initializerScripts.upgradeScripts,
        ),
        // We will clear the entire database on downgrade.
        // Luckily, sqflite does that by default, if we don't specify the
        // onDowngrade callback (i.e., null).
        // ignore: avoid_redundant_argument_values
        onDowngrade: (db, oldVersion, newVersion) => null,
        onOpen: (db) => _executeSingleVersionedScripts(
          db,
          version,
          _initializerScripts.openScripts,
        ),
      ),
    );
  }

  @override
  FutureOr<void> dispose() {
    return _database?.close();
  }

  Future<void> _executeSingleVersionedScripts(
    Database database,
    int version,
    List<SingleVersionedDbScript> scripts,
  ) async {
    final sortedList = scripts
        .where((e) => e.targetVersion == version)
        .toList();
    for (final script in sortedList) {
      await database.execute(script.scriptText);
    }
  }

  Future<void> _executeDualVersionedScripts(
    Database database,
    int previousVersion,
    int presentVersion,
    List<DbMigrationScript> scripts,
  ) async {
    final sortedList = scripts
        .where(
          (e) =>
              e.presentVersion == presentVersion &&
              e.previousVersion == previousVersion,
        )
        .toList();
    for (final script in sortedList) {
      await database.execute(script.scriptText);
    }
  }
}
