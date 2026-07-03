// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';
import 'dart:ui';

import 'package:app_template/features/app/infrastructure/models/build_metadata.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/metadata_adder_interceptor.dart';
import 'package:app_template/features/settings/application/services/settings_service.dart';
import 'package:app_template/features/app/domain/entities/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/net_kit.dart';

class _MockSettingsService extends Mock implements SettingsService {}

void main() {
  const effectiveLocale = AppLocale.EN;

  late _MockSettingsService settingsService;
  late MetadataAdderInterceptor interceptor;

  final buildMetadata = BuildMetadata(
    scope: 'flutter',
    platform: Platform.operatingSystem,
    platformVersion: Platform.operatingSystemVersion,
    runtime: 'dart',
    runtimeVersion: Platform.version,
    packageName: 'com.mycoolapp.whatever',
    flavor: 'dev',
    versionName: '1.0.0',
    versionCode: '1',
  );

  Map<String, String> expectedMetadataHeaders(BuildMetadata metadata) {
    return {
      MetadataHeaderKeys.APP_SCOPE: metadata.scope,
      MetadataHeaderKeys.APP_PLATFORM: metadata.platform,
      MetadataHeaderKeys.APP_PLATFORM_VERSION: metadata.platformVersion,
      MetadataHeaderKeys.APP_RUNTIME: metadata.runtime,
      MetadataHeaderKeys.APP_RUNTIME_VERSION: metadata.runtimeVersion,
      MetadataHeaderKeys.APP_PACKAGE: metadata.packageName,
      MetadataHeaderKeys.APP_FLAVOR: metadata.flavor,
      MetadataHeaderKeys.APP_VERSION_NAME: metadata.versionName,
      MetadataHeaderKeys.APP_VERSION_CODE: metadata.versionCode,
    };
  }

  setUp(() {
    settingsService = _MockSettingsService();
    interceptor = MetadataAdderInterceptor(buildMetadata, settingsService);

    when(
      () => settingsService.getEffectiveLocale(),
    ).thenAnswer((_) async => effectiveLocale);
  });

  test(
    'attaches locale, user-agent, app metadata headers, and then proceeds',
    () async {
      final request = RequestSpec(
        pathOrUrl: '/ping',
        baseUrl: 'https://abc.com',
        method: HttpMethod.GET,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );

      final result = await interceptor.onRequest(request);

      expect(result, isA<ContinueWithRequest>());
      final modifiedRequest = (result as ContinueWithRequest).request;
      final headers = modifiedRequest.headers;

      // Locale
      expect(
        headers[HttpHeaders.acceptLanguageHeader],
        Locale.fromSubtags(
          languageCode: effectiveLocale.languageCode,
          scriptCode: effectiveLocale.scriptCode,
          countryCode: effectiveLocale.countryCode,
        ).toLanguageTag(),
      );

      // User agent
      expect(
        headers[HttpHeaders.userAgentHeader],
        '${buildMetadata.packageName}/${buildMetadata.versionName}'
        ' (${buildMetadata.platform}; ${buildMetadata.runtime}; ${buildMetadata.flavor})',
      );

      // App metadata
      final expectedHeaders = expectedMetadataHeaders(buildMetadata);
      for (final entry in expectedHeaders.entries) {
        expect(
          headers,
          containsPair(entry.key, entry.value),
          reason: 'Missing or incorrect metadata header: ${entry.key}',
        );
      }

      // Original headers should still be there
      expect(headers[HttpHeaders.contentTypeHeader], 'application/json');
    },
  );
}
