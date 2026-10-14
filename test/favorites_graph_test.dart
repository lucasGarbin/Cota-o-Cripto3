import 'package:cotacao_cripto3/controllers/market_controller.dart';
import 'package:cotacao_cripto3/models/chart_range.dart';
import 'package:cotacao_cripto3/models/currency.dart';
import 'package:cotacao_cripto3/models/exchange_rates.dart';
import 'package:cotacao_cripto3/models/market_candle.dart';
import 'package:cotacao_cripto3/services/api_result.dart';
import 'package:cotacao_cripto3/services/coinbase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeCoinbaseService extends CoinbaseService {
  final List<String> requestedProducts = [];

  @override
  Future<ApiResult<Map<String, String>>> fetchUsdProducts() async {
    return ApiResult.success({
      'BTC': 'BTC-USD',
      'ETH': 'ETH-USD',
      'ADA': 'ADA-USD',
    });
  }

  @override
  Future<ApiResult<CurrencyResponse>> fetchCurrencies() async {
    return ApiResult.success(
      const CurrencyResponse(
        data: [
          Currency(id: 'BTC', name: 'Bitcoin', minSize: '0.00000001'),
          Currency(id: 'ETH', name: 'Ethereum', minSize: '0.00000001'),
          Currency(id: 'ADA', name: 'Cardano', minSize: '0.000001'),
          Currency(id: 'XYZ', name: 'Sem mercado USD', minSize: '0.000001'),
        ],
      ),
    );
  }

  @override
  Future<ApiResult<CurrencyResponse>> fetchFiatCurrencies() async {
    return ApiResult.success(
      const CurrencyResponse(
        data: [
          Currency(id: 'BRL', name: 'Brazilian Real', minSize: '0.01'),
          Currency(id: 'USD', name: 'US Dollar', minSize: '0.01'),
        ],
      ),
    );
  }

  @override
  Future<ApiResult<ExchangeRates>> fetchExchangeRates(String currency) async {
    return ApiResult.success(
      ExchangeRates(
        currency: currency,
        rates: const {
          'USD': '1',
          'BRL': '5',
        },
      ),
    );
  }

  @override
  Future<ApiResult<List<MarketCandle>>> fetchCandles({
    required String productId,
    required ChartRange range,
  }) async {
    requestedProducts.add(productId);

    return ApiResult.success([
      MarketCandle(
        time: DateTime.utc(2026, 10, 1),
        low: 1,
        high: 2,
        open: 1,
        close: 1,
        volume: 10,
      ),
      MarketCandle(
        time: DateTime.utc(2026, 10, 2),
        low: 1,
        high: 3,
        open: 1,
        close: 2,
        volume: 12,
      ),
    ]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('remove favorito antigo sem mercado USD ao iniciar', () async {
    SharedPreferences.setMockInitialValues({
      'favorite_assets_v1': ['BTC', 'XYZ', 'BRL'],
    });

    final service = FakeCoinbaseService();
    final controller = MarketController(service: service);

    await controller.initialize();

    expect(controller.favoriteAssets, ['BTC']);
    expect(controller.currencies.map((e) => e.id), ['ADA', 'BTC', 'ETH']);
    expect(controller.productId, 'BTC-USD');
  });

  test('favoritar e selecionar moeda usa o product_id correto no gráfico',
      () async {
    SharedPreferences.setMockInitialValues({
      'favorite_assets_v1': ['BTC'],
    });

    final service = FakeCoinbaseService();
    final controller = MarketController(service: service);

    await controller.initialize();
    await controller.toggleFavorite('ADA');
    await controller.selectAsset('ADA');

    expect(controller.isFavorite('ADA'), isTrue);
    expect(controller.selectedAsset, 'ADA');
    expect(controller.productId, 'ADA-USD');
    expect(service.requestedProducts.last, 'ADA-USD');
    expect(controller.candles, isNotEmpty);
  });

  test('desfavoritar moeda selecionada troca para outra favorita e atualiza gráfico',
      () async {
    SharedPreferences.setMockInitialValues({
      'favorite_assets_v1': ['BTC', 'ADA'],
    });

    final service = FakeCoinbaseService();
    final controller = MarketController(service: service);

    await controller.initialize();
    await controller.selectAsset('ADA');
    await controller.toggleFavorite('ADA');

    expect(controller.isFavorite('ADA'), isFalse);
    expect(controller.selectedAsset, 'BTC');
    expect(controller.productId, 'BTC-USD');
    expect(service.requestedProducts.last, 'BTC-USD');
  });

  test('ativo sem mercado USD não pode entrar nos favoritos', () async {
    SharedPreferences.setMockInitialValues({
      'favorite_assets_v1': ['BTC'],
    });

    final controller = MarketController(
      service: FakeCoinbaseService(),
    );

    await controller.initialize();
    await controller.toggleFavorite('XYZ');

    expect(controller.isFavorite('XYZ'), isFalse);
  });
}
