// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';
import 'dart:ui';

import 'package:app_template/features/app/application/use_cases/get_effective_locale_use_case.dart';
import 'package:app_template/features/app/domain/models/locale_components.dart';
import 'package:app_template/features/app/infrastructure/models/build_metadata.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/metadata_adder_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/fake_http_client_adapter.dart';

class _MockGetEffectiveLocaleUseCase extends Mock
    implements GetEffectiveLocaleUseCase {}

void main() {
  const effectiveLocale = LocaleComponents(languageCode: 'en');

  late _MockGetEffectiveLocaleUseCase getEffectiveLocaleUseCase;
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
    getEffectiveLocaleUseCase = _MockGetEffectiveLocaleUseCase();
    interceptor = MetadataAdderInterceptor(
      buildMetadata,
      getEffectiveLocaleUseCase,
    );

    when(
      () => getEffectiveLocaleUseCase(),
    ).thenAnswer((_) async => effectiveLocale);
  });

  test('requestShouldBeSentWithTheMetadataHeadersIfTheLocaleIsRead', () async {
    final adapter = FakeHttpClientAdapter(
      (_) => ResponseBody.fromString('', 200),
    );

    await fakeDio(adapter, interceptors: [interceptor]).get<dynamic>(
      '/ping',
      options: Options(
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      ),
    );

    final headers = adapter.requests.single.headers;

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
  });

  test('requestShouldFailWithTheCauseIfTheLocaleCannotBeRead', () async {
    final cause = Exception('unreadable');
    when(() => getEffectiveLocaleUseCase()).thenThrow(cause);
    final adapter = FakeHttpClientAdapter(
      (_) => ResponseBody.fromString('', 200),
    );

    await expectLater(
      fakeDio(adapter, interceptors: [interceptor]).get<dynamic>('/ping'),
      throwsA(isA<DioException>().having((e) => e.error, 'error', cause)),
    );
    expect(adapter.requests, isEmpty);
  });
}
