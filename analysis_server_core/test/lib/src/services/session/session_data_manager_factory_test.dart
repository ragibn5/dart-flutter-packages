import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockContextConfigLoader extends Mock implements ContextConfigLoader {}

void main() {
  late _MockContextConfigLoader configLoader;

  setUp(() {
    configLoader = _MockContextConfigLoader();
  });

  test('creates SessionDataManager instance', () {
    final manager = SessionDataManagerFactory.createNewInstance(configLoader);

    expect(manager, isA<SessionDataManager>());
  });
}
