import 'package:app_template/features/user_data/data/models/user_data_dto.dart';
import 'package:app_template/features/user_data/domain/models/user_data.dart';
import 'package:data_domain_converters/data_domain_converters.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: DataDomainConverter<UserDataDTO, UserData>)
class UserDataMapper implements DataDomainConverter<UserDataDTO, UserData> {
  @override
  UserData convertDataToDomain(UserDataDTO dataModel) {
    return UserData(id: dataModel.id, name: dataModel.name);
  }

  @override
  UserDataDTO convertDomainToData(UserData domainModel) {
    return UserDataDTO(id: domainModel.id, name: domainModel.name);
  }
}
