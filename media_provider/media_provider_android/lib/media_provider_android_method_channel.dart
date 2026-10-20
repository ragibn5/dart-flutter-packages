import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/exceptions/media_query_exception.dart';
import 'package:media_provider_android/src/exceptions/media_read_exception.dart';
import 'package:media_provider_android/src/io/media_read_session.dart';
import 'package:media_provider_android/src/io/method_channel_media_read_session.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:media_provider_android/src/models/media_read_request.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
import 'package:media_provider_android/src/models/volume_info.dart';
import 'package:media_provider_android/src/utils/platform_exception_mapper.dart';

// ignore: lines_longer_than_80_chars
/// An implementation of [MediaProviderAndroidPlatform] that uses method channels.
class MethodChannelMediaProviderAndroid extends MediaProviderAndroidPlatform {
  static const CHANNEL_NAME = 'media_provider_android';

  @visibleForTesting
  final methodChannel = const MethodChannel(CHANNEL_NAME);

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
    final result = await guardPlatformCall(
      () => methodChannel.invokeMethod<String>('queryMedia', {
        'query': jsonEncode(query.toJson()),
      }),
      _queryMediaExceptionMapper.map,
    );
    final items = jsonDecode(result!) as List<dynamic>;
    return items
        .map((item) => MediaItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MediaReadSession> openReadSession(MediaReadRequest request) async {
    final result = await guardPlatformCall(
      () => methodChannel.invokeMethod<String>('openReadSession', {
        'request': jsonEncode(request.toJson()),
      }),
      _openReadSessionExceptionMapper.map,
    );
    final reply = jsonDecode(result!) as Map<String, dynamic>;
    return MethodChannelMediaReadSession(
      channel: methodChannel,
      id: reply['sessionId'] as String,
      size: reply['size'] as int?,
    );
  }
}
