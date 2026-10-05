import 'package:flutter/material.dart';

import '../controllers/market_controller.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/chart_range.dart';
import '../widgets/app_card.dart';
import '../widgets/footer_area.dart';
import '../widgets/market_line_chart.dart';
import '../widgets/metric_card.dart';
import '../widgets/responsive_page.dart';
import '../widgets/section_header.dart';
import '../widgets/state_panels.dart';

class DashboardScreen extends StatelessWidget {
  final MarketController controller;

  const DashboardScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final change = controller.periodChangePercent;
    final changeColor = change == null
        ? Theme.of(context).textTheme.bodyLarge?.color
        : change >= 0
            ? AppTheme.green
            : AppTheme.red;

    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroMarketCard(controller: controller),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 780;
              if (!wide) {
                return Column(
                  children: [
                    _MetricGrid(controller: controller),
                    const SizedBox(height: 18),
                    _MarketSummary(
                      controller: controller,
                      changeColor: changeColor,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _MetricGrid(controller: controller),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 3,
                    child: _MarketSummary(
                      controller: controller,
                      changeColor: changeColor,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          _ChartSection(controller: controller),
          const SizedBox(height: 34),
          const FooterArea(),
        ],
      ),
    );
  }
}

class _HeroMarketCard extends StatelessWidget {
  final MarketController controller;

  const _HeroMarketCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final change = controller.periodChangePercent;
    final changeText = change == null ? '--' : Formatters.percent(change);
    final changeColor = change == null
        ? Theme.of(context).textTheme.bodyLarge?.color
        : change >= 0
            ? AppTheme.green
            : AppTheme.red;

    return AppCard(
      highlighted: true,
      padding: const EdgeInsets.all(26),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;

          final overview = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MERCADO CRIPTO',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  letterSpacing: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${controller.selectedAsset} / USD',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.lastClose != null
                    ? Formatters.usd(controller.lastClose!)
                    : controller.currentUsd != null
                        ? Formatters.usd(controller.currentUsd!)
                        : 'Carregando preço...',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    changeText,
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'no período ${controller.range.label}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          );

          final selector = controller.favoriteAssets.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: const Text(
                    'Favorite moedas na aba Moedas para criar seus atalhos.',
                    textAlign: TextAlign.center,
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: controller.favoriteAssets.map((asset) {
                    final selected = asset == controller.selectedAsset;
                    return ChoiceChip(
                      label: Text(asset),
                      selected: selected,
                      onSelected: (_) => controller.selectAsset(asset),
                      showCheckmark: false,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: selected ? const Color(0xFF12171B) : null,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    );
                  }).toList(),
                );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                overview,
                const SizedBox(height: 22),
                selector,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: overview),
              const SizedBox(width: 24),
              Flexible(child: selector),
            ],
          );
        },
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final MarketController controller;

  const _MetricGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    final values = [
      (
        'Em reais',
        controller.currentBrl == null
            ? '--'
            : Formatters.brl(controller.currentBrl!),
        '1 ${controller.selectedAsset} em BRL',
      ),
      (
        'Em dólares',
        controller.currentUsd == null
            ? '--'
            : Formatters.usd(controller.currentUsd!),
        '1 ${controller.selectedAsset} em USD',
      ),
      (
        'Em euros',
        controller.currentEur == null
            ? '--'
            : 'EUR ${Formatters.number(controller.currentEur!)}',
        '1 ${controller.selectedAsset} em EUR',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 1;
        final itemWidth = columns == 3
            ? (constraints.maxWidth - 24) / 3
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: values.map((item) {
            return SizedBox(
              width: itemWidth,
              child: MetricCard(
                label: item.$1,
                value: item.$2,
                helper: item.$3,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _MarketSummary extends StatelessWidget {
  final MarketController controller;
  final Color? changeColor;

  const _MarketSummary({
    required this.controller,
    required this.changeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do período',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 20),
          _SummaryRow(
            label: 'Abertura',
            value: controller.firstClose == null
                ? '--'
                : Formatters.usd(controller.firstClose!),
          ),
          const SizedBox(height: 13),
          _SummaryRow(
            label: 'Último',
            value: controller.lastClose != null
                ? Formatters.usd(controller.lastClose!)
                : controller.currentUsd != null
                    ? Formatters.usd(controller.currentUsd!)
                    : '--',
          ),
          const SizedBox(height: 13),
          _SummaryRow(
            label: 'Variação',
            value: controller.periodChangePercent == null
                ? '--'
                : Formatters.percent(controller.periodChangePercent!),
            valueColor: changeColor,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: controller.loadingMarket
                  ? null
                  : controller.refreshMarket,
              child: const Text('Atualizar mercado'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _ChartSection extends StatelessWidget {
  final MarketController controller;

  const _ChartSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Histórico ${controller.productId}',
            subtitle:
                'Preço de fechamento dos candles. Toque ou passe o mouse sobre o gráfico para inspecionar valores.',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ChartRange.values.map((range) {
              final selected = controller.range == range;
              return ChoiceChip(
                label: Text(range.label),
                selected: selected,
                showCheckmark: false,
                onSelected: (_) => controller.selectRange(range),
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: selected ? const Color(0xFF12171B) : null,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          if (controller.loadingCandles)
            const LoadingPanel(label: 'Carregando histórico...')
          else if (controller.candlesError != null)
            ErrorPanel(message: controller.candlesError!)
          else
            MarketLineChart(
              candles: controller.candles,
              range: controller.range,
            ),
        ],
      ),
    );
  }
}
