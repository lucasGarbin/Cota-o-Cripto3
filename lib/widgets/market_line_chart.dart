import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/chart_range.dart';
import '../models/market_candle.dart';
import '../painters/line_chart_painter.dart';

class MarketLineChart extends StatefulWidget {
  final List<MarketCandle> candles;
  final ChartRange range;

  const MarketLineChart({
    super.key,
    required this.candles,
    required this.range,
  });

  @override
  State<MarketLineChart> createState() => _MarketLineChartState();
}

class _MarketLineChartState extends State<MarketLineChart> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant MarketLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candles != widget.candles) {
      _selectedIndex = null;
    }
  }

  void _selectFromDx(double dx, double width) {
    if (widget.candles.isEmpty || width <= 0) {
      return;
    }

    final ratio = (dx / width).clamp(0.0, 1.0);
    final index = (ratio * (widget.candles.length - 1)).round();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final candles = widget.candles;
    final selected = _selectedIndex == null || candles.isEmpty
        ? null
        : candles[_selectedIndex!];

    final color = Theme.of(context).colorScheme.primary;
    final gridColor = Theme.of(context).dividerColor.withOpacity(0.45);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: selected == null
              ? const SizedBox(height: 42)
              : SizedBox(
                  key: ValueKey(selected.time),
                  height: 42,
                  child: Row(
                    children: [
                      Text(
                        Formatters.usd(selected.close),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        Formatters.dateTimeLabel(
                          selected.time,
                          includeDate: widget.range != ChartRange.day,
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
        ),
        SizedBox(
          height: 250,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  _selectFromDx(
                    details.localPosition.dx,
                    constraints.maxWidth,
                  );
                },
                onPanStart: (details) {
                  _selectFromDx(
                    details.localPosition.dx,
                    constraints.maxWidth,
                  );
                },
                onPanUpdate: (details) {
                  _selectFromDx(
                    details.localPosition.dx,
                    constraints.maxWidth,
                  );
                },
                onPanEnd: (_) {
                  setState(() {
                    _selectedIndex = null;
                  });
                },
                child: MouseRegion(
                  onHover: (event) {
                    _selectFromDx(
                      event.localPosition.dx,
                      constraints.maxWidth,
                    );
                  },
                  onExit: (_) {
                    setState(() {
                      _selectedIndex = null;
                    });
                  },
                  child: CustomPaint(
                    painter: LineChartPainter(
                      candles: candles,
                      lineColor: color,
                      gridColor: gridColor,
                      fillColor: AppTheme.yellowSoft.withOpacity(0.18),
                      selectedIndex: _selectedIndex,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        if (candles.isNotEmpty)
          Row(
            children: [
              Text(
                Formatters.dateTimeLabel(
                  candles.first.time,
                  includeDate: true,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                Formatters.dateTimeLabel(
                  candles.last.time,
                  includeDate: true,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
