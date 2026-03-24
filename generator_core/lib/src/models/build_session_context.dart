import 'package:generator_core/generator_core.dart';

class BuildSessionContext<T extends ContextConfig> {
  final T config;
  final SessionLogger logger;

  const BuildSessionContext({required this.config, required this.logger});
}
