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
    final id = (json['id'] ?? json['code'])?.toString() ?? '';

    return Currency(
      id: id.trim().toUpperCase(),
      name: json['name']?.toString() ?? id,
      minSize: _readMinSize(json),
    );
  }

  static String _readMinSize(Map<String, dynamic> json) {
    final explicit = json['min_size']?.toString();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }

    // O endpoint /v2/currencies/crypto informa a precisão por "exponent".
    // Ex.: exponent 8 -> unidade mínima 0.00000001.
    final exponent = int.tryParse(json['exponent']?.toString() ?? '');
    if (exponent == null || exponent <= 0) {
      return '1';
    }

    final zeros = List.filled(exponent - 1, '0').join();
    return '0.${zeros}1';
  }
}

class CurrencyResponse {
  final List<Currency> data;

  const CurrencyResponse({required this.data});

  /// Aceita os dois formatos da Coinbase:
  /// - fiat: { "data": [...] }
  /// - crypto: [ ... ]
  factory CurrencyResponse.fromDynamic(dynamic json) {
    final dynamic raw;

    if (json is List) {
      raw = json;
    } else if (json is Map) {
      raw = json['data'];
    } else {
      raw = const <dynamic>[];
    }

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
          .where((currency) => currency.id.isNotEmpty)
          .toList(),
    );
  }
}
