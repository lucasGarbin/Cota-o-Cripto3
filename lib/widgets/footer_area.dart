import 'package:flutter/material.dart';

class FooterArea extends StatelessWidget {
  const FooterArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Theme.of(context).dividerColor),
        const SizedBox(height: 14),
        Text(
          'Cotação Cripto3 - Projeto acadêmico em Flutter',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Dados de mercado fornecidos por endpoints públicos da Coinbase.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
