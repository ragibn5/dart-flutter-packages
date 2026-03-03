import 'package:equatable/equatable.dart';

class DbConnectionData extends Equatable {
  final String hostDirectoryPath;
  final String name;
  final int version;

  const DbConnectionData({
    required this.hostDirectoryPath,
    required this.name,
    required this.version,
  });

  @override
  List<Object?> get props => [hostDirectoryPath, name, version];
}
