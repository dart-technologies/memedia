Uri explorerRoute(Uri base, {String? topic, String? channel, String? video}) {
  final query = {...base.queryParameters}
    ..remove('channel')
    ..remove('topic')
    ..remove('video');
  if (channel != null) {
    query['channel'] = channel;
  } else if (topic != null) {
    query['topic'] = topic;
  }
  if (video != null && (channel != null || topic != null)) {
    query['video'] = video;
  }
  final result = base.replace(queryParameters: query).removeFragment();
  return query.isEmpty ? Uri.parse(result.toString().split('?').first) : result;
}
