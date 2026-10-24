import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_provider_android/src/models/volume_identity.dart';

part 'file_location.g.dart';

@JsonSerializable()
class FileLocation extends Equatable {
  final VolumeIdentity volumeIdentity;
  final String relativeParentPath;
  final String fileNameWithExtension;
  final String absoluteFilePath;

  const FileLocation({
    required this.volumeIdentity,
    required this.relativeParentPath,
    required this.fileNameWithExtension,
    required this.absoluteFilePath,
  });

  factory FileLocation.fromJson(Map<String, dynamic> json) =>
      _$FileLocationFromJson(json);

  Map<String, dynamic> toJson() => _$FileLocationToJson(this);

  @override
  List<Object?> get props => [
    volumeIdentity,
    relativeParentPath,
    fileNameWithExtension,
    absoluteFilePath,
  ];
}
