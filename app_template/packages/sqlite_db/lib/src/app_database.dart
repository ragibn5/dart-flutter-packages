import 'dart:async';
import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_db/src/enums/data_conflict_algorithm.dart';
import 'package:sqlite_db/src/models/db_connection_data.dart';
import 'package:sqlite_db/src/models/db_initialization_scripts.dart';
import 'package:sqlite_db/src/models/db_script.dart';
import 'package:sqlite_db/src/sqlite_db.dart';

class AppDatabase implements SQLiteDb {
  final DbConnectionData _connectionData;
  final DbInitializerScripts _initializerScripts;

  final DatabaseFactory _databaseFactory;

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

  Database get _db {
    if (_database == null || _database?.isOpen == false) {
      throw StateError('Database is not initialized.');
    }
    return _database!;
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

  @override
  Future<List<Map<String, Object?>>> get(
    String tableName,
    String idColumnName,
    List<String> ids, {
    bool? distinct,
    String? groupBy,
    String? having,
    String? orderBy,
  }) async {
    if (ids.isEmpty) {
      return [];
    }

    final results = await _withChunks(500, ids, (chunk) {
      return _db.query(
        tableName,
        where:
            // ignore: lines_longer_than_80_chars
            '${_escape(idColumnName)} IN (${List.filled(chunk.length, '?').join(', ')})',
        whereArgs: chunk,
        distinct: distinct,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
      );
    });

    return results.expand((e) => e).toList();
  }

  @override
  Future<int> insert(
    String tableName,
    List<Map<String, Object?>> items, {
    DataConflictAlgorithm conflictAlgorithm = DataConflictAlgorithm.REPLACE,
  }) async {
    if (items.isEmpty) {
      return 0;
    }

    return _db.transaction((tnx) async {
      final batch = tnx.batch();
      for (final item in items) {
        batch.insert(
          tableName,
          item,
          conflictAlgorithm: _mapConflictAlgorithm(conflictAlgorithm),
        );
      }
      await batch.commit(noResult: true);
      return items.length;
    });
  }

  @override
  Future<int> delete(
    String tableName,
    String idColumnName,
    List<String> ids,
  ) async {
    if (ids.isEmpty) {
      return 0;
    }

    return _db.transaction((tnx) async {
      final batch = tnx.batch();
      for (final chunk in _chunkList(ids, 500)) {
        batch.delete(
          tableName,
          where:
              // ignore: lines_longer_than_80_chars
              '${_escape(idColumnName)} IN (${List.filled(chunk.length, '?').join(', ')})',
          whereArgs: chunk,
        );
      }
      final results = await batch.commit(noResult: false);
      return results.fold<int>(0, (sum, r) => sum + (r is int ? r : 0));
    });
  }

  @override
  Future<int> deleteAll(String tableName) async {
    return _db.delete(tableName);
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    return _db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String query, [
    List<Object?>? arguments,
  ]) {
    return _db.rawQuery(query, arguments);
  }

  @override
  Future<void> execute(String query, [List<Object?>? arguments]) {
    return _db.execute(query, arguments);
  }

  @override
  Future<T> executeTransaction<T>(T Function(SQLiteDb db) scope) {
    return _db.transaction((tnx) async {
      return scope(this);
    });
  }

  Future<void> _executeSingleVersionedScripts(
    Database database,
    int version,
    List<SingleVersionedDbScript> scripts,
  ) async {
    final sortedList =
        scripts.where((e) => e.targetVersion == version).toList();
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

  Future<List<O>> _withChunks<I, O>(
    int size,
    List<I> allItems,
    Future<O> Function(List<I> chunk) runnable,
  ) async {
    final chunks = _chunkList(allItems, size);

    final results = <O>[];
    for (final chunk in chunks) {
      results.add(await runnable(chunk));
    }

    return results;
  }

  String _escape(String identifier) {
    return '"${identifier.replaceAll('"', '""')}"';
  }

  Iterable<List<T>> _chunkList<T>(List<T> list, int size) {
    return [
      for (var i = 0; i < list.length; i += size)
        list.sublist(i, math.min(i + size, list.length)),
    ];
  }

  ConflictAlgorithm? _mapConflictAlgorithm(
    DataConflictAlgorithm conflictAlgorithm,
  ) {
    return switch (conflictAlgorithm) {
      DataConflictAlgorithm.ROLLBACK => ConflictAlgorithm.rollback,
      DataConflictAlgorithm.ABORT => ConflictAlgorithm.abort,
      DataConflictAlgorithm.FAIL => ConflictAlgorithm.fail,
      DataConflictAlgorithm.IGNORE => ConflictAlgorithm.ignore,
      DataConflictAlgorithm.REPLACE => ConflictAlgorithm.replace,
    };
  }
}
