import 'package:flutter/material.dart';

import 'app_card.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String helper;
  final Color? valueColor;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.helper,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: valueColor ??
                        Theme.of(context).textTheme.headlineSmall?.color,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            helper,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
