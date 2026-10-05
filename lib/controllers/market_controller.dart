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
  String get productId => '$_selectedAsset-USD';
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

    if (_favoriteAssets.isNotEmpty &&
        !_favoriteAssets.contains(_selectedAsset)) {
      _selectedAsset = _favoriteAssets.first;
    }

    await Future.wait([
      loadCurrencies(),
      refreshMarket(),
    ]);
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

  bool isFavorite(String asset) {
    return _favoriteAssets.contains(asset.trim().toUpperCase());
  }

  Future<void> toggleFavorite(String asset) async {
    final normalized = asset.trim().toUpperCase();
    if (normalized.isEmpty) return;

    final wasFavorite = _favoriteAssets.contains(normalized);

    if (wasFavorite) {
      _favoriteAssets.remove(normalized);
    } else {
      _favoriteAssets.add(normalized);
    }

    await _saveFavorites();
    notifyListeners();

    // Se a moeda selecionada deixou de ser favorita, seleciona a primeira
    // favorita restante para manter os atalhos do Dashboard coerentes.
    if (wasFavorite &&
        normalized == _selectedAsset &&
        _favoriteAssets.isNotEmpty) {
      await selectAsset(_favoriteAssets.first);
    }
  }

  String? currencyName(String code) {
    final normalized = code.trim().toUpperCase();

    for (final currency in _currencies) {
      if (currency.id.toUpperCase() == normalized) {
        return currency.name;
      }
    }

    return null;
  }

  Future<void> loadCurrencies() async {
    _loadingCurrencies = true;
    _currenciesError = null;
    notifyListeners();

    final result = await _service.fetchCurrencies();

    _loadingCurrencies = false;
    if (result.isSuccess) {
      _currencies = result.data!.data;
      _currenciesJson = result.rawJson;
    } else {
      _currenciesError = result.error;
    }
    notifyListeners();
  }

  Future<void> refreshMarket() async {
    await Future.wait([
      loadRates(),
      loadCandles(),
    ]);
  }

  Future<void> loadRates() async {
    _loadingRates = true;
    _ratesError = null;
    notifyListeners();

    final result = await _service.fetchExchangeRates(_selectedAsset);

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
    _loadingCandles = true;
    _candlesError = null;
    notifyListeners();

    final result = await _service.fetchCandles(
      productId: productId,
      range: _range,
    );

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
