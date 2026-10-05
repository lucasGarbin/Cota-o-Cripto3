import 'package:flutter/material.dart';

import 'app_card.dart';

class JsonViewer extends StatelessWidget {
  final String title;
  final String json;

  const JsonViewer({
    super.key,
    required this.title,
    required this.json,
  });

  @override
  Widget build(BuildContext context) {
    final content = json.trim().isEmpty
        ? 'Nenhuma resposta carregada ainda.'
        : json;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 160,
              maxHeight: 360,
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                content,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
