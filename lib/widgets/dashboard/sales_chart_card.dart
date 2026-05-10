import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'dashboard_models.dart';

/// Premium Sales Chart Card with interactive hover tooltips (optional future enhance),
/// smooth custom painted Bezier curves, and gradient fill.
class SalesChartCard extends StatelessWidget {
  const SalesChartCard({super.key, required this.data});

  final List<SalesPoint> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revenue Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Weekly sales overview across all stores',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD1FAE5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.arrow_upward_rounded, color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 4),
                    Text(
                      '12.8%',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Chart
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: _SalesChartPainter(data),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesChartPainter extends CustomPainter {
  _SalesChartPainter(this.data);

  final List<SalesPoint> data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const leftPadding = 36.0;
    const topPadding = 16.0;
    const bottomPadding = 28.0;
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - topPadding - bottomPadding;
    final maxValue = data.map((point) => point.value).reduce(math.max);
    final safeMax = maxValue == 0 ? 1.0 : maxValue;
    final minValue = 0.0;

    // Grid lines (Dashed effect simulated if we want, currently solid light grey)
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = topPadding + chartHeight * i / 3;
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);
    }

    // Coordinates mapping
    final points = <Offset>[];
    final divisor = data.length > 1 ? data.length - 1 : 1;
    for (var i = 0; i < data.length; i++) {
      final x = leftPadding + (chartWidth / divisor) * i;
      final normalized = (data[i].value - minValue) / (safeMax - minValue);
      final y = topPadding + chartHeight - normalized * chartHeight;
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      // Smooth Bezier Curve Path
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      final fillPath = Path()..moveTo(points.first.dx, topPadding + chartHeight)..lineTo(points.first.dx, points.first.dy);

      for (var i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

        linePath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
        fillPath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
      }

      fillPath.lineTo(points.last.dx, topPadding + chartHeight);
      fillPath.close();

      // Paint Gradient Fill
      final fillPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x332D5BFF), Color(0x002D5BFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, topPadding, size.width, chartHeight));
      canvas.drawPath(fillPath, fillPaint);

      // Paint Line
      final linePaint = Paint()
        ..color = const Color(0xFF2D5BFF)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;

      // Glow effect for line
      final glowPaint = Paint()
        ..color = const Color(0xFF2D5BFF).withOpacity(0.2)
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawPath(linePath, glowPaint);
      canvas.drawPath(linePath, linePaint);
    }

    // Draw Points & Labels
    final dotPaintOuter = Paint()..color = Colors.white;
    final dotPaintInner = Paint()..color = const Color(0xFF2D5BFF);

    final labelStyle = const TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    for (var i = 0; i < data.length; i++) {
      final point = points[i];

      // Dots (white border)
      canvas.drawCircle(point, 6, dotPaintOuter);
      canvas.drawCircle(point, 4, dotPaintInner);

      // X-Axis Labels
      final dayText = _textPainter(data[i].day, labelStyle, maxWidth: 40);
      dayText.paint(
        canvas,
        Offset(point.dx - dayText.width / 2, topPadding + chartHeight + 12),
      );
    }

    // Y-Axis Labels
    final yLabels = [safeMax, safeMax * 0.66, safeMax * 0.33, minValue];
    for (var i = 0; i < yLabels.length; i++) {
      final label = _textPainter(
        yLabels[i].round().toString(),
        labelStyle,
        maxWidth: 32,
      );
      final y = topPadding + chartHeight * i / 3 - label.height / 2;
      label.paint(canvas, Offset(0, y));
    }
  }

  TextPainter _textPainter(String text, TextStyle style, {required double maxWidth}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);
    return painter;
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
