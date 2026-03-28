import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockContextConfigLoader extends Mock implements ContextConfigLoader {}

void main() {
  late _MockContextConfigLoader mockConfigLoader;

  setUp(() {
    mockConfigLoader = _MockContextConfigLoader();
  });

  test('creates SessionDataManager instance', () {
    final manager = SessionDataManagerFactory.createNewInstance(
      mockConfigLoader,
    );

    expect(manager, isA<SessionDataManager>());
  });
}
