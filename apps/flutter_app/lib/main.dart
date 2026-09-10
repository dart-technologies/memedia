import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genui/genui.dart';
import 'package:http/http.dart' as http;

import 'browser_prefs.dart';
import 'demo_bridge.dart';
import 'stellar_slate.dart';

void main() => runApp(const MeMediaApp());

class MeMediaApp extends StatefulWidget {
  const MeMediaApp({super.key, this.initialScene});
  final Map<String, dynamic>? initialScene;
  @override
  State<MeMediaApp> createState() => _MeMediaAppState();
}

class _MeMediaAppState extends State<MeMediaApp> {
  late final SurfaceController controller;
  late final A2uiTransportAdapter transport;
  final subscriptions = <StreamSubscription<dynamic>>[];
  final pending = <String>{};
  Map<String, dynamic> scene = {};
  String? error;
  @override
  void initState() {
    super.initState();
    controller = SurfaceController(catalogs: [stellarCatalog()]);
    transport = A2uiTransportAdapter(onSend: send);
    subscriptions.add(
      transport.incomingMessages.listen(controller.handleMessage),
    );
    subscriptions.add(controller.onSubmit.listen(transport.sendRequest));
    subscriptions.add(
      controller.surfaceUpdates.listen((_) {
        if (mounted) setState(() {});
      }),
    );
    initialize();
  }

  void feed(Map<String, Object?> m) =>
      transport.addChunk('```json\n${jsonEncode(m)}\n```\n');
  void update() {
    if (!mounted) return;
    scene = {...scene, 'revision': (scene['revision'] as int? ?? 0) + 1};
    feed({
      'version': 'v0.9',
      'updateDataModel': {
        'surfaceId': 'stellar-slate',
        'path': '/scene',
        'value': scene,
      },
    });
  }

  Future<void> initialize() async {
    try {
      scene =
          widget.initialScene ??
          Map<String, dynamic>.from(
            jsonDecode(await rootBundle.loadString('assets/explorer.json'))
                as Map,
          );
      scene = {
        ...scene,
        'selectedTopicId': null,
        'selectedChannelId': null,
        'scanStates': <String, dynamic>{},
        'cacheEntries': <String, dynamic>{},
        'backendAvailable': false,
      };
      try {
        final saved = readPreferences();
        if (saved != null) {
          final prefs = jsonDecode(saved) as Map;
          scene['followedChannelIds'] = prefs['followedChannelIds'] is List
              ? prefs['followedChannelIds']
              : [];
          scene['passenger'] = prefs['passenger'] == 'general'
              ? 'general'
              : 'business';
        }
      } catch (_) {}
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
      update();
      registerDemo(runDemoCue);
      if (widget.initialScene == null) unawaited(connect());
    } catch (_) {
      if (mounted) {
        setState(() => error = 'The sky could not load. Reload to try again.');
      }
    }
  }

  Future<void> connect() async {
    try {
      final r = await http
          .get(Uri.base.resolve('/api/explorer'))
          .timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return;
      final j = jsonDecode(r.body) as Map;
      if (j['entries'] is! Map || j['world'] is! Map) return;
      if (!mounted) return;
      scene = {
        ...scene,
        'backendAvailable': true,
        'cacheEntries': j['entries'],
        'world': j['world'],
      };
      update();
      unawaited(refresh('world'));
    } catch (_) {
      /* The embedded snapshot remains available on a static host. */
    }
  }

  int demoSequence = 0;
  void runDemoCue(String action) {
    if (!mounted || scene.isEmpty) return;
    if (action == 'warm') {
      unawaited(refresh('hands-on'));
      return;
    }
    const channelCues = {'channel', 'freshness', 'timeline'};
    scene = {
      ...scene,
      'selectedTopicId': action == 'discovery' ? null : 'iphone-duo',
      'selectedChannelId': channelCues.contains(action) ? 'hands-on' : null,
      'demoCue': {'sequence': ++demoSequence, 'action': action},
    };
    update();
    if (action == 'channel') unawaited(refresh('hands-on'));
  }

