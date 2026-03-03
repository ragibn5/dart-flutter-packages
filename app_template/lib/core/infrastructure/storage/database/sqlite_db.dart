import 'package:app_template/core/contracts/disposable.dart';
import 'package:app_template/core/contracts/initializable.dart';
import 'package:app_template/core/infrastructure/storage/database/sqlite_db_dao.dart';

/// The base class for SQLite databases.
abstract class SQLiteDb implements Initializable, Disposable {
  SQLiteDbDao get dao;
}
