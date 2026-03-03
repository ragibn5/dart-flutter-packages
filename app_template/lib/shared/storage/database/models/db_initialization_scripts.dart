import 'package:app_template/shared/storage/database/models/db_script.dart';
import 'package:equatable/equatable.dart';

class DbInitializerScripts extends Equatable {
  /// Configuration scripts.
  ///
  /// Suitable for enabling foreign keys, write-ahead logging etc.
  final List<SingleVersionedDbScript> configurationScripts;

  /// Creation scripts.
  ///
  /// Suitable for creating tables, views, triggers, indexes, etc.
  final List<SingleVersionedDbScript> creationScripts;

  /// Upgrade scripts.
  ///
  /// Suitable for schema and data migration.
  final List<DbMigrationScript> upgradeScripts;

  /// Open scripts.
  ///
  /// Suitable for post initialization tasks.
  final List<SingleVersionedDbScript> openScripts;

  const DbInitializerScripts({
    this.configurationScripts = const [],
    this.creationScripts = const [],
    this.upgradeScripts = const [],
    this.openScripts = const [],
  });

  @override
  List<Object?> get props => [
    configurationScripts,
    creationScripts,
    upgradeScripts,
    openScripts,
  ];
}
