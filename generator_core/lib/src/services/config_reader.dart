import 'package:build/build.dart';

abstract interface class ConfigReader<ConfigType> {
  Future<ConfigType> readConfig(BuilderOptions options);
}
