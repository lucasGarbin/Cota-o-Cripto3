class ApiConstants {
  ApiConstants._();

  static const String currencies =
      'https://api.coinbase.com/v2/currencies';

  static const String exchangeRates =
      'https://api.coinbase.com/v2/exchange-rates';

  static const String publicBrokerageBase =
      'https://api.coinbase.com/api/v3/brokerage/market';

  static String publicCandles(String productId) =>
      '$publicBrokerageBase/products/$productId/candles';

  /// No Flutter Web, o browser não consegue ler diretamente algumas respostas
  /// da API de mercado por política de CORS. O proxy local incluído no projeto
  /// faz a chamada servidor-servidor e devolve a resposta ao navegador.
  ///
  /// Em produção, substitua com:
  /// --dart-define=CANDLES_PROXY_URL=https://seu-backend.com
  static const String webCandlesProxy = String.fromEnvironment(
    'CANDLES_PROXY_URL',
    defaultValue: 'http://127.0.0.1:8787',
  );
}
