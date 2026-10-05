class Currency {
  final String id;
  final String name;
  final String minSize;

  const Currency({
    required this.id,
    required this.name,
    required this.minSize,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      minSize: json['min_size']?.toString() ?? '',
    );
  }
}

class CurrencyResponse {
  final List<Currency> data;

  const CurrencyResponse({required this.data});

  factory CurrencyResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final items = raw is List ? raw : <dynamic>[];

    return CurrencyResponse(
      data: items
          .whereType<Map>()
          .map(
            (item) => Currency.fromJson(
              item.map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            ),
          )
          .toList(),
    );
  }
}
