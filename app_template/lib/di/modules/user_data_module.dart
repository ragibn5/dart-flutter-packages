import 'package:app_template/features/user_data/data/mappers/user_data_mapper.dart';
import 'package:app_template/features/user_data/data/models/user_data_dto.dart';
import 'package:app_template/features/user_data/data/repositories/user_data_repository_impl.dart';
import 'package:app_template/features/user_data/data/sources/user_data_data_source.dart';
import 'package:app_template/features/user_data/data/sources/user_data_data_source_impl.dart';
import 'package:app_template/features/user_data/domain/models/user_data.dart';
import 'package:app_template/features/user_data/domain/repositories/user_data_repository.dart';
import 'package:app_template/features/user_data/domain/services/user_data_service.dart';
import 'package:app_template/features/user_data/domain/services/user_data_service_impl.dart';
import 'package:data_domain_converters/data_domain_converters.dart';
import 'package:injectable/injectable.dart';
import 'package:sqlite_db/sqlite_db.dart';

@module
abstract class UserDataModule {
  DataDomainConverter<UserDataDTO, UserData> getUserDataMapper() {
    return UserDataMapper();
  }

  @singleton
  UserDataDataSource getUserDataDataSource(SQLiteDb sqliteDb) {
    return UserDataDataSourceImpl(sqliteDb);
  }

  @singleton
  UserDataRepository getUserDataRepository(
    DataDomainConverter<UserDataDTO, UserData> userDataMapper,
    UserDataDataSource userDataDataSource,
  ) {
    return UserDataRepositoryImpl(userDataMapper, userDataDataSource);
  }

  @singleton
  UserDataService getUserDataService(UserDataRepository userDataRepository) {
    return UserDataServiceImpl(userDataRepository);
  }
}
