import 'package:cotacao_cripto3/models/exchange_rates.dart';
import 'package:cotacao_cripto3/models/market_candle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseia ExchangeRates', () {
    final model = ExchangeRates.fromJson({
      'data': {
        'currency': 'BTC',
        'rates': {'USD': '100.0', 'BRL': '500.0'},
      },
    });

    expect(model.currency, 'BTC');
    expect(model.rate('USD'), 100.0);
  });

  test('parseia MarketCandle', () {
    final candle = MarketCandle.fromAdvancedTradeJson({
      'start': '1700000000',
      'low': '10',
      'high': '15',
      'open': '11',
      'close': '14',
      'volume': '50',
    });

    expect(candle.close, 14);
    expect(candle.volume, 50);
  });
}
