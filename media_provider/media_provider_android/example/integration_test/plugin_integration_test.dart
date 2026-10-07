// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:media_provider_android/media_provider_android.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getMedia test', (WidgetTester tester) async {
    final MediaProviderAndroid plugin = MediaProviderAndroid();
    // Contents depend on the device's library and granted permissions, so
    // just assert that the call round-trips.
    final media = await plugin.getMedia(
      AndroidMediaQuery(
        types: {AndroidMediaType.photo, AndroidMediaType.video},
        volumes: null,
      ),
    );
    expect(media, isA<List<AndroidMediaItem>>());
  });
}
