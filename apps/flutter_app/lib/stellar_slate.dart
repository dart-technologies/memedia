import 'dart:async';
import 'dart:math' as math;

import 'channel_player.dart';
import 'stellar_clusters.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:url_launcher/url_launcher.dart';

const ink = Color(0xfff2f1f8),
    muted = Color(0xff9899b0),
    mint = Color(0xffb7f5df),
    line = Color(0xff28293c),
    panel = Color(0xff121421);
const violet = Color(0xffc4b3ff), gold = Color(0xffffd5a7);
Catalog stellarCatalog() => Catalog([
  CatalogItem(
    name: 'StellarSlate',
    dataSchema: S.object(
      properties: {
        'scene': S.object(properties: {'path': S.string()}),
      },
    ),
    widgetBuilder: (c) => StellarSlate(context: c),
  ),
], catalogId: 'dev.memedia.stellar');
String rawCount(Object? v) => v == null
    ? '—'
    : v.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
String compactCount(Object? value) {
  if (value == null) return '—';
  final n = double.tryParse(value.toString().replaceAll(',', ''));
  if (n == null || !n.isFinite) return value.toString();
  for (final unit in [(1e9, 'B'), (1e6, 'M'), (1e3, 'K')]) {
    if (n.abs() >= unit.$1 * .99995) {
      final scaled = n / unit.$1;
      return '${scaled.toStringAsFixed(scaled.abs() < 10 ? 2 : 1).replaceFirst(RegExp(r'\.?0+$'), '')}${unit.$2}';
    }
  }
  return n.toStringAsFixed(0);
}

