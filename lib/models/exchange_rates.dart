class ExchangeRates {
  final String currency;
  final Map<String, String> rates;

  const ExchangeRates({
    required this.currency,
    required this.rates,
  });

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    if (rawData is! Map) {
      return const ExchangeRates(currency: '', rates: {});
    }

    final data = rawData.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    final rawRates = data['rates'];
    final parsedRates = <String, String>{};

    if (rawRates is Map) {
      for (final entry in rawRates.entries) {
        parsedRates[entry.key.toString()] = entry.value.toString();
      }
    }

    return ExchangeRates(
      currency: data['currency']?.toString() ?? '',
      rates: parsedRates,
    );
  }

  double? rate(String code) => double.tryParse(rates[code] ?? '');
}
