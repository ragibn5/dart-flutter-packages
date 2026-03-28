import 'package:analysis_server_core/analysis_server_core.dart';
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
