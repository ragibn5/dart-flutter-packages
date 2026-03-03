import 'package:app_template/features/user_data/infrastructure/database/user_data_table_constants.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_data_dto.g.dart';

@JsonSerializable()
class UserDataDTO extends Equatable {
  @JsonKey(name: UserDataTableConstants.COLUMN_ID)
  final String id;

  @JsonKey(name: UserDataTableConstants.COLUMN_NAME)
  final String name;

  const UserDataDTO({required this.id, required this.name});

  Map<String, dynamic> toJson() => _$UserDataDTOToJson(this);

  factory UserDataDTO.fromJson(Map<String, dynamic> json) =>
      _$UserDataDTOFromJson(json);

  @override
  List<Object?> get props => [id, name];
}
