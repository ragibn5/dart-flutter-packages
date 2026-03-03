import 'package:app_template/core/infrastructure/storage/database/sqlite_db.dart';
import 'package:app_template/features/user_data/data/models/user_data_dto.dart';
import 'package:app_template/features/user_data/data/sources/user_data_data_source.dart';
import 'package:app_template/features/user_data/infrastructure/database/user_data_table_constants.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: UserDataDataSource)
class UserDataDataSourceImpl implements UserDataDataSource {
  final SQLiteDb _sqliteDb;

  UserDataDataSourceImpl(this._sqliteDb);

  @override
  Future<UserDataDTO?> getUserData(String userId) async {
    final result = await _sqliteDb.dao.get(
      UserDataTableConstants.NAME,
      UserDataTableConstants.COLUMN_ID,
      [userId],
    );
    return result.isEmpty ? null : UserDataDTO.fromJson(result.first);
  }

  @override
  Future<void> setUserData(UserDataDTO entity) {
    return _sqliteDb.dao.insert(UserDataTableConstants.NAME, [entity.toJson()]);
  }

  @override
  Future<void> removeUserData(String userId) {
    return _sqliteDb.dao.delete(
      UserDataTableConstants.NAME,
      UserDataTableConstants.COLUMN_ID,
      [userId],
    );
  }
}