String runtime(Object? v) {
  final m = RegExp(r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$')
      .firstMatch(v?.toString() ?? '');
  if (m == null) return 'READ';
  final s =
      (int.tryParse(m[1] ?? '') ?? 0) * 3600 +
      (int.tryParse(m[2] ?? '') ?? 0) * 60 +
      (int.tryParse(m[3] ?? '') ?? 0);
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

String flags(Object? codes) => (codes is List ? codes : [codes])
    .whereType<String>()
    .map(
      (c) => RegExp(r'^[A-Z]{2}$').hasMatch(c)
          ? String.fromCharCodes(c.codeUnits.map((n) => n + 127397))
          : '🌐',
    )
    .join(' ');
String primaryFlag(Map topic) => flags(
  topic['primaryRegion'] ??
      topic['region'] ??
      (topic['regions'] as List? ?? []).firstOrNull,
);

double metricNumber(Object? raw) {
  final m = RegExp(
    r'^([\d.,]+)\s*([KMB])?$',
    caseSensitive: false,
  ).firstMatch(raw?.toString() ?? '');
  if (m == null) return -1;
  return (double.tryParse(m[1]!.replaceAll(',', '')) ?? -1) *
      ({'K': 1e3, 'M': 1e6, 'B': 1e9}[m[2]?.toUpperCase()] ?? 1);
}

bool established(Map a) => metricNumber(a['creatorSubscribers']) >= 100000;
bool topSignal(Map a) =>
    a['platform'] != 'YouTube' ||
    established(a) ||
    metricNumber(a['views']) >= 10000;
int mediaOrder(Map a, Map b) {
  final tier = (established(b) ? 1 : 0) - (established(a) ? 1 : 0);
  if (tier != 0) return tier;
  final views = metricNumber(b['views'] ?? b['viewsDisplay'])
      .compareTo(metricNumber(a['views'] ?? a['viewsDisplay']));
  if (views != 0) return views;
  return metricNumber(b['likes'] ?? b['likesDisplay'])
      .compareTo(metricNumber(a['likes'] ?? a['likesDisplay']));
}

bool playable(Map a) =>
    (a['platform'] == 'YouTube' &&
        a['embeddable'] != false &&
        RegExp(r'^yt-[\w-]{11}$').hasMatch(a['id'].toString())) ||
    (a['platform'] == 'TikTok' &&
        RegExp(r'^tt-\d+$').hasMatch(a['id'].toString()));

String relativeTime(Object? raw, DateTime now) {
  final date = DateTime.tryParse(raw?.toString() ?? '');
  if (date == null) return 'time unknown';
  final d = now.toUtc().difference(date.toUtc());
  if (d.inSeconds < -60) return 'time ahead';
  if (d.inMinutes < 1) return 'just now';
  if (d.inHours < 1) return '${d.inMinutes}m ago';
  if (d.inDays < 1) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}

String stamp(Object? v) {
  final d = DateTime.tryParse(v?.toString() ?? '');
  if (d == null) return 'Unknown';
  return '${d.month}/${d.day} · ${d.toUtc().hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} UTC';
}

Color tint(Map c) => Color(
  int.parse(
    (c['color'] as String? ?? '#c4b3ff').replaceFirst('#', 'ff'),
    radix: 16,
  ),
);
bool knownBy(Map a, DateTime horizon, bool observed) {
  final raw = observed
      ? (a['browserRecordedAt'] ?? a['firstObservedAt'])
      : a['publishedAt'];
  if (raw == null) {
    final first = DateTime.tryParse(a['firstObservedAt']?.toString() ?? '');
    return first != null && !first.isAfter(horizon);
  }
  final date = DateTime.tryParse(raw.toString());
  if (date == null) return false;
  if (a['publicationTimePrecision'] == 'day' && !observed) {
    final first = DateTime.tryParse(a['firstObservedAt']?.toString() ?? '');
    return DateTime.utc(
          date.year,
          date.month,
          date.day,
          23,
          59,
        ).isBefore(horizon) ||
        (first != null && !first.isAfter(horizon) && !date.isAfter(horizon));
  }
  return !date.isAfter(horizon);
}

String topicLabel(Map t) {
  const translations = {
    'alerta extremo de tempestade': 'Brazil storm alerts',
    'jogos da champions hoje': 'Champions League',
    '1ドル': 'Dollar / yen',
    'astros - phillies': 'Astros × Phillies',
    'mobland season 2 release date': 'MobLand returns',
    'shree charani': 'Shree Charani',
    'kranti gaud': 'Kranti Gaud',
    '中島卓也': 'Takuya Nakashima',
    'missouri supreme court': 'Missouri Supreme Court',
  };
  return translations[t['label']] ?? t['label'] as String;
}

String reviewLabel(Map a) => a['publisherIdentityVerified'] == true
    ? 'Publisher checked'
    : a['evidenceStatus'] == 'ORIGINAL_POST_INSPECTED'
    ? 'Original inspected'
    : a['evidenceStatus'] == 'OPENED_TEXT'
    ? 'Source inspected'
    : a['reviewStatus'] == 'ASTRA_METADATA_SCREENED'
    ? 'Astra · metadata fit'
    : 'Review pending';
List<Map> channelMembers(Map scene, Map channel) {
  final seed = (scene['artifacts'] as List).cast<Map>();
  final byId = {for (final a in seed) a['id']: a};
  final cache = (scene['cacheEntries'] as Map? ?? {})[channel['id']] as Map?;
  final fresh = (cache?['artifacts'] as List? ?? []).cast<Map>();
  for (final a in fresh) {
    final old = byId[a['id']];
    byId[a['id']] = old == null
        ? a
        : {
            ...a,
            ...old,
            'views': a['views'],
            'likes': a['likes'],
            'metricsObservedAt': a['metricsObservedAt'],
            'curatedAt': a['curatedAt'],
            'curatedReason': a['why'],
            'creatorSubscribers':
                a['creatorSubscribers'] ?? old['creatorSubscribers'],
            'embeddable': a['embeddable'] ?? old['embeddable'],
          };
  }
  final ids = <dynamic>{
    ...channel['seedArtifactIds'] as List,
    ...fresh.where((a) => a['included'] == true).map((a) => a['id']),
  };
  return ids.where(byId.containsKey).map((id) => byId[id]!).toList()
    ..sort(mediaOrder);
}

class StellarSlate extends StatefulWidget {
  const StellarSlate({super.key, required this.context});
  final CatalogItemContext context;
  @override
  State<StellarSlate> createState() => _StellarSlateState();
}

class _StellarSlateState extends State<StellarSlate>
    with SingleTickerProviderStateMixin {
  late final AnimationController drift;
  Timer? timer;
  DateTime now = DateTime.now().toUtc();
  bool observed = false, english = true, savedOnly = false, topOnly = true;
  String? playingId;
  String playbackState = 'loading';
  int? navigationRevision;
  String? routeVideo;
  String? selectionIdentity;
  bool revealPlaying = false;
  bool resolveLinkedFilters = false;
  double horizon = 1;
  String platform = 'All';
  final rail = ScrollController();
  @override
  void initState() {
    super.initState();
    drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35),
    )..repeat();
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => now = DateTime.now().toUtc());
    });
  }

  @override
  void dispose() {
    drift.dispose();
    timer?.cancel();
    rail.dispose();
    super.dispose();
  }

  void act(String name, Map scene, [Map<String, Object?> extra = const {}]) =>
      widget.context.dispatchEvent(
        UserActionEvent(
          name: name,
          sourceComponentId: widget.context.id,
          surfaceId: widget.context.surfaceId,
          context: {'revision': scene['revision'], ...extra},
        ),
      );
  void select(Map c, Map scene) {
    setState(() {
      horizon = 1;
      platform = 'All';
      playingId = null;
    });
    act('select_channel', scene, {'channelId': c['id']});
    if (rail.hasClients) rail.jumpTo(0);
  }

  Future<void> openSource(Map a) async {
    final uri = Uri.tryParse(a['url']?.toString() ?? '');
    if (uri == null || uri.scheme != 'https') return;
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  }

  @override
  Widget build(BuildContext context) {
    final binding = (widget.context.data as Map)['scene'] as Map;
    return ValueListenableBuilder<Object?>(
      valueListenable: widget.context.dataContext.subscribe<Object>(
        DataPath(binding['path'] as String),
      ),
      builder: (context, value, _) {
        if (value is! Map) {
          return const Center(child: CircularProgressIndicator());
        }
        handleDemoCue(value);
        return buildSky(value);
      },
    );
  }

  int? demoSequence;
  DialogRoute<void>? demoDialog;
  void handleDemoCue(Map scene) {
    final cue = scene['demoCue'];
    if (cue is! Map || cue['sequence'] == demoSequence) return;
    demoSequence = cue['sequence'] as int;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || (scene['demoCue'] as Map)['sequence'] != demoSequence) {
        return;
      }
      final navigator = Navigator.of(context);
      if (demoDialog?.isActive == true) navigator.removeRoute(demoDialog!);
      demoDialog = null;
      final action = cue['action'];
      setState(() {
        horizon = 1;
        observed = false;
        platform = 'All';
        english = true;
        topOnly = true;
        if (action == 'channel') playingId = scene['playingVideoId'] as String?;
        if (action == 'discovery') playingId = null;
      });
      if (rail.hasClients) rail.jumpTo(0);
      Map? explanation;
      if (action == 'relationships') {
        explanation = (scene['clusterGroups'] as List).cast<Map>().firstWhere(
          (g) => (g['label'] as String).toLowerCase().contains('reactions'),
        );
      }
      if (action == 'relationships' || action == 'freshness') {
        final channel = (scene['channels'] as List).cast<Map>().firstWhere(
          (c) => c['id'] == 'hands-on',
        );
        demoDialog = DialogRoute<void>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: panel,
            title: Text(
              explanation?['label'] as String? ?? 'Curation & freshness',
            ),
            content: Text(
              explanation?['reason'] as String? ??
                  '${channel['whyThisChannel']}\n\nOpening a channel scans YouTube and screens metadata with Astra. Fresh cache is reused. Views and likes are observed counts; publication age and scan time stay separate. Errors retain current media.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
        navigator.push(demoDialog!);
      }
    });
  }

  Widget buildSky(Map scene) {
    final selection =
        '${scene['selectedTopicId']}/${scene['selectedChannelId']}';
    if (selection != selectionIdentity ||
        scene['navigationRevision'] != navigationRevision ||
        scene['playingVideoId'] != routeVideo) {
      if (scene['navigationRevision'] != navigationRevision &&
          scene['playingVideoId'] != null) {
        resolveLinkedFilters = true;
      }
      selectionIdentity = selection;
      navigationRevision = scene['navigationRevision'] as int?;
      routeVideo = scene['playingVideoId'] as String?;
      if (playingId != routeVideo) playbackState = 'loading';
      playingId = routeVideo;
      revealPlaying = true;
    }
    now = DateTime.now().toUtc();
    final channels = (scene['channels'] as List).cast<Map>();
    final world = scene['world'] as Map? ?? {'topics': []};
    final topics = (world['topics'] as List? ?? []).cast<Map>();
    final topicId = scene['selectedTopicId'];
    final isWorld = topicId == null;
    final isDuo = topicId == 'iphone-duo';
    final selected = channels
        .where((c) => c['id'] == scene['selectedChannelId'])
        .firstOrNull;
    final topic =
        topics.where((t) => t['id'] == topicId).firstOrNull ??
        (scene['focusedTopic'] is Map &&
                (scene['focusedTopic'] as Map)['id'] == topicId
            ? scene['focusedTopic'] as Map
            : null);
    final selectedKey = selected?['id'] ?? topic?['id'];
    final cache = (scene['cacheEntries'] as Map? ?? {})[selectedKey] as Map?;
    var members = selected != null
        ? channelMembers(scene, selected)
        : topic != null
        ? <Map>[
            ...(topic['articles'] as List).cast<Map>(),
            ...(cache?['artifacts'] as List? ?? []).cast<Map>().where(
              (a) => a['included'] == true,
            ),
          ]
        : <Map>[];
    if (resolveLinkedFilters && playingId != null) {
      final linked = members.where((a) => a['id'] == playingId).firstOrNull;
      if (linked != null) {
        if (!topSignal(linked)) topOnly = false;
        if (!(linked['language'] as String? ?? '').startsWith('en')) {
          english = false;
        }
        horizon = 1;
        platform = 'All';
        resolveLinkedFilters = false;
      }
    }
    final start = DateTime.utc(2026, 9, 9);
    final end = now.isAfter(start) ? now : start.add(const Duration(days: 1));
    final cutoff = start.add(
      Duration(
        milliseconds: ((end.difference(start).inMilliseconds) * horizon)
            .round(),
      ),
    );
    members = members
        .where((a) => horizon == 1 || knownBy(a, cutoff, observed))
        .where((a) => !topOnly || topSignal(a))
        .where((a) => platform == 'All' || a['platform'] == platform)
        .where(
          (a) =>
              !english ||
              a['platform'] != 'YouTube' ||
              (a['language'] as String? ?? '').startsWith('en'),
        )
        .map((a) {
          final metrics = DateTime.tryParse(
            a['metricsObservedAt']?.toString() ?? '',
          );
          return horizon < 1 && metrics != null && metrics.isAfter(cutoff)
              ? {
                  ...a,
                  'views': null,
                  'likes': null,
                  'likesDisplay': null,
                  'viewsDisplay': null,
                }
              : a;
        })
        .toList();
    members.sort(mediaOrder);
    final inChannel = selected != null || topic != null;
    final title = isWorld
        ? 'Unfolding moments.'
        : selected?['shortLabel'] ??
              selected?['label'] ??
              (isDuo ? 'The iPhone aftershock.' : topicLabel(topic!));
    return LayoutBuilder(
      builder: (context, b) {
        final compact = b.maxWidth < 760;
        final reduced = MediaQuery.disableAnimationsOf(context);
        if (reduced && drift.isAnimating) drift.stop();
        if (!reduced && !drift.isAnimating) drift.repeat();
        final header = Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 20 : 32,
            18,
            compact ? 20 : 32,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: mint, size: 21),
                  const SizedBox(width: 9),
                  const Text(
                    'MeMedia',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 16),
                    Text(
                      'UNFOLDING MOMENTS. CONNECTING REACTIONS.',
                      style: TextStyle(
                        fontSize: 9,
                        color: muted,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                  const Spacer(),
                  pill('NYC', Icons.near_me_outlined, () => contextInfo()),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Saved channels',
                    onPressed: () {
                      setState(() => savedOnly = !savedOnly);
                      allChannels(scene);
                    },
                    icon: Icon(
                      savedOnly ? Icons.bookmark : Icons.bookmark_border,
                      size: 19,
                      color: muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => act('galaxy', scene),
                              child: tiny('DISCOVER', isWorld ? mint : muted),
                            ),
                            if (!isWorld) ...[
                              const Icon(
                                Icons.chevron_right,
                                size: 12,
                                color: muted,
                              ),
                              InkWell(
                                onTap: () => act('open_showcase', scene),
                                child: tiny(
                                  isDuo ? 'IPHONE DUO' : 'GLOBAL PULSE',
                                  violet,
                                ),
                              ),
                            ],
                            if (selected != null) ...[
                              const Icon(
                                Icons.chevron_right,
                                size: 12,
                                color: muted,
                              ),
                              tiny('CHANNEL', muted),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title as String,
                          style: TextStyle(
                            fontSize: compact ? 28 : 35,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -1.2,
                            height: 1.06,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!compact)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isWorld
                              ? 'Global pulse · highest search-volume signals'
                              : isDuo
                              ? 'One launch. Every perspective.'
                              : flags(topic?['regions'] as List? ?? []),
                          style: const TextStyle(fontSize: 11, color: muted),
                        ),
                        const SizedBox(height: 8),
                        scanLabel(
                          scene,
                          selectedKey ?? 'world',
                          cache ?? world,
                        ),
                      ],
                    ),
                ],
              ),
              if (compact) ...[
                const SizedBox(height: 10),
                scanLabel(scene, selectedKey ?? 'world', cache ?? world),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
        final map = skyMap(
          scene,
          channels,
          topics,
          isWorld,
          isDuo,
          selected,
          topic,
          compact,
          inChannel,
          members,
        );
        final footer = Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 20 : 32,
            vertical: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isWorld
                      ? 'Global pulse · ranked across monitored feeds · source details in About'
                      : 'Source marks identify origin · previews retain individual review status',
                  style: const TextStyle(color: muted, fontSize: 9),
                ),
              ),
              TextButton(
                onPressed: () => about(scene),
                child: const Text(
                  'How it’s curated',
                  style: TextStyle(fontSize: 10, color: muted),
                ),
              ),
            ],
          ),
        );
        final strip = inChannel
            ? channelRail(
                scene,
                selected,
                topic,
                members,
                cache,
                selectedKey as String,
                cutoff,
                compact,
              )
            : worldRail(scene, channels, compact);
        if (inChannel ||
            compact ||
            b.maxHeight < 680 ||
            (isDuo && selected == null)) {
          return Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: SkyPainter())),
              SingleChildScrollView(
                child: Column(
                  children: [
                    header,
                    SizedBox(
                      height: inChannel
                          ? (compact ? 250 : 190)
                          : isDuo
                          ? (compact ? 970 : 480)
                          : (compact ? 510 : 500),
                      child: map,
                    ),
                    if (inChannel)
                      strip
                    else
                      worldRail(scene, channels, compact),
                    footer,
                  ],
                ),
              ),
            ],
          );
        }
        return Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: SkyPainter())),
            Column(
              children: [
                header,
                Expanded(child: map),
                strip,
                footer,
              ],
            ),
          ],
        );
      },
    );
  }

  Widget tiny(String text, Color color) => Text(
    text,
    style: TextStyle(
      fontSize: 9,
      letterSpacing: 1.8,
      fontWeight: FontWeight.w600,
      color: color,
    ),
  );
  Widget pill(String text, IconData icon, VoidCallback tap) => InkWell(
    onTap: tap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(20),
        color: panel.withValues(alpha: .65),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: mint),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 10, color: ink)),
        ],
      ),
    ),
  );
  Widget scanLabel(Map scene, String key, Map? cached) {
    final state = (scene['scanStates'] as Map? ?? {})[key];
    final scanning = state == 'scanning';
    final checked = cached?['checkedAt'] ?? cached?['observedAt'];
    final text = scanning
        ? 'Scanning · keeping your selection'
        : state == 'retained'
        ? 'Scan unavailable · cache kept'
        : checked != null
        ? 'Scanned ${relativeTime(checked, now)}'
        : 'Recorded selection';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (scanning)
          const SizedBox(
            width: 9,
            height: 9,
            child: CircularProgressIndicator(strokeWidth: 1.3, color: mint),
          )
        else
          Icon(Icons.circle, size: 5, color: state == 'retained' ? gold : mint),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: state == 'retained' ? gold : muted,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget imageTile(Map? a, {double radius = 16}) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: a?['thumbnailUrl'] is String
        ? Image.network(
            a!['thumbnailUrl'] as String,
            fit: BoxFit.cover,
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            errorBuilder: (_, e, s) => fallback(a),
          )
        : fallback(a),
  );
  Widget fallback(Map? a) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xff32283e), Color(0xff16272f)]),
    ),
    child: Center(
      child: Icon(
        a?['platform'] == 'TikTok' ? Icons.music_note : Icons.auto_awesome,
        color: violet.withValues(alpha: .65),
        size: 28,
      ),
    ),
  );
  Map? cover(Map scene, Map c) {
    final all = channelMembers(scene, c);
    return all.where((a) => a['thumbnailUrl'] != null).firstOrNull;
  }

  Widget channelPreview(Map scene, Map channel) {
    final items = channelMembers(scene, channel)
        .where((a) => a['thumbnailUrl'] != null && (!topOnly || topSignal(a)))
        .take(3)
        .toList();
    final entry = (scene['cacheEntries'] as Map? ?? {})[channel['id']] as Map?;
    final checked = DateTime.tryParse(entry?['checkedAt']?.toString() ?? '');
    final state = (scene['scanStates'] as Map? ?? {})[channel['id']];
    final recent =
        checked != null &&
        now.difference(checked).inMinutes >= 0 &&
        now.difference(checked).inMinutes < 15;
    final status = state == 'scanning'
        ? 'Scanning'
        : state == 'retained'
        ? 'Cache kept'
        : checked != null
        ? 'Scanned ${relativeTime(checked, now)}'
        : 'Recorded picks';
    return ChannelPreview(
      key: ValueKey('channel-preview-${channel['id']}'),
      label: (channel['shortLabel'] ?? channel['label']).toString(),
      color: tint(channel),
      images: items.isEmpty
          ? [fallback(null)]
          : items.map((a) => imageTile(a, radius: 10)).toList(),
      sourceMark: items.isEmpty
          ? const Icon(Icons.article_outlined, size: 12, color: muted)
          : platformMark(items.first),
      status: status,
      explanation:
          channel['whyThisChannel']?.toString() ??
          'An editorial perspective on this topic.',
      freshness: FreshnessMarker(
        scanning: state == 'scanning',
        recent: recent,
        retained: state == 'retained',
        description:
            '$status. This indicates scan time, not publication age or popularity.',
      ),
      onOpen: () => select(channel, scene),
      onExplain: () => channelWhy(channel, scene),
    );
  }

  Widget channelNeighborhoods(Map scene, List<Map> channels, bool compact) {
    final groups = (scene['clusterGroups'] as List? ?? []).cast<Map>();
    Widget group(Map g) {
      final nodes = (g['channelIds'] as List)
          .map((id) => channels.where((c) => c['id'] == id).firstOrNull)
          .whereType<Map>()
          .toList();
      return TopicCluster(
        key: ValueKey(g['id']),
        label: g['label'] as String,
        reason: g['reason'] as String,
        color: tint(g),
        channels: nodes,
        related: (a, b) =>
            (a['relatedChannelIds'] as List? ?? []).contains(b['id']) ||
            (b['relatedChannelIds'] as List? ?? []).contains(a['id']),
        previews: nodes.map((c) => channelPreview(scene, c)).toList(),
        onExplain: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: panel,
            title: Text(g['label'] as String),
            content: Text(
              '${g['reason']}\n\nThumbnail order follows the current channel ranking. Source marks identify origin; review status and observed views / likes remain on individual media cards.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, b) {
        if (compact) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(child: tiny('12 CONNECTED CHANNELS', mint)),
                    IconButton(
                      tooltip: 'All 12 channels',
                      onPressed: () => allChannels(scene),
                      icon: const Icon(Icons.grid_view, size: 16, color: muted),
                    ),
                  ],
                ),
              ),
              for (final g in groups)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: SizedBox(height: 215, child: group(g)),
                ),
              pill(
                'All 12 channels',
                Icons.grid_view,
                () => allChannels(scene),
              ),
            ],
          );
        }
        final groupW = b.maxWidth * .435;
        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: RelationshipLinks(
                    edges: const [],
                    color: mint,
                    glow: true,
                  ),
                ),
              ),
            ),
            for (var i = 0; i < groups.length; i++)
              Positioned(
                left: i.isEven ? b.maxWidth * .025 : b.maxWidth * .54,
                top: i < 2 ? 12 : 247,
                width: groupW,
                height: 211,
                child: group(groups[i]),
              ),
            Positioned(
              left: b.maxWidth / 2 - 52,
              top: 180,
              width: 104,
              child: InkWell(
                onTap: () => channelWhy(
                  channels.firstWhere((c) => c['id'] == 'launch'),
                  scene,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: mint.withValues(alpha: .4)),
                        boxShadow: [
                          BoxShadow(
                            color: mint.withValues(alpha: .12),
                            blurRadius: 42,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: imageTile(
                          cover(
                            scene,
                            channels.firstWhere((c) => c['id'] == 'launch'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('iPhone Duo', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 3),
                    tiny('THE MOMENT', mint),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 32,
              bottom: 0,
              child: tiny('NEARBY = SHARED EDITORIAL LENS', muted),
            ),
            Positioned(
              right: 28,
              bottom: 0,
              child: pill(
                'All 12 channels',
                Icons.grid_view,
                () => allChannels(scene),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget discoveryField(
    Map scene,
    List<Map> channels,
    List<Map> topics,
  ) => LayoutBuilder(
    builder: (context, b) {
      final w = b.maxWidth, h = b.maxHeight;
      final hero = (scene['artifacts'] as List)
          .cast<Map>()
          .where((a) => a['id'] == 'yt-bxSGfpoFP30')
          .firstOrNull;
      final nearby = [
        'hands-on',
        'competition',
        'visual-memes',
      ].map((id) => channels.firstWhere((c) => c['id'] == id)).toList();
      final core = Offset(w * .5, h * .40);
      final satelliteSpread = (w * .12).clamp(92.0, 150.0);
      final points = [
        Offset(core.dx - satelliteSpread, h * .59),
        Offset(core.dx, h * .76),
        Offset(core.dx + satelliteSpread, h * .59),
      ];
      final topicWidth = w >= 1000 ? 156.0 : 132.0;
      final topicPoints = [
        Offset(w * .10, h * .14),
        Offset(w * .31, h * .03),
        Offset(w * .69, h * .03),
        Offset(w * .90, h * .14),
        Offset(w * .90, h * .60),
        Offset(w * .76, h * .75),
        Offset(w * .24, h * .75),
        Offset(w * .10, h * .60),
      ];
      return Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: RelationshipLinks(
                  edges: [for (final p in points) (core, p)],
                  color: mint,
                  glow: true,
                ),
              ),
            ),
          ),
          Positioned(
            left: core.dx - 78,
            top: core.dy - 110,
            width: 156,
            child: Semantics(
              button: true,
              label: 'Explore iPhone Duo showcase',
              child: InkWell(
                onTap: () => act('open_showcase', scene),
                borderRadius: BorderRadius.circular(90),
                child: Column(
                  children: [
                    Container(
                      width: 138,
                      height: 138,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: mint.withValues(alpha: .5)),
                        boxShadow: [
                          BoxShadow(
                            color: mint.withValues(alpha: .14),
                            blurRadius: 65,
                          ),
                        ],
                      ),
                      child: ClipOval(child: imageTile(hero)),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'iPhone Duo',
                      style: TextStyle(fontSize: 22, letterSpacing: -.6),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'SHOWCASE · 12 CHANNELS ↗',
                      style: TextStyle(
                        fontSize: 8,
                        letterSpacing: 1,
                        color: mint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (var i = 0; i < nearby.length; i++)
            Positioned(
              left: points[i].dx - 53,
              top: points[i].dy - 30,
              width: 106,
              height: 158,
              child: channelPreview(scene, nearby[i]),
            ),
          for (var i = 0; i < math.min(8, topics.length); i++)
            Positioned(
              left: topicPoints[i].dx - topicWidth / 2,
              top: topicPoints[i].dy,
              width: topicWidth,
              height: 180,
              child: Tooltip(
                message:
                    'Primary observation: ${topics[i]['primaryRegion'] ?? topics[i]['region'] ?? 'unknown'}. Not topic nationality.',
                child: constellationNode(
                  scene,
                  topics[i],
                  true,
                  false,
                  null,
                  topicWidth,
                ),
              ),
            ),
          Positioned(
            left: 30,
            bottom: 2,
            child: tiny('ALSO UNFOLDING · GLOBAL PULSE', violet),
          ),
          Positioned(
            right: 28,
            bottom: 0,
            child: pill(
              'Refresh topics',
              Icons.refresh,
              () => act('refresh', scene, {'key': 'world'}),
            ),
          ),
        ],
      );
    },
  );

  Widget skyMap(
    Map scene,
    List<Map> channels,
    List<Map> topics,
    bool world,
    bool duo,
    Map? selected,
    Map? topic,
    bool compact,
    bool drilling,
    List<Map> media,
  ) {
    if (duo && selected == null) {
      return channelNeighborhoods(scene, channels, compact);
    }
    if (world && !compact) return discoveryField(scene, channels, topics);
    final chosen = <Map>[];
    if (selected != null) {
      chosen.addAll(
        media.where((a) => a['thumbnailUrl'] != null).take(compact ? 4 : 6),
      );
    } else if (world) {
      chosen.addAll(topics.take(compact ? 5 : 8));
    } else if (duo) {
      final priority = [
        'competition',
        'visual-memes',
        'brand-banter',
        'hands-on',
        'software',
        'business',
        'value',
        'launch',
      ];
      for (final id in priority) {
        final c = channels.where((c) => c['id'] == id).firstOrNull;
        if (c != null) chosen.add(c);
      }
      if (selected != null && !chosen.any((c) => c['id'] == selected['id'])) {
        chosen[chosen.length - 1] = selected;
      }
      if (compact) {
        final keep = chosen.take(5).toList();
        if (selected != null && !keep.any((c) => c['id'] == selected['id'])) {
          keep[4] = selected;
        }
        chosen
          ..clear()
          ..addAll(keep);
      }
    } else {
      chosen.addAll(media.take(compact ? 4 : 5));
    }
    return LayoutBuilder(
      builder: (context, b) {
        final w = b.maxWidth, h = b.maxHeight;
        final centre = Offset(w * (compact ? .5 : .48), h * .47);
        final points = compact
            ? <Offset>[
                Offset(w * .22, h * .13),
                Offset(w * .79, h * .19),
                Offset(w * .79, h * .70),
                Offset(w * .25, h * .83),
                Offset(w * .17, h * .48),
              ]
            : <Offset>[
                Offset(w * .19, h * .23),
                Offset(w * .77, h * .18),
                Offset(w * .88, h * .62),
                Offset(w * .69, h * .82),
                Offset(w * .29, h * .81),
                Offset(w * .09, h * .61),
                Offset(w * .48, h * .09),
                Offset(w * .53, h * .88),
              ];
        final nodeW = compact
            ? 106.0
            : drilling
            ? 127.0
            : 145.0;
        final nodeH = compact
            ? 178.0
            : drilling
            ? 152.0
            : 170.0;
        final heroSize = compact
            ? 134.0
            : drilling
            ? 142.0
            : 178.0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: drift,
                builder: (context, _) => CustomPaint(
                  painter: OrbitPainter(
                    centre: centre,
                    points: points.take(chosen.length).toList(),
                    phase: drift.value,
                    world: world,
                    timestamps: null,
                  ),
                ),
              ),
            ),
            Positioned(
              left: centre.dx - heroSize / 2,
              top: centre.dy - heroSize / 2 - 8,
              width: heroSize,
              height: heroSize + 50,
              child: Semantics(
                button: true,
                label: world
                    ? 'Explore iPhone Duo showcase'
                    : duo
                    ? 'iPhone Duo launch beacon'
                    : 'Current topic ${topicLabel(topic!)}',
                child: InkWell(
                  onTap: selected != null
                      ? () => channelWhy(selected, scene)
                      : world
                      ? () => act('open_showcase', scene)
                      : duo
                      ? () => select(
                          channels.firstWhere((c) => c['id'] == 'launch'),
                          scene,
                        )
                      : () => openSource(
                          (topic!['articles'] as List).first as Map,
                        ),
                  borderRadius: BorderRadius.circular(90),
                  child: Column(
                    children: [
                      Container(
                        width: heroSize,
                        height: heroSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: mint.withValues(alpha: .5)),
                          boxShadow: [
                            BoxShadow(
                              color: mint.withValues(alpha: .10),
                              blurRadius: 55,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: violet.withValues(alpha: .12),
                              blurRadius: 100,
                              spreadRadius: 18,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(7),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipOval(
                              child: world || duo
                                  ? imageTile(
                                      selected != null
                                          ? (media
                                                .where(
                                                  (a) =>
                                                      a['thumbnailUrl'] != null,
                                                )
                                                .firstOrNull)
                                          : (scene['artifacts'] as List)
                                                .cast<Map>()
                                                .where(
                                                  (a) =>
                                                      a['id'] ==
                                                      'yt-bxSGfpoFP30',
                                                )
                                                .firstOrNull,
                                      radius: 90,
                                    )
                                  : imageTile(topic, radius: 90),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: .45),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 17,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: tiny(
                                  world
                                      ? 'SHOWCASE'
                                      : selected != null
                                      ? 'IN FOCUS'
                                      : duo
                                      ? 'LAUNCH BEACON'
                                      : 'IN FOCUS',
                                  mint,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          world
                              ? 'iPhone Duo'
                              : selected != null
                              ? 'Sep 9 · UTC origin'
                              : duo
                              ? 'Sep 9 · Apple'
                              : flags(topic!['regions']),
                          style: TextStyle(
                            fontSize: world ? 18 : 11,
                            color: world ? ink : muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            for (var i = 0; i < chosen.length; i++)
              Positioned(
                left: (points[i].dx - nodeW / 2).clamp(10, w - nodeW - 10),
                top: (points[i].dy - nodeH / 2).clamp(0, h - nodeH),
                width: nodeW,
                height: nodeH,
                child: constellationNode(
                  scene,
                  chosen[i],
                  world,
                  duo && selected == null,
                  selected,
                  nodeW,
                ),
              ),
            Positioned(
              right: compact ? 14 : 28,
              bottom: 1,
              child: pill(
                world
                    ? 'Refresh topics'
                    : duo
                    ? 'All 12 channels'
                    : 'Source context',
                world ? Icons.refresh : Icons.grid_view,
                world
                    ? () => act('refresh', scene, {'key': 'world'})
                    : duo
                    ? () => allChannels(scene)
                    : () => about(scene),
              ),
            ),
            if (!compact)
              Positioned(
                left: 28,
                bottom: 8,
                child: tiny(
                  world
                      ? 'FOLLOW WHAT’S UNFOLDING'
                      : drilling
                      ? (observed
                            ? 'RECORDED SOURCES · TIME FILTER BELOW'
                            : 'RELATED MEDIA · TIME FILTER BELOW')
                      : 'FOLLOW A PERSPECTIVE',
                  muted,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget constellationNode(
    Map scene,
    Map item,
    bool world,
    bool duo,
    Map? selected,
    double width,
  ) {
    final isChannel = !world && duo;
    final active = selected?['id'] == item['id'];
    final a = isChannel ? cover(scene, item) : item;
    final color = world
        ? violet
        : isChannel
        ? tint(item)
        : mint;
    final label = world
        ? topicLabel(item)
        : isChannel
        ? (item['shortLabel'] ?? item['label']) as String
        : item['publisher'] as String;
    final cache = (scene['cacheEntries'] as Map? ?? {})[item['id']] as Map?;
    final state = (scene['scanStates'] as Map? ?? {})[item['id']];
    return Semantics(
      button: true,
      selected: active,
      label: world
          ? 'Trending topic $label'
          : isChannel
          ? 'Channel ${item['label']}'
          : 'Source $label',
      child: InkWell(
        onTap: world
            ? () {
                setState(() => horizon = 1);
                act('open_topic', scene, {'topicId': item['id']});
              }
            : isChannel
            ? () => select(item, scene)
            : () => detail(item),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            SizedBox(
              height: width < 120 ? 63 : 70,
              width: width < 120 ? 85 : 103,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 9,
                    right: 12,
                    bottom: 0,
                    child: Transform.rotate(
                      angle: -.16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: .09),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: color.withValues(alpha: .25),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 0,
                    right: 0,
                    bottom: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: active ? mint : color.withValues(alpha: .45),
                          width: active ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: active ? .24 : .12),
                            blurRadius: active ? 26 : 17,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: imageTile(a, radius: 10),
                    ),
                  ),
                  Positioned(
                    right: -1,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: state == 'scanning'
                            ? mint
                            : active
                            ? mint
                            : color,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: .6),
                            blurRadius: 9,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width < 120 ? 11 : 12,
                fontWeight: FontWeight.w500,
                color: active ? mint : ink,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              world
                  ? primaryFlag(item)
                  : state == 'scanning'
                  ? 'SCANNING'
                  : cache != null
                  ? 'CHECKED ${relativeTime(cache['checkedAt'], now).toUpperCase()}'
                  : isChannel
                  ? 'EXPLORE CHANNEL'
                  : '${item['viewsDisplay'] ?? compactCount(item['views'])} views · ${item['likesDisplay'] ?? compactCount(item['likes'])} likes',
              style: TextStyle(
                fontSize: world ? 12 : 7,
                letterSpacing: isChannel ? 1.3 : 0,
                color: active ? mint : muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget worldRail(Map scene, List<Map> channels, bool compact) {
    final meme = channels.firstWhere((c) => c['id'] == 'visual-memes');
    final banter = channels.firstWhere((c) => c['id'] == 'brand-banter');
    final magic = channels.firstWhere((c) => c['id'] == 'software');
    return Container(
      margin: EdgeInsets.fromLTRB(compact ? 16 : 30, 8, compact ? 16 : 30, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: line.withValues(alpha: .7)),
        borderRadius: BorderRadius.circular(22),
        color: panel.withValues(alpha: .5),
      ),
      child: Row(
        children: [
          if (!compact)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  tiny('THE AFTERSHOCK', mint),
                  const SizedBox(height: 6),
                  const Text(
                    'Follow the reaction.',
                    style: TextStyle(fontSize: 19),
                  ),
                ],
              ),
            ),
          for (final c in [meme, banter, magic])
            Expanded(
              child: InkWell(
                onTap: () => select(c, scene),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: compact ? 39 : 64,
                        height: compact ? 45 : 54,
                        child: imageTile(cover(scene, c), radius: 10),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          c['shortLabel'] as String? ?? c['label'] as String,
                          style: TextStyle(fontSize: compact ? 10 : 12),
                        ),
                      ),
                      if (!compact)
                        const Icon(Icons.north_east, size: 13, color: muted),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget channelRail(
    Map scene,
    Map? channel,
    Map? topic,
    List<Map> members,
    Map? cache,
    String key,
    DateTime cutoff,
    bool compact,
  ) {
    final selectedName =
        channel?['shortLabel'] ?? channel?['label'] ?? topicLabel(topic!);
    final playlist = members.where(playable).toList();
    playingId ??= playlist.firstOrNull?['id'] as String?;
    final chosen = playlist.where((a) => a['id'] == playingId).firstOrNull;
    final queue = playlist;
    final normalWidth = compact ? 238.0 : 250.0;
    final activeWidth = compact
        ? math.min(350.0, MediaQuery.sizeOf(context).width - 32)
        : 440.0;
    double titleHeight = 0;
    for (final a in members) {
      final text = TextPainter(
        text: TextSpan(
          text: a['title'] as String,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: normalWidth);
      titleHeight = math.max(titleHeight, text.height);
    }
    if (revealPlaying && chosen != null) {
      revealPlaying = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !rail.hasClients) return;
        final index = members.indexWhere((a) => a['id'] == playingId);
        final left = index * (normalWidth + 13);
        final right = left + activeWidth;
        final viewport = rail.position.viewportDimension;
        final offset = rail.offset;
        final target = left < offset
            ? left
            : right > offset + viewport
            ? right - viewport
            : offset;
        if ((target - offset).abs() < 1) return;
        rail.animateTo(
          target.clamp(0.0, rail.position.maxScrollExtent),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
    final scanning = (scene['scanStates'] as Map? ?? {})[key] == 'scanning';
    final cards = SizedBox(
      height: 332 + titleHeight,
      child: members.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.travel_explore, color: violet, size: 25),
                  const SizedBox(height: 8),
                  Text(
                    scanning
                        ? 'Finding the next signal…'
                        : 'No signals at this horizon.',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      horizon = 1;
                      platform = 'All';
                      english = false;
                    }),
                    child: const Text(
                      'Show all cached sources',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              controller: rail,
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < members.length; i++) ...[
                    if (i > 0) const SizedBox(width: 13),
                    SizedBox(
                      key: ValueKey(members[i]['id']),
                      height: 332 + titleHeight,
                      child: mediaCard(
                        members[i],
                        i,
                        cache,
                        compact,
                        scene,
                        queue,
                        members[i]['id'] == chosen?['id'],
                        members[i]['id'] == chosen?['id']
                            ? activeWidth
                            : normalWidth,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff0c0e19).withValues(alpha: .95),
        border: const Border(top: BorderSide(color: line)),
      ),
      padding: EdgeInsets.fromLTRB(compact ? 16 : 30, 10, compact ? 16 : 30, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!compact) ...[
                tiny('YOUR CHANNEL', mint),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  selectedName as String,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              IconButton(
                tooltip: 'Copy channel and video link',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await Clipboard.setData(
                    ClipboardData(text: Uri.base.toString()),
                  );
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Link copied')),
                    );
                  }
                },
                icon: const Icon(Icons.link, size: 17),
              ),
              IconButton(
                tooltip: 'Refresh channel',
                onPressed: scanning
                    ? null
                    : () => act('refresh', scene, {'key': key}),
                icon: const Icon(Icons.refresh, size: 17),
              ),
              if (channel != null)
                IconButton(
                  tooltip: 'Save channel',
                  onPressed: () => act('follow_channel', scene, {
                    'channelId': channel['id'],
                  }),
                  icon: Icon(
                    (scene['followedChannelIds'] as List? ?? []).contains(
                          channel['id'],
                        )
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    size: 17,
                  ),
                ),
              TextButton(
                onPressed: () => setState(() => topOnly = !topOnly),
                child: Text(
                  topOnly ? 'Top signals' : 'All signals',
                  style: const TextStyle(fontSize: 10, color: mint),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Media filter',
                initialValue: platform,
                onSelected: (v) => setState(() => platform = v),
                itemBuilder: (_) => [
                  'All',
                  'YouTube',
                  'TikTok',
                  'X',
                  'Web',
                ].map((v) => PopupMenuItem(value: v, child: Text(v))).toList(),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '$platform ▾',
                    style: const TextStyle(fontSize: 10, color: muted),
                  ),
                ),
              ),
            ],
          ),
          if (channel != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    channel['editorialQuestion'] as String,
                    style: const TextStyle(fontSize: 11, color: muted),
                  ),
                ),
                InkWell(
                  onTap: () => channelWhy(channel, scene),
                  child: const Text(
                    'Why this channel ↗',
                    style: TextStyle(fontSize: 10, color: mint),
                  ),
                ),
              ],
            ),
          SizedBox(
            height: compact ? 48 : 36,
            child: Row(
              children: [
                InkWell(
                  onTap: () => setState(() => observed = !observed),
                  child: Text(
                    observed ? 'OBSERVED' : 'PUBLISHED',
                    style: const TextStyle(
                      fontSize: 8,
                      color: violet,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 1,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 4,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: horizon,
                      onChanged: (v) => setState(() => horizon = v),
                      semanticFormatterCallback: (v) =>
                          v == 1 ? 'Latest evidence' : stamp(cutoff),
                    ),
                  ),
                ),
                Text(
                  horizon == 1 ? 'NOW' : stamp(cutoff),
                  style: const TextStyle(fontSize: 8, color: muted),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => setState(() => english = !english),
                  child: Text(
                    english ? 'EN' : 'ALL LANG',
                    style: const TextStyle(fontSize: 9, color: muted),
                  ),
                ),
              ],
            ),
          ),
          if (chosen == null && playingId != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Linked video is not available in this channel or the current filters.',
                style: const TextStyle(color: gold, fontSize: 12),
              ),
            ),
          if (queue.isEmpty && members.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'No playable videos in the current selection. ',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  if (topOnly)
                    TextButton(
                      onPressed: () => setState(() {
                        topOnly = false;
                        english = false;
                      }),
                      child: const Text('Include smaller creators'),
                    ),
                ],
              ),
            ),
          cards,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Expanded(child: scanLabel(scene, key, cache)),
                if (channel != null) ...[
                  const SizedBox(width: 10),
                  ...((channel['relatedChannelIds'] as List? ?? []).take(
                    compact ? 1 : 3,
                  )).map((id) {
                    final c = (scene['channels'] as List)
                        .cast<Map>()
                        .firstWhere((c) => c['id'] == id);
                    return Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: InkWell(
                        onTap: () => select(c, scene),
                        child: Text(
                          '${c['shortLabel'] ?? c['label']} ↗',
                          style: const TextStyle(fontSize: 9, color: violet),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void choosePlayback(Map scene, String id) {
    setState(() {
      playingId = id;
      playbackState = 'loading';
      revealPlaying = true;
    });
    act('play_media', scene, {'videoId': id});
  }

  Widget mediaCard(
    Map a,
    int index,
    Map? cache,
    bool compact,
    Map scene,
    List<Map> queue,
    bool active,
    double width,
  ) {
    final raw = a['publishedAt'];
    final precise = a['publicationTimePrecision'] != 'day';
    final published = DateTime.tryParse(raw?.toString() ?? '');
    final hours = published == null ? null : now.difference(published).inHours;
    final fresh = precise && hours != null && hours >= 0 && hours < 6;
    final newItem = (cache?['newIds'] as List? ?? []).contains(a['id']);
    final age = raw == null
        ? 'UNDATED'
        : precise
        ? relativeTime(raw, now).toUpperCase()
        : 'SEP ${published?.day} · DATE ONLY';
    return SizedBox(
      width: width,
      child: MediaCardInteraction(
        active: active,
        onTap: () =>
            playable(a) ? choosePlayback(scene, a['id'] as String) : detail(a),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 27,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  active
                      ? (playbackState == 'playing'
                            ? 'NOW PLAYING'
                            : playbackState == 'paused'
                            ? 'PAUSED'
                            : playbackState == 'unavailable'
                            ? 'PLAYBACK UNAVAILABLE'
                            : 'LOADING VIDEO')
                      : playable(a)
                      ? 'PLAY HERE'
                      : 'SOURCE PREVIEW',
                  style: TextStyle(
                    color: active ? mint : muted,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            Expanded(
              child: active
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: mint, width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: ChannelPlayer(
                          key: ValueKey(a['id']),
                          items: queue,
                          initialId: a['id'] as String,
                          onChanged: (id, state) {
                            if (!mounted) return;
                            if (id != playingId) {
                              choosePlayback(scene, id);
                            } else if (state != playbackState) {
                              setState(() => playbackState = state);
                            }
                            if (id == playingId &&
                                scene['playingVideoId'] != id) {
                              act('play_media', scene, {'videoId': id});
                            }
                          },
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: line),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          imageTile(a, radius: 14),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: .1),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: .78),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 9,
                            top: 9,
                            child: badge(age, fresh ? mint : ink),
                          ),
                          Positioned(
                            right: 9,
                            top: 9,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: .65),
                              ),
                              child: Center(
                                child: Text(
                                  newItem ? '•' : '${index + 1}',
                                  style: const TextStyle(fontSize: 9),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: Row(
                              children: [
                                platformMark(a),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    a['publisher'] as String? ?? 'Source',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (a['platform'] == 'YouTube' ||
                                    a['platform'] == 'TikTok')
                                  const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              a['title'] as String,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Text(
              '${a['viewsDisplay'] ?? compactCount(a['views'])} views  ·  ${a['likesDisplay'] ?? compactCount(a['likes'])} likes',
              style: const TextStyle(fontSize: 10, color: ink),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    reviewLabel(a),
                    style: TextStyle(
                      fontSize: 8,
                      color: a['evidenceStatus'] == 'ORIGINAL_POST_INSPECTED'
                          ? mint
                          : muted,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => detail(a),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      'Why ↗',
                      style: TextStyle(fontSize: 9, color: violet),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xee101420),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: color.withValues(alpha: .25)),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 7, color: color, letterSpacing: .7),
    ),
  );
  Widget platformMark(Map a) {
    final p = a['platform'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (p == 'YouTube')
          const Icon(Icons.smart_display, color: Color(0xffff4a64), size: 17)
        else if (p == 'TikTok')
          const Icon(Icons.music_note, color: mint, size: 15)
        else if (p != 'X')
          const Icon(Icons.article_outlined, size: 14, color: Colors.white)
        else
          Text('𝕏', style: const TextStyle(fontSize: 14, color: Colors.white)),
        if (p != 'Web') ...[
          const SizedBox(width: 3),
          Text(
            p as String,
            style: const TextStyle(fontSize: 8, color: Colors.white),
          ),
        ],
      ],
    );
  }

  void detail(Map a) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: panel,
    showDragHandle: true,
    builder: (context) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .88,
        maxWidth: 780,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                platformMark(a),
                const Spacer(),
                IconButton(
                  tooltip: 'Close source detail',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 19),
                ),
              ],
            ),
            SizedBox(
              height: 230,
              width: double.infinity,
              child: imageTile(a, radius: 18),
            ),
            const SizedBox(height: 18),
            Text(
              a['title'] as String,
              style: const TextStyle(fontSize: 23, height: 1.15),
            ),
            const SizedBox(height: 8),
            Text(
              a['publisher'] as String? ?? 'Source',
              style: const TextStyle(color: muted),
            ),
            const SizedBox(height: 16),
            Text(
              '${a['viewsDisplay'] ?? rawCount(a['views'])} Views   ·   ${a['likesDisplay'] ?? rawCount(a['likes'])} Likes',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 5),
            Text(
              '${established(a) ? 'Established creator · ${rawCount(a['creatorSubscribers'])} subscribers\n' : ''}Metrics observed ${stamp(a['metricsObservedAt'])}${a['viewsDisplay'] != null || a['likesDisplay'] != null ? ' · rounded by source' : ''}',
              style: const TextStyle(fontSize: 10, color: muted),
            ),
            const SizedBox(height: 20),
            tiny('WHY IT SURFACES', mint),
            const SizedBox(height: 7),
            Text(
              a['curatedReason'] as String? ??
                  a['why'] as String? ??
                  'Selected for this perspective.',
              style: const TextStyle(height: 1.5, fontSize: 13),
            ),
            const SizedBox(height: 15),
            Text(
              a['limitations'] as String? ?? 'Content review pending.',
              style: const TextStyle(fontSize: 11, color: gold, height: 1.5),
            ),
            const SizedBox(height: 15),
            Text(
              'Published ${a['publishedAt'] ?? 'unknown'}\nFirst seen ${stamp(a['firstObservedAt'])}\n${reviewLabel(a)}\nLanguage ${a['language'] ?? 'unknown'}',
              style: const TextStyle(fontSize: 11, color: muted, height: 1.7),
            ),
            const SizedBox(height: 15),
            SelectableText(
              a['url'] as String? ?? '',
              style: const TextStyle(color: muted, fontSize: 10),
            ),
            const SizedBox(height: 17),
            FilledButton.icon(
              onPressed: () => openSource(a),
              icon: const Icon(Icons.open_in_new, size: 15),
              label: const Text('Open original'),
            ),
          ],
        ),
      ),
    ),
  );
  void allChannels(Map scene) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: panel,
    showDragHandle: true,
    builder: (context) {
      final channels = (scene['channels'] as List)
          .cast<Map>()
          .where(
            (c) =>
                !savedOnly ||
                (scene['followedChannelIds'] as List? ?? []).contains(c['id']),
          )
          .toList();
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * .75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      savedOnly ? 'Saved channels' : 'Choose your rabbit hole',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close channels',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: channels.isEmpty
                  ? const Center(
                      child: Text(
                        'Save a channel to keep it here.',
                        style: TextStyle(color: muted),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(18),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.sizeOf(context).width < 600
                            ? 2
                            : 4,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: channels.length,
                      itemBuilder: (context, i) {
                        final c = channels[i];
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            select(c, scene);
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: imageTile(cover(scene, c)),
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                c['shortLabel'] as String? ??
                                    c['label'] as String,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
  void channelWhy(Map c, Map scene) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: panel,
      title: Text(c['shortLabel'] as String? ?? c['label'] as String),
      content: Text(
        '${c['whyThisChannel']}\n\n${c['programReason']}\n\nOpening this channel triggers a bounded YouTube scan and Astra metadata screen. Cache under two minutes old is reused; provider failures retain the last accepted result.',
        style: const TextStyle(fontSize: 13, height: 1.6),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to discovery'),
        ),
      ],
    ),
  );
  void contextInfo() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: panel,
      title: const Text('Your context'),
      content: const Text(
        'New York City is selected context. English is the default video filter. Worldwide topics come from regional search feeds; they are not geolocated recommendations or a global popularity ranking.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
  void about(Map scene) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: panel,
      title: const Text('Connected moments. Clear evidence.'),
      content: const SingleChildScrollView(
        child: Text(
          'The galaxy ranks one pool from 24 country feeds by the highest reported search-volume bucket, with no country quota. Flags indicate where a signal was observed, not creator nationality. This is not an exact worldwide total; coverage and feed availability limit the ranking. iPhone Duo is the curated showcase, not a claim to be the world’s #1 topic.\n\nChannel previews come from real media. Background stars and orbits are decorative. Channel neighborhoods are editorial groupings. Lines within a neighborhood use recorded related-channel IDs; they do not imply causality or factual agreement. Positions do not encode authority, engagement or time. Use the labeled timeline for time filtering. Mint dots indicate a cache check within 15 minutes; outlined dots mean older or unknown scan time, and amber indicates retained cache after an error.\n\nFreshness: publication age on each card. Scan status: when the cache was checked. Views and Likes: unmodified provider observations. Top signals keeps YouTube videos with 10K+ views or creators with 100K+ subscribers; All signals includes niche finds. Among topical matches, established creators lead, followed by views and likes. Subscriber size is not factual authority. Inline video starts muted; use Unmute for sound and Next to continue. Unknown stays unknown.\n\nAstra screens new YouTube metadata for topic fit. This is not full video verification. TikTok links were discovered through the signed-in browser; hosted TikTok crawling is not enabled.\n\nPublication history is reconstructed. Observed history filters recorded evidence. Current channel definitions are not historical editorial snapshots.',
          style: TextStyle(fontSize: 13, height: 1.6),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Explore'),
        ),
      ],
    ),
  );
}

class SkyPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xff080911));
    final nebula = Rect.fromCenter(
      center: Offset(s.width * .53, s.height * .30),
      width: s.width,
      height: s.height,
    );
    c.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x282c184e), Color(0x18102f31), Colors.transparent],
          stops: [0, .55, 1],
        ).createShader(nebula),
    );
    final r = math.Random(17);
    for (var i = 0; i < 180; i++) {
      final p = Offset(r.nextDouble() * s.width, r.nextDouble() * s.height);
      final radius = r.nextDouble() * 1.05 + .15;
      c.drawCircle(
        p,
        radius,
        Paint()
          ..color = (i % 4 == 0 ? violet : ink).withValues(
            alpha: .12 + r.nextDouble() * .40,
          ),
      );
      if (i % 29 == 0) {
        c.drawLine(
          p - const Offset(3, 0),
          p + const Offset(3, 0),
          Paint()
            ..color = ink.withValues(alpha: .35)
            ..strokeWidth = .5,
        );
        c.drawLine(
          p - const Offset(0, 3),
          p + const Offset(0, 3),
          Paint()
            ..color = ink.withValues(alpha: .35)
            ..strokeWidth = .5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SkyPainter old) => false;
}

class OrbitPainter extends CustomPainter {
  OrbitPainter({
    required this.centre,
    required this.points,
    required this.phase,
    required this.world,
    this.timestamps,
  });
  final Offset centre;
  final List<Offset> points;
  final double phase;
  final bool world;
  final List<DateTime?>? timestamps;
  @override
  void paint(Canvas c, Size s) {
    if (timestamps != null) {
      final rx = s.width * .39, ry = s.height * .38;
      final origin = DateTime.utc(2026, 9, 9);
      for (var hour = 12; hour <= 48; hour += 12) {
        final fraction = .32 + .68 * hour / 48;
        c.drawOval(
          Rect.fromCenter(
            center: centre,
            width: rx * 2 * fraction,
            height: ry * 2 * fraction,
          ),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = violet.withValues(alpha: .15)
            ..strokeWidth = .6,
        );
        final tp = TextPainter(
          text: TextSpan(
            text: '${hour}h',
            style: TextStyle(fontSize: 7, color: muted.withValues(alpha: .75)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(c, Offset(centre.dx + rx * fraction - 12, centre.dy + 2));
      }
      for (var i = 0; i < timestamps!.length; i++) {
        final date = timestamps![i];
        if (date == null) continue;
        final t = (date.difference(origin).inMinutes / (48 * 60)).clamp(
          0.0,
          1.0,
        );
        final anchor = points[i];
        final angle = math.atan2(
          (anchor.dy - centre.dy) / ry,
          (anchor.dx - centre.dx) / rx,
        );
        final p = Offset(
          centre.dx + math.cos(angle) * rx * (.32 + .68 * t),
          centre.dy + math.sin(angle) * ry * (.32 + .68 * t),
        );
        c.drawLine(
          p,
          anchor,
          Paint()
            ..color = mint.withValues(alpha: .25)
            ..strokeWidth = .6,
        );
        c.drawCircle(p, 3, Paint()..color = mint);
        c.drawCircle(p, 7, Paint()..color = mint.withValues(alpha: .10));
      }
      return;
    }
    c.save();
    c.translate(centre.dx, centre.dy);
    c.rotate(-.16);
    for (var i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: s.width * (.40 + i * .17),
        height: s.height * (.38 + i * .20),
      );
      c.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .6
          ..color = violet.withValues(alpha: .10 - i * .017),
      );
    }
    c.restore();
    for (var i = 0; !world && i < points.length; i++) {
      final p = points[i];
      final path = Path()
        ..moveTo(centre.dx, centre.dy)
        ..quadraticBezierTo(
          (centre.dx + p.dx) / 2 + (i.isEven ? 28 : -25),
          (centre.dy + p.dy) / 2 - 28,
          p.dx,
          p.dy,
        );
      c.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = mint.withValues(alpha: .08)
          ..strokeWidth = .7,
      );
      final a = Offset.lerp(centre, p, .55)!;
      c.drawCircle(a, 1, Paint()..color = violet.withValues(alpha: .4));
    }
    final angle = phase * math.pi * 2;
    c.drawCircle(
      Offset(
        centre.dx + math.cos(angle) * s.width * .21,
        centre.dy + math.sin(angle) * s.height * .19,
      ),
      1.7,
      Paint()..color = mint.withValues(alpha: .65),
    );
  }

  @override
  bool shouldRepaint(covariant OrbitPainter old) =>
      old.phase != phase || old.centre != centre || old.points != points;
}

class MediaCardInteraction extends StatelessWidget {
  const MediaCardInteraction({
    super.key,
    required this.active,
    required this.onTap,
    required this.borderRadius,
    required this.child,
  });
  final bool active;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final Widget child;
  @override
  Widget build(BuildContext context) => active
      ? child
      : InkWell(onTap: onTap, borderRadius: borderRadius, child: child);
}
