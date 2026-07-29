import 'package:analysis_server_plugin_core/src/services/config/context_config_loader.dart';
import 'package:analysis_server_plugin_core/src/services/session/session_data_manager.dart';
import 'package:analysis_server_plugin_core/src/services/session/session_data_manager_factory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockContextConfigLoader extends Mock implements ContextConfigLoader {}

void main() {
  late _MockContextConfigLoader sut;

  setUp(() {
    sut = _MockContextConfigLoader();
  });

  test('creates SessionDataManager instance', () {
    final manager = SessionDataManagerFactory.createNewInstance(sut);

    expect(manager, isA<SessionDataManager>());
  });
}
