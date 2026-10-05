import 'package:flutter/material.dart';

import '../controllers/market_controller.dart';
import '../widgets/app_card.dart';
import '../widgets/footer_area.dart';
import '../widgets/json_viewer.dart';
import '../widgets/responsive_page.dart';
import '../widgets/section_header.dart';

class IntegrationScreen extends StatelessWidget {
  final MarketController controller;

  const IntegrationScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const flow = [
      'Flutter UI',
      'MarketController',
      'CoinbaseService',
      'Proxy Web / Coinbase',
      'Models',
      'Widgets / gráfico',
    ];

    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Integração e arquitetura',
            subtitle:
                'Estrutura separada por responsabilidades para facilitar manutenção, testes e apresentação acadêmica.',
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (int index = 0; index < flow.length; index++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: index == 0
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.12)
                          : Colors.transparent,
                      border: Border.all(
                        color: index == 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Text(
                      '${index + 1}. ${flow[index]}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 820
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ArchitectureCard(
                    width: width,
                    title: 'Models',
                    lines: const [
                      'Currency',
                      'CurrencyResponse',
                      'ExchangeRates',
                      'MarketCandle',
                      'ChartRange',
                    ],
                  ),
                  _ArchitectureCard(
                    width: width,
                    title: 'Services',
                    lines: const [
                      'CoinbaseService',
                      'GET currencies',
                      'GET exchange-rates',
                      'GET candles via proxy no Web',
                    ],
                  ),
                  _ArchitectureCard(
                    width: width,
                    title: 'UI nativa',
                    lines: const [
                      'Material 3',
                      'CustomPainter',
                      'ChangeNotifier',
                      'Responsive Layout',
                      'Dark / Light Mode',
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Endpoints utilizados',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12),
                SelectableText(
                  'GET https://api.coinbase.com/v2/currencies',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
                SizedBox(height: 8),
                SelectableText(
                  'GET https://api.coinbase.com/v2/exchange-rates?currency={currency}',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
                SizedBox(height: 8),
                SelectableText(
                  'WEB: GET http://127.0.0.1:8787/api/candles  →  Coinbase Public Candles',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flutter Web e CORS',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  'No navegador, o histórico é obtido pelo proxy Dart local incluído em server/proxy.dart. Em Android/mobile a chamada pública de candles é feita diretamente para a Coinbase.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Segurança das credenciais',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  'O aplicativo usa apenas endpoints públicos. Nenhum Secret da Coinbase é armazenado no Flutter, no APK, no AAB ou no JavaScript do Flutter Web.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          JsonViewer(
            title: 'JSON mais recente do histórico',
            json: controller.candlesJson,
          ),
          const SizedBox(height: 34),
          const FooterArea(),
        ],
      ),
    );
  }
}

class _ArchitectureCard extends StatelessWidget {
  final double width;
  final String title;
  final List<String> lines;

  const _ArchitectureCard({
    required this.width,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(line),
              ),
          ],
        ),
      ),
    );
  }
}
