import 'package:equatable/equatable.dart';

sealed class DbScript extends Equatable {
  final String scriptText;

  const DbScript({required this.scriptText});
}

class SingleVersionedDbScript extends DbScript {
  final int targetVersion;

  const SingleVersionedDbScript({
    required super.scriptText,
    required this.targetVersion,
  });

  @override
  List<Object?> get props => [scriptText, targetVersion];
}

class DbMigrationScript extends DbScript {
  final int previousVersion;
  final int presentVersion;

  const DbMigrationScript({
    required super.scriptText,
    required this.previousVersion,
    required this.presentVersion,
  });

  @override
  List<Object?> get props => [scriptText, presentVersion, presentVersion];
}
