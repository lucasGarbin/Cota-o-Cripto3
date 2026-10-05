import 'package:flutter/material.dart';

import 'app_card.dart';

class LoadingPanel extends StatelessWidget {
  final String label;

  const LoadingPanel({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(label),
        ],
      ),
    );
  }
}

class ErrorPanel extends StatelessWidget {
  final String message;

  const ErrorPanel({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Não foi possível concluir a consulta',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(message),
        ],
      ),
    );
  }
}
