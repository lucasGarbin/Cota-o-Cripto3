import 'package:flutter/material.dart';

import '../controllers/market_controller.dart';
import '../models/currency.dart';
import '../widgets/app_card.dart';
import '../widgets/footer_area.dart';
import '../widgets/json_viewer.dart';
import '../widgets/responsive_page.dart';
import '../widgets/section_header.dart';
import '../widgets/state_panels.dart';

class CurrenciesScreen extends StatefulWidget {
  final MarketController controller;
  final VoidCallback onOpenConversion;

  const CurrenciesScreen({
    super.key,
    required this.controller,
    required this.onOpenConversion,
  });

  @override
  State<CurrenciesScreen> createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.controller.currencies.where((currency) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) return true;
      return currency.id.toLowerCase().contains(query) ||
          currency.name.toLowerCase().contains(query);
    }).take(120).toList();

    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Moedas disponíveis',
            subtitle:
                'Pesquise, favorite as moedas que quer acompanhar no Início e abra qualquer moeda no conversor.',
            trailing: FilledButton(
              onPressed: widget.controller.loadingCurrencies
                  ? null
                  : widget.controller.loadCurrencies,
              child: const Text('Atualizar lista'),
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            highlighted: true,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Favoritas no Início:',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                if (widget.controller.favoriteAssets.isEmpty)
                  const Text('nenhuma moeda favoritada')
                else
                  ...widget.controller.favoriteAssets.map(
                    (asset) => OutlinedButton(
                      onPressed: () =>
                          widget.controller.toggleFavorite(asset),
                      child: Text('$asset  Remover'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar moeda',
              hintText: 'BTC, Bitcoin, USD...',
            ),
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
          ),
          const SizedBox(height: 18),
          if (widget.controller.loadingCurrencies)
            const LoadingPanel(label: 'Carregando moedas...')
          else if (widget.controller.currenciesError != null)
            ErrorPanel(message: widget.controller.currenciesError!)
          else
            _CurrencyList(
              currencies: filtered,
              controller: widget.controller,
              onSelect: (currency) async {
                await widget.controller.selectAsset(currency.id);
                widget.onOpenConversion();
              },
            ),
          const SizedBox(height: 26),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Endpoint',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                SelectableText(
                  'GET https://api.coinbase.com/v2/currencies',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
                SizedBox(height: 8),
                Text('Principais campos: data, id, name e min_size.'),
              ],
            ),
          ),
          const SizedBox(height: 26),
          JsonViewer(
            title: 'Resposta JSON da API',
            json: widget.controller.currenciesJson,
          ),
          const SizedBox(height: 34),
          const FooterArea(),
        ],
      ),
    );
  }
}

class _CurrencyList extends StatelessWidget {
  final List<Currency> currencies;
  final MarketController controller;
  final ValueChanged<Currency> onSelect;

  const _CurrencyList({
    required this.currencies,
    required this.controller,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (currencies.isEmpty) {
      return const AppCard(
        child: Text('Nenhuma moeda encontrada para esta busca.'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: currencies.map((currency) {
              final favorite = controller.isFavorite(currency.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currency.id,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 3),
                                Text(currency.name),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                controller.toggleFavorite(currency.id),
                            child: Text(
                              favorite ? 'Favorita' : 'Favoritar',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Min Size: ${currency.minSize}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => onSelect(currency),
                          child: const Text('Usar na conversão'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }

        return AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 74,
                      child: Text(
                        'ID',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Nome',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    SizedBox(
                      width: 122,
                      child: Text(
                        'Min Size',
                        textAlign: TextAlign.end,
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    SizedBox(width: 18),
                    SizedBox(
                      width: 110,
                      child: Text(
                        'Favorito',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    SizedBox(width: 105),
                  ],
                ),
              ),
              for (final currency in currencies) ...[
                Divider(height: 1, color: Theme.of(context).dividerColor),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 74,
                        child: Text(
                          currency.id,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Expanded(child: Text(currency.name)),
                      SizedBox(
                        width: 122,
                        child: Text(
                          currency.minSize,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      SizedBox(
                        width: 110,
                        child: TextButton(
                          onPressed: () =>
                              controller.toggleFavorite(currency.id),
                          child: Text(
                            controller.isFavorite(currency.id)
                                ? 'Favorita'
                                : 'Favoritar',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 97,
                        child: OutlinedButton(
                          onPressed: () => onSelect(currency),
                          child: const Text('Usar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
