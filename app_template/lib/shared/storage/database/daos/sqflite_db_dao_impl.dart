// ignore_for_file: lines_longer_than_80_chars

import 'dart:math' as math;

import 'package:app_template/core/infrastructure/storage/database/sqlite_db_dao.dart';
import 'package:app_template/shared/storage/database/enums/data_conflict_algorithm.dart';
import 'package:sqflite/sqflite.dart';

class SqfLiteDbDaoImpl implements SQLiteDbDao {
  final Database _database;

  SqfLiteDbDaoImpl(this._database);

  @override
  Future<List<Map<String, Object?>>> get(
    String tableName,
    String idColumnName,
    List<String>? ids, {
    bool? distinct,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return _database.query(
      tableName,
      where: ids != null
          ? '${_escape(idColumnName)} IN (${List.filled(ids.length, '?').join(', ')})'
          : null,
      whereArgs: ids,
      distinct: distinct,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> insert(
    String tableName,
    List<Map<String, Object?>> items, {
    int chunkSize = 16,
    DataConflictAlgorithm conflictAlgorithm = DataConflictAlgorithm.REPLACE,
  }) async {
    if (items.isEmpty) {
      return 0;
    }

    return _database.transaction((tnx) async {
      final insertCounts = await _withChunks(chunkSize, items, (chunk) async {
        var insertedCount = 0;
        for (final item in chunk) {
          final lastId = await tnx.insert(
            tableName,
            item,
            conflictAlgorithm: _mapConflictAlgorithm(conflictAlgorithm),
          );
          insertedCount += lastId <= 0 ? 0 : 1;
        }

        return insertedCount;
      });

      return insertCounts.reduce((a, b) => a + b);
    });
  }

  @override
  Future<int> delete(
    String tableName,
    String idColumnName,
    List<String> ids, {
    int chunkSize = 16,
  }) async {
    if (ids.isEmpty) {
      return 0;
    }

    final deleteCounts = await _withChunks(100, ids, (chunk) async {
      return _database.delete(
        tableName,
        where:
            '${_escape(idColumnName)} IN (${List.filled(chunk.length, '?').join(', ')})',
        whereArgs: ids,
      );
    });

    return deleteCounts.reduce((a, b) => a + b);
  }

  @override
  Future<int> deleteAll(String tableName) async {
    return _database.delete(tableName);
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
    return _database.query(
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
    return _database.rawQuery(query, arguments);
  }

  @override
  Future<void> execute(String query, [List<Object?>? arguments]) {
    return _database.execute(query, arguments);
  }

  @override
  Future<T> executeTransaction<T>(T Function(SQLiteDbDao dao) scope) {
    return _database.transaction((tnx) async {
      return scope(SqfLiteDbDaoImpl(tnx.database));
    });
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

  /// Simple identifier escaper for tables/columns
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
