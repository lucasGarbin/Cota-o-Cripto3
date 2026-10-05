import 'package:flutter/material.dart';

import '../controllers/market_controller.dart';
import '../core/utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/destination_currency_picker.dart';
import '../widgets/footer_area.dart';
import '../widgets/json_viewer.dart';
import '../widgets/responsive_page.dart';
import '../widgets/section_header.dart';
import '../widgets/state_panels.dart';

class ConversionScreen extends StatefulWidget {
  final MarketController controller;

  const ConversionScreen({
    super.key,
    required this.controller,
  });

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  late final TextEditingController _assetController;
  final TextEditingController _amountController =
      TextEditingController(text: '1');
  String _target = 'BRL';

  @override
  void initState() {
    super.initState();
    _assetController = TextEditingController(
      text: widget.controller.selectedAsset,
    );
  }

  @override
  void didUpdateWidget(covariant ConversionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_assetController.text != widget.controller.selectedAsset) {
      _assetController.text = widget.controller.selectedAsset;
    }
  }

  @override
  void dispose() {
    _assetController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double? get _amount => double.tryParse(
        _amountController.text.replaceAll(',', '.').trim(),
      );

  String get _effectiveTarget {
    final targets = widget.controller.destinationCurrencies;
    if (targets.contains(_target)) return _target;
    if (targets.contains('BRL')) return 'BRL';
    if (targets.isNotEmpty) return targets.first;
    return _target;
  }

  double? get _result {
    final amount = _amount;
    if (amount == null) return null;
    return widget.controller.conversionValue(
      amount: amount,
      target: _effectiveTarget,
    );
  }

  Future<void> _consult() async {
    final asset = _assetController.text.trim().toUpperCase();
    if (asset.isEmpty) return;
    await widget.controller.selectAsset(asset);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final targets = widget.controller.destinationCurrencies;
    final target = _effectiveTarget;
    final rate = widget.controller.exchangeRates?.rate(target);

    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Conversão de moedas',
            subtitle:
                'Escolha qualquer moeda de destino disponível na resposta da Coinbase. Use a busca para localizar rapidamente pelo código ou nome.',
            trailing: FilledButton(
              onPressed: widget.controller.loadingRates ? null : _consult,
              child: const Text('Atualizar cotação'),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;

              final assetField = TextField(
                controller: _assetController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Moeda de origem',
                  hintText: 'BTC',
                ),
              );

              final amountField = TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  hintText: '1',
                ),
                onChanged: (_) => setState(() {}),
              );

              final targetField = DestinationCurrencyPicker(
                selectedCode: target,
                codes: targets,
                nameForCode: widget.controller.currencyName,
                onChanged: (value) {
                  setState(() {
                    _target = value;
                  });
                },
              );

              if (compact) {
                return Column(
                  children: [
                    assetField,
                    const SizedBox(height: 14),
                    amountField,
                    const SizedBox(height: 14),
                    targetField,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: assetField),
                  const SizedBox(width: 14),
                  Expanded(child: amountField),
                  const SizedBox(width: 14),
                  Expanded(child: targetField),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.controller.loadingRates ? null : _consult,
            child: const Text('Consultar e calcular'),
          ),
          const SizedBox(height: 22),
          if (widget.controller.loadingRates)
            const LoadingPanel(label: 'Atualizando cotação...')
          else if (widget.controller.ratesError != null)
            ErrorPanel(message: widget.controller.ratesError!)
          else
            AppCard(
              highlighted: true,
              padding: const EdgeInsets.all(26),
              child: Column(
                children: [
                  Text(
                    'Resultado',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _result == null
                          ? '--'
                          : '${Formatters.number(_result!)} $target',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    rate == null
                        ? 'Taxa indisponível.'
                        : '1 ${widget.controller.selectedAsset} = ${Formatters.number(rate)} $target',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${targets.length} moedas de destino disponíveis nesta consulta.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 26),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Endpoint de conversão',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                SelectableText(
                  'GET https://api.coinbase.com/v2/exchange-rates?currency={currency}',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
                SizedBox(height: 8),
                Text(
                  'A lista de moedas de destino é gerada dinamicamente a partir das chaves do objeto rates retornado pela API.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          JsonViewer(
            title: 'Resposta JSON da API',
            json: widget.controller.ratesJson,
          ),
          const SizedBox(height: 34),
          const FooterArea(),
        ],
      ),
    );
  }
}