  Future<void> refresh(String key) async {
    if (pending.contains(key)) return;
    pending.add(key);
    demoStatus('$key: scanning');
    scene = {
      ...scene,
      'scanStates': {...scene['scanStates'] as Map, key: 'scanning'},
    };
    update();
    try {
      final r = await http
          .post(
            Uri.base.resolve('/api/explorer/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'key': key}),
          )
          .timeout(const Duration(seconds: 100));
      if (r.statusCode != 200) throw StateError('refresh_failed');
      final j = jsonDecode(r.body) as Map;
      if (j['revision'] is! int ||
          (key == 'world' ? j['topics'] is! List : j['artifacts'] is! List)) {
        throw StateError('invalid_result');
      }
      if (!mounted) return;
      final old = key == 'world'
          ? scene['world']
          : (scene['cacheEntries'] as Map)[key];
      if (old is Map &&
          (old['revision'] as int? ?? 0) > (j['revision'] as int)) {
        scene = {
          ...scene,
          'scanStates': {...scene['scanStates'] as Map, key: 'retained'},
        };
        return;
      }
      scene = {
        ...scene,
        'backendAvailable': true,
        if (key == 'world') 'world': j,
        if (key != 'world')
          'cacheEntries': {...scene['cacheEntries'] as Map, key: j},
        'scanStates': {
          ...scene['scanStates'] as Map,
          key: j['cacheHit'] == true ? 'cached' : 'updated',
        },
      };
    } catch (_) {
      if (mounted) {
        scene = {
          ...scene,
          'scanStates': {...scene['scanStates'] as Map, key: 'retained'},
        };
      }
    } finally {
      pending.remove(key);
      demoStatus('$key: ${(scene['scanStates'] as Map)[key]}');
      if (mounted) update();
    }
  }

  Future<void> send(ChatMessage message) async {
    try {
      final action =
          (jsonDecode(message.parts.uiInteractionParts.single.interaction)
                  as Map)['action']
              as Map;
      final data = action['context'] as Map;
      if (data['revision'] != scene['revision']) return;
      final name = action['name'];
      final ids = (scene['channels'] as List).map((c) => c['id']).toSet();
      String? scan;
      if (name == 'galaxy') {
        scene = {...scene, 'selectedTopicId': null, 'selectedChannelId': null};
      } else if (name == 'open_showcase') {
        scene = {
          ...scene,
          'selectedTopicId': 'iphone-duo',
          'selectedChannelId': null,
        };
      } else if (name == 'select_channel' && ids.contains(data['channelId'])) {
        scene = {
          ...scene,
          'selectedTopicId': 'iphone-duo',
          'selectedChannelId': data['channelId'],
        };
        scan = data['channelId'] as String;
      } else if (name == 'open_topic' &&
          ((scene['world'] as Map)['topics'] as List).any(
            (t) => t['id'] == data['topicId'],
          )) {
        scene = {
          ...scene,
          'selectedTopicId': data['topicId'],
          'focusedTopic': ((scene['world'] as Map)['topics'] as List)
              .firstWhere((t) => t['id'] == data['topicId']),
          'selectedChannelId': null,
        };
        scan = data['topicId'] as String;
      } else if (name == 'refresh') {
        scan = data['key'] as String;
      } else if (name == 'follow_channel' && ids.contains(data['channelId'])) {
        final ids = Set<String>.from(
          scene['followedChannelIds'] as List? ?? [],
        );
        ids.contains(data['channelId'])
            ? ids.remove(data['channelId'])
            : ids.add(data['channelId'] as String);
        scene = {...scene, 'followedChannelIds': ids.toList()};
      } else if (name == 'set_intent') {
        scene = {
          ...scene,
          'passenger': scene['passenger'] == 'business'
              ? 'general'
              : 'business',
        };
      } else {
        return;
      }
      savePreferences(
        jsonEncode({
          'followedChannelIds': scene['followedChannelIds'],
          'passenger': scene['passenger'],
        }),
      );
      update();
      if (scan != null) unawaited(refresh(scan));
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Action unavailable. Your current sky is retained.',
        );
      }
    }
  }

  @override
  void dispose() {
    for (final s in subscriptions) {
      s.cancel();
    }
    transport.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MeMedia — Unfolding moments',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xff080911),
      colorScheme: const ColorScheme.dark(primary: mint, surface: panel),
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'Inter',
        bodyColor: ink,
        displayColor: ink,
      ),
    ),
    home: Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (controller.activeSurfaceIds.contains('stellar-slate'))
              Surface(
                key: const ValueKey('stellar-slate'),
                surfaceContext: controller.contextFor('stellar-slate'),
              )
            else
              Center(
                child: error == null
                    ? const CircularProgressIndicator()
                    : Text(error!),
              ),
            if (error != null && controller.activeSurfaceIds.isNotEmpty)
              Positioned(
                left: 20,
                right: 20,
                bottom: 10,
                child: Material(
                  color: panel,
                  child: ListTile(
                    title: Text(error!),
                    trailing: IconButton(
                      onPressed: () => setState(() => error = null),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
