# Proxy de histórico para Flutter Web

`proxy.dart` existe apenas para contornar a restrição CORS do navegador ao consultar
os candles públicos da Coinbase.

Executar:

```bash
dart run server/proxy.dart
```

Rota local:

```text
GET http://127.0.0.1:8787/api/candles
```

Parâmetros:

- `product_id`
- `start`
- `end`
- `granularity`
- `limit`

O proxy encaminha a consulta para o endpoint público da Coinbase. Ele não precisa de
API Key nem Secret.
