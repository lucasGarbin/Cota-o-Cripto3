import 'package:flutter/material.dart';

import '../controllers/market_controller.dart';
import 'conversion_screen.dart';
import 'currencies_screen.dart';
import 'dashboard_screen.dart';
import 'integration_screen.dart';

enum AppSection {
  dashboard,
  currencies,
  conversion,
  integration,
}

class HomeShell extends StatefulWidget {
  final MarketController controller;
  final bool darkModeEnabled;
  final ValueChanged<bool> onThemeChanged;

  const HomeShell({
    super.key,
    required this.controller,
    required this.darkModeEnabled,
    required this.onThemeChanged,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  AppSection _section = AppSection.dashboard;

  void _selectSection(AppSection section) {
    setState(() {
      _section = section;
    });
  }

  Future<void> _openSettings() async {
    bool dark = widget.darkModeEnabled;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Configurações'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo escuro',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 5),
                          Text('Alterna o tema visual do aplicativo.'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Switch(
                      value: dark,
                      onChanged: (value) {
                        setDialogState(() {
                          dark = value;
                        });
                        widget.onThemeChanged(value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 76,
            titleSpacing: 20,
            title: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                children: [
                  const TextSpan(text: 'Cotação '),
                  TextSpan(
                    text: 'Cripto3',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: _openSettings,
                child: const Text('Configurações'),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: KeyedSubtree(
                      key: ValueKey(_section),
                      child: _buildSection(),
                    ),
                  ),
                ),
                _BottomNavigation(
                  current: _section,
                  onSelected: _selectSection,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection() {
    switch (_section) {
      case AppSection.dashboard:
        return DashboardScreen(controller: widget.controller);
      case AppSection.currencies:
        return CurrenciesScreen(
          controller: widget.controller,
          onOpenConversion: () {
            _selectSection(AppSection.conversion);
          },
        );
      case AppSection.conversion:
        return ConversionScreen(controller: widget.controller);
      case AppSection.integration:
        return IntegrationScreen(controller: widget.controller);
    }
  }
}

class _BottomNavigation extends StatelessWidget {
  final AppSection current;
  final ValueChanged<AppSection> onSelected;

  const _BottomNavigation({
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const items = <AppSection, String>{
      AppSection.dashboard: 'Início',
      AppSection.currencies: 'Moedas',
      AppSection.conversion: 'Conversão',
      AppSection.integration: 'Integração',
    };

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: items.entries.map((entry) {
              final selected = current == entry.key;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: TextButton(
                    onPressed: () => onSelected(entry.key),
                    style: TextButton.styleFrom(
                      foregroundColor: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      backgroundColor: selected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
