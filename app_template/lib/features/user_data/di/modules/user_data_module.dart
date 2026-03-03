import 'package:app_template/features/user_data/domain/repositories/user_data_repository.dart';
import 'package:app_template/features/user_data/domain/services/user_data_service.dart';
import 'package:app_template/features/user_data/domain/services/user_data_service_impl.dart';
import 'package:injectable/injectable.dart';

@module
abstract class UserDataModule {
  @singleton
  UserDataService getUserDataService(UserDataRepository userDataRepository) {
    return UserDataServiceImpl(userDataRepository);
  }
}
