import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/exceptions/media_action_exception.dart';
import 'package:media_provider_android/src/exceptions/media_query_exception.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:media_provider_android/src/models/open_media_with_request.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
import 'package:media_provider_android/src/models/share_media_request.dart';
import 'package:media_provider_android/src/models/volume_info.dart';
import 'package:media_provider_android/src/utils/json_decoder.dart';
import 'package:media_provider_android/src/utils/platform_call_guarder.dart';

// ignore: lines_longer_than_80_chars
/// An implementation of [MediaProviderAndroidPlatform] that uses method channels.
class MethodChannelMediaProviderAndroid extends MediaProviderAndroidPlatform {
  static const CHANNEL_NAME = 'media_provider_android';

  /// Main channel.
  @visibleForTesting
  final methodChannel = const MethodChannel(CHANNEL_NAME);

  final MediaQueryExceptionMapper _queryMediaExceptionMapper;
  final MediaActionExceptionMapper _mediaActionExceptionMapper;

  MethodChannelMediaProviderAndroid({
    @visibleForTesting
    MediaQueryExceptionMapper queryMediaExceptionMapper =
        const MediaQueryExceptionMapper(),
    @visibleForTesting
    MediaActionExceptionMapper mediaActionExceptionMapper =
        const MediaActionExceptionMapper(),
  }) : _queryMediaExceptionMapper = queryMediaExceptionMapper,
       _mediaActionExceptionMapper = mediaActionExceptionMapper;

  @override
  Future<List<VolumeInfo>> getVolumes() async {
    final result = await methodChannel.invokeMethod<String>('getVolumes');
    return decodeJsonList(result!, VolumeInfo.fromJson);
  }

  @override
  Future<List<MediaItem>> getMedia(QuerySpec query) async {
    final result = await guardPlatformCall(
      _queryMediaExceptionMapper,
      () => methodChannel.invokeMethod<String>(
        'queryMedia',
        jsonEncode(query.toJson()),
      ),
    );

    return decodeJsonListInBackground(result!, MediaItem.fromJson);
  }

  @override
  Future<void> shareMedia(ShareMediaRequest request) {
    return guardPlatformCall(
      _mediaActionExceptionMapper,
      () => methodChannel.invokeMethod<void>(
        'shareMedia',
        jsonEncode(request.toJson()),
      ),
    );
  }

  @override
  Future<void> openMediaWith(OpenMediaWithRequest request) {
    return guardPlatformCall(
      _mediaActionExceptionMapper,
      () => methodChannel.invokeMethod<void>(
        'openMediaWith',
        jsonEncode(request.toJson()),
      ),
    );
  }
}
