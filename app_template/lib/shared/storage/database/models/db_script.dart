import 'package:equatable/equatable.dart';

/// A database script containing a query and a sequence id.
sealed class DbScript extends Equatable {
  /// The query to execute.
  final String scriptText;

  const DbScript({required this.scriptText});
}

/// A database script targeted for a specific version.
class SingleVersionedDbScript extends DbScript {
  final int targetVersion;

  const SingleVersionedDbScript({
    required super.scriptText,
    required this.targetVersion,
  });

  @override
  List<Object?> get props => [scriptText, targetVersion];
}

/// A database script targeted for two specific versions.
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
