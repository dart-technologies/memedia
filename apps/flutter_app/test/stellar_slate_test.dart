import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:memedia/stellar_slate.dart';
import 'package:memedia/stellar_clusters.dart';
import 'package:memedia/main.dart';
import 'package:memedia/channel_player.dart';
import 'package:memedia/explorer_route.dart';

void main() {
  test('top signals gate niche videos and sort known curator reach before views and likes', () {
    final niche = {
      'platform': 'YouTube',
      'views': '1508',
      'creatorSubscribers': '900',
    };
    expect(topSignal(niche), false);
    expect(
      topSignal({
        'platform': 'YouTube',
        'views': '900',
        'creatorSubscribers': '100000',
      }),
      true,
    );
    final rows = <Map>[
      niche,
      {'views': '100000', 'likes': '1'},
      {'views': '100000', 'likes': '5'},
      {'views': '1000', 'creatorSubscribers': '200000'},
    ]..sort(mediaOrder);
    expect(rows.first['creatorSubscribers'], '200000');
    expect(rows[1]['likes'], '5');
    expect(flags(['US', 'GB']), '🇺🇸 🇬🇧');
    expect(
      primaryFlag({
        'primaryRegion': 'GB',
        'regions': ['US', 'GB'],
      }),
      '🇬🇧',
    );
  });

  test(
    'compact metrics preserve unknown and zero and use readable magnitudes',
    () {
      expect(compactCount(null), '—');
      expect(compactCount('0'), '0');
      expect(compactCount('999'), '999');
      expect(compactCount('1508'), '1.51K');
      expect(compactCount('100000'), '100K');
      expect(compactCount('7714520'), '7.71M');
      expect(compactCount('999950'), '1M');
    },
  );
  test(
    'deep links preserve demo mode and clear old selections on discovery',
    () {
      final base = Uri.parse(
        'https://example.org/?demo=1&channel=old&video=old',
      );
      final channel = explorerRoute(
        base,
        channel: 'hands-on',
        video: 'yt-Od6M0AXpcxQ',
      );
      expect(channel.queryParameters, {
        'demo': '1',
        'channel': 'hands-on',
        'video': 'yt-Od6M0AXpcxQ',
      });
      expect(explorerRoute(channel).queryParameters, {'demo': '1'});
      expect(
        explorerRoute(Uri.parse('https://example.org/?channel=old')).hasQuery,
        false,
      );
      expect(explorerRoute(base, topic: 'iphone-duo').queryParameters, {
        'demo': '1',
        'topic': 'iphone-duo',
      });
    },
  );

  test('raw counts keep zero distinct from unavailable', () {
    expect(rawCount(null), '—');
    expect(rawCount('0'), '0');
    expect(rawCount('12345678'), '12,345,678');
  });
  test('recorded history never uses publication as observation', () {
    final a = {
      'publishedAt': '2026-09-09T17:00:00Z',
      'firstObservedAt': '2026-09-10T16:00:00Z',
    };
    final horizon = DateTime.utc(2026, 9, 9, 20);
    expect(knownBy(a, horizon, false), true);
    expect(knownBy(a, horizon, true), false);
    expect(knownBy({'publishedAt': null}, horizon, true), false);
  });
  test('date-only sources do not receive invented intra-day times', () {
    final a = {'publishedAt': '2026-09-09', 'publicationTimePrecision': 'day'};
    expect(knownBy(a, DateTime.utc(2026, 9, 9, 12), false), false);
    expect(knownBy(a, DateTime.utc(2026, 9, 10), false), true);
  });
  testWidgets('channel action and scene update retain surface state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = SurfaceController(catalogs: [stellarCatalog()]);
    final transport = A2uiTransportAdapter();
    final sub = transport.incomingMessages.listen(controller.handleMessage);
    void feed(Map<String, Object?> m) =>
        transport.addChunk('```json\n${jsonEncode(m)}\n```\n');
    final scene = jsonDecode(
      File('assets/explorer.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    scene['selectedTopicId'] = 'iphone-duo';
    scene['selectedChannelId'] = 'competition';
    feed({
      'version': 'v0.9',
      'createSurface': {
        'surfaceId': 'stellar-slate',
        'catalogId': 'dev.memedia.stellar',
      },
    });
    feed({
      'version': 'v0.9',
      'updateComponents': {
        'surfaceId': 'stellar-slate',
        'components': [
          {
            'id': 'root',
            'component': 'StellarSlate',
            'scene': {'path': '/scene'},
          },
        ],
      },
    });
    feed({
      'version': 'v0.9',
      'updateDataModel': {
        'surfaceId': 'stellar-slate',
        'path': '/scene',
        'value': scene,
      },
    });
    await tester.pump();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Surface(surfaceContext: controller.contextFor('stellar-slate')),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final state = tester.state(find.byType(StellarSlate));
    expect(find.text('Samsung responds'), findsWidgets);
    String? action;
    final actions = controller.onSubmit.listen(
      (m) => action = m.parts.uiInteractionParts.single.interaction,
    );
    await tester.ensureVisible(find.byTooltip('Save channel'));
    await tester.tap(find.byTooltip('Save channel'));
    await tester.pump();
    expect(action, contains('"name":"follow_channel"'));
    feed({
      'version': 'v0.9',
      'updateDataModel': {
        'surfaceId': 'stellar-slate',
        'path': '/scene',
        'value': {...scene, 'revision': 2, 'selectedChannelId': 'visual-memes'},
      },
    });
    await tester.pump(const Duration(milliseconds: 400));
    expect(identical(state, tester.state(find.byType(StellarSlate))), true);
    expect(
      find.text('Which visual jokes are actually documented?'),
      findsOneWidget,
    );
    expect(tester.takeException(), null);
    feed({
      'version': 'v0.9',
      'updateDataModel': {
        'surfaceId': 'stellar-slate',
        'path': '/scene',
        'value': {...scene, 'revision': 3, 'selectedChannelId': null},
      },
    });
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(TopicCluster), findsNWidgets(4));
    expect(find.byType(ChannelPreview), findsNWidgets(12));
    expect(find.text('REACTIONS & MEMES'), findsOneWidget);
    feed({
      'version': 'v0.9',
      'updateDataModel': {
        'surfaceId': 'stellar-slate',
        'path': '/scene/clusterGroups/0/label',
        'value': 'Hands-on perspectives',
      },
    });
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('HANDS-ON PERSPECTIVES'), findsOneWidget);
    expect(identical(state, tester.state(find.byType(StellarSlate))), true);
    expect(tester.takeException(), null);
    void demoCue(int sequence, String action) => feed({
      'version': 'v0.9',
      'updateDataModel': {
        'surfaceId': 'stellar-slate',
        'path': '/scene',
        'value': {
          ...scene,
          'selectedChannelId': action == 'freshness' ? 'hands-on' : null,
          'demoCue': {'sequence': sequence, 'action': action},
        },
      },
    });
    demoCue(1, 'relationships');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Reactions & memes'), findsOneWidget);
    demoCue(2, 'freshness');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Curation & freshness'), findsOneWidget);
    expect(find.byType(ChannelPlayer), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(ChannelPlayer),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
    expect(find.text('Reactions & memes'), findsNothing);
    demoCue(3, 'closing');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Continue'), findsNothing);
    expect(identical(state, tester.state(find.byType(StellarSlate))), true);
    expect(tester.takeException(), null);
    await tester.pumpWidget(const SizedBox());
    actions.cancel();
    sub.cancel();
    transport.dispose();
    controller.dispose();
  });
  testWidgets(
    'narrow screen loads and opens channel chooser without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MeMediaApp(
          initialScene: Map<String, dynamic>.from(
            jsonDecode(File('assets/explorer.json').readAsStringSync()) as Map,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('MeMedia'), findsOneWidget);
      expect(tester.takeException(), null);
      await tester.tap(find.text('iPhone Duo'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.ensureVisible(find.text('All 12 channels'));
      await tester.tap(find.text('All 12 channels'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Choose your rabbit hole'), findsOneWidget);
      expect(tester.takeException(), null);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.ensureVisible(find.text('First looks').last);
      await tester.tap(find.text('First looks').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Top signals'), findsOneWidget);
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
