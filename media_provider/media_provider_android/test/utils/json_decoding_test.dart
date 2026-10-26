import 'dart:convert';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/models/open_media_read_reply.dart';
import 'package:media_provider_android/src/models/volume_identity.dart';
import 'package:media_provider_android/src/models/volume_info.dart';
import 'package:media_provider_android/src/models/volume_state.dart';
import 'package:media_provider_android/src/models/volume_type.dart';
import 'package:media_provider_android/src/utils/json_decoder.dart';

void main() {
  const primary = VolumeInfo(
    identity: VolumeIdentity(
      volumePath: '/storage/emulated/0',
      isPrimary: true,
      isRemovable: false,
      isEmulated: true,
      type: VolumeType.primary,
      capacityInBytes: 128000000000,
      uuid: null,
    ),
    state: VolumeState.mounted,
    availableSpaceInBytes: 64000000000,
  );
  const sdCard = VolumeInfo(
    identity: VolumeIdentity(
      volumePath: '/storage/1234-ABCD',
      isPrimary: false,
      isRemovable: true,
      isEmulated: false,
      type: VolumeType.sdCard,
      capacityInBytes: null,
      uuid: '1234-ABCD',
    ),
    state: VolumeState.mounted,
    availableSpaceInBytes: 1000,
  );
  final volumesJson = jsonEncode([primary, sdCard]);

  group('decodeJsonList', () {
    test('decodes every object, in order', () {
      expect(decodeJsonList(volumesJson, VolumeInfo.fromJson), [
        primary,
        sdCard,
      ]);
    });

    test('decodes an empty array', () {
      expect(decodeJsonList('[]', VolumeInfo.fromJson), isEmpty);
    });

    test('throws a FormatException for invalid JSON', () {
      expect(
        () => decodeJsonList('[', VolumeInfo.fromJson),
        throwsFormatException,
      );
    });
  });

  group('decodeJsonListInBackground', () {
    test('decodes like decodeJsonList, with a constructor tear-off', () async {
      expect(
        await decodeJsonListInBackground(volumesJson, VolumeInfo.fromJson),
        decodeJsonList(volumesJson, VolumeInfo.fromJson),
      );
    });

    test('rethrows a FormatException from the new isolate', () {
      expect(
        decodeJsonListInBackground('[', VolumeInfo.fromJson),
        throwsFormatException,
      );
    });

    test('rejects a fromJson that captures something unsendable', () async {
      final port = ReceivePort();
      addTearDown(port.close);

      VolumeInfo fromJson(Map<String, dynamic> json) {
        port.sendPort.send(null);
        return VolumeInfo.fromJson(json);
      }

      await expectLater(
        decodeJsonListInBackground(volumesJson, fromJson),
        throwsArgumentError,
      );
    });

    test(
      'called from a method capturing `this`, it sends nothing else',
      () async {
        final owner = _UnsendableOwner(volumesJson);
        addTearDown(owner.dispose);

        expect(await owner.decodeWithHelper(), [primary, sdCard]);
      },
    );

    test('an inline Isolate.run in the same method sends `this`', () async {
      final owner = _UnsendableOwner(volumesJson);
      addTearDown(owner.dispose);

      await expectLater(owner.decodeInline(), throwsArgumentError);
    });
  });

  group('decodeJsonObject', () {
    test('decodes a descriptor reply, defaulting the offset to 0', () {
      final reply = decodeJsonObject(
        jsonEncode({
          'kind': 'descriptor',
          'fd': 42,
          'sizeInBytes': 2048,
          'isSeekable': true,
        }),
        OpenMediaReadReply.fromJson,
      );

      expect(
        reply,
        const DescriptorReply(
          fd: 42,
          offset: 0,
          sizeInBytes: 2048,
          isSeekable: true,
        ),
      );
    });

    test('decodes a channel reply', () {
      final reply = decodeJsonObject(
        jsonEncode({
          'kind': 'channel',
          'sessionId': 's1',
          'sizeInBytes': null,
          'isSeekable': false,
        }),
        OpenMediaReadReply.fromJson,
      );

      expect(
        reply,
        const ChannelReply(
          sessionId: 's1',
          sizeInBytes: null,
          isSeekable: false,
        ),
      );
    });

    test('throws a FormatException for an unknown or missing kind', () {
      for (final json in [
        {'kind': 'pipe', 'sessionId': 's1', 'isSeekable': false},
        {'sessionId': 's1', 'isSeekable': false},
      ]) {
        expect(
          () => decodeJsonObject(jsonEncode(json), OpenMediaReadReply.fromJson),
          throwsFormatException,
        );
      }
    });
  });
}

/// Calls the decoders from an instance method shaped like `getMedia`: a
/// closure that uses `this`, then a background decode. Holds a [ReceivePort],
/// which can't be sent to another isolate.
class _UnsendableOwner {
  final ReceivePort _port = ReceivePort();

  final String _json;

  _UnsendableOwner(this._json);

  Future<List<VolumeInfo>> decodeWithHelper() async {
    final result = await _call(() async => _json);
    return decodeJsonListInBackground(result, VolumeInfo.fromJson);
  }

  Future<List<VolumeInfo>> decodeInline() async {
    final result = await _call(() async => _json);
    return Isolate.run(() => decodeJsonList(result, VolumeInfo.fromJson));
  }

  void dispose() => _port.close();

  Future<String> _call(Future<String> Function() call) => call();
}
