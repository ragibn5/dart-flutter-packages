import 'package:equatable/equatable.dart';

class BuildMetadata extends Equatable {
  final String scope;
  final String platform;
  final String platformVersion;
  final String runtime;
  final String runtimeVersion;
  final String packageName;
  final String flavor;
  final String versionName;
  final String versionCode;

  const BuildMetadata({
    required this.scope,
    required this.platform,
    required this.platformVersion,
    required this.runtime,
    required this.runtimeVersion,
    required this.packageName,
    required this.flavor,
    required this.versionName,
    required this.versionCode,
  });

  @override
  List<Object?> get props => [
    scope,
    platform,
    platformVersion,
    runtime,
    runtimeVersion,
    packageName,
    flavor,
    versionName,
    versionCode,
  ];
}
