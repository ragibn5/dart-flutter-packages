import 'package:app_template/features/user_data/data/models/user_data_dto.dart';
import 'package:app_template/features/user_data/data/sources/user_data_data_source.dart';
import 'package:app_template/features/user_data/infrastructure/database/constants/user_data_table_constants.dart';
import 'package:sqlite_db/sqlite_db.dart';

class UserDataDataSourceImpl implements UserDataDataSource {
  final SQLiteDb _sqliteDb;

  UserDataDataSourceImpl(this._sqliteDb);

  @override
  Future<UserDataDTO?> getUserData(String userId) async {
    final result = await _sqliteDb.get(
      UserDataTableConstants.NAME,
      UserDataTableConstants.COLUMN_ID,
      [userId],
    );
    return result.isEmpty ? null : UserDataDTO.fromJson(result.first);
  }

  @override
  Future<void> setUserData(UserDataDTO entity) {
    return _sqliteDb.insert(UserDataTableConstants.NAME, [entity.toJson()]);
  }

  @override
  Future<void> removeUserData(String userId) {
    return _sqliteDb.delete(
      UserDataTableConstants.NAME,
      UserDataTableConstants.COLUMN_ID,
      [userId],
    );
  }
}
