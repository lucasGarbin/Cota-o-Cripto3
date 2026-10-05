import 'dart:convert';
import 'dart:io';

const int proxyPort = 8787;
const String coinbaseHost = 'api.coinbase.com';

Future<void> main() async {
  final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    proxyPort,
  );

  stdout.writeln('Cotação Cripto3 - proxy de candles ativo');
  stdout.writeln('http://127.0.0.1:$proxyPort');
  stdout.writeln('Mantenha esta janela aberta enquanto usar o Flutter Web.');

  await for (final request in server) {
    _setCors(request.response);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      continue;
    }

    if (request.method != 'GET' || request.uri.path != '/api/candles') {
      await _json(
        request.response,
        HttpStatus.notFound,
        {'error': 'Rota não encontrada.'},
      );
      continue;
    }

    await _handleCandles(request);
  }
}

Future<void> _handleCandles(HttpRequest request) async {
  final response = request.response;
  final params = request.uri.queryParameters;

  final productId = params['product_id']?.trim() ?? '';
  final start = params['start']?.trim() ?? '';
  final end = params['end']?.trim() ?? '';
  final granularity = params['granularity']?.trim() ?? '';
  final limit = params['limit']?.trim() ?? '';

  if (productId.isEmpty ||
      start.isEmpty ||
      end.isEmpty ||
      granularity.isEmpty) {
    await _json(
      response,
      HttpStatus.badRequest,
      {
        'error':
            'Parâmetros obrigatórios: product_id, start, end e granularity.',
      },
    );
    return;
  }

  final coinbaseUri = Uri.https(
    coinbaseHost,
    '/api/v3/brokerage/market/products/$productId/candles',
    {
      'start': start,
      'end': end,
      'granularity': granularity,
      if (limit.isNotEmpty) 'limit': limit,
    },
  );

  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15);

  try {
    final outbound = await client.getUrl(coinbaseUri);
    outbound.headers.set(HttpHeaders.acceptHeader, 'application/json');
    outbound.headers.set(
      HttpHeaders.userAgentHeader,
      'CotacaoCripto3/2.1',
    );

    final coinbaseResponse = await outbound.close();
    final body = await utf8.decoder.bind(coinbaseResponse).join();

    response.statusCode = coinbaseResponse.statusCode;
    response.headers.contentType = ContentType.json;
    response.write(body);
    await response.close();
  } catch (error) {
    await _json(
      response,
      HttpStatus.badGateway,
      {
        'error': 'Falha do proxy ao consultar a Coinbase: $error',
      },
    );
  } finally {
    client.close(force: true);
  }
}

void _setCors(HttpResponse response) {
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
  response.headers.set('Access-Control-Allow-Headers', 'Accept, Content-Type');
  response.headers.set('Cache-Control', 'no-store');
}

Future<void> _json(
  HttpResponse response,
  int statusCode,
  Map<String, Object?> body,
) async {
  response.statusCode = statusCode;
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(body));
  await response.close();
}
