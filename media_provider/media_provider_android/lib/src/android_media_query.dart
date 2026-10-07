import 'package:equatable/equatable.dart';
import 'package:media_provider_android/media_provider_android.dart';
import 'package:meta/meta.dart';

@immutable
class AndroidMediaQuery extends Equatable {
  /// The media types to include in the query result.
  ///
  /// If null or empty, empty results will be returned.
  final Set<AndroidMediaType>? types;

  /// The storage volumes to search.
  ///
  /// If null or empty, no volume based filtration is done and the result
  /// may include media from all the available storage volumes on the device.
  final Set<AndroidStorageVolume>? volumes;

  const AndroidMediaQuery({required this.types, required this.volumes});

  @override
  List<Object?> get props => [types, volumes];

  AndroidMediaQuery copyWith({
    Set<AndroidMediaType>? types,
    Set<AndroidStorageVolume>? volumes,
  }) {
    return AndroidMediaQuery(
      types: types ?? this.types,
      volumes: volumes ?? this.volumes,
    );
  }
}
