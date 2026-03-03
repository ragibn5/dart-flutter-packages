import 'package:analysis_server_core/src/models/mappable.dart';

class RuleMetadata implements Mappable {
  final String name;
  final String description;

  RuleMetadata(this.name, this.description);

  @override
  Map<String, dynamic> toMap() => {'name': name, 'description': description};
}
