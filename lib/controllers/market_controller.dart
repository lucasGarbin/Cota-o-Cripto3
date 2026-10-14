import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chart_range.dart';
import '../models/currency.dart';
import '../models/exchange_rates.dart';
import '../models/market_candle.dart';
import '../services/coinbase_service.dart';

class MarketController extends ChangeNotifier {
  final CoinbaseService _service;

  MarketController({CoinbaseService? service})
      : _service = service ?? CoinbaseService();

  static const String _favoritesKey = 'favorite_assets_v1';
  static const List<String> _defaultFavorites = [
    'BTC',
    'ETH',
    'SOL',
    'ADA',
    'LINK',
  ];

  String _selectedAsset = 'BTC';
  ChartRange _range = ChartRange.week;
  List<String> _favoriteAssets = List<String>.from(_defaultFavorites);
  List<Currency> _currencies = const [];
  Map<String, String> _usdProducts = const {};
  Map<String, String> _currencyNames = const {};
  ExchangeRates? _exchangeRates;
  List<MarketCandle> _candles = const [];

  String _currenciesJson = '';
  String _ratesJson = '';
  String _candlesJson = '';

  bool _loadingCurrencies = false;
  bool _loadingRates = false;
  bool _loadingCandles = false;

  String? _currenciesError;
  String? _ratesError;
  String? _candlesError;

  String get selectedAsset => _selectedAsset;
  String get productId =>
      _usdProducts[_selectedAsset] ?? '$_selectedAsset-USD';
  ChartRange get range => _range;
  List<String> get favoriteAssets => List.unmodifiable(_favoriteAssets);
  List<Currency> get currencies => _currencies;
  ExchangeRates? get exchangeRates => _exchangeRates;
  List<MarketCandle> get candles => _candles;

  String get currenciesJson => _currenciesJson;
  String get ratesJson => _ratesJson;
  String get candlesJson => _candlesJson;

  bool get loadingCurrencies => _loadingCurrencies;
  bool get loadingRates => _loadingRates;
  bool get loadingCandles => _loadingCandles;
  bool get loadingMarket => _loadingRates || _loadingCandles;

  String? get currenciesError => _currenciesError;
  String? get ratesError => _ratesError;
  String? get candlesError => _candlesError;

  double? get currentUsd => _exchangeRates?.rate('USD');
  double? get currentBrl => _exchangeRates?.rate('BRL');
  double? get currentEur => _exchangeRates?.rate('EUR');

  List<String> get destinationCurrencies {
    final codes = _exchangeRates?.rates.keys
            .map((code) => code.trim().toUpperCase())
            .where((code) => code.isNotEmpty)
            .toSet()
            .toList() ??
        <String>[];

    codes.sort();
    return codes;
  }

  double? get firstClose =>
      _candles.isEmpty ? null : _candles.first.close;

  double? get lastClose =>
      _candles.isEmpty ? null : _candles.last.close;

  double? get periodChangePercent {
    final first = firstClose;
    final last = lastClose;

    if (first == null || last == null || first == 0) {
      return null;
    }

    return ((last - first) / first) * 100;
  }

  Future<void> initialize() async {
    await _loadFavorites();
    await loadCurrencies();

    _sanitizeFavorites();

    if (_favoriteAssets.isNotEmpty &&
        !_favoriteAssets.contains(_selectedAsset)) {
      _selectedAsset = _favoriteAssets.first;
    }

    await _saveFavorites();
    notifyListeners();
    await refreshMarket();
  }

  Future<void> _loadFavorites() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getStringList(_favoritesKey);

      if (saved == null) {
        _favoriteAssets = List<String>.from(_defaultFavorites);
        return;
      }

