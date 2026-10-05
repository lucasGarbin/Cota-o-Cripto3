class Formatters {
  Formatters._();

  static String number(double value, {int decimals = 2}) {
    final negative = value < 0;
    final absolute = value.abs();
    final fixed = absolute.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final integer = parts.first;
    final reversed = integer.split('').reversed.toList();
    final grouped = <String>[];

    for (int index = 0; index < reversed.length; index++) {
      if (index > 0 && index % 3 == 0) {
        grouped.add('.');
      }
      grouped.add(reversed[index]);
    }

    final integerFormatted = grouped.reversed.join();
    final decimal = decimals > 0 ? ',${parts.last}' : '';

    return '${negative ? '-' : ''}$integerFormatted$decimal';
  }

  static String usd(double value) => 'US\$ ${number(value)}';

  static String brl(double value) => 'R\$ ${number(value)}';

  static String compact(double value) {
    final absolute = value.abs();

    if (absolute >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (absolute >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (absolute >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toStringAsFixed(2);
  }

  static String percent(double value) {
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  static String dateTimeLabel(DateTime value, {required bool includeDate}) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    if (!includeDate) {
      return '$hour:$minute';
    }

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}
