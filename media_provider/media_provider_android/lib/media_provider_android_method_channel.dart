import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/exceptions/media_query_exception.dart';
import 'package:media_provider_android/src/io/session/media_read_session.dart';
import 'package:media_provider_android/src/io/source/media_byte_source_factory.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:media_provider_android/src/models/open_media_read_request.dart';
import 'package:media_provider_android/src/models/open_thumbnail_read_request.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
import 'package:media_provider_android/src/models/volume_info.dart';
import 'package:media_provider_android/src/utils/json_decoding.dart';
import 'package:media_provider_android/src/utils/platform_exception_mapper.dart';

// ignore: lines_longer_than_80_chars
/// An implementation of [MediaProviderAndroidPlatform] that uses method channels.
class MethodChannelMediaProviderAndroid extends MediaProviderAndroidPlatform {
  static const CHANNEL_NAME = 'media_provider_android';
  static const READ_CHANNEL_NAME = 'media_provider_android/read';

  /// Main channel.
  @visibleForTesting
  final methodChannel = const MethodChannel(CHANNEL_NAME);

  final MediaQueryExceptionMapper _queryMediaExceptionMapper;

  /// Opens the sources that read sessions read from.
  final MediaByteSourceFactory _sourceFactory;

  MethodChannelMediaProviderAndroid({
    @visibleForTesting
    MediaQueryExceptionMapper queryMediaExceptionMapper =
        const MediaQueryExceptionMapper(),
    @visibleForTesting
    MediaByteSourceFactory sourceFactory = const DefaultMediaByteSourceFactory(
      channel: MethodChannel(CHANNEL_NAME),
      readChannel: MethodChannel(READ_CHANNEL_NAME),
    ),
  }) : _queryMediaExceptionMapper = queryMediaExceptionMapper,
       _sourceFactory = sourceFactory;

  @override
  Future<List<VolumeInfo>> getVolumes() async {
    final result = await methodChannel.invokeMethod<String>('getVolumes');
    return decodeJsonList(result!, VolumeInfo.fromJson);
  }

  @override
  Future<List<MediaItem>> getMedia(QuerySpec query) async {
    final result = await guardPlatformCall(
      () => methodChannel.invokeMethod<String>(
        'queryMedia',
        jsonEncode(query.toJson()),
      ),
      _queryMediaExceptionMapper.map,
    );

    return decodeJsonListInBackground(result!, MediaItem.fromJson);
  }

  @override
  Future<MediaReadSession> openReadSession(OpenMediaReadRequest request) async {
    final source = await _sourceFactory.open(request);
    return MediaReadSession(source: source);
  }

  @override
  Future<MediaReadSession> openThumbnailReadSession(
    OpenThumbnailReadRequest request,
  ) async {
    final source = await _sourceFactory.openThumbnail(request);
    return MediaReadSession(source: source);
  }
}
