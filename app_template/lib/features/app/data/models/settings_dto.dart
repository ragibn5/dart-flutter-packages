import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings_dto.g.dart';

@JsonSerializable()
class SettingsDTO extends Equatable {
  final String? locale;
  final String? themeMode;

  const SettingsDTO({this.themeMode, this.locale});

  factory SettingsDTO.fromJson(Map<String, dynamic> json) =>
      _$SettingsDTOFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsDTOToJson(this);

  @override
  List<Object?> get props => [locale, themeMode];
}
