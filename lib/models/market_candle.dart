class MarketCandle {
  final DateTime time;
  final double low;
  final double high;
  final double open;
  final double close;
  final double volume;

  const MarketCandle({
    required this.time,
    required this.low,
    required this.high,
    required this.open,
    required this.close,
    required this.volume,
  });

  factory MarketCandle.fromAdvancedTradeJson(
    Map<String, dynamic> json,
  ) {
    final seconds = int.tryParse(json['start']?.toString() ?? '') ?? 0;

    return MarketCandle(
      time: DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000,
        isUtc: true,
      ),
      low: double.tryParse(json['low']?.toString() ?? '') ?? 0,
      high: double.tryParse(json['high']?.toString() ?? '') ?? 0,
      open: double.tryParse(json['open']?.toString() ?? '') ?? 0,
      close: double.tryParse(json['close']?.toString() ?? '') ?? 0,
      volume: double.tryParse(json['volume']?.toString() ?? '') ?? 0,
    );
  }
}
