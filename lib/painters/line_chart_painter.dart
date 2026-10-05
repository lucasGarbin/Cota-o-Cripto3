import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/market_candle.dart';

class LineChartPainter extends CustomPainter {
  final List<MarketCandle> candles;
  final Color lineColor;
  final Color gridColor;
  final Color fillColor;
  final int? selectedIndex;

  LineChartPainter({
    required this.candles,
    required this.lineColor,
    required this.gridColor,
    required this.fillColor,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.length < 2 || size.width <= 0 || size.height <= 0) {
      return;
    }

    const topPadding = 10.0;
    const bottomPadding = 12.0;
    final chartHeight = size.height - topPadding - bottomPadding;

    final values = candles.map((item) => item.close).toList();
    var minValue = values.reduce(math.min);
    var maxValue = values.reduce(math.max);

    if ((maxValue - minValue).abs() < 0.000001) {
      minValue -= 1;
      maxValue += 1;
    }

    final verticalPadding = (maxValue - minValue) * 0.08;
    minValue -= verticalPadding;
    maxValue += verticalPadding;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int index = 0; index <= 4; index++) {
      final y = topPadding + (chartHeight * index / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    Offset pointForIndex(int index) {
      final x = size.width * index / (candles.length - 1);
      final normalized =
          (candles[index].close - minValue) / (maxValue - minValue);
      final y = topPadding + chartHeight * (1 - normalized);
      return Offset(x, y);
    }

    final linePath = Path();
    for (int index = 0; index < candles.length; index++) {
      final point = pointForIndex(index);
      if (index == 0) {
        linePath.moveTo(point.dx, point.dy);
      } else {
        linePath.lineTo(point.dx, point.dy);
      }
    }

    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height - bottomPadding)
      ..lineTo(0, size.height - bottomPadding)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          fillColor,
          fillColor.withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < candles.length) {
      final selectedPoint = pointForIndex(selectedIndex!);
      final guidePaint = Paint()
        ..color = lineColor.withOpacity(0.35)
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(selectedPoint.dx, topPadding),
        Offset(selectedPoint.dx, size.height - bottomPadding),
        guidePaint,
      );

      final outerPaint = Paint()..color = lineColor.withOpacity(0.20);
      final innerPaint = Paint()..color = lineColor;
      canvas.drawCircle(selectedPoint, 8, outerPaint);
      canvas.drawCircle(selectedPoint, 4, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