      _favoriteAssets = saved
          .map((asset) => asset.trim().toUpperCase())
          .where((asset) => asset.isNotEmpty)
          .toSet()
          .toList();
    } catch (_) {
      _favoriteAssets = List<String>.from(_defaultFavorites);
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(_favoritesKey, _favoriteAssets);
    } catch (_) {
      // Favoritos continuam funcionando em memória caso a persistência falhe.
    }
  }

  void _sanitizeFavorites() {
    if (_usdProducts.isEmpty) {
      return;
    }

    _favoriteAssets = _favoriteAssets
        .where((asset) => _usdProducts.containsKey(asset))
        .toSet()
        .toList();

    if (_favoriteAssets.isNotEmpty) {
      return;
    }

    final defaults = _defaultFavorites
        .where((asset) => _usdProducts.containsKey(asset))
        .toList();

    if (defaults.isNotEmpty) {
      _favoriteAssets = defaults;
      return;
    }

    _favoriteAssets = _usdProducts.keys.take(5).toList();
  }

  bool isFavorite(String asset) {
    return _favoriteAssets.contains(asset.trim().toUpperCase());
  }

  bool canShowChart(String asset) {
    return _usdProducts.containsKey(asset.trim().toUpperCase());
  }

  Future<void> toggleFavorite(String asset) async {
    final normalized = asset.trim().toUpperCase();
    if (normalized.isEmpty || !canShowChart(normalized)) {
      return;
    }

    final wasFavorite = _favoriteAssets.contains(normalized);

    if (wasFavorite) {
      _favoriteAssets.remove(normalized);
    } else {
      _favoriteAssets.add(normalized);
    }

    // Se a moeda selecionada foi removida, muda para outra favorita válida
    // antes de redesenhar o Dashboard. Assim não existe um estado intermediário
    // com um ativo selecionado que já não pertence aos atalhos.
    final removedSelected =
        wasFavorite && normalized == _selectedAsset;

    if (removedSelected && _favoriteAssets.isNotEmpty) {
      _selectedAsset = _favoriteAssets.first;
      _exchangeRates = null;
      _candles = const [];
      _ratesError = null;
      _candlesError = null;
    }

    await _saveFavorites();
    notifyListeners();

    if (removedSelected && _favoriteAssets.isNotEmpty) {
      await refreshMarket();
    }
  }

  String? currencyName(String code) {
    return _currencyNames[code.trim().toUpperCase()];
  }

  Future<void> loadCurrencies() async {
    _loadingCurrencies = true;
    _currenciesError = null;
    notifyListeners();

    final productsResult = await _service.fetchUsdProducts();
    final cryptoResult = await _service.fetchCurrencies();
    final fiatResult = await _service.fetchFiatCurrencies();

    _loadingCurrencies = false;

    if (!productsResult.isSuccess) {
      _currenciesError = productsResult.error;
      _usdProducts = const {};
      notifyListeners();
      return;
    }

    _usdProducts = productsResult.data!;

    if (!cryptoResult.isSuccess) {
      _currenciesError = cryptoResult.error;
      notifyListeners();
      return;
    }

    // A tela Moedas exibe somente criptomoedas para as quais existe um
    // produto SPOT em USD. Portanto, qualquer moeda favoritada daqui possui
    // um product_id válido para o endpoint de candles.
    _currencies = cryptoResult.data!.data
        .where((currency) => _usdProducts.containsKey(currency.id))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    _currenciesJson = cryptoResult.rawJson;

    final names = <String, String>{};
    for (final currency in cryptoResult.data!.data) {
      names[currency.id] = currency.name;
    }
    if (fiatResult.isSuccess) {
      for (final currency in fiatResult.data!.data) {
        names[currency.id] = currency.name;
      }
    }
    _currencyNames = names;

    _sanitizeFavorites();
    notifyListeners();
  }

  Future<void> refreshMarket() async {
    await Future.wait([
      loadRates(),
      loadCandles(),
    ]);
  }

  Future<void> loadRates() async {
    final assetAtRequestStart = _selectedAsset;

    _loadingRates = true;
    _ratesError = null;
    notifyListeners();

    final result = await _service.fetchExchangeRates(assetAtRequestStart);

    // Ignora uma resposta antiga caso o usuário tenha trocado de favorito
    // antes da requisição terminar.
    if (assetAtRequestStart != _selectedAsset) {
      return;
    }

    _loadingRates = false;
    if (result.isSuccess) {
      _exchangeRates = result.data;
      _ratesJson = result.rawJson;
    } else {
      _ratesError = result.error;
    }
    notifyListeners();
  }

  Future<void> loadCandles() async {
    final assetAtRequestStart = _selectedAsset;
    final rangeAtRequestStart = _range;
    final productAtRequestStart = productId;

    if (!canShowChart(assetAtRequestStart)) {
      _candles = const [];
      _candlesError =
          'Histórico indisponível para $assetAtRequestStart em USD.';
      _loadingCandles = false;
      notifyListeners();
      return;
    }

    _loadingCandles = true;
    _candlesError = null;
    notifyListeners();

    final result = await _service.fetchCandles(
      productId: productAtRequestStart,
      range: rangeAtRequestStart,
    );

    // Evita que uma resposta de um favorito anterior sobrescreva o gráfico
    // da moeda atualmente selecionada.
    if (assetAtRequestStart != _selectedAsset ||
        rangeAtRequestStart != _range) {
      return;
    }

    _loadingCandles = false;
    if (result.isSuccess) {
      _candles = result.data!;
      _candlesJson = result.rawJson;
    } else {
      _candles = const [];
      _candlesError = result.error;
    }
    notifyListeners();
  }

  Future<void> selectAsset(String asset) async {
    final normalized = asset.trim().toUpperCase();
    if (normalized.isEmpty || normalized == _selectedAsset) {
      return;
    }

    _selectedAsset = normalized;
    _exchangeRates = null;
    _candles = const [];
    _ratesError = null;
    _candlesError = null;
    notifyListeners();
    await refreshMarket();
  }

  Future<void> selectRange(ChartRange range) async {
    if (_range == range) {
      return;
    }

    _range = range;
    notifyListeners();
    await loadCandles();
  }

  double? conversionValue({
    required double amount,
    required String target,
  }) {
    final rate = _exchangeRates?.rate(target);
    if (rate == null) {
      return null;
    }
    return rate * amount;
  }
}
