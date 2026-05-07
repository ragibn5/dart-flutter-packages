import 'package:app_template/features/app/infrastructure/models/startup_config.dart';
import 'package:app_template/main_common.dart';

void main() {
  runFlavoredApp(startupConfig: StartupConfig.stage());
}
