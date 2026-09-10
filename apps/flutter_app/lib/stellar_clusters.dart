import 'dart:math' as math;

import 'package:flutter/material.dart';

const _text = Color(0xfff2f1f8), _quiet = Color(0xff9899b0);

/// Stable editorial neighborhoods. Refreshes change their contents, not slots.
class TopicCluster extends StatelessWidget {
  const TopicCluster({
    super.key,
    required this.label,
    required this.reason,
    required this.color,
    required this.channels,
    required this.previews,
    required this.related,
    required this.onExplain,
  });
  final String label, reason;
  final Color color;
  final List<Map> channels;
  final List<Widget> previews;
  final bool Function(Map, Map) related;
  final VoidCallback onExplain;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final n = previews.length;
      final width = (box.maxWidth / math.max(n, 1) - 8).clamp(70.0, 140.0);
      final points = List.generate(
        n,
        (i) => Offset(box.maxWidth * (i + .5) / n, i == 1 ? 112 : 86),
      );
      final edges = <(Offset, Offset)>[];
      for (var i = 0; i < n; i++) {
        for (var j = i + 1; j < n; j++) {
          if (related(channels[i], channels[j])) {
            edges.add((points[i], points[j]));
          }
        }
      }
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: RelationshipLinks(
                edges: edges,
                color: color,
                glow: true,
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 0,
            right: 8,
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Tooltip(
                  message: reason,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Why $label',
                    onPressed: onExplain,
                    icon: const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: _quiet,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < n; i++)
            Positioned(
              left: points[i].dx - width / 2,
              top: points[i].dy - 46,
              width: width,
              height: 140,
              child: previews[i],
            ),
        ],
      );
    },
  );
}

/// Three actual media previews, never placeholder cards posing as evidence.
class ChannelPreview extends StatefulWidget {
  const ChannelPreview({
    super.key,
    required this.label,
    required this.color,
    required this.images,
    required this.sourceMark,
    required this.status,
    required this.freshness,
    required this.onOpen,
    required this.onExplain,
    required this.explanation,
  });
  final String label, status, explanation;
  final Color color;
  final List<Widget> images;
  final Widget sourceMark, freshness;
  final VoidCallback onOpen, onExplain;
  @override
  State<ChannelPreview> createState() => _ChannelPreviewState();
}

class _ChannelPreviewState extends State<ChannelPreview> {
  bool hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hover = true),
    onExit: (_) => setState(() => hover = false),
    child: Column(
      children: [
        Semantics(
          button: true,
          label: 'Channel ${widget.label}',
          child: InkWell(
            onTap: widget.onOpen,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              transform: Matrix4.translationValues(0, hover ? -4 : 0, 0),
              height: 85,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var i = widget.images.length - 1; i >= 0; i--)
                    Positioned(
                      left: 5 + i * 6,
                      right: 8 - i * 2,
                      top: 10.0 - i * 4,
                      bottom: 0.0 + i * 4,
                      child: Transform.rotate(
                        angle: i == 0 ? 0 : (i == 1 ? -.10 : .10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: widget.color.withValues(
                                alpha: hover ? .85 : .38,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withValues(
                                  alpha: hover ? .18 : .07,
                                ),
                                blurRadius: 22,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2),
                          child: widget.images[i],
                        ),
                      ),
                    ),
                  Positioned(
                    left: 10,
                    bottom: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .8),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: widget.sourceMark,
                    ),
                  ),
                  Positioned(right: 3, top: 2, child: widget.freshness),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        InkWell(
          onTap: widget.onOpen,
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: _text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Tooltip(
          message: widget.explanation,
          child: InkWell(
            onTap: widget.onExplain,
            child: Text(
              '${widget.status} · Why ↗',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 8, color: _quiet),
            ),
          ),
        ),
      ],
    ),
  );
}

class FreshnessMarker extends StatelessWidget {
  const FreshnessMarker({
    super.key,
    required this.scanning,
    required this.recent,
    required this.retained,
    required this.description,
  });
  final bool scanning, recent, retained;
  final String description;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: description,
    child: Semantics(
      label: description,
      child: Container(
        width: 12,
        height: 12,
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Color(0xff10121b),
          shape: BoxShape.circle,
        ),
        child: scanning
            ? const CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Color(0xffb7f5df),
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: retained
                      ? const Color(0xffffd5a7)
                      : recent
                      ? const Color(0xffb7f5df)
                      : Colors.transparent,
                  border: Border.all(
                    color: retained
                        ? const Color(0xffffd5a7)
                        : recent
                        ? const Color(0xffb7f5df)
                        : _quiet,
                  ),
                ),
              ),
      ),
    ),
  );
}

class RelationshipLinks extends CustomPainter {
  RelationshipLinks({
    required this.edges,
    required this.color,
    this.glow = false,
  });
  final List<(Offset, Offset)> edges;
  final Color color;
  final bool glow;
  @override
  void paint(Canvas canvas, Size size) {
    if (glow) {
      final bounds = Offset.zero & size;
      canvas.drawRect(
        bounds,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: .09),
              color.withValues(alpha: .02),
              Colors.transparent,
            ],
            stops: const [0, .65, 1],
          ).createShader(bounds),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: bounds.center,
          width: size.width * .96,
          height: size.height * .67,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color.withValues(alpha: .07),
      );
    }
    for (final (a, b) in edges) {
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(
          (a.dx + b.dx) / 2,
          math.max(a.dy, b.dy) + 30,
          b.dx,
          b.dy,
        );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8
          ..color = color.withValues(alpha: .35),
      );
      final midpoint = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 + 15);
      canvas.drawCircle(
        midpoint,
        2,
        Paint()..color = color.withValues(alpha: .65),
      );
    }
  }

  @override
  bool shouldRepaint(covariant RelationshipLinks oldDelegate) =>
      oldDelegate.edges != edges || oldDelegate.color != color;
}
