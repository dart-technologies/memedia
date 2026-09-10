import 'package:flutter/material.dart';

class ChannelPlayer extends StatelessWidget {
  const ChannelPlayer({super.key, required this.items});
  final List<Map> items;
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Inline channel player'));
}
