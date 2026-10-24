import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/exceptions/media_query_exception.dart';
import 'package:media_provider_android/src/exceptions/media_read_exception.dart';
import 'package:media_provider_android/src/io/media_read_session.dart';
import 'package:media_provider_android/src/io/method_channel_media_read_session.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:media_provider_android/src/models/open_media_read_request.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
import 'package:media_provider_android/src/models/volume_info.dart';
import 'package:media_provider_android/src/utils/platform_exception_mapper.dart';
import 'package:media_provider_android/src/utils/timing.dart';

// ignore: lines_longer_than_80_chars
/// An implementation of [MediaProviderAndroidPlatform] that uses method channels.
class MethodChannelMediaProviderAndroid extends MediaProviderAndroidPlatform {
  static const CHANNEL_NAME = 'media_provider_android';
  static const READ_CHANNEL_NAME = 'media_provider_android/read';

  /// Experimental: whether sessions read over [readChannel], which the
  /// platform serves on a background task queue, instead of [methodChannel].
  static bool useBackgroundReadChannel = true;

  @visibleForTesting
  final methodChannel = const MethodChannel(CHANNEL_NAME);

  @visibleForTesting
  final readChannel = const MethodChannel(READ_CHANNEL_NAME);

  final MediaQueryExceptionMapper _queryMediaExceptionMapper;
  final MediaReadExceptionMapper _openReadSessionExceptionMapper;

  MethodChannelMediaProviderAndroid({
    @visibleForTesting
    MediaQueryExceptionMapper queryMediaExceptionMapper =
        const MediaQueryExceptionMapper(),
    @visibleForTesting
    MediaReadExceptionMapper openReadSessionExceptionMapper =
        const MediaReadExceptionMapper(),
  }) : _queryMediaExceptionMapper = queryMediaExceptionMapper,
       _openReadSessionExceptionMapper = openReadSessionExceptionMapper;

  @override
  Future<List<VolumeInfo>> getVolumes() async {
    final result = await methodChannel.invokeMethod<String>('getVolumes');
    final items = jsonDecode(result!) as List<dynamic>;
    return items
        .map((item) => VolumeInfo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MediaItem>> getMedia(QuerySpec query) async {
    logMark('[queryMedia] dart sent');
    final result = await timed(
      '[queryMedia] dart invokeMethod round trip',
      () => guardPlatformCall(
        () => methodChannel.invokeMethod<String>(
          'queryMedia',
          jsonEncode(query.toJson()),
        ),
        _queryMediaExceptionMapper.map,
      ),
    );
    logMark('[queryMedia] dart reply received (${result!.length} chars)');
    // Decoding a large library takes tens of milliseconds, so it runs on a
    // background isolate to keep the UI isolate free.
    return timed(
      '[queryMedia] dart decode on background isolate (await)',
      () => _decodeInBackground(result),
    );
  }

  // Static, so the closure sent to the isolate captures only [json].
  static Future<List<MediaItem>> _decodeInBackground(String json) =>
      Isolate.run(() => _decodeMediaItems(json));

  static List<MediaItem> _decodeMediaItems(String json) {
    final items = timedSync(
      '[queryMedia] dart jsonDecode (background isolate)',
      () => jsonDecode(json) as List<dynamic>,
    );
    return timedSync(
      '[queryMedia] dart MediaItem.fromJson x${items.length} '
      '(background isolate)',
      () => items
          .map((item) => MediaItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<MediaReadSession> openReadSession(OpenMediaReadRequest request) async {
    final result = await guardPlatformCall(
      () => methodChannel.invokeMethod<String>(
        'openMediaReadSession',
        jsonEncode(request.toJson()),
      ),
      _openReadSessionExceptionMapper.map,
    );
    final reply = jsonDecode(result!) as Map<String, dynamic>;
    return MethodChannelMediaReadSession(
      channel: methodChannel,
      readChannel: useBackgroundReadChannel ? readChannel : methodChannel,
      sessionId: reply['sessionId'] as String,
      contentUri: reply['contentUri'] as String,
      sizeInBytes: reply['sizeInBytes'] as int?,
      isSeekable: reply['isSeekable'] as bool,
      directPath: reply['directPath'] as String?,
      descriptorFd: reply['descriptorFd'] as int?,
    );
  }
}
