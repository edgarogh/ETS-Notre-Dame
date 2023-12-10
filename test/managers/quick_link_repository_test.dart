// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/quick_link_repository.dart';
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/core/models/quick_link_data.dart';
import 'package:notredame/core/services/remote_config_service.dart';
import '../helpers.dart';
import '../mock/managers/cache_manager_mock.dart';
import '../mock/services/remote_config_service_mock.dart';

void main() {
  CacheManager cacheManager;
  QuickLinkRepository quickLinkRepository;

  group("QuickLinkRepository - ", () {
    setUp(() {
      // Setup needed services and managers
      cacheManager = setupCacheManagerMock();

      quickLinkRepository = QuickLinkRepository();
    });

    tearDown(() {
      clearInteractions(cacheManager);
      unregister<CacheManager>();
    });

    group("getQuickLinkDataFromCache - ", () {
      test("QuickLinkData is loaded from cache.", () async {
        // Stub the cache to return some QuickLinkData
        final quickLinkData = QuickLinkData(id: 1, index: 0);
        CacheManagerMock.stubGet(
            cacheManager as CacheManagerMock,
            QuickLinkRepository.quickLinksCacheKey,
            jsonEncode([quickLinkData]));

        final List<QuickLinkData> results =
            await quickLinkRepository.getQuickLinkDataFromCache();

        expect(results, isInstanceOf<List<QuickLinkData>>());
        expect(results[0].id, quickLinkData.id);
        expect(results[0].index, quickLinkData.index);

        verify(cacheManager.get(QuickLinkRepository.quickLinksCacheKey))
            .called(1);
      });

      test(
          "Trying to recover QuickLinkData from cache but an exception is raised.",
          () async {
        // Stub the cache to throw an exception
        CacheManagerMock.stubGetException(cacheManager as CacheManagerMock,
            QuickLinkRepository.quickLinksCacheKey);

        expect(quickLinkRepository.getQuickLinkDataFromCache(),
            throwsA(isInstanceOf<Exception>()));
      });
    });

    group("updateQuickLinkDataToCache - ", () {
      test("Updating QuickLinkData to cache.", () async {
        // Prepare some QuickLinkData to be cached
        final quickLink =
            QuickLink(id: 1, image: const Text(""), name: 'name', link: 'url');
        final quickLinkData = QuickLinkData(id: quickLink.id, index: 0);

        await quickLinkRepository.updateQuickLinkDataToCache([quickLink]);

        verify(cacheManager.update(QuickLinkRepository.quickLinksCacheKey,
            jsonEncode([quickLinkData]))).called(1);
      });

      test(
          "Trying to update QuickLinkData to cache but an exception is raised.",
          () async {
        // Stub the cache to throw an exception
        CacheManagerMock.stubUpdateException(cacheManager as CacheManagerMock,
            QuickLinkRepository.quickLinksCacheKey);

        final quickLink =
            QuickLink(id: 1, image: const Text(""), name: 'name', link: 'url');

        expect(quickLinkRepository.updateQuickLinkDataToCache([quickLink]),
            throwsA(isInstanceOf<Exception>()));
      });
    });

    group("getDefaultQuickLinks", () {
      AppIntl appIntl;
      RemoteConfigServiceMock remoteConfigServiceMock;

      dynamic quicklinkRemoteConfigIconStub = [
        {
          "id": 0,
          "nameEn": "ETS Portal",
          "nameFr": "Portail de l'ÉTS",
          "icon": "home"
        },
      ];

      setUp(() async {
        appIntl = await setupAppIntl();

        remoteConfigServiceMock =
            setupRemoteConfigServiceMock() as RemoteConfigServiceMock;
      });

      tearDown(() {
        clearInteractions(remoteConfigServiceMock);
        unregister<RemoteConfigService>();
      });

      test("Trying to get quicklinks when remote config is inacessible.",
          () async {
        when(remoteConfigServiceMock.quicklinks_values).thenAnswer(null);

        final quickLinks =
            await quickLinkRepository.getDefaultQuickLinks(appIntl);

        verify(remoteConfigServiceMock.quicklinks_values).called(1);
        verify(remoteConfigServiceMock).called(0);
        verify(cacheManager).called(0);
        expect(quickLinks, isInstanceOf<List<QuickLink>>());
        expect(quickLinks.length, 9);
        expect(quickLinks.length, 9);
        for (int i = 0; i < quickLinks.length; i++) {
          expect(quickLinks[i].id, i);
        }
      });

      test(
          "Trying to get quicklinks from remote config with one icon attribute.",
          () async {
        // Stub the remote config to have values for quicklinks
        when(remoteConfigServiceMock.quicklinks_values)
            .thenAnswer((_) async => quicklinkRemoteConfigIconStub);

        final quickLinks =
            await quickLinkRepository.getDefaultQuickLinks(appIntl);

        verify(remoteConfigServiceMock.quicklinks_values).called(1);
        verify(remoteConfigServiceMock).called(0);
        verify(cacheManager).called(0);
        expect(quickLinks, isInstanceOf<List<QuickLink>>());
        expect(quickLinks.length, 9);
        expect(quickLinks.length, 9);
        for (int i = 0; i < quickLinks.length; i++) {
          expect(quickLinks[i].id, i);
        }
      });
    });
  });
}
