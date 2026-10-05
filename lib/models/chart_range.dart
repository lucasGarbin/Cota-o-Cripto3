enum ChartRange {
  day,
  week,
  month,
  quarter,
}

extension ChartRangeExtension on ChartRange {
  String get label {
    switch (this) {
      case ChartRange.day:
        return '24H';
      case ChartRange.week:
        return '7D';
      case ChartRange.month:
        return '30D';
      case ChartRange.quarter:
        return '90D';
    }
  }

  Duration get lookback {
    switch (this) {
      case ChartRange.day:
        return const Duration(hours: 24);
      case ChartRange.week:
        return const Duration(days: 7);
      case ChartRange.month:
        return const Duration(days: 30);
      case ChartRange.quarter:
        return const Duration(days: 90);
    }
  }

  String get granularity {
    switch (this) {
      case ChartRange.day:
      case ChartRange.week:
        return 'ONE_HOUR';
      case ChartRange.month:
        return 'SIX_HOUR';
      case ChartRange.quarter:
        return 'ONE_DAY';
    }
  }

  int get limit {
    switch (this) {
      case ChartRange.day:
        return 30;
      case ChartRange.week:
        return 180;
      case ChartRange.month:
        return 140;
      case ChartRange.quarter:
        return 100;
    }
  }
}
