import 'package:flutter/material.dart';

class ChannelPlayer extends StatelessWidget {
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
  Widget build(BuildContext context) =>
      const Center(child: Text('Inline channel player'));
}
