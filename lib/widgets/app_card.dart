import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlighted;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: highlighted
              ? Theme.of(context).colorScheme.primary.withOpacity(0.55)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: child,
    );
  }
}
