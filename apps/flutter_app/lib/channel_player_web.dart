import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';

extension type FrameElement(JSObject _) implements JSObject {
  external void setAttribute(JSString name, JSString value);
}

@JS('memediaRegisterPlayer')
external void _registerPlayer(JSFunction handler);
@JS('memediaUpdatePlayer')
external void _updatePlayer(JSString queue);

class ChannelPlayer extends StatefulWidget {
  const ChannelPlayer({
    super.key,
    required this.items,
    required this.initialId,
    required this.onChanged,
  });
  final List<Map> items;
  final String initialId;
  final void Function(String, String) onChanged;
  @override
  State<ChannelPlayer> createState() => _ChannelPlayerState();
}

class _ChannelPlayerState extends State<ChannelPlayer> {
  late final String source;
  @override
  void initState() {
    super.initState();
    _registerPlayer(
      ((JSString id, JSString state) {
        if (mounted) widget.onChanged(id.toDart, state.toDart);
      }).toJS,
    );
    final queue = widget.items
        .map(
          (a) => {
            'id': a['id'],
            'title': a['title'],
            'platform': a['platform'],
          },
        )
        .toList();
    source = Uri.base
        .resolve('channel-player.html')
        .replace(
          fragment: jsonEncode({'items': queue, 'startId': widget.initialId}),
        )
        .toString();
  }

  @override
  void didUpdateWidget(covariant ChannelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (jsonEncode(oldWidget.items) != jsonEncode(widget.items)) {
      _updatePlayer(
        jsonEncode(
          widget.items
              .map(
                (a) => {
                  'id': a['id'],
                  'title': a['title'],
                  'platform': a['platform'],
                },
              )
              .toList(),
        ).toJS,
      );
    }
  }

  @override
  Widget build(BuildContext context) => HtmlElementView.fromTagName(
    tagName: 'iframe',
    onElementCreated: (element) {
      final frame = FrameElement(element as JSObject);
      frame.setAttribute('data-memedia-player'.toJS, 'true'.toJS);
      frame.setAttribute('src'.toJS, source.toJS);
      frame.setAttribute('title'.toJS, 'MeMedia channel player'.toJS);
      frame.setAttribute(
        'allow'.toJS,
        'autoplay; fullscreen; encrypted-media; picture-in-picture'.toJS,
      );
      frame.setAttribute(
        'style'.toJS,
        'width:100%;height:100%;border:0;border-radius:12px;background:#080a11'
            .toJS,
      );
    },
  );
}
