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
      QuerySpec(
        types: const {MediaType.photo, MediaType.video},
        volumes: {const VolumeSpec.primary()},
      ),
    );
    expect(media, isA<List<MediaItem>>());
  });

  testWidgets('getVolumes test', (WidgetTester tester) async {
    final MediaProviderAndroid plugin = MediaProviderAndroid();
    // A device always has at least its primary volume, so this one can be
    // asserted on regardless of the library's contents.
    final volumes = await plugin.getVolumes();
    expect(volumes, isA<List<VolumeInfo>>());
    expect(
      volumes.map((volume) => volume.state),
      isNot(contains(VolumeState.unknown)),
    );
    expect(
      volumes
          .where((volume) => volume.identity.isPrimary)
          .map((volume) => volume.identity.type),
      everyElement(VolumeType.primary),
    );
    // A mounted volume has a real filesystem behind it, so it reports a capacity
    // and some free space, neither of which exceeds the other.
    for (final volume
        in volumes.where((volume) => volume.state == VolumeState.mounted)) {
      expect(volume.identity.capacityInBytes, greaterThan(0));
      expect(
        volume.availableSpaceInBytes,
        lessThanOrEqualTo(volume.identity.capacityInBytes),
      );
    }
  });
}
