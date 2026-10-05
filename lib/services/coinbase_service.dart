import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/chart_range.dart';
import '../models/currency.dart';
import '../models/exchange_rates.dart';
import '../models/market_candle.dart';
import 'api_result.dart';

class CoinbaseService {
  static const Map<String, String> _headers = {
    'Accept': 'application/json',
  };

  Future<ApiResult<CurrencyResponse>> fetchCurrencies() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.currencies),
        headers: _headers,
      );

      if (!_successful(response.statusCode)) {
        return ApiResult.failure(
          'Erro HTTP ${response.statusCode} ao consultar moedas.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return ApiResult.failure('Formato de moedas inesperado.');
      }

      return ApiResult.success(
        CurrencyResponse.fromJson(decoded),
        rawJson: _pretty(decoded),
      );
    } catch (error) {
      return ApiResult.failure('Falha ao carregar moedas: $error');
    }
  }

  Future<ApiResult<ExchangeRates>> fetchExchangeRates(
    String currency,
  ) async {
    try {
      final normalized = currency.trim().toUpperCase();
      final uri = Uri.parse(
        '${ApiConstants.exchangeRates}?currency=$normalized',
      );
      final response = await http.get(uri, headers: _headers);

      if (!_successful(response.statusCode)) {
        return ApiResult.failure(
          'Erro HTTP ${response.statusCode} ao consultar cotações.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return ApiResult.failure('Formato de cotações inesperado.');
      }

      return ApiResult.success(
        ExchangeRates.fromJson(decoded),
        rawJson: _pretty(decoded),
      );
    } catch (error) {
      return ApiResult.failure('Falha ao carregar cotações: $error');
    }
  }

  Future<ApiResult<List<MarketCandle>>> fetchCandles({
    required String productId,
    required ChartRange range,
  }) async {
    try {
      final end = DateTime.now().toUtc();
      final start = end.subtract(range.lookback);

      final query = {
        'product_id': productId,
        'start': '${start.millisecondsSinceEpoch ~/ 1000}',
        'end': '${end.millisecondsSinceEpoch ~/ 1000}',
        'granularity': range.granularity,
        'limit': '${range.limit}',
      };

      // O endpoint público de candles funciona em chamadas servidor-servidor e
      // mobile. No Flutter Web, o navegador pode bloquear a resposta por CORS.
      // Por isso, no Web usamos o pequeno proxy Dart incluído em /server.
      final Uri uri = kIsWeb
          ? Uri.parse('${ApiConstants.webCandlesProxy}/api/candles').replace(
              queryParameters: query,
            )
          : Uri.parse(ApiConstants.publicCandles(productId)).replace(
              queryParameters: {
                'start': query['start']!,
                'end': query['end']!,
                'granularity': query['granularity']!,
                'limit': query['limit']!,
              },
            );

      final response = await http.get(uri, headers: _headers);

      if (!_successful(response.statusCode)) {
        String detail = '';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['error'] != null) {
            detail = ' ${body['error']}';
          }
        } catch (_) {}

        return ApiResult.failure(
          'Erro HTTP ${response.statusCode} ao consultar histórico.$detail',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return ApiResult.failure('Formato de histórico inesperado.');
      }

      final rawCandles = decoded['candles'];
      if (rawCandles is! List) {
        return ApiResult.failure('A resposta não contém candles.');
      }

      final candles = rawCandles
          .whereType<Map>()
          .map(
            (item) => MarketCandle.fromAdvancedTradeJson(
              item.map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            ),
          )
          .where((candle) => candle.close > 0)
          .toList()
        ..sort((a, b) => a.time.compareTo(b.time));

      if (candles.isEmpty) {
        return ApiResult.failure(
          'A Coinbase não retornou candles para $productId.',
        );
      }

      return ApiResult.success(
        candles,
        rawJson: _pretty(decoded),
      );
    } catch (error) {
      if (kIsWeb) {
        return ApiResult.failure(
          'Não foi possível carregar o histórico no navegador. '
          'Inicie o proxy local antes do Flutter Web usando '
          'run_web_windows.bat (Windows) ou run_web_unix.sh (macOS/Linux). '
          'Detalhes: $error',
        );
      }

      return ApiResult.failure('Falha ao carregar histórico: $error');
    }
  }

  static bool _successful(int code) => code >= 200 && code < 300;

  static String _pretty(dynamic value) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(value);
  }
}
