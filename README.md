# Cotação Cripto3 — versão corrigida para Flutter Web

Esta versão corrige o erro de histórico/gráfico visto no Chrome:

```text
ClientException: Failed to fetch
https://api.coinbase.com/api/v3/brokerage/market/products/.../candles
```

## Por que acontecia?

O endpoint público de candles é válido, mas uma aplicação Flutter Web roda dentro do
navegador. O navegador aplica CORS e pode impedir que o JavaScript leia diretamente
a resposta desse endpoint. Isso não é o mesmo que um erro de API Key.

As cotações `/v2/currencies` e `/v2/exchange-rates` continuam sendo chamadas pelo
Flutter normalmente. O histórico usa um proxy Dart local no Web.

## Windows — jeito recomendado

Dê dois cliques em:

```text
run_web_windows.bat
```

Ele abre o proxy em `http://127.0.0.1:8787` e depois executa `flutter run -d chrome`.
Mantenha a janela do proxy aberta.

## macOS / Linux

```bash
./run_web_unix.sh
```

## Rodando manualmente

Terminal 1:

```bash
dart run server/proxy.dart
```

Terminal 2:

```bash
flutter pub get
flutter run -d chrome
```

## Android / mobile

No Android não é necessário iniciar o proxy:

```bash
flutter run
```

A aplicação chama diretamente o endpoint público da Coinbase.

## Produção Web

Hospede `server/proxy.dart` (ou um backend equivalente) e informe a URL ao build:

```bash
flutter build web --release --dart-define=CANDLES_PROXY_URL=https://api.seudominio.com
```

O backend precisa expor `GET /api/candles` com os mesmos parâmetros usados pelo
proxy deste projeto.

## Endpoints

```text
GET https://api.coinbase.com/v2/currencies
GET https://api.coinbase.com/v2/exchange-rates?currency={currency}
GET https://api.coinbase.com/api/v3/brokerage/market/products/{product_id}/candles
```

## Segurança

Nenhum Secret da Coinbase está incluído neste projeto. Os dados usados são públicos.
Nunca coloque Secret dentro de Flutter Web, APK ou AAB.

## Novidades da versão 2.2

- Favoritos persistentes na tela **Moedas**.
- As moedas favoritas substituem os atalhos fixos BTC/ETH/SOL/ADA/LINK na tela **Início**.
- Os favoritos são salvos localmente com `shared_preferences` e reaparecem ao abrir o app novamente.
- A moeda de destino do conversor não é mais limitada a BRL/USD/EUR/GBP/JPY.
- O seletor de destino é pesquisável e usa dinamicamente todas as moedas presentes em `rates` no retorno da Coinbase.
- O gráfico continua baseado no par `{MOEDA}-USD`; moedas sem mercado USD podem não possuir candles históricos.
