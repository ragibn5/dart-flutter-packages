import 'package:app_template/shared/storage/database/enums/data_conflict_algorithm.dart';

abstract interface class SQLiteDbDao {
  /// Get entities with the given IDs.
  ///
  /// **Params:**
  /// - [tableName]: The name of the table to query.
  /// - [idColumnName]: The name of the column that contains the IDs.
  /// - [ids]: The IDs of the entities to get.
  /// - [distinct]: Whether to use distinct or not.
  /// - [groupBy]: The group by clause.
  /// - [having]: The having clause.
  /// - [orderBy]: The order by clause.
  /// - [limit]: The limit clause.
  /// - [offset]: The offset clause.
  ///
  /// **Returns:**
  /// - If [ids] is null, returns all entities.
  /// - If [ids] is an empty list, returns an empty list.
  /// - Or, returns a list of entities with the given IDs.
  ///
  /// **Warning:**
  /// If [ids] is null, or it is a very long list, this method
  /// may return a very large number of rows, which can cause memory overflow,
  /// which can eventually cause the app to crash.
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
  });

  /// Inserts or updates entities and returns the number of inserted entities.
  ///
  /// **Params:**
  /// - [tableName]: The name of the table to insert or update.
  /// - [entities]: The entities to insert or update.
  /// - [chunkSize]: The number of entities to insert or update in each chunk.
  /// - [conflictAlgorithm]: The conflict algorithm to use.
  ///
  /// **Note:**
  /// If an item with the same ID already exists, the behavior depends
  /// on [conflictAlgorithm], which defaults to [DataConflictAlgorithm.REPLACE].
  Future<int> insert(
    String tableName,
    List<Map<String, Object?>> entities, {
    int chunkSize = 16,
    DataConflictAlgorithm conflictAlgorithm = DataConflictAlgorithm.REPLACE,
  });

  /// Deletes entities by their IDs and returns the number of deleted entities.
  ///
  /// **Params:**
  /// - [tableName]: The name of the table to delete.
  /// - [idColumnName]: The name of the column that contains the IDs.
  /// - [ids]: The IDs of the entities to delete.
  ///
  /// **Note:**
  /// Passing an empty list of [ids] will not delete any rows.
  Future<int> delete(
    String tableName,
    String idColumnName,
    List<String> ids, {
    int chunkSize = 16,
  });

  /// Deletes all entities from the collection, and returns the number
  /// of deleted entities.
  ///
  /// **Params:**
  /// - [tableName]: The name of the table to delete.
  ///
  /// **Warning:**
  /// Make sure to use this method with caution.
  Future<int> deleteAll(String tableName);

  /// Executes a query and returns a list of entities returned from underlying
  /// database.
  ///
  /// **Params:**
  /// - [table]: The name of the table to query.
  /// - [distinct]: Whether to use distinct or not.
  /// - [columns]: The columns to select.
  /// - [where]: The where clause.
  /// - [whereArgs]: The arguments to pass to the where clause, which will be
  ///   placed in place of the ? in the where clause, in order they are given.
  /// - [groupBy]: The group by clause.
  /// - [having]: The having clause.
  /// - [orderBy]: The order by clause.
  /// - [limit]: The limit clause.
  /// - [offset]: The offset clause.
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
  });

  /// Executes a raw query and returns a list of entities returned
  /// from underlying database.
  ///
  /// **Params:**
  /// - [query]: The query to execute. Use ? as argument placeholder.
  /// - [arguments]: The arguments to pass to the query, which will be
  ///   placed in place of the ? in the query, in order they are given.
  ///
  /// **Returns:**
  /// - A list of data returned by the database containing zero or more
  ///   entities, if the query is supposed to return data.
  /// - An empty list, if the query is not supposed to return any data.
  ///   In those cases, consider using specialized methods from this interface,
  ///   as they contain natural return values for each operation.
  ///
  /// **Notes:**
  /// - Most platforms has limits on what or how much you can do in a single
  ///   query or transaction, for example, max number of arguments in a SQLite
  ///   query is 1000 (recent versions, less on older ones). This fact apples
  ///   to almost all type of operations. If you feel that your query does a
  ///   lot of things, consider splitting it into multiple queries before
  ///   sending here. See [Limits In SQLite](https://sqlite.org/limits.html)
  ///   for more info (but not limited to SQL/SQLite).
  /// - As within a DAO, This method should only be used to execute DML queries.
  ///   Executing DDL queries may damage the underlying database and/or its data.
  ///   So, use this method with caution.
  ///   See [Types of SQL Statements](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/Types-of-SQL-Statements.html)
  ///   for more info (but not limited to SQL/SQLite).
  Future<List<Map<String, Object?>>> rawQuery(
    String query, [
    List<Object?>? arguments,
  ]);

  /// Execute a raw query with no return value.
  ///
  /// **Params:**
  /// - [query]: The query to execute.
  /// - [arguments]: The arguments to pass to the query.
  Future<void> execute(String query, [List<Object?>? arguments]);

  /// Execute a transaction and return the result of the scope.
  ///
  /// **Params:**
  /// - [scope]: The scope of the transaction.
  Future<T> executeTransaction<T>(T Function(SQLiteDbDao dao) scope);
}
