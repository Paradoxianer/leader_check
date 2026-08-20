import 'package:flutter/material.dart';

import '../theme.dart';

/// Eine Antwortstufe als volle Zeile — auf dem Handy leichter zu treffen als
/// ein Radiobutton, und auf dem Desktop per Tab erreichbar.
class LikertOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const LikertOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Material(
      color: selected ? AppColors.accent : AppColors.card,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected
                  ? AppColors.accent
                  : AppColors.ink.withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            label,
            style: text.bodyLarge?.copyWith(
              color: selected ? Colors.white : AppColors.ink,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
