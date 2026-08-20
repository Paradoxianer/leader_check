import 'package:flutter/material.dart';

import '../theme.dart';

/// Zentriert den Inhalt und begrenzt seine Breite. Wird von allen Screens
/// genutzt, damit die Weboberfläche auf breiten Monitoren lesbar bleibt.
class ContentFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const ContentFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
