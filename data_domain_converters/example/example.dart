import 'package:data_domain_converters/data_domain_converters.dart';

class UserDto {
  final String fullName;

  UserDto(this.fullName);
}

class User {
  final String name;

  User(this.name);
}

class UserConverter implements DataDomainConverter<UserDto, User> {
  @override
  User convertDataToDomain(UserDto dto) => User(dto.fullName);

  @override
  UserDto convertDomainToData(User domain) => UserDto(domain.name);
}

void main() {
  final converter = UserConverter();
  final user = converter.convertDataToDomain(UserDto('Alice'));
  print('Hello, ${user.name}!');
}
