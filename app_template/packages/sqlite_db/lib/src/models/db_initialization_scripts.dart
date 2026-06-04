import 'package:equatable/equatable.dart';
import 'package:sqlite_db/src/models/db_script.dart';

class DbInitializerScripts extends Equatable {
  final List<SingleVersionedDbScript> configurationScripts;
  final List<SingleVersionedDbScript> creationScripts;
  final List<DbMigrationScript> upgradeScripts;
  final List<SingleVersionedDbScript> openScripts;

  const DbInitializerScripts({
    this.configurationScripts = const [],
    this.creationScripts = const [],
    this.upgradeScripts = const [],
    this.openScripts = const [],
  });

  @override
  List<Object?> get props =>
      [configurationScripts, creationScripts, upgradeScripts, openScripts];
}
