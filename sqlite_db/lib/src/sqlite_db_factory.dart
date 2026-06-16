import 'package:sqlite_db/src/models/db_connection_data.dart';
import 'package:sqlite_db/src/models/db_initialization_scripts.dart';
import 'package:sqlite_db/src/sqlite_db.dart';
import 'package:sqlite_db/src/sqlite_db_impl.dart';

/// Creates a new [SQLiteDb] instance.
///
/// Usage:
/// ```dart
/// final db = SQLiteDbFactory().create(connectionData, scripts);
/// await db.initialize();
/// ```
///
/// Consumers receive a [SQLiteDb] and never see the concrete implementation.
class SQLiteDbFactory {
  const SQLiteDbFactory();

  SQLiteDb create(
    DbConnectionData connectionData,
    DbInitializerScripts initializerScripts,
  ) {
    return SQLiteDbImpl(connectionData, initializerScripts);
  }
}
