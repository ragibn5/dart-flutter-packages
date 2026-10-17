// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:user_provider_android/user_provider_android.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getIdentity test', (WidgetTester tester) async {
    final UserProviderAndroid plugin = UserProviderAndroid();

    final identity = await plugin.getIdentity();

    // Which user and app the process runs under depends on the device, but the
    // three values are always consistent with each other.
    expect(identity.userId, greaterThanOrEqualTo(0));
    expect(identity.appId, greaterThanOrEqualTo(0));
    expect(identity.appId, lessThan(100000));
    expect(identity.uid, identity.userId * 100000 + identity.appId);
  });
}
