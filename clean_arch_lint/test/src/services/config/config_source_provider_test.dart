import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_lint/src/services/config/config_source_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockPackageInfo extends Mock implements PackageInfo {}

void main() {
  const packageRootPath = 'a/b/c';

  late _MockPackageInfo mockPackageInfo;

  late ConfigSourceProvider sut;

  setUp(() {
    mockPackageInfo = _MockPackageInfo();

    sut = ConfigSourceProviderImpl();

    when(() => mockPackageInfo.location).thenReturn(packageRootPath);
  });

  test('Should return config source file with valid path', () {
    const configFileName = 'pubspec.yaml';
    final configSource = sut.getConfigSource(mockPackageInfo, configFileName);

    expect(configSource.path, path.join(packageRootPath, configFileName));
  });
}
